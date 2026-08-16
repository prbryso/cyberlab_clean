import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:systems_studio/engine/graph/graph_focus.dart';
import 'package:systems_studio/engine/graph/graph_query.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_overlay.dart';
import 'package:systems_studio/engine/simulation/studio_situation_snapshot.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/graphs/system_graph_canvas.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/causal_graph_view.dart';
import 'package:systems_studio/engine/ui/workspace/studio_graph_view_controller.dart';
import 'package:systems_studio/engine/ui/workspace/workspace_controller.dart';
import 'package:systems_studio/engine/ui/workspace/workspace_details_panel.dart';
import 'package:systems_studio/engine/ui/workspace/workspace_toolbar.dart';
import 'package:systems_studio/engine/ui/workspace/workspace_camera.dart';

/// Primary interactive workspace for examining a system graph.
///
/// The graph owns system knowledge.
/// Perspectives interpret the graph.
/// The workspace owns interaction state such as selection, focus, search,
/// navigation history, zoom, and panel visibility.
///
/// [StudioGraphViewController] owns graph-presentation state such as which
/// hierarchy nodes are expanded or collapsed.
class SystemWorkspace extends StatefulWidget {
  const SystemWorkspace({
    super.key,
    required this.graph,
    this.initialSelectedNodeId,
    this.initialFocusNodeId,
    this.onNodeSelected,
    this.onOpenOverview,
    this.onOpenArchitecture,
    this.onOpenExplore,
    this.simulation,
  });

  final StudioSystemGraph graph;

  /// The run to draw on top of the architecture, when one is being explored.
  ///
  /// Optional on purpose. Without it — or before anything has happened — the
  /// workspace is the architecture workspace it has always been.
  final StudioSimulationController? simulation;

  final String? initialSelectedNodeId;
  final String? initialFocusNodeId;

  /// Notified whenever the workspace selection changes.
  final ValueChanged<StudioGraphNode>? onNodeSelected;

  /// Optional perspective-navigation callbacks used by the Insight Panel.
  final VoidCallback? onOpenOverview;
  final VoidCallback? onOpenArchitecture;
  final VoidCallback? onOpenExplore;

  @override
  State<SystemWorkspace> createState() => _SystemWorkspaceState();
}

class _SystemWorkspaceState extends State<SystemWorkspace> {
  late final WorkspaceController _controller;
  late final StudioGraphViewController _graphViewController;
  late final WorkspaceCamera _camera;

  Size? _canvasSize;
  Size? _viewportSize;

  String? _lastReportedSelectedNodeId;

  bool _needsInitialFit = true;

  @override
  void initState() {
    super.initState();

    final initialSelectedNodeId = widget.initialSelectedNodeId;
    final initialFocusNodeId = widget.initialFocusNodeId;

    _controller = WorkspaceController(
      graph: widget.graph,
      initialSelectedElement: initialSelectedNodeId == null
          ? null
          : StudioElementRef.node(initialSelectedNodeId),
      initialFocusElement: initialFocusNodeId == null
          ? null
          : StudioElementRef.node(initialFocusNodeId),
    );

    _graphViewController = StudioGraphViewController();

    // Begin with the root expanded so its immediate children are visible.
    _graphViewController.expand(widget.graph.systemId);

    _camera = WorkspaceCamera();

    _controller.addListener(_handleWorkspaceChanged);
    widget.simulation?.addListener(_handleSimulationChanged);

    // A run may already be under way when this workspace opens.
    _revealRun();
  }

  @override
  void didUpdateWidget(covariant SystemWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.simulation, widget.simulation)) {
      oldWidget.simulation?.removeListener(_handleSimulationChanged);
      widget.simulation?.addListener(_handleSimulationChanged);

      _revealRun();
    }

    if (!identical(oldWidget.graph, widget.graph)) {
      _controller.updateGraph(widget.graph);

      // Make sure the root of a replacement graph is visible.
      _graphViewController.expand(widget.graph.systemId);

      _needsInitialFit = true;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleWorkspaceChanged);
    widget.simulation?.removeListener(_handleSimulationChanged);

    _controller.dispose();
    _graphViewController.dispose();
    _camera.dispose();

    super.dispose();
  }

  /// The current run, as the two things this workspace draws from it: the
  /// causal record and its placement onto the architecture.
  ///
  /// Both come from one derivation. The overlay is built from the causal
  /// record rather than from the run a second time, so the graph and the
  /// panel beside it can never be describing different chains.
  ///
  /// Null when there is no run, or nothing has happened in it yet.
  StudioSituationSnapshot? get _run {
    final simulation = widget.simulation;

    if (simulation == null) {
      return null;
    }

    final situation = StudioSituationSnapshot.of(
      simulation.graph,
      simulation.run,
    );

    return situation.isAtStart ? null : situation;
  }

  void _handleSimulationChanged() {
    if (!mounted) {
      return;
    }

    // Revealing notifies the view controller, so it happens outside setState
    // rather than nested inside another state's rebuild.
    _revealRun();

    setState(() {
      if (_run == null) {
        // The run is over. A sidebar choice made during it was about that
        // run, so the next one starts from the default again rather than
        // inheriting a preference the learner may not remember making.
        _sidebarChoice = null;
      }
    });
  }

  /// Opens whatever hierarchy the causal path runs through.
  ///
  /// A chain routinely crosses levels: an actor at the top acts on a component
  /// nested two subsystems down. Leaving the learner to guess which arrows to
  /// click before the chain appears would hide the thing they ran the
  /// simulation to see. Only containers are opened, and only those on the
  /// path — expanding everything would trade one unreadable picture for
  /// another.
  ///
  /// Nothing is closed again on reset. Collapsing containers the learner may
  /// have opened themselves would take away work that was theirs, not ours.
  void _revealRun() {
    final run = _run;

    if (run == null) {
      return;
    }

    _graphViewController.expandAll(run.overlay.expandNodeIds);
  }

  /// Which question the right sidebar is answering.
  ///
  /// Null means nobody has chosen, so the workspace answers the question the
  /// situation raises: with a run under way that is what happened, and
  /// without one it is what this element is.
  _SidebarView? _sidebarChoice;

  _SidebarView _sidebarViewFor(bool hasRun) {
    if (!hasRun) {
      return _SidebarView.details;
    }

    return _sidebarChoice ?? _SidebarView.whatHappened;
  }

  void _handleWorkspaceChanged() {
    final selectedNode = _controller.selectedNode;

    if (selectedNode == null ||
        selectedNode.id == _lastReportedSelectedNodeId) {
      return;
    }

    _lastReportedSelectedNodeId = selectedNode.id;
    widget.onNodeSelected?.call(selectedNode);
  }

  void _selectNode(StudioGraphNode node) {
    _controller.selectNode(node.id);
  }

  void _selectRelationship(StudioRelationship relationship) {
    _controller.selectRelationship(relationship.id);
  }

  void _focusNode(StudioGraphNode node) {
    _controller.focusOnNode(node);
    _graphViewController.expand(node.id);
    _fitToView();
  }

  void _fitToView() {
    final canvasSize = _canvasSize;
    final viewportSize = _viewportSize;

    if (canvasSize == null || viewportSize == null) {
      return;
    }

    const margin = 80.0;

    final availableWidth = viewportSize.width - margin;
    final availableHeight = viewportSize.height - margin;

    final scale = math
        .min(
          availableWidth / canvasSize.width,
          availableHeight / canvasSize.height,
        )
        .clamp(0.10, 4.0);

    final offsetX = (viewportSize.width - canvasSize.width * scale) / 2;

    final offsetY = (viewportSize.height - canvasSize.height * scale) / 2;

    _camera.transformationController.value = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale);
  }

  StudioSystemGraph _focusedGraph(SimulationGraphOverlay? overlay) {
    final graph = _controller.graph;
    final focusElement = _controller.state.focusElement;

    if (!graph.containsElement(focusElement)) {
      return graph;
    }

    final focusNode = _controller.focusNode;

    // A relationship focus shows both endpoints and their immediate context.
    final depth = focusNode == null
        ? 1
        : focusNode.type == StudioGraphNodeType.system
        ? 0
        : 1;

    final query = StudioGraphQuery(graph);

    final focused = query.focusedSubgraph(
      StudioGraphFocus(
        center: focusElement,
        depth: depth,
        includeParents: true,
        includeChildren: true,
        includeIncoming: true,
        includeOutgoing: true,
      ),
    );

    return overlay == null ? focused : overlay.revealWithin(graph, focused);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _graphViewController]),
      builder: (context, child) {
        final state = _controller.state;
        final selectedNode = _controller.selectedNode;
        final run = _run;
        final overlay = run?.overlay;
        final focusedGraph = _focusedGraph(overlay);

        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            final veryCompact = constraints.maxWidth < 650;

            return Column(
              children: [
                WorkspaceToolbar(
                  controller: _controller,
                  onFitToView: _fitToView,
                  onSearchResultSelected: (nodeId) {
                    _graphViewController.expand(nodeId);
                    _fitToView();
                  },
                ),
                if (overlay != null) _RunBanner(overlay: overlay),
                const Divider(height: 1),
                Expanded(
                  child: compact
                      ? _buildCompactWorkspace(
                          focusedGraph: focusedGraph,
                          selectedNode: selectedNode,
                          run: run,
                          veryCompact: veryCompact,
                        )
                      : _buildDesktopWorkspace(
                          focusedGraph: focusedGraph,
                          selectedNode: selectedNode,
                          run: run,
                          showStructurePanel: state.showStructurePanel,
                          showDetailsPanel: state.showDetailsPanel,
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// The right-hand sidebar.
  ///
  /// With no run this is the inspector, untouched and unwrapped — the
  /// workspace behaves exactly as it did before simulation existed. With a
  /// run there are two questions worth asking about the same selection, so a
  /// switch appears and What Happened is shown first. The inspector is never
  /// taken away, only put one tap behind.
  Widget _buildSidebar({
    required StudioGraphNode? selectedNode,
    required StudioSituationSnapshot? run,
  }) {
    final detailsPanel = WorkspaceDetailsPanel(
      controller: _controller,
      onExploreHere: selectedNode == null
          ? null
          : () {
              _controller.focusNodeById(selectedNode.id);
              _graphViewController.expand(selectedNode.id);
              _fitToView();
            },
      onOpenOverview: widget.onOpenOverview,
      onOpenArchitecture: widget.onOpenArchitecture,
      onOpenExplore: widget.onOpenExplore,
    );

    if (run == null) {
      return detailsPanel;
    }

    final view = _sidebarViewFor(true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SidebarSwitch(
          view: view,
          stepCount: run.causal.links.length,
          onChanged: (chosen) {
            setState(() {
              _sidebarChoice = chosen;
            });
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: switch (view) {
            // Scrolls on its own, so a long chain never fights the graph for
            // room and neither has to be resized to read the other.
            _SidebarView.whatHappened => SingleChildScrollView(
              key: const Key('workspace-causal-panel'),
              padding: const EdgeInsets.all(16),
              child: CausalGraphView(
                causalGraph: run.causal,
                // The same actor marking the graph marks the chain, so the
                // two surfaces agree about whose knowledge is being shown.
                selectedActor: _selectedActor(),
                selectedElement: _controller.selectedElement,
                onElementSelected: _selectElementRef,
              ),
            ),
            _SidebarView.details => detailsPanel,
          },
        ),
      ],
    );
  }

  /// Selects an element without changing focus, matching a click on the graph.
  void _selectElementRef(StudioElementRef element) {
    _controller.selectElement(element);
  }

  Widget _buildDesktopWorkspace({
    required StudioSystemGraph focusedGraph,
    required StudioGraphNode? selectedNode,
    required StudioSituationSnapshot? run,
    required bool showStructurePanel,
    required bool showDetailsPanel,
  }) {
    final overlay = run?.overlay;
    return Row(
      children: [
        if (showStructurePanel) ...[
          SizedBox(
            width: 285,
            child: _WorkspaceStructureExplorer(
              graph: _controller.graph,
              selectedNodeId: selectedNode?.id,
              focusNodeId: _controller.focusNode?.id,
              onNodeSelected: _selectNode,
              onNodeFocused: _focusNode,
              onClose: _controller.toggleStructurePanel,
            ),
          ),
          const VerticalDivider(width: 1),
        ],
        Expanded(
          child: _WorkspaceCanvas(
            graph: focusedGraph,
            controller: _graphViewController,
            selectedElement: _controller.selectedElement,
            overlay: overlay,
            overlayActor: _selectedActor(),
            transformationController: _camera.transformationController,
            highlightNeighbors: _controller.state.highlightNeighbors,
            onNodeSelected: _selectNode,
            onRelationshipSelected: _selectRelationship,
            onNodeFocused: _focusNode,
            onCanvasSizeChanged: (size) {
              _canvasSize = size;

              if (_needsInitialFit && _viewportSize != null) {
                _needsInitialFit = false;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _fitToView();
                  }
                });
              }
            },
            onViewportSizeChanged: (size) {
              _viewportSize = size;

              if (_needsInitialFit && _canvasSize != null) {
                _needsInitialFit = false;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _fitToView();
                  }
                });
              }
            },
          ),
        ),
        if (showDetailsPanel) ...[
          const VerticalDivider(width: 1),
          SizedBox(
            width: 340,
            child: _buildSidebar(selectedNode: selectedNode, run: run),
          ),
        ],
      ],
    );
  }

  /// The selection, when it is an actor whose knowledge can be marked.
  ///
  /// Marking only means anything for a participant. Asking what a component
  /// "saw" borrows language that belongs to actors.
  StudioElementRef? _selectedActor() {
    final selection = _controller.selectedElement;

    if (!selection.isNode) {
      return null;
    }

    return _graph.nodeById(selection.id)?.type == StudioGraphNodeType.actor
        ? selection
        : null;
  }

  StudioSystemGraph get _graph => _controller.graph;

  Widget _buildCompactWorkspace({
    required StudioSystemGraph focusedGraph,
    required StudioGraphNode? selectedNode,
    required StudioSituationSnapshot? run,
    required bool veryCompact,
  }) {
    final state = _controller.state;
    final overlay = run?.overlay;

    return Column(
      children: [
        if (state.showStructurePanel)
          SizedBox(
            height: veryCompact ? 175 : 210,
            child: _WorkspaceStructureExplorer(
              graph: _controller.graph,
              selectedNodeId: selectedNode?.id,
              focusNodeId: _controller.focusNode?.id,
              onNodeSelected: _selectNode,
              onNodeFocused: _focusNode,
              onClose: _controller.toggleStructurePanel,
              compact: true,
            ),
          ),
        if (state.showStructurePanel) const Divider(height: 1),
        Expanded(
          child: _WorkspaceCanvas(
            graph: focusedGraph,
            controller: _graphViewController,
            selectedElement: _controller.selectedElement,
            overlay: overlay,
            overlayActor: _selectedActor(),
            transformationController: _camera.transformationController,
            highlightNeighbors: _controller.state.highlightNeighbors,
            onNodeSelected: _selectNode,
            onRelationshipSelected: _selectRelationship,
            onNodeFocused: _focusNode,
            onCanvasSizeChanged: (size) {
              _canvasSize = size;
            },
            onViewportSizeChanged: (size) {
              _viewportSize = size;
            },
          ),
        ),
        if (state.showDetailsPanel) ...[
          const Divider(height: 1),
          SizedBox(
            // A causal chain needs more room to read than a detail list.
            height: run == null
                ? (veryCompact ? 245 : 300)
                : (veryCompact ? 300 : 360),
            child: _buildSidebar(selectedNode: selectedNode, run: run),
          ),
        ],
      ],
    );
  }
}

/// Which question the workspace sidebar is answering.
///
/// Two questions, not two modes: "what happened here?" and "what is this?".
/// They are both about the same selection and neither replaces the other,
/// which is why the learner can move between them rather than choosing once.
enum _SidebarView { whatHappened, details }

/// Lets the learner move between what happened and what a thing is.
///
/// Deliberately a pair of buttons rather than a panel of its own: the sidebar
/// already has a job, and the smallest thing that lets someone change the
/// question is two words they can tap.
class _SidebarSwitch extends StatelessWidget {
  const _SidebarSwitch({
    required this.view,
    required this.stepCount,
    required this.onChanged,
  });

  final _SidebarView view;
  final int stepCount;
  final ValueChanged<_SidebarView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('workspace-sidebar-switch'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: _SidebarSwitchButton(
              key: const Key('sidebar-what-happened'),
              label: 'What happened',
              badge: '$stepCount',
              selected: view == _SidebarView.whatHappened,
              onPressed: () => onChanged(_SidebarView.whatHappened),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SidebarSwitchButton(
              key: const Key('sidebar-details'),
              label: 'Details',
              selected: view == _SidebarView.details,
              onPressed: () => onChanged(_SidebarView.details),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSwitchButton extends StatelessWidget {
  const _SidebarSwitchButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final badge = this.badge;

    return Material(
      color: selected
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Text(
                  badge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A short statement of what the drawn run is, above the graph.
///
/// The graph is now answering two questions at once, and a learner is owed a
/// sentence saying so — otherwise highlighted architecture reads as an
/// architectural claim rather than a record of what took place.
class _RunBanner extends StatelessWidget {
  const _RunBanner({required this.overlay});

  final SimulationGraphOverlay overlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final undeclared = overlay.undeclaredSteps.length;

    final summary =
        'Showing what happened in this run: ${overlay.steps.length} steps '
        'across ${overlay.involvedNodeIds.length} elements. '
        'The rest of the architecture is dimmed, not hidden.';

    // Worth saying plainly rather than leaving a dashed line to be decoded.
    final unconnected = undeclared == 0
        ? ''
        : ' $undeclared step${undeclared == 1 ? '' : 's'} crossed no declared '
              'relationship, shown dashed.';

    return Container(
      key: const Key('workspace-run-banner'),
      color: colorScheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 18,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$summary$unconnected',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceCanvas extends StatelessWidget {
  const _WorkspaceCanvas({
    required this.graph,
    required this.controller,
    required this.selectedElement,
    required this.overlay,
    required this.overlayActor,
    required this.transformationController,
    required this.highlightNeighbors,
    required this.onNodeSelected,
    required this.onRelationshipSelected,
    required this.onNodeFocused,
    required this.onCanvasSizeChanged,
    required this.onViewportSizeChanged,
  });

  final StudioSystemGraph graph;
  final StudioGraphViewController controller;
  final StudioElementRef? selectedElement;
  final SimulationGraphOverlay? overlay;
  final StudioElementRef? overlayActor;
  final TransformationController transformationController;
  final bool highlightNeighbors;
  final ValueChanged<StudioGraphNode> onNodeSelected;
  final ValueChanged<StudioRelationship> onRelationshipSelected;
  final ValueChanged<StudioGraphNode> onNodeFocused;
  final ValueChanged<Size> onCanvasSizeChanged;
  final ValueChanged<Size> onViewportSizeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                onViewportSizeChanged(
                  Size(constraints.maxWidth, constraints.maxHeight),
                );

                return InteractiveViewer(
                  transformationController: transformationController,
                  minScale: 0.10,
                  maxScale: 4,
                  boundaryMargin: const EdgeInsets.all(600),
                  constrained: false,
                  panEnabled: true,
                  scaleEnabled: true,
                  trackpadScrollCausesScale: true,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: SystemGraphCanvas(
                      graph: graph,
                      controller: controller,
                      selectedElement: selectedElement,
                      overlay: overlay,
                      overlayActor: overlayActor,
                      onNodeSelected: onNodeSelected,
                      onRelationshipSelected: onRelationshipSelected,
                      onCanvasSizeChanged: (size) {
                        onCanvasSizeChanged(
                          Size(size.width + 64, size.height + 64),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: _CanvasHint(highlightNeighbors: highlightNeighbors),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _ZoomControls(controller: transformationController),
          ),
        ],
      ),
    );
  }
}

class _CanvasHint extends StatelessWidget {
  const _CanvasHint({required this.highlightNeighbors});

  final bool highlightNeighbors;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mouse_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              'Drag to pan • Scroll to zoom • Select a node',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            if (highlightNeighbors) ...[
              const SizedBox(width: 8),
              Icon(Icons.hub_outlined, size: 17, color: colorScheme.primary),
            ],
          ],
        ),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.controller});

  final TransformationController controller;

  void _zoom(double factor) {
    final current = controller.value.clone();
    final currentScale = current.getMaxScaleOnAxis();

    final targetScale = (currentScale * factor).clamp(0.10, 4.0);
    final appliedFactor = targetScale / currentScale;

    controller.value = current..scale(appliedFactor);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom in',
            onPressed: () => _zoom(1.2),
            icon: const Icon(Icons.add),
          ),
          const Divider(height: 1),
          IconButton(
            tooltip: 'Zoom out',
            onPressed: () => _zoom(1 / 1.2),
            icon: const Icon(Icons.remove),
          ),
          const Divider(height: 1),
          IconButton(
            tooltip: 'Reset view',
            onPressed: () {
              controller.value = Matrix4.identity();
            },
            icon: const Icon(Icons.center_focus_weak_outlined),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceStructureExplorer extends StatelessWidget {
  const _WorkspaceStructureExplorer({
    required this.graph,
    required this.selectedNodeId,
    required this.focusNodeId,
    required this.onNodeSelected,
    required this.onNodeFocused,
    required this.onClose,
    this.compact = false,
  });

  final StudioSystemGraph graph;
  final String? selectedNodeId;
  final String? focusNodeId;
  final ValueChanged<StudioGraphNode> onNodeSelected;
  final ValueChanged<StudioGraphNode> onNodeFocused;
  final VoidCallback onClose;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final root = graph.nodeById(graph.systemId);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 6, 10),
            child: Row(
              children: [
                const Icon(Icons.account_tree_outlined, size: 21),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Structure Explorer',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Hide Structure Explorer',
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: root == null
                ? const Center(child: Text('No system root is available.'))
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    children: [
                      _StructureNode(
                        graph: graph,
                        node: root,
                        selectedNodeId: selectedNodeId,
                        focusNodeId: focusNodeId,
                        onNodeSelected: onNodeSelected,
                        onNodeFocused: onNodeFocused,
                        depth: 0,
                        compact: compact,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StructureNode extends StatelessWidget {
  const _StructureNode({
    required this.graph,
    required this.node,
    required this.selectedNodeId,
    required this.focusNodeId,
    required this.onNodeSelected,
    required this.onNodeFocused,
    required this.depth,
    required this.compact,
  });

  final StudioSystemGraph graph;
  final StudioGraphNode node;
  final String? selectedNodeId;
  final String? focusNodeId;
  final ValueChanged<StudioGraphNode> onNodeSelected;
  final ValueChanged<StudioGraphNode> onNodeFocused;
  final int depth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final children =
        graph.nodes
            .where((candidate) => candidate.parentId == node.id)
            .where(
              (candidate) =>
                  candidate.type == StudioGraphNodeType.subsystem ||
                  candidate.type == StudioGraphNodeType.component ||
                  candidate.type == StudioGraphNodeType.process,
            )
            .toList()
          ..sort(
            (left, right) =>
                left.label.toLowerCase().compareTo(right.label.toLowerCase()),
          );

    final selected = selectedNodeId == node.id;
    final focused = focusNodeId == node.id;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: compact ? depth * 10 : depth * 14),
          child: Material(
            color: selected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onNodeSelected(node),
              onDoubleTap: () => onNodeFocused(node),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Row(
                  children: [
                    Icon(
                      _iconForNodeType(node.type),
                      size: 19,
                      color: selected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        node.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: selected ? FontWeight.bold : null,
                          color: selected
                              ? colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                    if (focused)
                      Icon(
                        Icons.center_focus_strong_outlined,
                        size: 17,
                        color: colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        for (final child in children)
          _StructureNode(
            graph: graph,
            node: child,
            selectedNodeId: selectedNodeId,
            focusNodeId: focusNodeId,
            onNodeSelected: onNodeSelected,
            onNodeFocused: onNodeFocused,
            depth: depth + 1,
            compact: compact,
          ),
      ],
    );
  }
}

IconData _iconForNodeType(StudioGraphNodeType type) {
  return switch (type) {
    StudioGraphNodeType.system => Icons.account_tree_outlined,
    StudioGraphNodeType.subsystem => Icons.hub_outlined,
    StudioGraphNodeType.component => Icons.widgets_outlined,
    StudioGraphNodeType.actor => Icons.person_outline,
    StudioGraphNodeType.asset => Icons.inventory_2_outlined,
    StudioGraphNodeType.interface => Icons.compare_arrows_outlined,
    StudioGraphNodeType.boundary => Icons.border_outer_outlined,
    StudioGraphNodeType.input => Icons.input_outlined,
    StudioGraphNodeType.output => Icons.output_outlined,
    StudioGraphNodeType.failureMode => Icons.warning_amber_outlined,
    StudioGraphNodeType.control => Icons.shield_outlined,
    StudioGraphNodeType.simulation => Icons.science_outlined,
    StudioGraphNodeType.incident => Icons.crisis_alert_outlined,
    StudioGraphNodeType.reference => Icons.menu_book_outlined,
    StudioGraphNodeType.externalSystem => Icons.cloud_outlined,
    StudioGraphNodeType.process => Icons.settings_outlined,
    StudioGraphNodeType.state => Icons.change_circle_outlined,
    StudioGraphNodeType.custom => Icons.extension_outlined,
  };
}

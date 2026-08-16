import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_overlay.dart';
import 'package:systems_studio/engine/ui/workspace/studio_graph_view_controller.dart';

class SystemGraphCanvas extends StatefulWidget {
  const SystemGraphCanvas({
    super.key,
    required this.graph,
    required this.controller,
    this.onNodeSelected,
    this.onRelationshipSelected,
    this.selectedElement,
    this.onCanvasSizeChanged,
    this.overlay,
    this.overlayActor,
  });

  final StudioSystemGraph graph;
  final StudioGraphViewController controller;
  final ValueChanged<StudioGraphNode>? onNodeSelected;

  /// Called when the user taps a drawn relationship.
  ///
  /// Edges are only tappable when this callback is supplied. Screens that do
  /// not yet inspect relationships keep their existing node-only behaviour.
  final ValueChanged<StudioRelationship>? onRelationshipSelected;

  /// The currently selected element, of either kind.
  final StudioElementRef? selectedElement;

  /// Reports the complete drawing-surface size whenever the graph layout changes.
  final ValueChanged<Size>? onCanvasSizeChanged;

  /// What the current run did, drawn on top of the architecture.
  ///
  /// Null or empty means there is nothing to overlay, and this canvas behaves
  /// exactly as it does without a run: the architecture answers only the
  /// question it has always answered.
  final SimulationGraphOverlay? overlay;

  /// When set, steps this participant observed are marked on the overlay.
  ///
  /// Marking is additive. Nothing is hidden because someone did not see it —
  /// the graph continues to show what happened, not what one actor believes.
  final StudioElementRef? overlayActor;

  @override
  State<SystemGraphCanvas> createState() => _SystemGraphCanvasState();
}

class _SystemGraphCanvasState extends State<SystemGraphCanvas> {
  static const double _nodeWidth = 190;
  static const double _minimumNodeHeight = 92;

  static const double _nodeVerticalPadding = 20;
  static const double _nodeTypeLineHeight = 16;

  static const double _horizontalGap = 54;
  static const double _verticalGap = 44;
  static const double _groupGap = 84;
  static const double _canvasPadding = 72;

  late StudioSystemGraph _visibleGraph;
  late Map<String, Offset> _positions;
  late Map<String, Size> _nodeSizes;
  late Size _canvasSize;

  String? _hoveredNodeId;

  double _heightForNode(StudioGraphNode node) {
    const availableTextWidth = _nodeWidth - 38 - 9 - 32;

    final titlePainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: availableTextWidth);

    final titleHeight = titlePainter.height;
    const textGap = 3.0;

    final textContentHeight = titleHeight + textGap + _nodeTypeLineHeight;

    final contentHeight = math.max(38.0, textContentHeight);

    return math.max(_minimumNodeHeight, contentHeight + _nodeVerticalPadding);
  }

  void _calculateNodeSizes(StudioSystemGraph graph) {
    _nodeSizes = {
      for (final node in graph.nodes)
        node.id: Size(_nodeWidth, _heightForNode(node)),
    };
  }

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_handleViewChanged);
    _refreshVisibleGraph();
  }

  @override
  void didUpdateWidget(covariant SystemGraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleViewChanged);
      widget.controller.addListener(_handleViewChanged);
    }

    if (oldWidget.graph != widget.graph ||
        oldWidget.controller != widget.controller) {
      _refreshVisibleGraph();
    } else if (oldWidget.onCanvasSizeChanged != widget.onCanvasSizeChanged) {
      _reportCanvasSize();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleViewChanged);
    super.dispose();
  }

  void _handleViewChanged() {
    if (!mounted) {
      return;
    }

    setState(_refreshVisibleGraph);
  }

  void _refreshVisibleGraph() {
    _visibleGraph = _createVisibleGraph(widget.graph);

    _calculateNodeSizes(_visibleGraph);

    _positions = _createLayout(_visibleGraph);
    _canvasSize = _calculateCanvasSize();

    if (_hoveredNodeId != null &&
        _visibleGraph.nodeById(_hoveredNodeId!) == null) {
      _hoveredNodeId = null;
    }

    _reportCanvasSize();
  }

  void _reportCanvasSize() {
    final callback = widget.onCanvasSizeChanged;

    if (callback == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        callback(_canvasSize);
      }
    });
  }

  StudioSystemGraph _createVisibleGraph(StudioSystemGraph graph) {
    final visibleNodes = widget.controller.visibleNodes(graph);
    final visibleNodeIds = visibleNodes.map((node) => node.id).toSet();

    final visibleRelationships = graph.relationships.where((relationship) {
      return visibleNodeIds.contains(relationship.sourceId) &&
          visibleNodeIds.contains(relationship.targetId);
    }).toList();

    return StudioSystemGraph(
      systemId: graph.systemId,
      nodes: List<StudioGraphNode>.unmodifiable(visibleNodes),
      relationships: List<StudioRelationship>.unmodifiable(
        visibleRelationships,
      ),
      // Collapsing hierarchy changes what is drawn, not what the system is.
      perspectiveDefinitions: graph.perspectiveDefinitions,
      stateVariables: graph.stateVariables,
      eventTypes: graph.eventTypes,
      actionDefinitions: graph.actionDefinitions,
      behaviorDefinitions: graph.behaviorDefinitions,
    );
  }

  /// The overlay to draw, or null when there is nothing to say about a run.
  ///
  /// An empty overlay is treated as no overlay so that a run which has not
  /// started yet, or one that has been reset, leaves the architecture exactly
  /// as it was.
  SimulationGraphOverlay? get _overlay {
    final overlay = widget.overlay;

    return overlay == null || overlay.isEmpty ? null : overlay;
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = _canvasSize;
    final overlay = _overlay;

    return Container(
      key: overlay == null
          ? const Key('system-graph-canvas')
          : const Key('system-graph-canvas-simulation'),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: canvasSize.width,
        height: canvasSize.height,
        child: Stack(
          children: [
            Positioned.fill(child: _buildRelationshipLayer(context)),
            for (final node in _visibleGraph.nodes) _buildNode(context, node),
            if (overlay != null)
              for (final node in _visibleGraph.nodes)
                ..._buildOverlayMarks(context, node, overlay),
          ],
        ),
      ),
    );
  }

  /// Run marks drawn beside an involved element.
  ///
  /// These sit outside the element box rather than inside it, so that adding
  /// a run to the picture never changes the size or shape of the architecture
  /// underneath it.
  List<Widget> _buildOverlayMarks(
    BuildContext context,
    StudioGraphNode node,
    SimulationGraphOverlay overlay,
  ) {
    if (!overlay.involves(node.id)) {
      return const [];
    }

    final position = _positions[node.id];

    if (position == null) {
      return const [];
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final nodeSize =
        _nodeSizes[node.id] ?? const Size(_nodeWidth, _minimumNodeHeight);

    final sequence = overlay.firstSequenceFor(node.id);

    // One entry per variable, however many times the run moved it. The
    // individual transitions live in the causal record, where the step that
    // caused each one is also shown.
    final state = overlay.stateFor(node.id);

    return [
      if (sequence != null)
        Positioned(
          left: position.dx - 11,
          top: position.dy - 11,
          child: Container(
            key: Key('overlay-order-${node.id}'),
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
            ),
            child: Text(
              '${sequence + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

      // Only values that actually changed during the run.
      if (state.isNotEmpty)
        Positioned(
          left: position.dx,
          top: position.dy + nodeSize.height + 4,
          width: nodeSize.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final summary in state)
                Container(
                  // One chip per variable, so this identifies exactly one
                  // widget however many times the run moved that variable.
                  key: Key('overlay-change-${node.id}-${summary.variableId}'),
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _stateSummaryLabel(summary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
    ];
  }

  /// The relationship layer sits beneath the node widgets in the stack, so
  /// node taps continue to win. Only when a relationship callback is supplied
  /// does this layer become tappable.
  Widget _buildRelationshipLayer(BuildContext context) {
    final painter = CustomPaint(
      painter: _RelationshipPainter(
        graph: _visibleGraph,
        positions: _positions,
        nodeSizes: _nodeSizes,
        colorScheme: Theme.of(context).colorScheme,
        selectedElement: widget.selectedElement,
        hoveredNodeId: _hoveredNodeId,
        overlay: _overlay,
        overlayActor: widget.overlayActor,
      ),
    );

    final onRelationshipSelected = widget.onRelationshipSelected;

    if (onRelationshipSelected == null) {
      return painter;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final relationship = _relationshipAt(details.localPosition);

        if (relationship != null) {
          onRelationshipSelected(relationship);
        }
      },
      child: painter,
    );
  }

  /// Returns the drawn relationship nearest [position], or null when nothing
  /// is within the hit tolerance.
  StudioRelationship? _relationshipAt(Offset position) {
    const hitTolerance = 14.0;

    StudioRelationship? nearest;
    var nearestDistance = hitTolerance;

    for (final relationship in _visibleGraph.relationships) {
      final path = _pathForRelationship(relationship);

      if (path == null) {
        continue;
      }

      final distance = _distanceToPath(path, position);

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = relationship;
      }
    }

    return nearest;
  }

  /// Rebuilds the drawn path for [relationship] using the same geometry the
  /// painter uses, so hit-testing cannot drift from what is on screen.
  Path? _pathForRelationship(StudioRelationship relationship) {
    final sourcePosition = _positions[relationship.sourceId];
    final targetPosition = _positions[relationship.targetId];

    if (sourcePosition == null || targetPosition == null) {
      return null;
    }

    final sourceSize = _nodeSizes[relationship.sourceId];
    final targetSize = _nodeSizes[relationship.targetId];

    if (sourceSize == null || targetSize == null) {
      return null;
    }

    final anchors = _RelationshipPainter._connectionAnchors(
      sourcePosition: sourcePosition,
      targetPosition: targetPosition,
      sourceCenter: Offset(
        sourcePosition.dx + sourceSize.width / 2,
        sourcePosition.dy + sourceSize.height / 2,
      ),
      targetCenter: Offset(
        targetPosition.dx + targetSize.width / 2,
        targetPosition.dy + targetSize.height / 2,
      ),
      sourceSize: sourceSize,
      targetSize: targetSize,
    );

    return _RelationshipPainter._relationshipPath(
      start: anchors.start,
      end: anchors.end,
    );
  }

  double _distanceToPath(Path path, Offset point) {
    const samplesPerSegment = 28;

    var minimum = double.infinity;

    for (final metric in path.computeMetrics()) {
      final length = metric.length;

      if (length <= 0) {
        continue;
      }

      for (var index = 0; index <= samplesPerSegment; index++) {
        final tangent = metric.getTangentForOffset(
          length * index / samplesPerSegment,
        );

        if (tangent == null) {
          continue;
        }

        final distance = (tangent.position - point).distance;

        if (distance < minimum) {
          minimum = distance;
        }
      }
    }

    return minimum;
  }

  Widget _buildNode(BuildContext context, StudioGraphNode node) {
    final position = _positions[node.id];

    if (position == null) {
      return const SizedBox.shrink();
    }

    final selected = widget.selectedElement?.referencesNode(node.id) ?? false;
    final hovered = _hoveredNodeId == node.id;
    final hasChildren = _hasChildren(node.id);
    final expanded = widget.controller.isExpanded(node.id);

    final overlay = _overlay;

    final involved = overlay?.involves(node.id) ?? false;

    // Architecture that had no part in the run stays on screen and stays
    // usable. Fading it answers "what just happened?" without ever answering
    // it by pretending the rest of the system is not there.
    final deEmphasized = overlay != null && !involved && !selected && !hovered;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = selected
        ? colorScheme.primaryContainer
        : hovered
        ? colorScheme.secondaryContainer
        : involved
        ? colorScheme.tertiaryContainer
        : colorScheme.surfaceContainerHighest;

    final borderColor = selected
        ? colorScheme.primary
        : hovered
        ? colorScheme.secondary
        : involved
        ? colorScheme.tertiary
        : colorScheme.outlineVariant;

    final borderWidth = selected
        ? 2.2
        : involved
        ? 2.0
        : 1.2;

    final nodeSize =
        _nodeSizes[node.id] ?? const Size(_nodeWidth, _minimumNodeHeight);

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: nodeSize.width,
      height: nodeSize.height,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredNodeId = node.id;
          });
        },
        onExit: (_) {
          setState(() {
            _hoveredNodeId = null;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              widget.onNodeSelected?.call(node);
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              // Faded, never removed: still drawn, still selectable, still
              // inspectable.
              opacity: deEmphasized ? 0.34 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                  boxShadow: selected || hovered
                      ? [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.14),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _colorForNodeType(
                          node.type,
                          colorScheme,
                        ).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconForNodeType(node.type),
                        size: 22,
                        color: _colorForNodeType(node.type, colorScheme),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _displayNodeType(node.type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasChildren)
                      Tooltip(
                        message: expanded
                            ? 'Collapse ${node.label}'
                            : 'Expand ${node.label}',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            widget.controller.toggle(node.id);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: selected
                                  ? colorScheme.surface.withValues(alpha: 0.95)
                                  : colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? colorScheme.onPrimaryContainer.withValues(
                                        alpha: 0.45,
                                      )
                                    : colorScheme.primary.withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                            child: AnimatedRotation(
                              turns: expanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                Icons.chevron_right,
                                size: 24,
                                color: selected
                                    ? colorScheme.onSurface
                                    : colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasChildren(String nodeId) {
    return widget.graph.nodes.any((candidate) => candidate.parentId == nodeId);
  }

  Map<String, Offset> _createLayout(StudioSystemGraph graph) {
    final positions = <String, Offset>{};

    final root =
        graph.nodeById(graph.systemId) ??
        graph.nodes.where((node) {
          return node.type == StudioGraphNodeType.system;
        }).firstOrNull;

    final actors = _nodesOfTypes(graph, const {
      StudioGraphNodeType.actor,
      StudioGraphNodeType.externalSystem,
    });

    final inputs = _nodesOfTypes(graph, const {StudioGraphNodeType.input});

    final subsystems = _nodesOfTypes(graph, const {
      StudioGraphNodeType.subsystem,
    });

    final assets = _nodesOfTypes(graph, const {StudioGraphNodeType.asset});

    final outputs = _nodesOfTypes(graph, const {StudioGraphNodeType.output});

    final failures = _nodesOfTypes(graph, const {
      StudioGraphNodeType.failureMode,
      StudioGraphNodeType.control,
    });

    final support = _nodesOfTypes(graph, const {
      StudioGraphNodeType.simulation,
      StudioGraphNodeType.incident,
      StudioGraphNodeType.reference,
    });

    final boundaries = _nodesOfTypes(graph, const {
      StudioGraphNodeType.boundary,
      StudioGraphNodeType.interface,
    });

    final processesAndStates = _nodesOfTypes(graph, const {
      StudioGraphNodeType.process,
      StudioGraphNodeType.state,
      StudioGraphNodeType.custom,
    });

    final rootX = _canvasPadding + 720;
    final rootY = _canvasPadding;

    if (root != null) {
      positions[root.id] = Offset(rootX, rootY);
    }

    final leftColumnX = _canvasPadding;
    var leftY = rootY + 20;

    leftY = _placeVerticalGroup(
      nodes: actors,
      x: leftColumnX,
      startY: leftY,
      positions: positions,
    );

    leftY += _groupGap / 2;

    _placeVerticalGroup(
      nodes: inputs,
      x: leftColumnX,
      startY: leftY,
      positions: positions,
    );

    final subsystemStartX = _canvasPadding + 360;
    final rootHeight = root == null
        ? _minimumNodeHeight
        : _nodeSizes[root.id]?.height ?? _minimumNodeHeight;

    final subsystemStartY = rootY + rootHeight + 120;

    var subsystemX = subsystemStartX;

    for (final subsystem in subsystems) {
      final components =
          graph.nodes
              .where(
                (node) =>
                    node.parentId == subsystem.id &&
                    node.type == StudioGraphNodeType.component,
              )
              .toList()
            ..sort((left, right) => left.label.compareTo(right.label));

      final subtreeWidth = math.max(
        _nodeWidth,
        components.length * (_nodeWidth + _horizontalGap) - _horizontalGap,
      );

      final subsystemCenterX = subsystemX + subtreeWidth / 2 - _nodeWidth / 2;

      positions[subsystem.id] = Offset(subsystemCenterX, subsystemStartY);

      for (var index = 0; index < components.length; index++) {
        positions[components[index].id] = Offset(
          subsystemX + index * (_nodeWidth + _horizontalGap),
          subsystemStartY +
              (_nodeSizes[subsystem.id]?.height ?? _minimumNodeHeight) +
              96,
        );
      }

      final childSubsystems =
          graph.nodes
              .where(
                (node) =>
                    node.parentId == subsystem.id &&
                    node.type == StudioGraphNodeType.subsystem,
              )
              .toList()
            ..sort((left, right) => left.label.compareTo(right.label));

      final subsystemHeight =
          _nodeSizes[subsystem.id]?.height ?? _minimumNodeHeight;

      final componentBottom = components.isEmpty
          ? subsystemStartY + subsystemHeight
          : components
                .map((component) {
                  final position = positions[component.id];
                  final height =
                      _nodeSizes[component.id]?.height ?? _minimumNodeHeight;

                  return position == null
                      ? subsystemStartY
                      : position.dy + height;
                })
                .reduce(math.max);

      var childY = componentBottom + 96;

      for (final child in childSubsystems) {
        positions[child.id] = Offset(subsystemCenterX, childY);

        childY +=
            (_nodeSizes[child.id]?.height ?? _minimumNodeHeight) + _verticalGap;
      }

      subsystemX += subtreeWidth + _groupGap;
    }

    final rightX = math.max(subsystemX + 80, rootX + 620);

    var rightY = rootY + 20;

    rightY = _placeVerticalGroup(
      nodes: assets,
      x: rightX,
      startY: rightY,
      positions: positions,
    );

    rightY += _groupGap / 2;

    _placeVerticalGroup(
      nodes: outputs,
      x: rightX,
      startY: rightY,
      positions: positions,
    );

    final occupiedComponentBottom = _maximumBottom(
      positions: positions,
      graph: graph,
      includedTypes: const {
        StudioGraphNodeType.subsystem,
        StudioGraphNodeType.component,
      },
    );

    final failureStartY = math.max(
      subsystemStartY + 360,
      occupiedComponentBottom + 100,
    );

    _placeHorizontalGroup(
      nodes: failures,
      startX: subsystemStartX,
      y: failureStartY,
      positions: positions,
      maximumPerRow: 4,
    );

    final failureBottom = _maximumBottom(
      positions: positions,
      graph: graph,
      includedTypes: const {
        StudioGraphNodeType.failureMode,
        StudioGraphNodeType.control,
      },
    );

    final boundaryStartY = math.max(
      failureStartY + _minimumNodeHeight + 110,
      failureBottom + 80,
    );

    _placeHorizontalGroup(
      nodes: boundaries,
      startX: subsystemStartX,
      y: boundaryStartY,
      positions: positions,
      maximumPerRow: 4,
    );

    final boundaryBottom = _maximumBottom(
      positions: positions,
      graph: graph,
      includedTypes: const {
        StudioGraphNodeType.boundary,
        StudioGraphNodeType.interface,
      },
    );

    final supportStartY = math.max(
      boundaryStartY + _minimumNodeHeight + 110,
      boundaryBottom + 80,
    );

    final afterSupportY = _placeHorizontalGroup(
      nodes: support,
      startX: subsystemStartX,
      y: supportStartY,
      positions: positions,
      maximumPerRow: 4,
    );

    _placeHorizontalGroup(
      nodes: processesAndStates,
      startX: subsystemStartX,
      y: afterSupportY + 70,
      positions: positions,
      maximumPerRow: 4,
    );

    _placeUnassignedNodes(
      graph: graph,
      positions: positions,
      startY: afterSupportY + 220,
    );

    return positions;
  }

  List<StudioGraphNode> _nodesOfTypes(
    StudioSystemGraph graph,
    Set<StudioGraphNodeType> types,
  ) {
    final nodes = graph.nodes
        .where((node) => types.contains(node.type))
        .toList();

    nodes.sort((left, right) => left.label.compareTo(right.label));

    return nodes;
  }

  double _placeVerticalGroup({
    required List<StudioGraphNode> nodes,
    required double x,
    required double startY,
    required Map<String, Offset> positions,
  }) {
    var y = startY;

    for (final node in nodes) {
      positions[node.id] = Offset(x, y);

      final height = _nodeSizes[node.id]?.height ?? _minimumNodeHeight;

      y += height + _verticalGap;
    }

    return y;
  }

  double _placeHorizontalGroup({
    required List<StudioGraphNode> nodes,
    required double startX,
    required double y,
    required Map<String, Offset> positions,
    required int maximumPerRow,
  }) {
    if (nodes.isEmpty) {
      return y;
    }

    var currentY = y;
    var index = 0;

    while (index < nodes.length) {
      final end = math.min(index + maximumPerRow, nodes.length);

      final rowNodes = nodes.sublist(index, end);

      var rowHeight = _minimumNodeHeight;

      for (var column = 0; column < rowNodes.length; column++) {
        final node = rowNodes[column];

        positions[node.id] = Offset(
          startX + column * (_nodeWidth + _horizontalGap),
          currentY,
        );

        final nodeHeight = _nodeSizes[node.id]?.height ?? _minimumNodeHeight;

        rowHeight = math.max(rowHeight, nodeHeight);
      }

      currentY += rowHeight + _verticalGap;
      index = end;
    }

    return currentY;
  }

  double _maximumBottom({
    required Map<String, Offset> positions,
    required StudioSystemGraph graph,
    required Set<StudioGraphNodeType> includedTypes,
  }) {
    var bottom = 0.0;

    for (final node in graph.nodes) {
      if (!includedTypes.contains(node.type)) {
        continue;
      }

      final position = positions[node.id];

      if (position == null) {
        continue;
      }

      final height = _nodeSizes[node.id]?.height ?? _minimumNodeHeight;

      bottom = math.max(bottom, position.dy + height);
    }

    return bottom;
  }

  void _placeUnassignedNodes({
    required StudioSystemGraph graph,
    required Map<String, Offset> positions,
    required double startY,
  }) {
    final unassigned =
        graph.nodes.where((node) => !positions.containsKey(node.id)).toList()
          ..sort((left, right) => left.label.compareTo(right.label));

    _placeHorizontalGroup(
      nodes: unassigned,
      startX: _canvasPadding + 360,
      y: startY,
      positions: positions,
      maximumPerRow: 5,
    );
  }

  Size _calculateCanvasSize() {
    if (_positions.isEmpty) {
      return const Size(1200, 800);
    }

    var maximumX = 0.0;
    var maximumY = 0.0;

    for (final node in _visibleGraph.nodes) {
      final position = _positions[node.id];

      if (position == null) {
        continue;
      }

      final nodeSize =
          _nodeSizes[node.id] ?? const Size(_nodeWidth, _minimumNodeHeight);

      maximumX = math.max(maximumX, position.dx + nodeSize.width);

      maximumY = math.max(maximumY, position.dy + nodeSize.height);
    }

    return Size(
      math.max(1500, maximumX + _canvasPadding),
      math.max(900, maximumY + _canvasPadding),
    );
  }
}

class _RelationshipPainter extends CustomPainter {
  const _RelationshipPainter({
    required this.graph,
    required this.positions,
    required this.nodeSizes,
    required this.colorScheme,
    required this.selectedElement,
    required this.hoveredNodeId,
    this.overlay,
    this.overlayActor,
  });

  final StudioSystemGraph graph;
  final Map<String, Offset> positions;
  final Map<String, Size> nodeSizes;
  final ColorScheme colorScheme;
  final StudioElementRef? selectedElement;
  final String? hoveredNodeId;
  final SimulationGraphOverlay? overlay;
  final StudioElementRef? overlayActor;

  /// The boxes a label must not disappear behind.
  Iterable<Rect> get _nodeRects sync* {
    for (final entry in positions.entries) {
      final size = nodeSizes[entry.key];

      if (size != null) {
        yield entry.value & size;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintRelationships(canvas);

    final overlay = this.overlay;

    if (overlay != null) {
      _paintUndeclaredSteps(canvas, overlay);
    }
  }

  void _paintRelationships(Canvas canvas) {
    for (final relationship in graph.relationships) {
      final sourcePosition = positions[relationship.sourceId];
      final targetPosition = positions[relationship.targetId];

      if (sourcePosition == null || targetPosition == null) {
        continue;
      }

      final sourceSize = nodeSizes[relationship.sourceId];
      final targetSize = nodeSizes[relationship.targetId];

      if (sourceSize == null || targetSize == null) {
        continue;
      }

      final sourceCenter = Offset(
        sourcePosition.dx + sourceSize.width / 2,
        sourcePosition.dy + sourceSize.height / 2,
      );

      final targetCenter = Offset(
        targetPosition.dx + targetSize.width / 2,
        targetPosition.dy + targetSize.height / 2,
      );

      final anchors = _connectionAnchors(
        sourcePosition: sourcePosition,
        targetPosition: targetPosition,
        sourceCenter: sourceCenter,
        targetCenter: targetCenter,
        sourceSize: sourceSize,
        targetSize: targetSize,
      );
      final selected =
          selectedElement?.referencesRelationship(relationship.id) ?? false;

      final endpointActive =
          (selectedElement?.referencesNode(relationship.sourceId) ?? false) ||
          (selectedElement?.referencesNode(relationship.targetId) ?? false) ||
          hoveredNodeId == relationship.sourceId ||
          hoveredNodeId == relationship.targetId;

      final highlighted = selected || endpointActive;

      final overlay = this.overlay;

      // Steps of the run this relationship actually carried. A relationship
      // may carry more than one, which is worth seeing: the same connection
      // can be used twice for different reasons.
      final steps = overlay == null
          ? const <StudioOverlayStep>[]
          : overlay.stepsFor(relationship.id);

      final carriesRun = steps.isNotEmpty;

      final Color relationshipColor;
      final double strokeWidth;

      if (carriesRun) {
        relationshipColor = _overlayColor(steps.first.kind, colorScheme);
        strokeWidth = 3.8;
      } else if (overlay != null && !highlighted) {
        // Architecture the run did not use recedes but stays legible.
        relationshipColor = colorScheme.outline.withValues(alpha: 0.16);
        strokeWidth = 0.9;
      } else {
        relationshipColor = highlighted
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.48);
        strokeWidth = selected
            ? 3.4
            : highlighted
            ? 2.4
            : 1.05;
      }

      final paint = Paint()
        ..color = relationshipColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      final path = _relationshipPath(start: anchors.start, end: anchors.end);

      canvas.drawPath(path, paint);

      if (relationship.direction != StudioRelationshipDirection.undirected) {
        _drawArrowHead(
          canvas: canvas,
          end: anchors.end,
          previousPoint: anchors.arrowReference,
          paint: paint,
        );
      }

      if (carriesRun) {
        _drawStepMarker(
          canvas: canvas,
          steps: steps,
          start: anchors.start,
          end: anchors.end,
        );
      } else if (highlighted) {
        _drawRelationshipLabel(
          canvas: canvas,
          relationship: relationship,
          start: anchors.start,
          end: anchors.end,
        );
      }
    }
  }

  /// Draws steps that no declared relationship carries.
  ///
  /// Dashed, so it cannot be mistaken for architecture. Something did happen
  /// between these two elements, and the honest way to show it is to draw the
  /// occurrence while making plain that the system as authored has no
  /// connection for it. Inventing a solid edge here would put a relationship
  /// on the map that nobody wrote.
  void _paintUndeclaredSteps(Canvas canvas, SimulationGraphOverlay overlay) {
    for (final step in overlay.undeclaredSteps) {
      final sourcePosition = positions[step.from.id];
      final targetPosition = positions[step.to.id];

      if (sourcePosition == null || targetPosition == null) {
        continue;
      }

      final sourceSize = nodeSizes[step.from.id];
      final targetSize = nodeSizes[step.to.id];

      if (sourceSize == null || targetSize == null) {
        continue;
      }

      final anchors = _connectionAnchors(
        sourcePosition: sourcePosition,
        targetPosition: targetPosition,
        sourceCenter: Offset(
          sourcePosition.dx + sourceSize.width / 2,
          sourcePosition.dy + sourceSize.height / 2,
        ),
        targetCenter: Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy + targetSize.height / 2,
        ),
        sourceSize: sourceSize,
        targetSize: targetSize,
      );

      final paint = Paint()
        ..color = _overlayColor(step.kind, colorScheme)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      final path = _relationshipPath(start: anchors.start, end: anchors.end);

      _drawDashedPath(canvas: canvas, path: path, paint: paint);

      _drawArrowHead(
        canvas: canvas,
        end: anchors.end,
        previousPoint: anchors.arrowReference,
        paint: paint,
      );

      _drawStepMarker(
        canvas: canvas,
        steps: [step],
        start: anchors.start,
        end: anchors.end,
      );
    }
  }

  void _drawDashedPath({
    required Canvas canvas,
    required Path path,
    required Paint paint,
  }) {
    const dashLength = 9.0;
    const gapLength = 6.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;

      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);

        canvas.drawPath(metric.extractPath(distance, end), paint);

        distance = end + gapLength;
      }
    }
  }

  /// The order marker on a causal step, and whether the selected participant
  /// saw it happen.
  void _drawStepMarker({
    required Canvas canvas,
    required List<StudioOverlayStep> steps,
    required Offset start,
    required Offset end,
  }) {
    final color = _overlayColor(steps.first.kind, colorScheme);

    final actor = overlayActor;

    final witnessed =
        actor != null && steps.any((step) => step.wasObservedBy(actor));

    final order = steps.map((step) => step.position).join(', ');

    // Same wording the causal record uses, so one vocabulary covers both.
    final label =
        '$order · ${steps.first.label}${witnessed ? ' · they saw this' : ''}';

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          backgroundColor: colorScheme.surface.withValues(alpha: 0.94),
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 200);

    final origin = causalLabelOrigin(
      start: start,
      end: end,
      labelSize: Size(textPainter.width, textPainter.height),
      obstacles: _nodeRects,
    );

    // A filled backing keeps the order readable where it crosses the diagram.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          origin.dx - 6,
          origin.dy - 3,
          textPainter.width + 12,
          textPainter.height + 6,
        ),
        const Radius.circular(9),
      ),
      Paint()..color = color.withValues(alpha: 0.20),
    );

    textPainter.paint(canvas, origin);
  }

  static _ConnectionAnchors _connectionAnchors({
    required Offset sourcePosition,
    required Offset targetPosition,
    required Offset sourceCenter,
    required Offset targetCenter,
    required Size sourceSize,
    required Size targetSize,
  }) {
    final deltaX = targetCenter.dx - sourceCenter.dx;
    final deltaY = targetCenter.dy - sourceCenter.dy;

    if (deltaX.abs() >= deltaY.abs()) {
      final targetIsRight = deltaX >= 0;

      final start = Offset(
        targetIsRight
            ? sourcePosition.dx + sourceSize.width
            : sourcePosition.dx,
        sourceCenter.dy,
      );

      final end = Offset(
        targetIsRight
            ? targetPosition.dx
            : targetPosition.dx + targetSize.width,
        targetCenter.dy,
      );

      return _ConnectionAnchors(
        start: start,
        end: end,
        arrowReference: Offset(end.dx + (targetIsRight ? -14 : 14), end.dy),
      );
    }

    final targetIsBelow = deltaY >= 0;

    final start = Offset(
      sourceCenter.dx,
      targetIsBelow ? sourcePosition.dy + sourceSize.height : sourcePosition.dy,
    );

    final end = Offset(
      targetCenter.dx,
      targetIsBelow ? targetPosition.dy : targetPosition.dy + targetSize.height,
    );

    return _ConnectionAnchors(
      start: start,
      end: end,
      arrowReference: Offset(end.dx, end.dy + (targetIsBelow ? -14 : 14)),
    );
  }

  static Path _relationshipPath({required Offset start, required Offset end}) {
    final deltaX = (end.dx - start.dx).abs();
    final deltaY = (end.dy - start.dy).abs();

    final path = Path()..moveTo(start.dx, start.dy);

    if (deltaX >= deltaY) {
      final controlDistance = math.max(36.0, deltaX * 0.42);

      final direction = end.dx >= start.dx ? 1.0 : -1.0;

      path.cubicTo(
        start.dx + controlDistance * direction,
        start.dy,
        end.dx - controlDistance * direction,
        end.dy,
        end.dx,
        end.dy,
      );
    } else {
      final controlDistance = math.max(36.0, deltaY * 0.42);

      final direction = end.dy >= start.dy ? 1.0 : -1.0;

      path.cubicTo(
        start.dx,
        start.dy + controlDistance * direction,
        end.dx,
        end.dy - controlDistance * direction,
        end.dx,
        end.dy,
      );
    }

    return path;
  }

  void _drawArrowHead({
    required Canvas canvas,
    required Offset end,
    required Offset previousPoint,
    required Paint paint,
  }) {
    final angle = math.atan2(
      end.dy - previousPoint.dy,
      end.dx - previousPoint.dx,
    );

    const arrowLength = 9.0;
    const arrowSpread = 0.55;

    final first = Offset(
      end.dx - arrowLength * math.cos(angle - arrowSpread),
      end.dy - arrowLength * math.sin(angle - arrowSpread),
    );

    final second = Offset(
      end.dx - arrowLength * math.cos(angle + arrowSpread),
      end.dy - arrowLength * math.sin(angle + arrowSpread),
    );

    final arrowPath = Path()
      ..moveTo(first.dx, first.dy)
      ..lineTo(end.dx, end.dy)
      ..lineTo(second.dx, second.dy);

    canvas.drawPath(arrowPath, paint);
  }

  void _drawRelationshipLabel({
    required Canvas canvas,
    required StudioRelationship relationship,
    required Offset start,
    required Offset end,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: relationship.label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          backgroundColor: colorScheme.surface.withValues(alpha: 0.94),
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 170);

    textPainter.paint(
      canvas,
      causalLabelOrigin(
        start: start,
        end: end,
        labelSize: Size(textPainter.width, textPainter.height),
        obstacles: _nodeRects,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _RelationshipPainter oldDelegate) {
    return oldDelegate.graph != graph ||
        oldDelegate.positions != positions ||
        oldDelegate.selectedElement != selectedElement ||
        oldDelegate.hoveredNodeId != hoveredNodeId ||
        oldDelegate.colorScheme != colorScheme ||
        !identical(oldDelegate.overlay, overlay) ||
        oldDelegate.overlayActor != overlayActor;
  }
}

/// What the run did to one variable, in one line under an element.
///
/// Shows the span rather than the latest move, because the question at an
/// element is what the run did to it, and the latest transition alone would
/// misstate where it started. When it moved more than once the count says so,
/// so a span is never mistaken for a single transition, and the causal record
/// remains the place to read each move and why it happened.
String _stateSummaryLabel(StudioOverlayStateSummary summary) {
  final name = summary.variableId.split('.').last;

  if (!summary.changedMoreThanOnce) {
    return '$name: ${summary.initialValue} → ${summary.currentValue}';
  }

  // Ending where it began is a real outcome, and a bare span would hide it.
  if (summary.returnedToStart) {
    return '$name: back to ${summary.currentValue} '
        'after ${summary.changeCount} changes';
  }

  return '$name: ${summary.initialValue} → ${summary.currentValue} '
      '(${summary.changeCount} changes)';
}

/// Where a connector's label sits, given the elements it must not hide behind.
///
/// The midpoint of a connector is the obvious place for its label and the
/// wrong one: node anchors sit on box edges, so a short or steep connector
/// puts its own midpoint inside a node and the text disappears underneath it.
///
/// The rule is local and deliberately dumb. Lift the label perpendicular to
/// the connector — upwards for a horizontal run, which is where a reader
/// expects it — and only push further if that lands on a node. Trying the
/// other side before giving up covers the case where a connector runs along
/// the top of the diagram and there is nothing above it.
///
/// This is not a layout engine. It moves one label a little way off one line;
/// it does not consider other labels, and it never moves a node.
///
/// Returns the top-left origin at which a label of [labelSize] should paint.
Offset causalLabelOrigin({
  required Offset start,
  required Offset end,
  required Size labelSize,
  required Iterable<Rect> obstacles,
  double gap = 8,
  double margin = 4,
  int maximumAttempts = 6,
}) {
  final centre = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

  final delta = end - start;
  final length = delta.distance;

  // Two coincident anchors give no direction to be perpendicular to. The
  // label is displaced sideways rather than not at all, and no direction is
  // promised for this case — there is no meaningful "above" a point.
  final unit = length == 0
      ? const Offset(0, -1)
      : Offset(delta.dx / length, delta.dy / length);

  // Perpendicular, pointed upwards. For a horizontal connector this is
  // straight up; for a diagonal it leans away from the path at right angles.
  var perpendicular = Offset(-unit.dy, unit.dx);

  if (perpendicular.dy > 0) {
    perpendicular = -perpendicular;
  }

  final step = labelSize.height + margin;

  Rect rectAt(Offset displacement) {
    return Rect.fromCenter(
      center: centre + displacement,
      width: labelSize.width + margin * 2,
      height: labelSize.height + margin * 2,
    );
  }

  bool isClear(Rect rect) =>
      !obstacles.any((obstacle) => obstacle.overlaps(rect));

  final firstOffset = labelSize.height / 2 + gap;

  // Preferred side first, then the other, each pushed out a step at a time.
  for (final direction in [perpendicular, -perpendicular]) {
    for (var attempt = 0; attempt < maximumAttempts; attempt++) {
      final displacement = direction * (firstOffset + step * attempt);

      if (isClear(rectAt(displacement))) {
        final centred = centre + displacement;

        return Offset(
          centred.dx - labelSize.width / 2,
          centred.dy - labelSize.height / 2,
        );
      }
    }
  }

  // Nowhere clear within reach. Sitting just off the connector on the
  // preferred side is still better than sitting on top of it.
  final fallback = centre + perpendicular * firstOffset;

  return Offset(
    fallback.dx - labelSize.width / 2,
    fallback.dy - labelSize.height / 2,
  );
}

/// Colour by what kind of occurrence a step was.
///
/// The same three distinctions the causal record makes, so that a learner
/// moving between the two views is reading one vocabulary rather than two.
Color _overlayColor(StudioCausalLinkKind kind, ColorScheme colorScheme) {
  return switch (kind) {
    StudioCausalLinkKind.chosenAction => colorScheme.primary,
    StudioCausalLinkKind.automaticBehavior => colorScheme.tertiary,
    StudioCausalLinkKind.observation => colorScheme.secondary,
  };
}

class _ConnectionAnchors {
  const _ConnectionAnchors({
    required this.start,
    required this.end,
    required this.arrowReference,
  });

  final Offset start;
  final Offset end;
  final Offset arrowReference;
}

String _displayNodeType(StudioGraphNodeType type) {
  return switch (type) {
    StudioGraphNodeType.system => 'System',
    StudioGraphNodeType.subsystem => 'Subsystem',
    StudioGraphNodeType.component => 'Component',
    StudioGraphNodeType.actor => 'Actor',
    StudioGraphNodeType.asset => 'Asset',
    StudioGraphNodeType.interface => 'Interface',
    StudioGraphNodeType.boundary => 'Boundary',
    StudioGraphNodeType.input => 'Input',
    StudioGraphNodeType.output => 'Output',
    StudioGraphNodeType.failureMode => 'Failure Mode',
    StudioGraphNodeType.control => 'Control',
    StudioGraphNodeType.simulation => 'Simulation',
    StudioGraphNodeType.incident => 'Incident',
    StudioGraphNodeType.reference => 'Reference',
    StudioGraphNodeType.externalSystem => 'External System',
    StudioGraphNodeType.process => 'Process',
    StudioGraphNodeType.state => 'State',
    StudioGraphNodeType.custom => 'Custom',
  };
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

Color _colorForNodeType(StudioGraphNodeType type, ColorScheme colorScheme) {
  return switch (type) {
    StudioGraphNodeType.failureMode ||
    StudioGraphNodeType.incident => colorScheme.error,
    StudioGraphNodeType.actor => colorScheme.tertiary,
    StudioGraphNodeType.asset => colorScheme.secondary,
    StudioGraphNodeType.system ||
    StudioGraphNodeType.subsystem ||
    StudioGraphNodeType.component => colorScheme.primary,
    _ => colorScheme.onSurfaceVariant,
  };
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;

    if (!iterator.moveNext()) {
      return null;
    }

    return iterator.current;
  }
}

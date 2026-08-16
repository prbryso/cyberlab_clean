import 'package:flutter/material.dart';

import 'package:systems_studio/engine/graph/event_capability.dart';
import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_focus.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/services/studio_system_detail_registry.dart';
import 'package:systems_studio/engine/simulation/simulation_overlay.dart';
import 'package:systems_studio/engine/simulation/studio_situation_snapshot.dart';
import 'package:systems_studio/engine/theme/spacing.dart';
import 'package:systems_studio/engine/ui/simulation/simulation_panel.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/facets/node_facets_view.dart';
import 'package:systems_studio/engine/ui/widgets/state/node_state_view.dart';
import 'package:systems_studio/engine/ui/widgets/graphs/system_graph_canvas.dart';
import 'package:systems_studio/engine/ui/workspace/studio_graph_view_controller.dart';
import 'package:systems_studio/engine/ui/workspace/system_workspace.dart';

/// The ways of looking at a system this screen offers.
///
/// One list, used for the tab strip, the controller's length, and the body
/// shown for the selected tab. They were three parallel lists before, and the
/// count silently diverged: the strip declared five while the body supplied
/// four, which is not something arithmetic can be trusted to keep in step.
/// Adding a case here forces a body, because the switch over it is exhaustive.
enum _ExplorerTab {
  overview('Overview', Icons.dashboard_outlined),
  architecture('Architecture', Icons.account_tree_outlined),
  explore('Explore', Icons.explore_outlined),
  workspace('Workspace', Icons.hub_outlined),
  simulate('Simulate', Icons.play_circle_outline);

  const _ExplorerTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

class SystemExplorerScreen extends StatefulWidget {
  const SystemExplorerScreen({
    super.key,
    required this.systemId,
    required this.title,
  });

  final String systemId;
  final String title;

  @override
  State<SystemExplorerScreen> createState() => _SystemExplorerScreenState();
}

class _SystemExplorerScreenState extends State<SystemExplorerScreen> {
  static const StudioGraphEngine _graphEngine = StudioGraphEngine();

  late final StudioGraphViewController _graphViewController;

  /// Owned per exploration screen, not app-wide: a run belongs to one person
  /// exploring one system, and leaving this screen should end it.
  StudioSimulationController? _simulationController;

  StudioGraphNode? _selectedNode;

  @override
  void initState() {
    super.initState();

    _graphViewController = StudioGraphViewController();
    _graphViewController.expand(widget.systemId);
  }

  @override
  void dispose() {
    _simulationController?.dispose();
    _graphViewController.dispose();

    super.dispose();
  }

  /// Creates the run lazily, once the graph has been built and validated.
  ///
  /// The graph is only available inside build, and building it is what proves
  /// the system can run at all.
  StudioSimulationController _simulationFor(StudioSystemGraph graph) {
    final existing = _simulationController;

    if (existing != null) {
      return existing;
    }

    // Someone has to be present for anything to begin, because an actor with
    // no involvement is offered no actions.
    //
    // Where the system authors scenarios, each one says who is present and
    // the learner picks between them, so nothing is guessed here. This
    // fallback is for systems that offer no situations: it takes the starter
    // to be the initiator of the first authored action — the participant
    // whose move the system's dynamics are written around.
    //
    // Seeding every possible initiator instead would make every actor involved
    // from the outset, and involvement arriving because information reached
    // someone is the thing worth showing.
    final starters = graph.scenarios.isNotEmpty
        ? const <StudioElementRef>{}
        : <StudioElementRef>{
            for (final action in graph.actionDefinitions)
              if (graph.nodeById(action.initiator.id)?.type ==
                  StudioGraphNodeType.actor)
                action.initiator,
          };

    final controller = StudioSimulationController(
      graph: graph,
      runId: widget.systemId,
      initialActors: starters.isEmpty ? const {} : {starters.first},
    );

    _simulationController = controller;

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final detail = StudioSystemDetailRegistry.instance.detailBySystemId(
      widget.systemId,
    );

    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Text(
            'No system detail is registered for "${widget.systemId}".',
          ),
        ),
      );
    }

    late final StudioGraphSession session;

    try {
      session = _graphEngine.open(detail);
    } on Object catch (error) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Unable to open the system model.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final rootNode = session.graph.nodeById(widget.systemId);

    if (rootNode == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Text('The system graph does not contain a root node.'),
        ),
      );
    }

    final selectedNode = _selectedNode ?? rootNode;

    final architectureFocus = session.query.focusedSubgraph(
      StudioGraphFocus.node(
        selectedNode.id,
        depth: selectedNode.type == StudioGraphNodeType.system ? 0 : 1,
        includeParents: true,
        includeChildren: true,
        includeIncoming: true,
        includeOutgoing: true,
      ),
    );

    final simulation = _simulationFor(session.graph);

    // One derivation for this build, shared by the architecture overlay and
    // the state display. Empty until something happens, so architecture with
    // no run behaves exactly as it always has.
    final situation = StudioSituationSnapshot.of(session.graph, simulation.run);

    final runSituation = situation.isAtStart ? null : situation;

    final focusedGraph = runSituation == null
        ? architectureFocus
        : runSituation.overlay.revealWithin(session.graph, architectureFocus);

    if (runSituation != null) {
      // Opening containers notifies listeners, which cannot happen while this
      // frame is being built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _graphViewController.expandAll(runSituation.overlay.expandNodeIds);
        }
      });
    }

    return DefaultTabController(
      length: _ExplorerTab.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: [
              for (final tab in _ExplorerTab.values)
                Tab(icon: Icon(tab.icon), text: tab.label),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);

            return AnimatedBuilder(
              // The run is listened to as well as the tab, so acting in
              // Simulate is reflected on the architecture without having to
              // leave and come back.
              animation: Listenable.merge([tabController, simulation]),
              builder: (context, child) {
                final tab = _ExplorerTab.values[tabController.index];

                if (tab == _ExplorerTab.simulate) {
                  return SimulationPanel(
                    controller: simulation,
                    session: session,
                    selectedElement: StudioElementRef.node(selectedNode.id),
                    onElementSelected: (ref) {
                      if (!ref.isNode) {
                        return;
                      }

                      final node = session.graph.nodeById(ref.id);

                      if (node != null) {
                        _selectNode(node);
                      }
                    },
                  );
                }

                if (tab == _ExplorerTab.workspace) {
                  return SystemWorkspace(
                    graph: session.graph,
                    simulation: simulation,
                    initialSelectedNodeId: selectedNode.id,
                    initialFocusNodeId: selectedNode.id,
                    onNodeSelected: _selectNode,
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final useSideNavigation = constraints.maxWidth >= 1000;

                    if (useSideNavigation) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 310,
                            child: _SystemHierarchyPanel(
                              graph: session.graph,
                              selectedNodeId: selectedNode.id,
                              onNodeSelected: _selectNode,
                            ),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(
                            child: _ExplorerContent(
                              fullGraph: session.graph,
                              focusedGraph: focusedGraph,
                              controller: _graphViewController,
                              selectedNode: selectedNode,
                              onNodeSelected: _selectNode,
                              situation: runSituation,
                              tab: tab,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _CompactHierarchySelector(
                          graph: session.graph,
                          selectedNode: selectedNode,
                          onNodeSelected: _selectNode,
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: _ExplorerContent(
                            fullGraph: session.graph,
                            focusedGraph: focusedGraph,
                            controller: _graphViewController,
                            selectedNode: selectedNode,
                            onNodeSelected: _selectNode,
                            situation: runSituation,
                            tab: tab,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _selectNode(StudioGraphNode node) {
    setState(() {
      _selectedNode = node;
    });
  }
}

class _SystemHierarchyPanel extends StatelessWidget {
  const _SystemHierarchyPanel({
    required this.graph,
    required this.selectedNodeId,
    required this.onNodeSelected,
  });

  final StudioSystemGraph graph;
  final String selectedNodeId;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final root = graph.nodeById(graph.systemId);

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: ListView(
        padding: EdgeInsets.all(spacing.md),
        children: [
          Text(
            'System Structure',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Select a system, subsystem, or component.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.md),
          if (root != null)
            _HierarchyNode(
              graph: graph,
              node: root,
              selectedNodeId: selectedNodeId,
              onNodeSelected: onNodeSelected,
              depth: 0,
            ),
        ],
      ),
    );
  }
}

class _HierarchyNode extends StatelessWidget {
  const _HierarchyNode({
    required this.graph,
    required this.node,
    required this.selectedNodeId,
    required this.onNodeSelected,
    required this.depth,
  });

  final StudioSystemGraph graph;
  final StudioGraphNode node;
  final String selectedNodeId;
  final ValueChanged<StudioGraphNode> onNodeSelected;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final children =
        graph.nodes
            .where((candidate) => candidate.parentId == node.id)
            .where(
              (candidate) =>
                  candidate.type == StudioGraphNodeType.subsystem ||
                  candidate.type == StudioGraphNodeType.component,
            )
            .toList()
          ..sort((left, right) => left.label.compareTo(right.label));

    final selected = selectedNodeId == node.id;
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 16),
          child: Card(
            elevation: 0,
            color: selected ? color.primary : color.surface,
            child: ListTile(
              dense: true,
              selected: selected,
              leading: Icon(
                _iconForNodeType(node.type),
                color: selected ? color.onPrimary : color.onSurface,
              ),
              title: Text(
                node.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? color.onPrimary : color.onSurface,
                ),
              ),
              subtitle: Text(
                _displayNodeType(node.type),
                style: TextStyle(
                  color: selected
                      ? color.onPrimary.withValues(alpha: 0.85)
                      : color.onSurfaceVariant,
                ),
              ),
              onTap: () => onNodeSelected(node),
            ),
          ),
        ),
        for (final child in children)
          _HierarchyNode(
            graph: graph,
            node: child,
            selectedNodeId: selectedNodeId,
            onNodeSelected: onNodeSelected,
            depth: depth + 1,
          ),
      ],
    );
  }
}

class _CompactHierarchySelector extends StatelessWidget {
  const _CompactHierarchySelector({
    required this.graph,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  final StudioSystemGraph graph;
  final StudioGraphNode selectedNode;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final selectableNodes = graph.nodes.where(
      (node) =>
          node.type == StudioGraphNodeType.system ||
          node.type == StudioGraphNodeType.subsystem ||
          node.type == StudioGraphNodeType.component,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField<String>(
        initialValue: selectedNode.id,
        decoration: const InputDecoration(
          labelText: 'System level',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.account_tree_outlined),
        ),
        items: selectableNodes.map((node) {
          return DropdownMenuItem<String>(
            value: node.id,
            child: Text('${node.label} — ${_displayNodeType(node.type)}'),
          );
        }).toList(),
        onChanged: (nodeId) {
          if (nodeId == null) {
            return;
          }

          final node = graph.nodeById(nodeId);

          if (node != null) {
            onNodeSelected(node);
          }
        },
      ),
    );
  }
}

class _ExplorerContent extends StatelessWidget {
  const _ExplorerContent({
    required this.fullGraph,
    required this.focusedGraph,
    required this.controller,
    required this.selectedNode,
    required this.onNodeSelected,
    required this.tab,
    this.situation,
  });

  /// Which way of looking at the system is selected.
  final _ExplorerTab tab;

  final StudioSystemGraph fullGraph;
  final StudioSystemGraph focusedGraph;
  final StudioGraphViewController controller;
  final StudioGraphNode selectedNode;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  /// The exploration in progress, when there is one. One snapshot serves both
  /// the architecture overlay and the state display, so they cannot describe
  /// different moments.
  final StudioSituationSnapshot? situation;

  @override
  Widget build(BuildContext context) {
    // One body for the selected tab, rather than a parallel list of children
    // that has to be kept the same length as the tab strip. The switch is
    // exhaustive over [_ExplorerTab], so a new way of looking at a system
    // cannot be added without deciding what it shows.
    return switch (tab) {
      _ExplorerTab.overview => _OverviewTab(
        graph: fullGraph,
        selectedNode: selectedNode,
        onNodeSelected: onNodeSelected,
        situation: situation,
      ),
      _ExplorerTab.architecture => _ArchitectureTab(
        graph: focusedGraph,
        controller: controller,
        selectedNode: selectedNode,
        onNodeSelected: onNodeSelected,
        overlay: situation?.overlay,
      ),
      _ExplorerTab.explore => _ExploreTab(
        graph: fullGraph,
        selectedNode: selectedNode,
        onNodeSelected: onNodeSelected,
      ),
      // Handled by the screen itself, which gives them the whole surface
      // rather than the space beside the hierarchy panel.
      _ExplorerTab.workspace ||
      _ExplorerTab.simulate => const SizedBox.shrink(),
    };
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.graph,
    required this.selectedNode,
    required this.onNodeSelected,
    this.situation,
  });

  final StudioSystemGraph graph;
  final StudioGraphNode selectedNode;
  final ValueChanged<StudioGraphNode> onNodeSelected;
  final StudioSituationSnapshot? situation;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    final children =
        graph.nodes
            .where(
              (node) =>
                  node.parentId == selectedNode.id &&
                  (node.type == StudioGraphNodeType.subsystem ||
                      node.type == StudioGraphNodeType.component ||
                      node.type == StudioGraphNodeType.process),
            )
            .toList()
          ..sort((left, right) => left.label.compareTo(right.label));

    final relationships = graph.relationshipsFor(selectedNode.id);

    return ListView(
      padding: EdgeInsets.all(spacing.md),
      children: [
        _SelectedElementHero(node: selectedNode),
        SizedBox(height: spacing.md),
        _InformationCard(
          title: 'Purpose and Description',
          icon: Icons.info_outline,
          child: Text(
            selectedNode.description.isEmpty
                ? 'No description has been supplied.'
                : selectedNode.description,
          ),
        ),
        SizedBox(height: spacing.md),
        _InformationCard(
          title: 'Element Facets',
          icon: Icons.help_outline,
          child: NodeFacetsView(
            facets: selectedNode.facets,
            eventCapability: StudioEventCapabilityIndex.forGraph(
              graph,
            ).capabilityFor(StudioElementRef.node(selectedNode.id)),
          ),
        ),
        SizedBox(height: spacing.md),
        _InformationCard(
          title: 'Declared State',
          icon: Icons.toggle_on_outlined,
          child: NodeStateView(
            variables: graph.stateVariablesFor(
              StudioElementRef.node(selectedNode.id),
            ),
            situation: situation,
          ),
        ),
        if (children.isNotEmpty) ...[
          SizedBox(height: spacing.md),
          _InformationCard(
            title: 'Contained Elements',
            icon: Icons.account_tree_outlined,
            child: Column(
              children: children.map((node) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_iconForNodeType(node.type)),
                  title: Text(node.label),
                  subtitle: Text(_displayNodeType(node.type)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onNodeSelected(node),
                );
              }).toList(),
            ),
          ),
        ],
        SizedBox(height: spacing.md),
        _InformationCard(
          title: 'Connections',
          icon: Icons.link_outlined,
          child: relationships.isEmpty
              ? const Text('No relationships are registered.')
              : Column(
                  children: relationships.map((relationship) {
                    final otherId = relationship.otherEndpoint(selectedNode.id);

                    final otherNode = otherId == null
                        ? null
                        : graph.nodeById(otherId);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.compare_arrows_outlined),
                      title: Text(relationship.label),
                      subtitle: Text(
                        otherNode?.label ?? otherId ?? 'Unknown element',
                      ),
                      trailing: Text(relationship.type.name),
                      onTap: otherNode == null
                          ? null
                          : () => onNodeSelected(otherNode),
                    );
                  }).toList(),
                ),
        ),
        if (_systemInformation(selectedNode).isNotEmpty) ...[
          SizedBox(height: spacing.md),
          _InformationCard(
            title: 'System Information',
            icon: Icons.data_object_outlined,
            child: _MetadataView(metadata: _systemInformation(selectedNode)),
          ),
        ],
      ],
    );
  }
}

class _ArchitectureTab extends StatelessWidget {
  const _ArchitectureTab({
    required this.graph,
    required this.controller,
    required this.selectedNode,
    required this.onNodeSelected,
    this.overlay,
  });

  final StudioSystemGraph graph;
  final StudioGraphViewController controller;
  final StudioGraphNode selectedNode;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  /// What the current run did, drawn over the architecture. Null until
  /// something has happened.
  final SimulationGraphOverlay? overlay;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    final overlay = this.overlay;

    return Padding(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${selectedNode.label} Architecture',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: spacing.xs),
          Text(
            // The architecture question is unchanged. What changes when a run
            // exists is that the same drawing also carries a record of what
            // took place in it, which the learner is told rather than left to
            // infer from unexplained highlighting.
            overlay == null
                ? 'The map is limited to the selected level and its immediate '
                      'system context.'
                : 'The map still shows how this system is built. Highlighted '
                      'on top of it is what happened in the current run, in '
                      'order. Everything else is dimmed, not hidden.',
            key: overlay == null
                ? const Key('architecture-subtitle')
                : const Key('architecture-subtitle-simulation'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.md),
          Expanded(
            child: SystemGraphCanvas(
              graph: graph,
              controller: controller,
              selectedElement: StudioElementRef.node(selectedNode.id),
              onNodeSelected: onNodeSelected,
              overlay: overlay,
              overlayActor:
                  selectedNode.type == StudioGraphNodeType.actor
                  ? StudioElementRef.node(selectedNode.id)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreTab extends StatelessWidget {
  const _ExploreTab({
    required this.graph,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  final StudioSystemGraph graph;
  final StudioGraphNode selectedNode;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    final relatedNodes = <StudioGraphNode>[];

    for (final relationship in graph.relationshipsFor(selectedNode.id)) {
      final otherId = relationship.otherEndpoint(selectedNode.id);

      final node = otherId == null ? null : graph.nodeById(otherId);

      if (node != null &&
          !relatedNodes.any((existing) => existing.id == node.id)) {
        relatedNodes.add(node);
      }
    }

    return ListView(
      padding: EdgeInsets.all(spacing.md),
      children: [
        _SelectedElementHero(node: selectedNode),
        SizedBox(height: spacing.md),
        Text(
          'Related Elements',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: spacing.sm),
        if (relatedNodes.isEmpty)
          const _InformationCard(
            title: 'No Related Elements',
            icon: Icons.link_off_outlined,
            child: Text(
              'No direct graph relationships are currently registered.',
            ),
          )
        else
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: relatedNodes.map((node) {
              return SizedBox(
                width: 280,
                child: Card(
                  child: ListTile(
                    leading: Icon(_iconForNodeType(node.type)),
                    title: Text(node.label),
                    subtitle: Text(_displayNodeType(node.type)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => onNodeSelected(node),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _SelectedElementHero extends StatelessWidget {
  const _SelectedElementHero({required this.node});

  final StudioGraphNode node;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(spacing.md),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(spacing.md),
            ),
            child: Icon(
              _iconForNodeType(node.type),
              color: color.onPrimary,
              size: 30,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.label,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  _displayNodeType(node.type),
                  style: text.titleMedium?.copyWith(
                    color: color.onPrimaryContainer,
                  ),
                ),
                Text(
                  node.id,
                  style: text.labelMedium?.copyWith(
                    color: color.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                SizedBox(width: spacing.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetadataView extends StatelessWidget {
  const _MetadataView({required this.metadata});

  final Map<String, Object?> metadata;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: metadata.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 170,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Text(_formatValue(entry.value))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Package metadata plus the node's typed semantics, for display.
Map<String, Object?> _systemInformation(StudioGraphNode node) {
  return {...node.metadata, ...node.semanticSummary()};
}

String _formatValue(Object? value) {
  if (value == null) {
    return '—';
  }

  if (value is Iterable) {
    return value.map((item) => item.toString()).join('\n');
  }

  if (value is Map) {
    return value.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  return value.toString();
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

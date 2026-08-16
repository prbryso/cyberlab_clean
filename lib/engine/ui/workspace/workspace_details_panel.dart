import 'package:flutter/material.dart';

import 'package:systems_studio/engine/graph/event_capability.dart';
import 'package:systems_studio/engine/graph/graph_query.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/ui/widgets/facets/node_facets_view.dart';
import 'package:systems_studio/engine/ui/widgets/state/node_state_view.dart';
import 'package:systems_studio/engine/ui/workspace/workspace_controller.dart';

/// Displays graph-derived insight for the currently selected workspace node.
///
/// The Insight Panel does not own system knowledge. It derives hierarchy,
/// connections, relationships, tags, and metadata from the workspace graph.
class WorkspaceDetailsPanel extends StatelessWidget {
  const WorkspaceDetailsPanel({
    super.key,
    required this.controller,
    this.onExploreHere,
    this.onOpenOverview,
    this.onOpenArchitecture,
    this.onOpenExplore,
  });

  final WorkspaceController controller;

  /// Optional callback used when the user chooses Explore Here.
  ///
  /// When omitted, the controller focuses the workspace on the selected node.
  final VoidCallback? onExploreHere;

  /// Optional perspective-navigation callbacks.
  final VoidCallback? onOpenOverview;
  final VoidCallback? onOpenArchitecture;
  final VoidCallback? onOpenExplore;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final selectedRelationship = controller.selectedRelationship;

        if (selectedRelationship != null) {
          return _RelationshipDetailsPanel(
            relationship: selectedRelationship,
            graph: controller.graph,
            onNodeSelected: controller.selectNode,
            onClose: controller.toggleDetailsPanel,
            onExploreHere: () {
              controller.focusOnRelationship(selectedRelationship);
            },
          );
        }

        final selectedNode = controller.selectedNode;

        if (selectedNode == null) {
          return const _EmptyDetailsPanel();
        }

        final graph = controller.graph;
        final query = StudioGraphQuery(graph);

        final ancestors = query.ancestorsOf(selectedNode.id);

        final children = query.childrenOf(selectedNode.id).toList()
          ..sort(_sortNodes);

        final neighbors = query.neighborsOf(selectedNode.id).toList()
          ..sort(_sortNodes);

        final incomingRelationships = query.incomingTo(selectedNode.id).toList()
          ..sort(_sortRelationships);

        final outgoingRelationships =
            query.outgoingFrom(selectedNode.id).toList()
              ..sort(_sortRelationships);

        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PanelHeader(
                node: selectedNode,
                onClose: controller.toggleDetailsPanel,
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Section(
                      title: 'Role',
                      icon: Icons.info_outline,
                      child: Text(
                        selectedNode.description.trim().isEmpty
                            ? 'No description has been supplied.'
                            : selectedNode.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.45),
                      ),
                    ),
                    if (ancestors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'System Location',
                        icon: Icons.route_outlined,
                        child: _HierarchyPath(
                          ancestors: ancestors,
                          selectedNode: selectedNode,
                          onNodeSelected: controller.selectNode,
                        ),
                      ),
                    ],
                    if (children.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Contains',
                        icon: Icons.account_tree_outlined,
                        child: _NodeList(
                          nodes: children,
                          onNodeSelected: controller.selectNode,
                        ),
                      ),
                    ],
                    if (neighbors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Connected Elements',
                        icon: Icons.hub_outlined,
                        child: _NodeList(
                          nodes: neighbors,
                          onNodeSelected: controller.selectNode,
                        ),
                      ),
                    ],
                    if (incomingRelationships.isNotEmpty ||
                        outgoingRelationships.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Relationships',
                        icon: Icons.compare_arrows_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (incomingRelationships.isNotEmpty)
                              _RelationshipGroup(
                                title: 'Incoming',
                                relationships: incomingRelationships,
                                selectedNode: selectedNode,
                                graph: graph,
                                onNodeSelected: controller.selectNode,
                              ),
                            if (incomingRelationships.isNotEmpty &&
                                outgoingRelationships.isNotEmpty)
                              const Divider(height: 28),
                            if (outgoingRelationships.isNotEmpty)
                              _RelationshipGroup(
                                title: 'Outgoing',
                                relationships: outgoingRelationships,
                                selectedNode: selectedNode,
                                graph: graph,
                                onNodeSelected: controller.selectNode,
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Element Facets',
                      icon: Icons.help_outline,
                      trailing: FacetCoverageLabel(
                        facets: selectedNode.facets,
                      ),
                      child: NodeFacetsView(
                        facets: selectedNode.facets,
                        eventCapability:
                            StudioEventCapabilityIndex.forGraph(
                              graph,
                            ).capabilityFor(
                              StudioElementRef.node(selectedNode.id),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Declared State',
                      icon: Icons.toggle_on_outlined,
                      child: NodeStateView(
                        variables: graph.stateVariablesFor(
                          StudioElementRef.node(selectedNode.id),
                        ),
                      ),
                    ),
                    if (selectedNode.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'Tags',
                        icon: Icons.sell_outlined,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedNode.tags
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                        ),
                      ),
                    ],
                    if (_systemInformation(selectedNode).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _Section(
                        title: 'System Information',
                        icon: Icons.data_object_outlined,
                        child: _MetadataList(
                          metadata: _systemInformation(selectedNode),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _ActionSection(
                      controller: controller,
                      selectedNode: selectedNode,
                      onExploreHere: onExploreHere,
                      onOpenOverview: onOpenOverview,
                      onOpenArchitecture: onOpenArchitecture,
                      onOpenExplore: onOpenExplore,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static int _sortNodes(StudioGraphNode left, StudioGraphNode right) {
    return left.label.toLowerCase().compareTo(right.label.toLowerCase());
  }

  static int _sortRelationships(
    StudioRelationship left,
    StudioRelationship right,
  ) {
    return left.label.toLowerCase().compareTo(right.label.toLowerCase());
  }
}

/// Details for a selected relationship.
///
/// A relationship is an edge between two elements. It has a type, a direction,
/// a strength, endpoints, and its own description, tags, and metadata. It has
/// no hierarchy of its own, and — by design — no goals, actions, or facets.
class _RelationshipDetailsPanel extends StatelessWidget {
  const _RelationshipDetailsPanel({
    required this.relationship,
    required this.graph,
    required this.onNodeSelected,
    required this.onClose,
    required this.onExploreHere,
  });

  final StudioRelationship relationship;
  final StudioSystemGraph graph;
  final ValueChanged<String> onNodeSelected;
  final VoidCallback onClose;
  final VoidCallback onExploreHere;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final source = graph.nodeById(relationship.sourceId);
    final target = graph.nodeById(relationship.targetId);

    return Material(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.compare_arrows_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relationship.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Relationship · ${relationship.type.name}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hide details',
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(
                  title: 'Meaning',
                  icon: Icons.info_outline,
                  child: Text(
                    relationship.description.trim().isEmpty
                        ? 'No description has been supplied.'
                        : relationship.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Connects',
                  icon: Icons.hub_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RelationshipEndpointTile(
                        roleLabel: 'Source',
                        nodeId: relationship.sourceId,
                        node: source,
                        onNodeSelected: onNodeSelected,
                      ),
                      _RelationshipEndpointTile(
                        roleLabel: 'Target',
                        nodeId: relationship.targetId,
                        node: target,
                        onNodeSelected: onNodeSelected,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Character',
                  icon: Icons.tune_outlined,
                  child: _MetadataList(
                    metadata: {
                      'type': relationship.type.name,
                      'direction': relationship.direction.name,
                      'strength': relationship.strength.name,
                    },
                  ),
                ),
                if (relationship.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Tags',
                    icon: Icons.sell_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: relationship.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ),
                ],
                if (relationship.metadata.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Section(
                    title: 'System Information',
                    icon: Icons.data_object_outlined,
                    child: _MetadataList(metadata: relationship.metadata),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Actions',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: onExploreHere,
                  icon: const Icon(Icons.center_focus_strong_outlined),
                  label: const Text('Explore Here'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipEndpointTile extends StatelessWidget {
  const _RelationshipEndpointTile({
    required this.roleLabel,
    required this.nodeId,
    required this.node,
    required this.onNodeSelected,
  });

  final String roleLabel;
  final String nodeId;
  final StudioGraphNode? node;
  final ValueChanged<String> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final resolved = node;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        resolved == null
            ? Icons.help_outline
            : _iconForNodeType(resolved.type),
      ),
      title: Text(resolved?.label ?? nodeId),
      subtitle: Text(
        resolved == null
            ? '$roleLabel · not present in this view'
            : '$roleLabel · ${_displayNodeType(resolved.type)}',
      ),
      trailing: resolved == null ? null : const Icon(Icons.chevron_right),
      onTap: resolved == null ? null : () => onNodeSelected(resolved.id),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.node, required this.onClose});

  final StudioGraphNode node;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconForNodeType(node.type),
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _displayNodeType(node.type),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  node.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hide Insight Panel',
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _HierarchyPath extends StatelessWidget {
  const _HierarchyPath({
    required this.ancestors,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  final List<StudioGraphNode> ancestors;
  final StudioGraphNode selectedNode;
  final ValueChanged<String> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final ancestor in ancestors.reversed) ...[
          ActionChip(
            avatar: Icon(_iconForNodeType(ancestor.type), size: 16),
            label: Text(ancestor.label),
            onPressed: () => onNodeSelected(ancestor.id),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
        Chip(
          avatar: Icon(_iconForNodeType(selectedNode.type), size: 16),
          label: Text(selectedNode.label),
        ),
      ],
    );
  }
}

class _NodeList extends StatelessWidget {
  const _NodeList({required this.nodes, required this.onNodeSelected});

  final List<StudioGraphNode> nodes;
  final ValueChanged<String> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: nodes.map((node) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(_iconForNodeType(node.type), size: 20),
          title: Text(node.label),
          subtitle: Text(_displayNodeType(node.type)),
          trailing: const Icon(Icons.chevron_right, size: 19),
          onTap: () => onNodeSelected(node.id),
        );
      }).toList(),
    );
  }
}

class _RelationshipGroup extends StatelessWidget {
  const _RelationshipGroup({
    required this.title,
    required this.relationships,
    required this.selectedNode,
    required this.graph,
    required this.onNodeSelected,
  });

  final String title;
  final List<StudioRelationship> relationships;
  final StudioGraphNode selectedNode;
  final StudioSystemGraph graph;
  final ValueChanged<String> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        for (final relationship in relationships)
          _RelationshipTile(
            relationship: relationship,
            selectedNode: selectedNode,
            graph: graph,
            onNodeSelected: onNodeSelected,
          ),
      ],
    );
  }
}

class _RelationshipTile extends StatelessWidget {
  const _RelationshipTile({
    required this.relationship,
    required this.selectedNode,
    required this.graph,
    required this.onNodeSelected,
  });

  final StudioRelationship relationship;
  final StudioGraphNode selectedNode;
  final StudioSystemGraph graph;
  final ValueChanged<String> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final otherId = relationship.otherEndpoint(selectedNode.id);
    final otherNode = otherId == null ? null : graph.nodeById(otherId);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.compare_arrows_outlined, size: 20),
      title: Text(
        relationship.label.trim().isEmpty
            ? relationship.type.name
            : relationship.label,
      ),
      subtitle: Text(otherNode?.label ?? otherId ?? 'Unknown element'),
      trailing: otherNode == null
          ? null
          : const Icon(Icons.chevron_right, size: 19),
      onTap: otherNode == null ? null : () => onNodeSelected(otherNode.id),
    );
  }
}

class _MetadataList extends StatelessWidget {
  const _MetadataList({required this.metadata});

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
                width: 130,
                child: Text(
                  _displayMetadataKey(entry.key),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  _formatValue(entry.value),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.controller,
    required this.selectedNode,
    required this.onExploreHere,
    required this.onOpenOverview,
    required this.onOpenArchitecture,
    required this.onOpenExplore,
  });

  final WorkspaceController controller;
  final StudioGraphNode selectedNode;
  final VoidCallback? onExploreHere;
  final VoidCallback? onOpenOverview;
  final VoidCallback? onOpenArchitecture;
  final VoidCallback? onOpenExplore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Actions',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed:
              onExploreHere ?? () => controller.focusNodeById(selectedNode.id),
          icon: const Icon(Icons.center_focus_strong_outlined),
          label: const Text('Explore Here'),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (onOpenOverview != null)
              OutlinedButton.icon(
                onPressed: onOpenOverview,
                icon: const Icon(Icons.dashboard_outlined),
                label: const Text('Overview'),
              ),
            if (onOpenArchitecture != null)
              OutlinedButton.icon(
                onPressed: onOpenArchitecture,
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Architecture'),
              ),
            if (onOpenExplore != null)
              OutlinedButton.icon(
                onPressed: onOpenExplore,
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Explore'),
              ),
          ],
        ),
      ],
    );
  }
}

class _EmptyDetailsPanel extends StatelessWidget {
  const _EmptyDetailsPanel();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Select a system element to inspect it.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Package metadata plus the node's typed semantics, for display.
///
/// Typed semantics are appended so that the ordering users already see is
/// preserved.
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

String _displayMetadataKey(String key) {
  final buffer = StringBuffer();

  for (var index = 0; index < key.length; index++) {
    final character = key[index];

    if (index > 0 &&
        character.toUpperCase() == character &&
        character.toLowerCase() != character) {
      buffer.write(' ');
    }

    buffer.write(character);
  }

  final result = buffer.toString().trim();

  if (result.isEmpty) {
    return key;
  }

  return '${result[0].toUpperCase()}${result.substring(1)}';
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

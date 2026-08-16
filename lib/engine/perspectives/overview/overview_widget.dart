import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/perspectives/overview/overview_view_model.dart';
import 'package:systems_studio/engine/theme/spacing.dart';
import 'package:systems_studio/engine/graph/event_capability.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/ui/widgets/facets/node_facets_view.dart';
import 'package:systems_studio/engine/ui/widgets/state/node_state_view.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({
    super.key,
    required this.model,
    required this.graph,
    required this.onNodeSelected,
  });

  final OverviewViewModel model;
  final StudioSystemGraph graph;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return ListView(
      padding: EdgeInsets.all(spacing.md),
      children: [
        _SelectedElementHero(node: model.selectedNode),
        SizedBox(height: spacing.md),

        _OverviewCard(
          title: 'Purpose and Description',
          icon: Icons.info_outline,
          child: Text(
            model.hasDescription
                ? model.selectedNode.description
                : 'No description has been supplied.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),

        SizedBox(height: spacing.md),
        _OverviewCard(
          title: 'Element Facets',
          icon: Icons.help_outline,
          child: NodeFacetsView(
            facets: model.facets,
            eventCapability: StudioEventCapabilityIndex.forGraph(
              graph,
            ).capabilityFor(StudioElementRef.node(model.selectedNode.id)),
          ),
        ),

        SizedBox(height: spacing.md),
        _OverviewCard(
          title: 'Declared State',
          icon: Icons.toggle_on_outlined,
          child: NodeStateView(
            variables: graph.stateVariablesFor(
              StudioElementRef.node(model.selectedNode.id),
            ),
          ),
        ),

        if (model.parent != null || model.ancestors.isNotEmpty) ...[
          SizedBox(height: spacing.md),
          _HierarchyContextCard(model: model, onNodeSelected: onNodeSelected),
        ],

        if (model.architecturalChildren.isNotEmpty) ...[
          SizedBox(height: spacing.md),
          _NodeSectionCard(
            title: 'Contained Elements',
            subtitle: 'The architectural elements directly contained here.',
            icon: Icons.account_tree_outlined,
            nodes: model.architecturalChildren,
            onNodeSelected: onNodeSelected,
          ),
        ],

        if (model.hasContextElements) ...[
          SizedBox(height: spacing.md),
          _OverviewCard(
            title: 'System Context',
            icon: Icons.hub_outlined,
            child: _CategoryGrid(
              categories: [
                _NodeCategory(
                  title: 'Actors',
                  icon: Icons.people_outline,
                  nodes: model.actors,
                ),
                _NodeCategory(
                  title: 'Assets',
                  icon: Icons.inventory_2_outlined,
                  nodes: model.assets,
                ),
                _NodeCategory(
                  title: 'Inputs',
                  icon: Icons.input_outlined,
                  nodes: model.inputs,
                ),
                _NodeCategory(
                  title: 'Outputs',
                  icon: Icons.output_outlined,
                  nodes: model.outputs,
                ),
                _NodeCategory(
                  title: 'Interfaces',
                  icon: Icons.compare_arrows_outlined,
                  nodes: model.interfaces,
                ),
                _NodeCategory(
                  title: 'Boundaries',
                  icon: Icons.border_outer_outlined,
                  nodes: model.boundaries,
                ),
              ],
              onNodeSelected: onNodeSelected,
            ),
          ),
        ],

        if (model.hasAnalysisElements) ...[
          SizedBox(height: spacing.md),
          _OverviewCard(
            title: 'Analysis and Exploration',
            icon: Icons.analytics_outlined,
            child: _CategoryGrid(
              categories: [
                _NodeCategory(
                  title: 'Failure Modes',
                  icon: Icons.warning_amber_outlined,
                  nodes: model.failureModes,
                ),
                _NodeCategory(
                  title: 'Controls',
                  icon: Icons.shield_outlined,
                  nodes: model.controls,
                ),
                _NodeCategory(
                  title: 'Incidents',
                  icon: Icons.crisis_alert_outlined,
                  nodes: model.incidents,
                ),
                _NodeCategory(
                  title: 'Simulations',
                  icon: Icons.science_outlined,
                  nodes: model.simulations,
                ),
                _NodeCategory(
                  title: 'References',
                  icon: Icons.menu_book_outlined,
                  nodes: model.references,
                ),
              ],
              onNodeSelected: onNodeSelected,
            ),
          ),
        ],

        if (model.hasRelationships) ...[
          SizedBox(height: spacing.md),
          _RelationshipsCard(
            model: model,
            graph: graph,
            onNodeSelected: onNodeSelected,
          ),
        ],

        if (model.hasSystemInformation) ...[
          SizedBox(height: spacing.md),
          _OverviewCard(
            title: 'System Information',
            icon: Icons.data_object_outlined,
            child: _MetadataView(metadata: model.systemInformation),
          ),
        ],

        SizedBox(height: spacing.xl),
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
        border: Border.all(color: color.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
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
                    fontWeight: FontWeight.w800,
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
                SizedBox(height: spacing.xs),
                SelectableText(
                  node.id,
                  style: text.labelMedium?.copyWith(
                    color: color.onPrimaryContainer.withValues(alpha: 0.75),
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

class _HierarchyContextCard extends StatelessWidget {
  const _HierarchyContextCard({
    required this.model,
    required this.onNodeSelected,
  });

  final OverviewViewModel model;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return _OverviewCard(
      title: 'System Location',
      icon: Icons.route_outlined,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final node in model.ancestors.reversed) ...[
            ActionChip(
              avatar: Icon(_iconForNodeType(node.type), size: 17),
              label: Text(node.label),
              onPressed: () => onNodeSelected(node),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
          Chip(
            avatar: Icon(_iconForNodeType(model.selectedNode.type), size: 17),
            label: Text(model.selectedNode.label),
          ),
        ],
      ),
    );
  }
}

class _NodeSectionCard extends StatelessWidget {
  const _NodeSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.nodes,
    required this.onNodeSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<StudioGraphNode> nodes;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return _OverviewCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      child: Column(
        children: nodes.map((node) {
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
    );
  }
}

class _NodeCategory {
  const _NodeCategory({
    required this.title,
    required this.icon,
    required this.nodes,
  });

  final String title;
  final IconData icon;
  final List<StudioGraphNode> nodes;
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.onNodeSelected});

  final List<_NodeCategory> categories;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final visibleCategories = categories
        .where((category) => category.nodes.isNotEmpty)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 700;
        final cardWidth = useTwoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: visibleCategories.map((category) {
            return SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(category.icon, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '${category.nodes.length}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final node in category.nodes)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(_iconForNodeType(node.type), size: 19),
                          title: Text(node.label),
                          trailing: const Icon(Icons.chevron_right, size: 19),
                          onTap: () => onNodeSelected(node),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _RelationshipsCard extends StatelessWidget {
  const _RelationshipsCard({
    required this.model,
    required this.graph,
    required this.onNodeSelected,
  });

  final OverviewViewModel model;
  final StudioSystemGraph graph;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return _OverviewCard(
      title: 'Relationships',
      subtitle:
          'How the selected element interacts with the surrounding system.',
      icon: Icons.link_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.incomingRelationships.isNotEmpty)
            _RelationshipGroup(
              title: 'Incoming',
              icon: Icons.call_received_outlined,
              relationships: model.incomingRelationships,
              selectedNode: model.selectedNode,
              graph: graph,
              onNodeSelected: onNodeSelected,
            ),
          if (model.incomingRelationships.isNotEmpty &&
              model.outgoingRelationships.isNotEmpty)
            const Divider(height: 28),
          if (model.outgoingRelationships.isNotEmpty)
            _RelationshipGroup(
              title: 'Outgoing',
              icon: Icons.call_made_outlined,
              relationships: model.outgoingRelationships,
              selectedNode: model.selectedNode,
              graph: graph,
              onNodeSelected: onNodeSelected,
            ),
          if (model.otherRelationships.isNotEmpty) ...[
            const Divider(height: 28),
            _RelationshipGroup(
              title: 'Other Connections',
              icon: Icons.sync_alt_outlined,
              relationships: model.otherRelationships,
              selectedNode: model.selectedNode,
              graph: graph,
              onNodeSelected: onNodeSelected,
            ),
          ],
        ],
      ),
    );
  }
}

class _RelationshipGroup extends StatelessWidget {
  const _RelationshipGroup({
    required this.title,
    required this.icon,
    required this.relationships,
    required this.selectedNode,
    required this.graph,
    required this.onNodeSelected,
  });

  final String title;
  final IconData icon;
  final List<StudioRelationship> relationships;
  final StudioGraphNode selectedNode;
  final StudioSystemGraph graph;
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
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
  final ValueChanged<StudioGraphNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final otherId = relationship.otherEndpoint(selectedNode.id);
    final otherNode = otherId == null ? null : graph.nodeById(otherId);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.compare_arrows_outlined),
      title: Text(
        relationship.label.isEmpty
            ? relationship.type.name
            : relationship.label,
      ),
      subtitle: Text(otherNode?.label ?? otherId ?? 'Unknown element'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            relationship.type.name,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          if (otherNode != null) const Icon(Icons.chevron_right),
        ],
      ),
      onTap: otherNode == null ? null : () => onNodeSelected(otherNode),
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
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: Text(
                  _displayMetadataKey(entry.key),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: SelectableText(_formatValue(entry.value))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: spacing.xs),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
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

    if (index > 0 && character.toUpperCase() == character) {
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

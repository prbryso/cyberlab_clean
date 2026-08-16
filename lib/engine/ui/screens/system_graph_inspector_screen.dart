import 'package:flutter/material.dart';

import 'package:systems_studio/engine/graph/event_capability.dart';
import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/services/studio_system_detail_registry.dart';
import 'package:systems_studio/engine/theme/spacing.dart';
import 'package:systems_studio/engine/ui/widgets/facets/node_facets_view.dart';
import 'package:systems_studio/engine/ui/widgets/state/node_state_view.dart';
import 'package:systems_studio/engine/ui/widgets/graphs/system_graph_canvas.dart';
import 'package:systems_studio/engine/ui/workspace/studio_graph_view_controller.dart';

class SystemGraphInspectorScreen extends StatefulWidget {
  const SystemGraphInspectorScreen({
    super.key,
    required this.systemId,
    required this.title,
  });

  final String systemId;
  final String title;

  @override
  State<SystemGraphInspectorScreen> createState() =>
      _SystemGraphInspectorScreenState();
}

class _SystemGraphInspectorScreenState
    extends State<SystemGraphInspectorScreen> {
  static const StudioGraphEngine _graphEngine = StudioGraphEngine();

  final TextEditingController _searchController = TextEditingController();

  late final StudioGraphViewController _graphViewController;

  StudioGraphNode? _selectedNode;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _graphViewController = StudioGraphViewController();
    _graphViewController.expand(widget.systemId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _graphViewController.dispose();

    super.dispose();
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
        body: _GraphBuildError(systemId: widget.systemId, error: error),
      );
    }

    final validation = _graphEngine.validate(session.graph);
    final visibleNodes = _filteredNodes(session.graph);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} — System Map')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useTwoColumns = constraints.maxWidth >= 900;

          if (useTwoColumns) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildMainPanel(
                    context: context,
                    graph: session.graph,
                    validation: validation,
                    visibleNodes: visibleNodes,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 2,
                  child: _NodeDetailsPanel(
                    graph: session.graph,
                    node: _selectedNode,
                  ),
                ),
              ],
            );
          }

          return _buildMainPanel(
            context: context,
            graph: session.graph,
            validation: validation,
            visibleNodes: visibleNodes,
            showInlineDetails: true,
          );
        },
      ),
    );
  }

  Widget _buildMainPanel({
    required BuildContext context,
    required StudioSystemGraph graph,
    required StudioGraphValidationResult validation,
    required List<StudioGraphNode> visibleNodes,
    bool showInlineDetails = false,
  }) {
    final spacing = CyberLabSpacing.of(context);

    return ListView(
      padding: EdgeInsets.all(spacing.md),
      children: [
        _GraphSummaryCard(graph: graph, validation: validation),
        SizedBox(height: spacing.md),
        SizedBox(
          height: 620,
          child: SystemGraphCanvas(
            graph: graph,
            controller: _graphViewController,
            // This screen inspects nodes only, so no relationship callback is
            // supplied and edges remain non-tappable here.
            selectedElement: switch (_selectedNode) {
              final node? => StudioElementRef.node(node.id),
              null => null,
            },
            onNodeSelected: (node) {
              setState(() {
                _selectedNode = node;
              });
            },
          ),
        ),
        SizedBox(height: spacing.md),
        _NodeTypeSummary(graph: graph),
        SizedBox(height: spacing.md),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search system elements',
            hintText: 'Actor, asset, component, failure, incident...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();

                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        SizedBox(height: spacing.md),
        _SectionHeading(
          title: 'System Elements',
          subtitle:
              '${visibleNodes.length} of ${graph.nodes.length} nodes shown',
        ),
        SizedBox(height: spacing.sm),
        ...visibleNodes.map(
          (node) => Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: _NodeCard(
              node: node,
              relationshipCount: graph.relationshipsFor(node.id).length,
              selected: _selectedNode?.id == node.id,
              onTap: () {
                setState(() {
                  _selectedNode = node;
                });
              },
            ),
          ),
        ),
        if (visibleNodes.isEmpty) const _EmptySearchResult(),
        if (showInlineDetails && _selectedNode != null) ...[
          SizedBox(height: spacing.lg),
          _SectionHeading(
            title: 'Selected Element',
            subtitle: _selectedNode!.label,
          ),
          SizedBox(height: spacing.sm),
          _NodeDetailsPanel(graph: graph, node: _selectedNode, embedded: true),
        ],
      ],
    );
  }

  List<StudioGraphNode> _filteredNodes(StudioSystemGraph graph) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return graph.nodes;
    }

    return graph.nodes.where((node) {
      final searchableValues = <String>[
        node.id,
        node.label,
        node.description,
        node.type.name,
        ...node.tags,
        ...node.semanticSearchValues(),
        ...graph
            .stateVariablesFor(StudioElementRef.node(node.id))
            .expand((variable) => [variable.name, ...variable.domain]),
        ...node.metadata.entries.expand(
          (entry) => [entry.key, entry.value.toString()],
        ),
      ];

      return searchableValues.any(
        (value) => value.toLowerCase().contains(query),
      );
    }).toList();
  }
}

class _GraphSummaryCard extends StatelessWidget {
  const _GraphSummaryCard({required this.graph, required this.validation});

  final StudioSystemGraph graph;
  final StudioGraphValidationResult validation;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final color = theme.colorScheme;

    final isValid = validation.isValid;

    // Structural problems only. Open questions are shown separately below.
    final defects = validation.issues
        .where(
          (issue) => issue.severity != StudioGraphValidationSeverity.info,
        )
        .toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 34,
                  color: color.primary,
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Graph',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        graph.systemId,
                        style: text.bodyMedium?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  avatar: Icon(
                    isValid ? Icons.check_circle_outline : Icons.error_outline,
                    size: 18,
                  ),
                  label: Text(isValid ? 'Valid' : 'Errors Found'),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.lg,
              runSpacing: spacing.sm,
              children: [
                _SummaryValue(label: 'Nodes', value: '${graph.nodes.length}'),
                _SummaryValue(
                  label: 'Relationships',
                  value: '${graph.relationships.length}',
                ),
                _SummaryValue(
                  label: 'Warnings',
                  value: '${validation.warnings.length}',
                ),
                _SummaryValue(
                  label: 'Errors',
                  value: '${validation.errors.length}',
                ),
                _SummaryValue(
                  label: 'Open questions',
                  value: '${validation.openQuestions.length}',
                ),
              ],
            ),
            if (defects.isNotEmpty) ...[
              SizedBox(height: spacing.md),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: const Text('Validation Findings'),
                children: defects.map((issue) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      issue.severity == StudioGraphValidationSeverity.error
                          ? Icons.error_outline
                          : Icons.warning_amber_outlined,
                    ),
                    title: Text(issue.message),
                    subtitle: Text(issue.code),
                  );
                }).toList(),
              ),
            ],
            // Unknown facets are listed separately. They are not defects —
            // they are the parts of the system this model has not answered
            // yet, and mixing them into the findings list would bury the
            // structural problems that need fixing.
            if (validation.infos.isNotEmpty) ...[
              SizedBox(height: spacing.sm),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: const Text('Open Questions'),
                subtitle: const Text(
                  'What this system model does not yet describe',
                ),
                children: validation.infos.map((issue) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.help_outline),
                    title: Text(issue.message),
                    subtitle: Text(issue.elementId ?? issue.code),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: text.headlineSmall?.copyWith(
            color: color.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: text.bodyMedium?.copyWith(color: color.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _NodeTypeSummary extends StatelessWidget {
  const _NodeTypeSummary({required this.graph});

  final StudioSystemGraph graph;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final counts = <StudioGraphNodeType, int>{};

    for (final node in graph.nodes) {
      counts.update(node.type, (value) => value + 1, ifAbsent: () => 1);
    }

    final entries = counts.entries.toList()
      ..sort((left, right) => left.key.name.compareTo(right.key.name));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Graph Composition',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: entries.map((entry) {
                return Chip(
                  avatar: Icon(_iconForNodeType(entry.key), size: 18),
                  label: Text('${_displayNodeType(entry.key)}: ${entry.value}'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.node,
    required this.relationshipCount,
    required this.selected,
    required this.onTap,
  });

  final StudioGraphNode node;
  final int relationshipCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      color: selected ? color.primaryContainer : null,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(_iconForNodeType(node.type))),
        title: Text(
          node.label,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          node.description.isEmpty
              ? _displayNodeType(node.type)
              : node.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$relationshipCount',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Text('links'),
          ],
        ),
      ),
    );
  }
}

class _NodeDetailsPanel extends StatelessWidget {
  const _NodeDetailsPanel({
    required this.graph,
    required this.node,
    this.embedded = false,
  });

  final StudioSystemGraph graph;
  final StudioGraphNode? node;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    if (node == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Select a system element to inspect its metadata and relationships.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final relationships = graph.relationshipsFor(node!.id);

    final content = ListView(
      padding: EdgeInsets.all(spacing.md),
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      children: [
        _NodeHeader(node: node!),
        SizedBox(height: spacing.md),
        if (node!.description.isNotEmpty)
          _DetailCard(title: 'Description', child: Text(node!.description)),
        if (node!.parentId != null) ...[
          SizedBox(height: spacing.sm),
          _DetailCard(
            title: 'Parent',
            child: Text(
              graph.nodeById(node!.parentId!)?.label ?? node!.parentId!,
            ),
          ),
        ],
        SizedBox(height: spacing.sm),
        _DetailCard(
          title: 'Element Facets',
          child: NodeFacetsView(
            facets: node!.facets,
            eventCapability: StudioEventCapabilityIndex.forGraph(
              graph,
            ).capabilityFor(StudioElementRef.node(node!.id)),
          ),
        ),
        SizedBox(height: spacing.sm),
        _DetailCard(
          title: 'Declared State',
          child: NodeStateView(
            variables: graph.stateVariablesFor(
              StudioElementRef.node(node!.id),
            ),
          ),
        ),
        if (node!.tags.isNotEmpty) ...[
          SizedBox(height: spacing.sm),
          _DetailCard(
            title: 'Tags',
            child: Wrap(
              spacing: spacing.xs,
              runSpacing: spacing.xs,
              children: node!.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
          ),
        ],
        if (_systemInformation(node!).isNotEmpty) ...[
          SizedBox(height: spacing.sm),
          _MetadataCard(metadata: _systemInformation(node!)),
        ],
        SizedBox(height: spacing.sm),
        _RelationshipCard(
          graph: graph,
          node: node!,
          relationships: relationships,
        ),
      ],
    );

    if (embedded) {
      return Card(child: content);
    }

    return content;
  }
}

class _NodeHeader extends StatelessWidget {
  const _NodeHeader({required this.node});

  final StudioGraphNode node;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(spacing.md),
      ),
      child: Row(
        children: [
          Icon(
            _iconForNodeType(node.type),
            size: 38,
            color: color.onPrimaryContainer,
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.label,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color.onPrimaryContainer,
                  ),
                ),
                Text(
                  _displayNodeType(node.type),
                  style: text.bodyMedium?.copyWith(
                    color: color.onPrimaryContainer,
                  ),
                ),
                Text(
                  node.id,
                  style: text.labelSmall?.copyWith(
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

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});

  final String title;
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
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

/// Package metadata plus the node's typed semantics, for display.
Map<String, Object?> _systemInformation(StudioGraphNode node) {
  return {...node.metadata, ...node.semanticSummary()};
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.metadata});

  final Map<String, Object?> metadata;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return _DetailCard(
      title: 'Metadata',
      child: Column(
        children: metadata.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Text(_formatMetadataValue(entry.value))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RelationshipCard extends StatelessWidget {
  const _RelationshipCard({
    required this.graph,
    required this.node,
    required this.relationships,
  });

  final StudioSystemGraph graph;
  final StudioGraphNode node;
  final List<StudioRelationship> relationships;

  @override
  Widget build(BuildContext context) {
    if (relationships.isEmpty) {
      return const _DetailCard(
        title: 'Relationships',
        child: Text('No relationships are currently registered.'),
      );
    }

    return _DetailCard(
      title: 'Relationships',
      child: Column(
        children: relationships.map((relationship) {
          final otherId = relationship.otherEndpoint(node.id);
          final otherNode = otherId == null ? null : graph.nodeById(otherId);

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_iconForRelationshipType(relationship.type)),
            title: Text(relationship.label),
            subtitle: Text(otherNode?.label ?? otherId ?? 'Unknown element'),
            trailing: Text(relationship.type.name),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: text.bodyMedium?.copyWith(color: color.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No system elements match this search.')),
      ),
    );
  }
}

class _GraphBuildError extends StatelessWidget {
  const _GraphBuildError({required this.systemId, required this.error});

  final String systemId;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to build the system graph for "$systemId".',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SelectableText(error.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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

IconData _iconForRelationshipType(StudioRelationshipType type) {
  return switch (type) {
    StudioRelationshipType.protects ||
    StudioRelationshipType.prevents ||
    StudioRelationshipType.mitigates => Icons.shield_outlined,
    StudioRelationshipType.threatens ||
    StudioRelationshipType.exploits ||
    StudioRelationshipType.exposes => Icons.warning_amber_outlined,
    StudioRelationshipType.monitors ||
    StudioRelationshipType.detects => Icons.visibility_outlined,
    StudioRelationshipType.contains => Icons.account_tree_outlined,
    StudioRelationshipType.sendsDataTo ||
    StudioRelationshipType.communicatesWith => Icons.swap_horiz_outlined,
    StudioRelationshipType.controls ||
    StudioRelationshipType.sendsCommandTo => Icons.tune_outlined,
    _ => Icons.link_outlined,
  };
}

String _formatMetadataValue(Object? value) {
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

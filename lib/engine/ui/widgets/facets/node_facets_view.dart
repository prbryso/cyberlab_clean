import 'package:flutter/material.dart';

import 'package:systems_studio/engine/graph/event_capability.dart';
import 'package:systems_studio/engine/models/studio_event_type.dart';
import 'package:systems_studio/engine/models/studio_facets.dart';

/// Renders the four declared facets of an element, including their epistemic
/// status.
///
/// All four facets are always shown. A facet that is unknown is as much a
/// statement about the system model as one that is known — PRODUCT_PRINCIPLES
/// asks Systems Studio to expose unknowns as places worthy of investigation,
/// which is only possible if they are visible.
///
/// Relationships are deliberately absent. They are a derived facet, read from
/// the graph rather than declared on an element.
class NodeFacetsView extends StatelessWidget {
  const NodeFacetsView({
    super.key,
    required this.facets,
    this.eventCapability,
  });

  final StudioNodeFacets facets;

  /// Event involvement derived from typed declarations.
  ///
  /// When this has content it replaces the Events facet entirely: typed
  /// declarations are authoritative, and showing authored prose beside them
  /// would present two answers to the same question.
  final StudioEventCapability? eventCapability;

  bool get _hasDerivedEvents => eventCapability?.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final entries = facets.entries().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          if (index > 0) const SizedBox(height: 14),
          if (entries[index].key == StudioFacetKind.eventTypes &&
              _hasDerivedEvents)
            _DerivedEventsRow(capability: eventCapability!)
          else
            _FacetRow(kind: entries[index].key, facet: entries[index].value),
        ],
      ],
    );
  }
}

/// The Events facet, derived from typed declarations rather than prose.
///
/// The three questions stay separate. What an element causes, what it reacts
/// to, and what it deliberately reports are different things to know about it,
/// and a monitor is the clearest case: it detects failures, generates alerts,
/// and reports only the alerts.
class _DerivedEventsRow extends StatelessWidget {
  const _DerivedEventsRow({required this.capability});

  final StudioEventCapability capability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                StudioFacetKind.eventTypes.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Declared',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _EventGroup(label: 'Generates', types: capability.generates),
        _EventGroup(label: 'Detects', types: capability.detects),
        _EventGroup(label: 'Reports', types: capability.reports),
      ],
    );
  }
}

class _EventGroup extends StatelessWidget {
  const _EventGroup({required this.label, required this.types});

  final String label;
  final List<StudioEventType> types;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final type in types)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      type.name,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
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

class _FacetRow extends StatelessWidget {
  const _FacetRow({required this.kind, required this.facet});

  final StudioFacetKind kind;
  final StudioFacet<List<String>> facet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final values = facet.value ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                kind.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FacetStatusChip(status: facet.status),
          ],
        ),
        const SizedBox(height: 4),
        if (facet.isKnown)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final value in values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            value,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        else
          Text(
            switch (facet.status) {
              StudioFacetStatus.notApplicable =>
                'This question does not apply to this element.',
              StudioFacetStatus.unknown => kind.question,
              StudioFacetStatus.known => '',
            },
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: facet.isUnknown ? FontStyle.italic : FontStyle.normal,
              height: 1.35,
            ),
          ),
      ],
    );
  }
}

/// Small badge showing whether a facet is known, not applicable, or unknown.
class FacetStatusChip extends StatelessWidget {
  const FacetStatusChip({super.key, required this.status});

  final StudioFacetStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (label, foreground, background) = switch (status) {
      StudioFacetStatus.known => (
        'Known',
        colorScheme.onPrimaryContainer,
        colorScheme.primaryContainer,
      ),
      StudioFacetStatus.notApplicable => (
        'Not applicable',
        colorScheme.onSurfaceVariant,
        colorScheme.surfaceContainerHighest,
      ),
      StudioFacetStatus.unknown => (
        'Unknown',
        colorScheme.onTertiaryContainer,
        colorScheme.tertiaryContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// One-line summary of how much of an element has been described.
///
/// Example: "2 of 4 answered".
class FacetCoverageLabel extends StatelessWidget {
  const FacetCoverageLabel({super.key, required this.facets});

  final StudioNodeFacets facets;

  @override
  Widget build(BuildContext context) {
    final total = StudioFacetKind.values.length;

    final answered = facets
        .entries()
        .where((entry) => !entry.value.isUnknown)
        .length;

    return Text(
      '$answered of $total answered',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

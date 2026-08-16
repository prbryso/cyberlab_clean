import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/perspectives/actor/actor_perspective_view.dart';
import 'package:systems_studio/engine/perspectives/studio_perspective.dart';

/// Renders what one actor currently knows.
///
/// A pure renderer: it displays an [ActorPerspectiveView] and nothing else. It
/// does not consult the run, the graph state, or the evaluator, so it cannot
/// show anything the perspective decided the actor does not know. Fidelity is
/// enforced upstream by omission — a withheld source is absent from the view
/// model, not hidden here.
class ActorPerspectiveRenderer extends StatelessWidget {
  const ActorPerspectiveRenderer({
    super.key,
    required this.view,
    required this.graph,
    this.onOpenActions,
    this.onElementSelected,
  });

  final ActorPerspectiveView view;

  /// Used only to turn element IDs into readable labels.
  final StudioSystemGraph graph;

  /// Opens the actions list. Null hides the control entirely.
  final VoidCallback? onOpenActions;

  final ValueChanged<StudioElementRef>? onElementSelected;

  String _label(StudioElementRef ref) =>
      graph.labelForElement(ref) ?? ref.id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const Key('actor-perspective'),
      padding: const EdgeInsets.all(16),
      children: [
        _Header(view: view),
        const SizedBox(height: 16),

        if (view.goalsAreKnown)
          _Section(
            title: 'Goals',
            icon: Icons.flag_outlined,
            child: _Bullets(values: view.goals),
          )
        else
          _Section(
            title: 'Goals',
            icon: Icons.flag_outlined,
            child: Text(
              'Not described for this participant.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        const SizedBox(height: 16),
        _Section(
          title: 'Knows about',
          icon: Icons.visibility_outlined,
          subtitle: 'Parts of the system this participant has learned about.',
          child: _ElementChips(
            refs: view.knownElements,
            label: _label,
            onSelected: onElementSelected,
            emptyMessage: 'Nothing yet.',
          ),
        ),

        const SizedBox(height: 16),
        // Deliberately a separate section. What someone has learned and what
        // they are merely positioned to learn are different claims, and
        // merging them would overstate what the participant knows.
        _Section(
          title: 'Could observe',
          icon: Icons.radar_outlined,
          subtitle:
              'Parts of the system that could reach this participant, whether '
              'or not anything has.',
          child: _ElementChips(
            refs: view.observableElements,
            label: _label,
            onSelected: onElementSelected,
            emptyMessage: 'Nothing is connected to this participant.',
          ),
        ),

        const SizedBox(height: 16),
        _Section(
          title: 'Observations received',
          icon: Icons.hearing_outlined,
          child: view.observedEvents.isEmpty
              ? Text(
                  'Nothing has reached this participant.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : Column(
                  children: [
                    for (final event in view.observedEvents)
                      _ObservationTile(
                        event: event,
                        label: _label,
                      ),
                  ],
                ),
        ),

        const SizedBox(height: 16),
        _Section(
          title: 'State visible',
          icon: Icons.toggle_on_outlined,
          child: view.visibleState.isEmpty
              ? Text(
                  'No state is visible to this participant yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in view.visibleState)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${_label(entry.owner)} · ${entry.name}: '
                          '${entry.value}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
        ),

        const SizedBox(height: 20),
        _ActionsControl(view: view, onOpenActions: onOpenActions),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Shown when a perspective declines to describe the selection.
///
/// Says what it cannot describe and why, rather than describing something
/// else. Selecting a relationship and being shown one of its endpoints would
/// be a quiet lie about what is on screen.
class PerspectiveUnsupportedView extends StatelessWidget {
  const PerspectiveUnsupportedView({super.key, required this.view});

  final StudioPerspectiveUnsupported view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      key: const Key('perspective-unsupported'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              view.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.view});

  final ActorPerspectiveView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  view.actorName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              ActorRelevanceBadge(isRelevant: view.isRelevant),
            ],
          ),
          if (view.actorDescription.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              view.actorDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Whether an actor has become part of the current exploration.
class ActorRelevanceBadge extends StatelessWidget {
  const ActorRelevanceBadge({super.key, required this.isRelevant});

  final bool isRelevant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: Key(isRelevant ? 'relevance-active' : 'relevance-inactive'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRelevant
            ? colorScheme.tertiaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRelevant
                ? Icons.notifications_active_outlined
                : Icons.circle_outlined,
            size: 14,
            color: isRelevant
                ? colorScheme.onTertiaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            isRelevant ? 'Involved' : 'Not involved',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isRelevant
                  ? colorScheme.onTertiaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObservationTile extends StatelessWidget {
  const _ObservationTile({required this.event, required this.label});

  final ObservedEventView event;
  final String Function(StudioElementRef) label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final source = event.source;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.eventTypeName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: event.isFull
                      ? colorScheme.secondaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  event.isFull ? 'Full detail' : 'Aware only',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: event.isFull
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          // Everything below exists only when the view model carries it, which
          // it does only at full fidelity.
          if (source != null)
            Text(
              'At ${label(source)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          if (event.description != null)
            Text(
              event.description!,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
          if (event.explanation != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                event.explanation!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          if (event.channelRelationshipIds.isNotEmpty)
            Text(
              'Reached them via ${event.channelRelationshipIds.join(", ")}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          if (event.isExistenceOnly)
            Text(
              'They can tell something of this kind happened, but not where '
              'or why.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionsControl extends StatelessWidget {
  const _ActionsControl({required this.view, required this.onOpenActions});

  final ActorPerspectiveView view;
  final VoidCallback? onOpenActions;

  @override
  Widget build(BuildContext context) {
    if (onOpenActions == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final count = view.availableActions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const Key('actions-button'),
          onPressed: onOpenActions,
          icon: const Icon(Icons.play_circle_outline),
          label: Text(count == 0 ? 'ACTIONS' : 'ACTIONS ($count)'),
        ),
        if (count == 0) ...[
          const SizedBox(height: 6),
          Text(
            view.isRelevant
                ? 'Nothing is available to this participant right now.'
                : 'This participant is not involved yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final value in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text('• $value', style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _ElementChips extends StatelessWidget {
  const _ElementChips({
    required this.refs,
    required this.label,
    required this.onSelected,
    required this.emptyMessage,
  });

  final List<StudioElementRef> refs;
  final String Function(StudioElementRef) label;
  final ValueChanged<StudioElementRef>? onSelected;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (refs.isEmpty) {
      return Text(
        emptyMessage,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final ref in refs)
          ActionChip(
            label: Text(label(ref)),
            onPressed: onSelected == null ? null : () => onSelected!(ref),
          ),
      ],
    );
  }
}

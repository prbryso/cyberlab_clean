import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';

/// The generated causal record of what has happened, in reading order.
///
/// Every entry was produced by running the system. Nothing here was authored
/// as a sequence: there is no step list, no narration script, and no notion of
/// what comes next. The order is the order things happened.
///
/// Each entry answers "why did this happen?" by naming the occurrence that
/// triggered it, so the chain can be read downwards without needing a diagram.
class TraceView extends StatelessWidget {
  const TraceView({
    super.key,
    required this.entries,
    required this.graph,
    this.emptyMessage = 'Nothing has happened yet.',
  });

  final List<StudioTraceEntry> entries;

  /// Used only to turn element IDs and event type IDs into readable labels.
  final StudioSystemGraph graph;

  final String emptyMessage;

  String _label(StudioElementRef ref) => graph.labelForElement(ref) ?? ref.id;

  String _eventName(String typeId) =>
      graph.eventTypeById(typeId)?.name ?? typeId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Padding(
        key: const Key('trace-empty'),
        padding: const EdgeInsets.all(24),
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      key: const Key('trace-view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in entries)
          _TraceEntryTile(
            entry: entry,
            label: _label,
            eventName: _eventName,
          ),
      ],
    );
  }
}

class _TraceEntryTile extends StatelessWidget {
  const _TraceEntryTile({
    required this.entry,
    required this.label,
    required this.eventName,
  });

  final StudioTraceEntry entry;
  final String Function(StudioElementRef) label;
  final String Function(String) eventName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isAction = entry.kind == StudioTraceCauseKind.action;

    final trigger = entry.triggeringEvent;

    return Card(
      key: Key('trace-entry-${entry.sequence}'),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAction
                      ? Icons.touch_app_outlined
                      : Icons.settings_suggest_outlined,
                  size: 18,
                  color: isAction ? colorScheme.primary : colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.definitionName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  isAction ? 'chosen' : 'automatic',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              entry.target == null
                  ? label(entry.subject)
                  : '${label(entry.subject)} → ${label(entry.target!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            // The causal link. Only the chosen action lacks one.
            if (trigger != null)
              Text(
                'Because ${eventName(trigger.typeId)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),

            if (entry.explanation.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.explanation,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ],

            if (entry.stateChanges.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final change in entry.stateChanges)
                Text(
                  '${label(change.owner)} · ${change.variableId.split(".").last}'
                  ': ${change.previousValue} → ${change.newValue}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
            ],

            if (entry.emittedEvents.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final event in entry.emittedEvents)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        eventName(event.typeId),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ],

            if (entry.guidingQuestion.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.guidingQuestion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

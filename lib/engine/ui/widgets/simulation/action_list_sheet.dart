import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// The list of actions a participant could take right now.
///
/// Presentation only. It receives the actions the engine says are available
/// and reports back which one was chosen; it never evaluates a precondition,
/// consults state, or decides availability. An action reaching this list has
/// already been judged available by the run.
class ActionListSheet extends StatelessWidget {
  const ActionListSheet({
    super.key,
    required this.actorName,
    required this.actions,
    required this.graph,
    required this.onActionSelected,
    this.isRelevant = true,
  });

  final String actorName;

  /// Actions the run reports as currently available.
  final List<StudioActionDefinition> actions;

  /// Used only to turn target IDs into readable labels.
  final StudioSystemGraph graph;

  final ValueChanged<StudioActionDefinition> onActionSelected;

  final bool isRelevant;

  /// Opens the sheet and completes with the chosen action, or null.
  static Future<StudioActionDefinition?> show(
    BuildContext context, {
    required String actorName,
    required List<StudioActionDefinition> actions,
    required StudioSystemGraph graph,
    bool isRelevant = true,
  }) {
    return showModalBottomSheet<StudioActionDefinition>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ActionListSheet(
          actorName: actorName,
          actions: actions,
          graph: graph,
          isRelevant: isRelevant,
          onActionSelected: (action) =>
              Navigator.of(sheetContext).pop(action),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      key: const Key('action-list-sheet'),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'What $actorName could do now',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: actions.isEmpty
                  ? _EmptyActions(
                      actorName: actorName,
                      isRelevant: isRelevant,
                    )
                  : ListView.separated(
                      key: const Key('action-list'),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: actions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final action = actions[index];

                        final target =
                            graph.labelForElement(action.target) ??
                            action.target.id;

                        return ListTile(
                          key: Key('action-${action.id}'),
                          title: Text(action.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (action.description.trim().isNotEmpty)
                                Text(action.description),
                              const SizedBox(height: 2),
                              Text(
                                'Against: $target',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: action.description.trim().isNotEmpty,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => onActionSelected(action),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActions extends StatelessWidget {
  const _EmptyActions({required this.actorName, required this.isRelevant});

  final String actorName;
  final bool isRelevant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      key: const Key('action-list-empty'),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.do_not_disturb_alt_outlined,
            size: 34,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            isRelevant
                ? 'Nothing is available to $actorName right now.'
                : '$actorName is not involved yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            isRelevant
                ? 'Conditions in the system have to change first.'
                : 'Something has to reach them before they can act.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

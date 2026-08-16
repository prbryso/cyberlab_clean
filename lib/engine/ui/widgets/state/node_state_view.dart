import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_state_variable.dart';
import 'package:systems_studio/engine/simulation/studio_situation_snapshot.dart';

/// Renders the state variables declared by one element.
///
/// This replaces the flat list of state names that used to appear under
/// "System Information". A name alone could not say what values were allowed
/// or where a run begins; a declaration can.
///
/// Values shown here are *declared* values, and "start" means where a run of
/// this element would begin. Which value that is depends on the situation:
/// see [situation].
class NodeStateView extends StatelessWidget {
  const NodeStateView({
    super.key,
    required this.variables,
    this.situation,
  });

  final List<StudioStateVariable> variables;

  /// The situation being explored, when one is.
  ///
  /// Without it, "start" means the value the system declares. With it, "start"
  /// means where *this situation* began, which a scenario may have overridden.
  /// Marking the system's default in a situation that deliberately starts
  /// somewhere else would tell the learner the run began somewhere it did not.
  final StudioSituationSnapshot? situation;

  @override
  Widget build(BuildContext context) {
    if (variables.isEmpty) {
      return Text(
        'This element declares no state.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < variables.length; index++) ...[
          if (index > 0) const SizedBox(height: 14),
          _StateVariableRow(
            variable: variables[index],
            situation: situation,
          ),
        ],
      ],
    );
  }
}

class _StateVariableRow extends StatelessWidget {
  const _StateVariableRow({required this.variable, this.situation});

  final StudioStateVariable variable;
  final StudioSituationSnapshot? situation;

  /// The value a run of this variable begins at.
  String get _startingValue =>
      situation?.startingState.valueOf(variable) ?? variable.initialValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          variable.name,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (variable.description.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            variable.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: variable.domain.map((value) {
            final isInitial = value == _startingValue;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: isInitial
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isInitial
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                isInitial ? '$value  · start' : value,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isInitial
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isInitial ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

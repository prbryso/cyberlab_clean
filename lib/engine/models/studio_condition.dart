/// Declarative conditions over simulation state.
///
/// A condition is **data, not code**. It is never a Dart callback, closure, or
/// predicate function. That constraint is deliberate and load-bearing: a
/// condition expressed as data can be validated before it runs, serialised,
/// exported, explained to a learner, rendered in a UI, and reasoned about by a
/// future AI layer. A closure can do none of those things, and the moment one
/// appears the authoring model becomes a program.
///
/// The v1 language is intentionally tiny:
///
/// - a state variable equals a value;
/// - a state variable does not equal a value;
/// - all of a set of conditions hold;
/// - any of a set of conditions hold;
/// - a condition does not hold.
///
/// There is no arithmetic, no iteration, no user-defined function, and no
/// domain-specific hook. If content needs something this language cannot say,
/// that is a signal to extend the language deliberately — not to add an
/// escape hatch.
///
/// Evaluation is strictly two-valued. Epistemic `unknown` is an authoring
/// concept about what Systems Studio knows of the real world; it never becomes
/// a runtime value and never enters this evaluation.
///
/// This file is intentionally free of Flutter dependencies.
library;

/// Base type for every condition.
///
/// Sealed so that evaluation can switch exhaustively and the compiler will
/// flag any new condition kind that an evaluator has not handled.
sealed class StudioCondition {
  const StudioCondition();
}

/// True when the named state variable currently holds [value].
class StudioStateEquals extends StudioCondition {
  const StudioStateEquals({required this.variableId, required this.value});

  /// ID of a declared StudioStateVariable.
  final String variableId;

  /// A value that must be a member of that variable's domain.
  final String value;
}

/// True when the named state variable currently holds anything but [value].
class StudioStateNotEquals extends StudioCondition {
  const StudioStateNotEquals({required this.variableId, required this.value});

  final String variableId;
  final String value;
}

/// True when every member of [conditions] is true.
///
/// An empty list is true, matching the usual reading of "all of nothing".
class StudioAllOf extends StudioCondition {
  const StudioAllOf(this.conditions);

  final List<StudioCondition> conditions;
}

/// True when at least one member of [conditions] is true.
///
/// An empty list is false.
class StudioAnyOf extends StudioCondition {
  const StudioAnyOf(this.conditions);

  final List<StudioCondition> conditions;
}

/// True when [condition] is false.
class StudioNot extends StudioCondition {
  const StudioNot(this.condition);

  final StudioCondition condition;
}

/// Every state-variable ID referenced anywhere in [condition].
///
/// Used by validation to check that a condition only names variables that
/// actually exist.
Iterable<String> studioConditionVariableIds(StudioCondition condition) sync* {
  switch (condition) {
    case StudioStateEquals(:final variableId):
      yield variableId;

    case StudioStateNotEquals(:final variableId):
      yield variableId;

    case StudioAllOf(:final conditions):
      for (final child in conditions) {
        yield* studioConditionVariableIds(child);
      }

    case StudioAnyOf(:final conditions):
      for (final child in conditions) {
        yield* studioConditionVariableIds(child);
      }

    case StudioNot(:final condition):
      yield* studioConditionVariableIds(condition);
  }
}

/// Every (variableId, value) comparison made anywhere in [condition].
///
/// Used by validation to check that a condition never compares a variable
/// against a value outside its declared domain.
Iterable<MapEntry<String, String>> studioConditionComparisons(
  StudioCondition condition,
) sync* {
  switch (condition) {
    case StudioStateEquals(:final variableId, :final value):
      yield MapEntry(variableId, value);

    case StudioStateNotEquals(:final variableId, :final value):
      yield MapEntry(variableId, value);

    case StudioAllOf(:final conditions):
      for (final child in conditions) {
        yield* studioConditionComparisons(child);
      }

    case StudioAnyOf(:final conditions):
      for (final child in conditions) {
        yield* studioConditionComparisons(child);
      }

    case StudioNot(:final condition):
      yield* studioConditionComparisons(condition);
  }
}

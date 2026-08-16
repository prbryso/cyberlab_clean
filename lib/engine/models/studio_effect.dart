/// Declarative changes to simulation state.
///
/// Like conditions, an effect is **data, not code**. It describes what changes
/// rather than performing the change, so it can be validated ahead of time,
/// serialised, explained, and displayed.
///
/// An effect never touches authored content. It produces a new SimulationState
/// from an existing one; the StudioSystemGraph and StudioSystemDetail it
/// overlays remain unchanged for the life of the application.
///
/// The v1 language has a single capability: assign a declared state variable
/// to another value from its declared domain.
///
/// This file is intentionally free of Flutter dependencies.
library;

/// Base type for every effect.
///
/// Sealed so an applier can switch exhaustively and the compiler flags any new
/// effect kind that has not been handled.
sealed class StudioEffect {
  const StudioEffect();
}

/// Sets a declared state variable to [value].
///
/// [value] must be a member of the variable's declared domain. Validation
/// catches violations before a run begins.
class StudioAssignState extends StudioEffect {
  const StudioAssignState({required this.variableId, required this.value});

  /// ID of a declared StudioStateVariable.
  final String variableId;

  /// The value to assign. Opaque to the engine.
  final String value;
}

/// Every state-variable ID referenced by [effect].
Iterable<String> studioEffectVariableIds(StudioEffect effect) sync* {
  switch (effect) {
    case StudioAssignState(:final variableId):
      yield variableId;
  }
}

/// Every (variableId, value) assignment made by [effect].
///
/// Used by validation to check that no effect assigns a value outside a
/// variable's declared domain.
Iterable<MapEntry<String, String>> studioEffectAssignments(
  StudioEffect effect,
) sync* {
  switch (effect) {
    case StudioAssignState(:final variableId, :final value):
      yield MapEntry(variableId, value);
  }
}

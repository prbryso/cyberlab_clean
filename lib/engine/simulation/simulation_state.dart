import 'package:systems_studio/engine/models/studio_effect.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/models/studio_state_variable.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// The value every declared state variable currently holds.
///
/// SimulationState is an **overlay**. The authored system — StudioSystemDetail
/// and the StudioSystemGraph built from it — is immutable and shared. A run
/// layers values on top of it and never writes back. Two people exploring the
/// same system therefore cannot diverge permanently, and a run can be
/// reproduced from its scenario plus the sequence applied to it.
///
/// State is keyed by [StudioStateKey], which pairs the owning element with the
/// variable's identity.
///
/// Values are opaque symbols. This class compares and stores them; it never
/// interprets them.
///
/// Epistemic `unknown` has no representation here. Whether Systems Studio
/// knows something about the real world is an authoring concern; a run always
/// has a fully determined value for every declared variable.
///
/// This file is intentionally free of Flutter dependencies.
class SimulationState {
  const SimulationState._(this._values);

  /// A state with no values assigned.
  ///
  /// Rarely useful directly — prefer [SimulationState.initial].
  static const SimulationState empty = SimulationState._(
    <StudioStateKey, String>{},
  );

  final Map<StudioStateKey, String> _values;

  /// Builds the starting state for a run from the graph's declarations.
  ///
  /// Every declared variable receives its declared initial value, so a run
  /// always begins fully determined.
  factory SimulationState.initial(StudioSystemGraph graph) {
    return SimulationState._(
      Map<StudioStateKey, String>.unmodifiable({
        for (final variable in graph.stateVariables)
          variable.key: variable.initialValue,
      }),
    );
  }

  /// Builds the starting state for a run of [scenario].
  ///
  /// The system's declared values first, then the scenario's overrides on top.
  /// That order is what makes a scenario a difference from the system's
  /// resting condition rather than a restatement of it: a variable the
  /// scenario says nothing about still begins where the system says it begins.
  ///
  /// Overrides naming an unknown variable are ignored here rather than
  /// throwing. Validation rejects them with the scenario named, which is a far
  /// more useful failure than one raised mid-run.
  factory SimulationState.forScenario(
    StudioSystemGraph graph,
    StudioScenario scenario,
  ) {
    if (scenario.initialStateOverrides.isEmpty) {
      return SimulationState.initial(graph);
    }

    final values = <StudioStateKey, String>{
      for (final variable in graph.stateVariables)
        variable.key: variable.initialValue,
    };

    for (final entry in scenario.initialStateOverrides.entries) {
      final variable = graph.stateVariableById(entry.key);

      if (variable == null) {
        continue;
      }

      values[variable.key] = entry.value;
    }

    return SimulationState._(
      Map<StudioStateKey, String>.unmodifiable(values),
    );
  }

  /// Number of state slots currently held.
  int get length => _values.length;

  bool get isEmpty => _values.isEmpty;

  /// Every slot and its value.
  Map<StudioStateKey, String> get values =>
      Map<StudioStateKey, String>.unmodifiable(_values);

  /// The value held at [key], or null when nothing is assigned.
  String? valueAt(StudioStateKey key) => _values[key];

  /// The value held by [variable], falling back to its declared initial value.
  String valueOf(StudioStateVariable variable) {
    return _values[variable.key] ?? variable.initialValue;
  }

  /// Returns a new state with [key] set to [value].
  ///
  /// The receiver is not modified.
  SimulationState withValue(StudioStateKey key, String value) {
    if (_values[key] == value) {
      return this;
    }

    return SimulationState._(
      Map<StudioStateKey, String>.unmodifiable({..._values, key: value}),
    );
  }

  /// Applies [effect] against [graph], returning a new state.
  ///
  /// Throws a [StateError] when the effect names a variable the graph does not
  /// declare, or assigns a value outside that variable's domain. Both are
  /// modelling errors that StudioGraphValidator reports before a run begins;
  /// reaching them at runtime means an unvalidated graph was used.
  SimulationState applyEffect(StudioEffect effect, StudioSystemGraph graph) {
    switch (effect) {
      case StudioAssignState(:final variableId, :final value):
        final variable = graph.stateVariableById(variableId);

        if (variable == null) {
          throw StateError(
            'Effect assigns unknown state variable "$variableId".',
          );
        }

        if (!variable.allows(value)) {
          throw StateError(
            'Effect assigns "$value" to state variable "$variableId", which '
            'is outside its declared domain ${variable.domain}.',
          );
        }

        return withValue(variable.key, value);
    }
  }

  /// Applies [effects] in order, returning the resulting state.
  SimulationState applyAll(
    Iterable<StudioEffect> effects,
    StudioSystemGraph graph,
  ) {
    var next = this;

    for (final effect in effects) {
      next = next.applyEffect(effect, graph);
    }

    return next;
  }

  /// Returns a state restored to the graph's declared initial values.
  SimulationState reset(StudioSystemGraph graph) {
    return SimulationState.initial(graph);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! SimulationState || other._values.length != _values.length) {
      return false;
    }

    for (final entry in _values.entries) {
      if (other._values[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    // Order-independent, so two states with the same assignments agree.
    var hash = 0;

    for (final entry in _values.entries) {
      hash ^= Object.hash(entry.key, entry.value);
    }

    return hash;
  }

  @override
  String toString() => 'SimulationState(${_values.length} values)';
}

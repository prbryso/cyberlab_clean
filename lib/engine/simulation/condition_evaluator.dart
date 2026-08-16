import 'package:systems_studio/engine/models/studio_condition.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';

/// Evaluates declarative conditions against a simulation state.
///
/// The evaluator is the only place that interprets the condition language, and
/// it lives in the engine. A content package supplies condition *data*; it
/// never supplies evaluation code. That boundary is what keeps a library
/// describing a system rather than programming one.
///
/// Evaluation is strictly two-valued. Every declared variable holds a value
/// for the whole of a run, so there is no third outcome. Epistemic `unknown`
/// describes what Systems Studio knows about the real world and never reaches
/// this code.
///
/// The engine compares value symbols for equality and nothing more. It has no
/// idea what "Locked" or "Compromised" mean.
///
/// This file is intentionally free of Flutter dependencies.
class StudioConditionEvaluator {
  const StudioConditionEvaluator();

  /// Returns whether [condition] holds in [state].
  ///
  /// Throws a [StateError] when the condition names a variable the graph does
  /// not declare. StudioGraphValidator reports that before a run begins;
  /// reaching it at runtime means an unvalidated graph was used.
  bool evaluate(
    StudioCondition condition,
    SimulationState state,
    StudioSystemGraph graph,
  ) {
    switch (condition) {
      case StudioStateEquals(:final variableId, :final value):
        return _valueOf(variableId, state, graph) == value;

      case StudioStateNotEquals(:final variableId, :final value):
        return _valueOf(variableId, state, graph) != value;

      case StudioAllOf(:final conditions):
        for (final child in conditions) {
          if (!evaluate(child, state, graph)) {
            return false;
          }
        }

        return true;

      case StudioAnyOf(:final conditions):
        for (final child in conditions) {
          if (evaluate(child, state, graph)) {
            return true;
          }
        }

        return false;

      case StudioNot(:final condition):
        return !evaluate(condition, state, graph);
    }
  }

  String _valueOf(
    String variableId,
    SimulationState state,
    StudioSystemGraph graph,
  ) {
    final variable = graph.stateVariableById(variableId);

    if (variable == null) {
      throw StateError(
        'Condition references unknown state variable "$variableId".',
      );
    }

    return state.valueOf(variable);
  }
}

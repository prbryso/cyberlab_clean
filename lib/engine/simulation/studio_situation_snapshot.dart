import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_overlay.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';

/// One way the present differs from where this situation began.
///
/// A difference is a *comparison of two endpoints*, not a record of a change.
/// It says nothing about how many times the value moved or what caused it —
/// the causal record answers that.
class StudioSituationDifference {
  const StudioSituationDifference({
    required this.variableId,
    required this.owner,
    required this.startedAs,
    required this.isNow,
  });

  final String variableId;

  /// The element whose state this is.
  final StudioElementRef owner;

  /// The value this variable held when the situation began — the scenario's
  /// starting value, which is not necessarily the system's declared one.
  final String startedAs;

  final String isNow;
}

/// The state of an exploration at one moment.
///
/// Derived purely from `(graph, run)` and immutable. It owns nothing: it
/// cannot act, cannot reset, and holds no evaluator. Deriving one has no
/// effect on the run it describes.
///
/// **What it adds** is the comparison nothing else makes: how the present
/// differs from where *this situation* started. That question has no existing
/// owner, and answering it from the trace gets it wrong — see [differences].
///
/// **What it deliberately excludes**, so it stays a description of a situation
/// rather than a second name for the run:
///
/// - trace, events, observations and relevant actors, which are single-field
///   reads on [SimulationRun] and need no second spelling here;
/// - available actions and actor perspectives, which depend on *who is
///   asking*. Those are functions of a situation, not properties of one.
///
/// This is a snapshot. It is accurate as of the moment it was derived and does
/// not update; hold the run, not this, if you need to stay current.
///
/// This file is intentionally free of Flutter dependencies.
class StudioSituationSnapshot {
  const StudioSituationSnapshot({
    required this.scenario,
    required this.startingState,
    required this.currentState,
    required this.differences,
    required this.causal,
    required this.overlay,
  });

  /// The situation being explored.
  final StudioScenario scenario;

  /// Where this situation began: the system's declared values with the
  /// scenario's overrides applied.
  ///
  /// Not the system's declared starting state. A scenario that begins with an
  /// account already locked began there, and nothing that reads this should
  /// have to know whether a value came from the system or the situation.
  final SimulationState startingState;

  /// Where the system is now.
  final SimulationState currentState;

  /// Every variable whose present value differs from its starting value.
  ///
  /// Computed by comparing the two states directly, across every declared
  /// variable. Deliberately not reconstructed from the trace, which would get
  /// two cases wrong:
  ///
  /// - a variable the scenario overrode but the run never touched has no trace
  ///   entry at all, yet it is one of the most important facts about the
  ///   situation;
  /// - a variable that moved A → B → A has trace entries but no present
  ///   difference, and reporting one would describe the system as it is not.
  ///
  /// Ordered by declaration, so the same situation always reads the same way.
  final List<StudioSituationDifference> differences;

  /// What happened, in causal order.
  final SimulationCausalGraph causal;

  /// The same chain, placed onto the architecture.
  ///
  /// Built from [causal] rather than from the run again, so the graph and any
  /// panel beside it cannot describe different chains.
  final SimulationGraphOverlay overlay;

  bool get hasDifferences => differences.isNotEmpty;

  /// True when nothing has happened yet.
  bool get isAtStart => causal.isEmpty;

  /// The difference recorded for [variableId], or null when it stands where
  /// the situation started.
  StudioSituationDifference? differenceFor(String variableId) {
    for (final difference in differences) {
      if (difference.variableId == variableId) {
        return difference;
      }
    }

    return null;
  }

  /// Derives the situation described by [run].
  ///
  /// The run carries its own scenario, so no caller can pair a run with a
  /// situation it was not started from.
  factory StudioSituationSnapshot.of(StudioSystemGraph graph, SimulationRun run) {
    final causal = SimulationCausalGraph.fromRun(run);

    final startingState = SimulationState.forScenario(graph, run.scenario);
    final currentState = run.state;

    final differences = <StudioSituationDifference>[
      for (final variable in graph.stateVariables)
        if (startingState.valueOf(variable) != currentState.valueOf(variable))
          StudioSituationDifference(
            variableId: variable.id,
            owner: variable.owner,
            startedAs: startingState.valueOf(variable),
            isNow: currentState.valueOf(variable),
          ),
    ];

    return StudioSituationSnapshot(
      scenario: run.scenario,
      startingState: startingState,
      currentState: currentState,
      differences: List<StudioSituationDifference>.unmodifiable(differences),
      causal: causal,
      overlay: SimulationGraphOverlay.fromCausalGraph(causal, run),
    );
  }
}

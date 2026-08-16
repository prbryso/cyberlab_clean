import 'package:flutter/foundation.dart';

import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/propagation_evaluator.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';

/// Owns the current exploration and tells the UI when it changes.
///
/// Deliberately separate from WorkspaceController. Selecting and focusing
/// elements is a different concern from running a system: one is about where
/// you are looking, the other about what has happened. Merging them would mean
/// every pan and click notified simulation listeners, and every simulation step
/// notified navigation listeners.
///
/// This is the only place Flutter meets the simulation engine. `SimulationRun`,
/// observations, events, propagation, conditions and effects are all plain
/// Dart and stay usable without a UI; this class exists so a widget tree can
/// listen to them.
///
/// The authored graph is immutable and is never modified here.
class StudioSimulationController extends ChangeNotifier {
  StudioSimulationController({
    required StudioSystemGraph graph,
    StudioScenario? scenario,
    Set<StudioElementRef> initialActors = const {},
    String runId = 'run',
    StudioPropagationEvaluator evaluator =
        const StudioPropagationEvaluator(),
  }) : _graph = graph,
       _initialActors = Set<StudioElementRef>.unmodifiable(initialActors),
       _runId = runId,
       _evaluator = evaluator,
       _run = SimulationRun.start(
         graph,
         runId: runId,
         scenario: scenario,
         initialActors: initialActors,
         evaluator: evaluator,
       );

  final StudioSystemGraph _graph;

  /// Who is present when no scenario says otherwise.
  ///
  /// Retained so that callers that predate scenarios keep behaving exactly as
  /// they did, including across a restart.
  final Set<StudioElementRef> _initialActors;

  final String _runId;
  final StudioPropagationEvaluator _evaluator;

  SimulationRun _run;

  /// The system being explored. Never modified.
  StudioSystemGraph get graph => _graph;

  /// The current exploration.
  SimulationRun get run => _run;

  String get runId => _run.runId;

  SimulationState get state => _run.state;

  List<StudioTraceEntry> get trace => _run.trace;

  List<StudioEvent> get events => _run.events;

  List<StudioObservation> get observations => _run.observations;

  Set<StudioElementRef> get relevantActors => _run.relevantActors;

  bool isRelevant(StudioElementRef actor) => _run.isRelevant(actor);

  List<StudioObservation> observationsFor(StudioElementRef observer) =>
      _run.observationsFor(observer);

  /// Actions any relevant actor could take right now.
  List<StudioActionDefinition> availableActions() => _run.availableActions();

  /// Actions [actor] could take right now.
  List<StudioActionDefinition> availableActionsFor(StudioElementRef actor) =>
      _run.availableActionsFor(actor);

  /// True when nothing has happened yet in this run.
  bool get isAtStart => _run.trace.isEmpty;

  /// Takes [action] and propagates everything that follows.
  ///
  /// Notifies listeners only when something actually happened, so an
  /// unavailable action does not cause a spurious rebuild.
  SimulationRunResult perform(StudioActionDefinition action) {
    final result = _run.perform(action);

    if (result.actionWasAvailable) {
      notifyListeners();
    }

    return result;
  }

  /// The situation being explored.
  StudioScenario get scenario => _run.scenario;

  /// Returns the current run to its scenario's starting condition, keeping its
  /// identity.
  ///
  /// Reset stays within the current situation. It is not a way back to
  /// choosing one.
  void reset() {
    _run.reset();
    notifyListeners();
  }

  /// Abandons the current run and begins a new one.
  ///
  /// Distinct from [reset]: a restart is a different exploration, and may
  /// explore a different [scenario] entirely. Omitting the scenario restarts
  /// from the participants this controller was created with, which is what a
  /// restart has always meant.
  void restart({
    StudioScenario? scenario,
    Set<StudioElementRef>? initialActors,
    String? runId,
  }) {
    _run = SimulationRun.start(
      _graph,
      runId: runId ?? _runId,
      scenario: scenario,
      initialActors: initialActors ?? _initialActors,
      evaluator: _evaluator,
    );

    notifyListeners();
  }
}

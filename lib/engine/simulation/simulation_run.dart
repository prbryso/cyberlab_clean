import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/observability_index.dart';
import 'package:systems_studio/engine/simulation/propagation_evaluator.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';

/// One exploration of a system: everything that has happened so far.
///
/// A run owns the mutable parts of exploring — which state the system is in,
/// what has occurred, who has seen what, and which actors have become
/// relevant. It owns none of the system itself. The graph it explores is
/// immutable and shared, and nothing here ever writes back to it, so two
/// people exploring the same system cannot permanently diverge.
///
/// The pieces it accumulates are each immutable: state is replaced rather than
/// edited, trace entries and observations are appended. The run is the one
/// mutable thing, and it is mutable in the same way a bookmark is.
///
/// This file is intentionally free of Flutter dependencies.
class SimulationRun {
  SimulationRun._({
    required String runId,
    required this.graph,
    required StudioObservabilityIndex observability,
    required this.scenario,
    required this.evaluator,
  }) : _runId = runId,
       _observability = observability,
       _state = SimulationState.forScenario(graph, scenario),
       _relevantActors = <StudioElementRef>{...scenario.initialActors};

  /// Begins a run of [graph].
  ///
  /// A run is always a run *of a situation*. When [scenario] is given it
  /// establishes the starting point: who is already present, and anything
  /// already true that differs from the system's declared values.
  ///
  /// When it is omitted the run begins from the system's declared values with
  /// [initialActors] present, which is what a run has always meant. That case
  /// is expressed as an implicit scenario rather than as a second code path,
  /// so there is only ever one answer to "what is this run a run of?".
  ///
  /// Supplying no actors at all is legitimate and means nobody is relevant
  /// until an occurrence reaches them.
  factory SimulationRun.start(
    StudioSystemGraph graph, {
    String runId = 'run',
    StudioScenario? scenario,
    Set<StudioElementRef> initialActors = const {},
    StudioPropagationEvaluator evaluator =
        const StudioPropagationEvaluator(),
    StudioObservabilityIndex? observability,
  }) {
    return SimulationRun._(
      runId: runId,
      graph: graph,
      observability:
          observability ?? StudioObservabilityIndex.forGraph(graph),
      scenario:
          scenario ?? StudioScenario.implicit(initialActors: initialActors),
      evaluator: evaluator,
    );
  }

  final String _runId;

  /// The situation this run explores.
  ///
  /// Authored data, never modified by the run. It is what [reset] restores to,
  /// which is why a run holds it rather than copying pieces out of it.
  final StudioScenario scenario;

  /// Identity of this run, distinguishing it from any other exploration.
  ///
  /// Scenario-scoped: two runs of the same system in different situations are
  /// different explorations, and a trace or overlay from one says nothing
  /// about the other. The implicit scenario adds nothing, so a system without
  /// authored scenarios keeps the plain identity it always had.
  String get runId =>
      scenario.isImplicit ? _runId : '$_runId:${scenario.id}';

  /// Identity of the situation being explored.
  String get scenarioId => scenario.id;

  /// The system being explored. Never modified.
  final StudioSystemGraph graph;

  final StudioPropagationEvaluator evaluator;

  final StudioObservabilityIndex _observability;

  SimulationState _state;

  final List<StudioTraceEntry> _trace = [];
  final List<StudioEvent> _events = [];
  final List<StudioObservation> _observations = [];
  final Set<StudioElementRef> _relevantActors;

  int _nextEventSequence = 0;
  int _nextEntrySequence = 0;

  /// Current values of every declared state variable.
  SimulationState get state => _state;

  /// Everything that has happened, oldest first, across every action taken.
  List<StudioTraceEntry> get trace =>
      List<StudioTraceEntry>.unmodifiable(_trace);

  /// Every occurrence so far, in order.
  List<StudioEvent> get events => List<StudioEvent>.unmodifiable(_events);

  /// Every observation so far, in order.
  List<StudioObservation> get observations =>
      List<StudioObservation>.unmodifiable(_observations);

  /// Actors that have become part of this exploration.
  ///
  /// Relevance means an actor now has a reason to be considered — not that
  /// they will do anything. Nothing here makes an actor act.
  Set<StudioElementRef> get relevantActors =>
      Set<StudioElementRef>.unmodifiable(_relevantActors);

  /// Graph-derived observability, computed once and shared for the whole run.
  StudioObservabilityIndex get observability => _observability;

  bool isRelevant(StudioElementRef actor) => _relevantActors.contains(actor);

  /// Observations received by [observer], oldest first.
  List<StudioObservation> observationsFor(StudioElementRef observer) {
    return List<StudioObservation>.unmodifiable(
      _observations.where((observation) => observation.observer == observer),
    );
  }

  /// Actions [actor] could take right now.
  ///
  /// Returns nothing for an actor who is not yet relevant: an actor who has no
  /// reason to be part of the exploration has nothing to offer it. Once
  /// relevant, availability depends only on the action's precondition and the
  /// current state.
  List<StudioActionDefinition> availableActionsFor(StudioElementRef actor) {
    if (!isRelevant(actor)) {
      return const [];
    }

    return evaluator.availableActions(graph, _state, initiator: actor);
  }

  /// Actions any relevant actor could take right now.
  List<StudioActionDefinition> availableActions() {
    final actions = <StudioActionDefinition>[];

    for (final action in evaluator.availableActions(graph, _state)) {
      if (isRelevant(action.initiator)) {
        actions.add(action);
      }
    }

    return List<StudioActionDefinition>.unmodifiable(actions);
  }

  /// Takes [action] and propagates everything that follows.
  ///
  /// Returns the result of this step. The run keeps the accumulated view.
  SimulationRunResult perform(StudioActionDefinition action) {
    final result = evaluator.run(
      action,
      graph,
      _state,
      observability: _observability,
      startingEventSequence: _nextEventSequence,
      startingEntrySequence: _nextEntrySequence,
    );

    if (!result.actionWasAvailable) {
      return result;
    }

    // Choosing an action is itself participation.
    _relevantActors.add(action.initiator);

    _state = result.state;
    _trace.addAll(result.trace.entries);
    _events.addAll(result.trace.allEvents);
    _observations.addAll(result.observations);

    _nextEventSequence = result.nextEventSequence;
    _nextEntrySequence = result.nextEntrySequence;

    _updateRelevance(result.observations);

    return result;
  }

  /// Returns the run to the starting condition of its scenario.
  ///
  /// State returns to where the scenario established it, history is discarded,
  /// and relevance returns to the actors the scenario said were present — an
  /// actor who became relevant by observing something has no reason to remain
  /// relevant once that never happened.
  ///
  /// Reset stays inside the scenario. Exploring a different situation is a
  /// different exploration, which is what starting a new run is for.
  void reset() {
    _state = SimulationState.forScenario(graph, scenario);

    _trace.clear();
    _events.clear();
    _observations.clear();

    _relevantActors
      ..clear()
      ..addAll(scenario.initialActors);

    _nextEventSequence = 0;
    _nextEntrySequence = 0;
  }

  /// An actor who observes something becomes relevant to this exploration.
  ///
  /// This is the whole mechanism. Nobody schedules an actor, and no authored
  /// content activates one: an administrator becomes relevant because an alert
  /// reached them, and for no other reason.
  void _updateRelevance(List<StudioObservation> observations) {
    for (final observation in observations) {
      final observer = observation.observer;

      if (!observer.isNode) {
        continue;
      }

      final node = graph.nodeById(observer.id);

      if (node?.type == StudioGraphNodeType.actor) {
        _relevantActors.add(observer);
      }
    }
  }
}

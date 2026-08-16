import 'dart:collection';

import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_behavior_definition.dart';
import 'package:systems_studio/engine/models/studio_effect.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_outcome.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/condition_evaluator.dart';
import 'package:systems_studio/engine/simulation/observability_index.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';

/// The result of running one chosen action to quiescence.
class SimulationRunResult {
  const SimulationRunResult({
    required this.state,
    required this.trace,
    required this.actionWasAvailable,
    this.observations = const [],
    this.nextEventSequence = 0,
    this.nextEntrySequence = 0,
  });

  /// State after the run. The state passed in is unchanged.
  final SimulationState state;

  /// The generated causal record of what happened.
  final StudioTrace trace;

  /// False when the action's precondition did not hold, in which case nothing
  /// ran and [state] is the state that was passed in.
  final bool actionWasAvailable;

  /// Every observation made during the run, in occurrence order.
  ///
  /// One occurrence produces several observations, or none. This is what makes
  /// two perspectives on the same run genuinely different.
  final List<StudioObservation> observations;

  /// Counters a caller should continue from for the next action in the same
  /// run, so occurrence identity stays unique across a whole run rather than
  /// restarting with each action.
  final int nextEventSequence;
  final int nextEntrySequence;
}

/// Runs actions and propagates the behaviours they set off.
///
/// The evaluator is a **fixed-point loop**, not an interpreter of authored
/// order. It repeatedly matches triggers, selects outcomes, applies effects,
/// and emits occurrences until nothing further is triggered. Authors never
/// specify sequence; the shape of a run is discovered by running it. That is
/// what makes a Flow generated rather than scripted.
///
/// Everything about a run is deterministic. Outcomes are selected by ordered
/// first match, behaviours are considered in authored order, and there is no
/// randomness anywhere. The same action from the same state always produces
/// the same state and the same trace — which is what makes a run reproducible
/// and its trace explainable.
///
/// The evaluator never modifies the graph or any authored content. It threads
/// an immutable SimulationState through the run and returns a new one.
///
/// This file is intentionally free of Flutter dependencies.
class StudioPropagationEvaluator {
  const StudioPropagationEvaluator({
    this.maximumDepth = 8,
    this.maximumEntries = 200,
    this.conditions = const StudioConditionEvaluator(),
  });

  /// How far a chain of behaviours may extend from the chosen action.
  ///
  /// A safeguard, not a modelling parameter. Reaching it means the model
  /// probably contains a loop, and the trace says so rather than hanging.
  final int maximumDepth;

  /// Absolute ceiling on generated trace entries.
  ///
  /// Guards against fan-out, which the depth limit alone does not bound.
  final int maximumEntries;

  final StudioConditionEvaluator conditions;

  /// Actions whose precondition currently holds.
  ///
  /// Availability is a property of the precondition alone. It never depends on
  /// which outcome would be selected.
  List<StudioActionDefinition> availableActions(
    StudioSystemGraph graph,
    SimulationState state, {
    StudioElementRef? initiator,
  }) {
    return List<StudioActionDefinition>.unmodifiable(
      graph.actionDefinitions.where((action) {
        if (initiator != null && action.initiator != initiator) {
          return false;
        }

        return isAvailable(action, graph, state);
      }),
    );
  }

  /// Whether [action] can currently be taken.
  bool isAvailable(
    StudioActionDefinition action,
    StudioSystemGraph graph,
    SimulationState state,
  ) {
    final precondition = action.precondition;

    if (precondition == null) {
      return true;
    }

    return conditions.evaluate(precondition, state, graph);
  }

  /// Runs [action] from [state] and propagates until quiescence.
  ///
  /// [observability] should be supplied by a caller that runs more than one
  /// action, so the index is computed once for the graph rather than rebuilt
  /// per action.
  ///
  /// [startingEventSequence] and [startingEntrySequence] let a run continue
  /// numbering across several actions.
  SimulationRunResult run(
    StudioActionDefinition action,
    StudioSystemGraph graph,
    SimulationState state, {
    StudioObservabilityIndex? observability,
    int startingEventSequence = 0,
    int startingEntrySequence = 0,
  }) {
    final index =
        observability ?? StudioObservabilityIndex.forGraph(graph);

    if (!isAvailable(action, graph, state)) {
      return SimulationRunResult(
        state: state,
        actionWasAvailable: false,
        nextEventSequence: startingEventSequence,
        nextEntrySequence: startingEntrySequence,
        trace: const StudioTrace(
          entries: [],
          termination: StudioTraceTermination.preconditionNotMet,
          notes: ['The action was not available in this state.'],
        ),
      );
    }

    final entries = <StudioTraceEntry>[];
    final notes = <String>[];
    final observations = <StudioObservation>[];

    var currentState = state;
    var eventSequence = startingEventSequence;
    var entrySequence = startingEntrySequence;

    // Which definition emitted each occurrence. Used to stop a behaviour
    // triggering on something it caused itself.
    final emittedBy = <int, String>{};

    // (behaviourId, eventSequence) pairs already handled, so a behaviour
    // cannot fire twice on the same occurrence.
    final fired = <String>{};

    var termination = StudioTraceTermination.quiescence;

    // --- the chosen action -------------------------------------------------

    final actionSelection = _select(action.outcomes, action.otherwise, currentState, graph);

    final actionApplication = _apply(
      outcome: actionSelection.outcome,
      graph: graph,
      state: currentState,
      source: action.target,
      participants: [action.initiator, action.target],
      nextEventSequence: eventSequence,
      emitterId: action.id,
      emittedBy: emittedBy,
    );

    currentState = actionApplication.state;
    eventSequence = actionApplication.nextEventSequence;

    for (final event in actionApplication.events) {
      observations.addAll(index.observationsOf(event));
    }

    entries.add(
      StudioTraceEntry(
        sequence: entrySequence++,
        depth: 0,
        kind: StudioTraceCauseKind.action,
        definitionId: action.id,
        definitionName: action.name,
        subject: action.initiator,
        target: action.target,
        outcomeIndex: actionSelection.index,
        usedOtherwise: actionSelection.usedOtherwise,
        stateChanges: actionApplication.changes,
        emittedEvents: actionApplication.events,
        explanation: actionSelection.outcome.explanation,
        guidingQuestion: actionSelection.outcome.guidingQuestion,
      ),
    );

    // --- propagation -------------------------------------------------------

    final pending = Queue<_PendingEvent>()
      ..addAll(
        actionApplication.events.map(
          (event) => _PendingEvent(event: event, depth: 1),
        ),
      );

    while (pending.isNotEmpty) {
      final current = pending.removeFirst();

      if (current.depth > maximumDepth) {
        termination = StudioTraceTermination.depthLimit;

        notes.add(
          'Propagation stopped at depth $maximumDepth. The model may contain '
          'a behaviour loop.',
        );

        break;
      }

      for (final behavior in _behaviorsTriggeredBy(graph, current.event)) {
        if (entries.length >= maximumEntries) {
          termination = StudioTraceTermination.entryLimit;

          notes.add(
            'Propagation stopped after $maximumEntries steps. The model may '
            'contain a behaviour loop.',
          );

          pending.clear();
          break;
        }

        // Safeguard: a behaviour does not react to what it caused itself
        // within this propagation.
        if (emittedBy[current.event.sequence] == behavior.id) {
          continue;
        }

        // Safeguard: at most once per triggering occurrence.
        final fireKey = '${behavior.id}@${current.event.sequence}';

        if (!fired.add(fireKey)) {
          continue;
        }

        // An element responds only to what it can actually perceive. Matching
        // the trigger type is no longer sufficient: a monitor with no line of
        // sight to an element learns nothing about it, however loudly that
        // element fails.
        if (!index.canObserve(behavior.owner, current.event)) {
          continue;
        }

        final gate = behavior.condition;

        if (gate != null && !conditions.evaluate(gate, currentState, graph)) {
          continue;
        }

        final selection = _select(
          behavior.outcomes,
          behavior.otherwise,
          currentState,
          graph,
        );

        final application = _apply(
          outcome: selection.outcome,
          graph: graph,
          state: currentState,
          source: behavior.owner,
          participants: [behavior.owner],
          nextEventSequence: eventSequence,
          emitterId: behavior.id,
          emittedBy: emittedBy,
        );

        currentState = application.state;
        eventSequence = application.nextEventSequence;

        for (final event in application.events) {
          observations.addAll(index.observationsOf(event));
        }

        entries.add(
          StudioTraceEntry(
            sequence: entrySequence++,
            depth: current.depth,
            kind: StudioTraceCauseKind.behavior,
            definitionId: behavior.id,
            definitionName: behavior.name,
            subject: behavior.owner,
            triggeringEvent: current.event,
            outcomeIndex: selection.index,
            usedOtherwise: selection.usedOtherwise,
            stateChanges: application.changes,
            emittedEvents: application.events,
            explanation: selection.outcome.explanation,
            guidingQuestion: selection.outcome.guidingQuestion,
          ),
        );

        pending.addAll(
          application.events.map(
            (event) => _PendingEvent(event: event, depth: current.depth + 1),
          ),
        );
      }

      if (termination == StudioTraceTermination.entryLimit) {
        break;
      }
    }

    return SimulationRunResult(
      state: currentState,
      actionWasAvailable: true,
      observations: List<StudioObservation>.unmodifiable(observations),
      nextEventSequence: eventSequence,
      nextEntrySequence: entrySequence,
      trace: StudioTrace(
        entries: List<StudioTraceEntry>.unmodifiable(entries),
        termination: termination,
        notes: List<String>.unmodifiable(notes),
      ),
    );
  }

  /// Behaviours triggered by [event], in authored order.
  ///
  /// Authored order is what makes propagation reproducible when several
  /// behaviours watch the same event type.
  List<StudioBehaviorDefinition> _behaviorsTriggeredBy(
    StudioSystemGraph graph,
    StudioEvent event,
  ) {
    return List<StudioBehaviorDefinition>.unmodifiable(
      graph.behaviorDefinitions.where(
        (behavior) => behavior.trigger == event.typeId,
      ),
    );
  }

  /// Ordered first match, falling back to the mandatory outcome.
  _OutcomeSelection _select(
    List<StudioOutcome> outcomes,
    StudioOutcome otherwise,
    SimulationState state,
    StudioSystemGraph graph,
  ) {
    for (var index = 0; index < outcomes.length; index++) {
      final candidate = outcomes[index];
      final condition = candidate.condition;

      if (condition == null || conditions.evaluate(condition, state, graph)) {
        return _OutcomeSelection(
          outcome: candidate,
          index: index,
          usedOtherwise: false,
        );
      }
    }

    return _OutcomeSelection(
      outcome: otherwise,
      index: -1,
      usedOtherwise: true,
    );
  }

  /// Applies one outcome: effects first, then occurrences.
  _OutcomeApplication _apply({
    required StudioOutcome outcome,
    required StudioSystemGraph graph,
    required SimulationState state,
    required StudioElementRef source,
    required List<StudioElementRef> participants,
    required int nextEventSequence,
    required String emitterId,
    required Map<int, String> emittedBy,
  }) {
    var currentState = state;

    final changes = <StudioStateChange>[];

    for (final effect in outcome.effects) {
      switch (effect) {
        case StudioAssignState(:final variableId, :final value):
          final variable = graph.stateVariableById(variableId);

          if (variable == null) {
            throw StateError(
              'Outcome assigns unknown state variable "$variableId".',
            );
          }

          final previous = currentState.valueOf(variable);

          currentState = currentState.applyEffect(effect, graph);

          if (previous != value) {
            changes.add(
              StudioStateChange(
                variableId: variableId,
                owner: variable.owner,
                previousValue: previous,
                newValue: value,
              ),
            );
          }
      }
    }

    final events = <StudioEvent>[];

    var sequence = nextEventSequence;

    for (final eventTypeId in outcome.emits) {
      final event = StudioEvent(
        sequence: sequence,
        typeId: eventTypeId,
        source: source,
        participants: List<StudioElementRef>.unmodifiable(participants),
      );

      emittedBy[sequence] = emitterId;

      events.add(event);

      sequence++;
    }

    return _OutcomeApplication(
      state: currentState,
      changes: List<StudioStateChange>.unmodifiable(changes),
      events: List<StudioEvent>.unmodifiable(events),
      nextEventSequence: sequence,
    );
  }
}

class _PendingEvent {
  const _PendingEvent({required this.event, required this.depth});

  final StudioEvent event;
  final int depth;
}

class _OutcomeSelection {
  const _OutcomeSelection({
    required this.outcome,
    required this.index,
    required this.usedOtherwise,
  });

  final StudioOutcome outcome;
  final int index;
  final bool usedOtherwise;
}

class _OutcomeApplication {
  const _OutcomeApplication({
    required this.state,
    required this.changes,
    required this.events,
    required this.nextEventSequence,
  });

  final SimulationState state;
  final List<StudioStateChange> changes;
  final List<StudioEvent> events;
  final int nextEventSequence;
}

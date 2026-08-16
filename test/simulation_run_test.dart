import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';

import 'simulation_fixture.dart';

void main() {
  group('run ownership', () {
    test('starts from the declared initial state', () {
      final graph = buildBasicGraph();
      final run = SimulationRun.start(graph, runId: 'r1');

      expect(run.runId, 'r1');
      expect(run.state, SimulationState.initial(graph));
      expect(run.trace, isEmpty);
      expect(run.events, isEmpty);
      expect(run.observations, isEmpty);
    });

    test('accumulates across actions and never touches the graph', () {
      final graph = buildBasicGraph();
      final run = SimulationRun.start(graph);

      final before = graph.stateVariables.map((v) => v.initialValue).toList();

      run.perform(graph.actionDefinitions.first);

      expect(run.trace, hasLength(2));
      expect(run.events, hasLength(2));
      expect(run.observations, isNotEmpty);

      expect(
        graph.stateVariables.map((v) => v.initialValue).toList(),
        before,
        reason: 'authored declarations must be untouched',
      );
      expect(identical(run.graph, graph), isTrue);
    });

    test('occurrence identity stays unique across actions in one run', () {
      final graph = buildSelfEmittingGraph();
      final run = SimulationRun.start(graph);

      run.perform(graph.actionDefinitions.first);
      run.perform(graph.actionDefinitions.first);

      final sequences = run.events.map((event) => event.sequence).toList();

      expect(sequences.toSet(), hasLength(sequences.length));
    });
  });

  group('reset', () {
    test('returns state, history and relevance to the start', () {
      final graph = buildBasicGraph();

      final run = SimulationRun.start(
        graph,
        initialActors: {actorRef},
      );

      run.perform(graph.actionDefinitions.first);

      expect(run.trace, isNotEmpty);
      expect(run.state, isNot(SimulationState.initial(graph)));

      run.reset();

      expect(run.state, SimulationState.initial(graph));
      expect(run.trace, isEmpty);
      expect(run.events, isEmpty);
      expect(run.observations, isEmpty);
      expect(run.relevantActors, {actorRef});
    });
  });

  group('determinism', () {
    test('two runs of the same system agree step for step', () {
      final graph = buildBasicGraph();

      final a = SimulationRun.start(graph)
        ..perform(graph.actionDefinitions.first);
      final b = SimulationRun.start(graph)
        ..perform(graph.actionDefinitions.first);

      expect(a.state, b.state);
      expect(
        a.trace.map((entry) => entry.definitionId),
        b.trace.map((entry) => entry.definitionId),
      );
      expect(
        a.observations.map((observation) => observation.observer),
        b.observations.map((observation) => observation.observer),
      );
      expect(a.relevantActors, b.relevantActors);
    });
  });

  group('actor relevance', () {
    test('an actor who observes nothing stays irrelevant', () {
      final graph = buildUnobservableGraph();

      final run = SimulationRun.start(graph);

      // Nobody is relevant before anything happens.
      expect(run.relevantActors, isEmpty);
      expect(run.availableActionsFor(actorRef), isEmpty);
    });

    test('taking an action makes the initiator relevant', () {
      final graph = buildBasicGraph();
      final run = SimulationRun.start(graph);

      run.perform(graph.actionDefinitions.first);

      expect(run.isRelevant(actorRef), isTrue);
    });

    test('relevance does not make an actor act', () {
      final graph = buildBasicGraph();

      final run = SimulationRun.start(
        graph,
        initialActors: {actorRef},
      );

      // Being relevant produced no trace of its own.
      expect(run.isRelevant(actorRef), isTrue);
      expect(run.trace, isEmpty);
    });

    test('available actions require both relevance and a precondition', () {
      final graph = buildBasicGraph();

      final run = SimulationRun.start(graph);

      expect(
        run.availableActionsFor(actorRef),
        isEmpty,
        reason: 'not relevant yet',
      );

      run.perform(graph.actionDefinitions.first);

      // Now relevant, but the engine is busy so the precondition fails.
      expect(run.isRelevant(actorRef), isTrue);
      expect(run.availableActionsFor(actorRef), isEmpty);
    });
  });
}

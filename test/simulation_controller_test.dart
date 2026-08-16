import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';

import 'simulation_fixture.dart';

void main() {
  group('notification', () {
    test('performing an action notifies listeners', () {
      final graph = buildBasicGraph();
      final controller = StudioSimulationController(graph: graph);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.perform(graph.actionDefinitions.first);

      expect(notifications, 1);
      expect(controller.isAtStart, isFalse);
    });

    test('an unavailable action does not notify', () {
      final graph = buildBasicGraph();
      final controller = StudioSimulationController(graph: graph);

      // Use it up, so the precondition no longer holds.
      controller.perform(graph.actionDefinitions.first);

      var notifications = 0;
      controller.addListener(() => notifications++);

      final result = controller.perform(graph.actionDefinitions.first);

      expect(result.actionWasAvailable, isFalse);
      expect(
        notifications,
        0,
        reason: 'nothing happened, so nothing needs rebuilding',
      );
    });

    test('reset and restart both notify', () {
      final graph = buildBasicGraph();
      final controller = StudioSimulationController(graph: graph);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.reset();
      controller.restart();

      expect(notifications, 2);
    });
  });

  group('state transitions', () {
    test('exposes the run it owns', () {
      final graph = buildBasicGraph();

      final controller = StudioSimulationController(
        graph: graph,
        runId: 'demo',
        initialActors: {actorRef},
      );

      expect(controller.runId, 'demo');
      expect(controller.isAtStart, isTrue);
      expect(controller.state, SimulationState.initial(graph));
      expect(controller.relevantActors, {actorRef});
      expect(identical(controller.graph, graph), isTrue);
    });

    test('reset keeps the run identity and clears history', () {
      final graph = buildBasicGraph();

      final controller = StudioSimulationController(
        graph: graph,
        runId: 'demo',
        initialActors: {actorRef},
      );

      controller.perform(graph.actionDefinitions.first);

      expect(controller.trace, isNotEmpty);

      controller.reset();

      expect(controller.runId, 'demo');
      expect(controller.trace, isEmpty);
      expect(controller.events, isEmpty);
      expect(controller.observations, isEmpty);
      expect(controller.state, SimulationState.initial(graph));
      expect(controller.relevantActors, {actorRef});
    });

    test('restart begins a new exploration', () {
      final graph = buildBasicGraph();

      final controller = StudioSimulationController(graph: graph);

      controller.perform(graph.actionDefinitions.first);

      final firstRun = controller.run;

      controller.restart(runId: 'second');

      expect(controller.runId, 'second');
      expect(identical(controller.run, firstRun), isFalse);
      expect(controller.trace, isEmpty);
      expect(controller.isAtStart, isTrue);
    });

    test('never mutates the authored graph', () {
      final graph = buildBasicGraph();

      final before = graph.stateVariables
          .map((variable) => variable.initialValue)
          .toList();

      StudioSimulationController(graph: graph)
        ..perform(graph.actionDefinitions.first)
        ..reset()
        ..restart();

      expect(
        graph.stateVariables.map((variable) => variable.initialValue).toList(),
        before,
      );
    });
  });

  group('available actions', () {
    test('follow relevance and preconditions', () {
      final graph = buildBasicGraph();
      final controller = StudioSimulationController(graph: graph);

      expect(
        controller.availableActionsFor(actorRef),
        isEmpty,
        reason: 'not relevant yet',
      );

      controller.perform(graph.actionDefinitions.first);

      expect(controller.isRelevant(actorRef), isTrue);
      expect(
        controller.availableActionsFor(actorRef),
        isEmpty,
        reason: 'relevant now, but the precondition no longer holds',
      );
    });
  });
}

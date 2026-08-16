import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/simulation/propagation_evaluator.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';

import 'simulation_fixture.dart';

/// Tests for the execution layer.
///
/// Behaviour triggering now depends on observability as well as trigger type,
/// so the fixtures carry the relationships that give each behaviour a line of
/// sight. Observability itself is tested in observability_test.dart.
void main() {
  const evaluator = StudioPropagationEvaluator();

  group('availability', () {
    test('an action is available when its precondition holds', () {
      final graph = buildBasicGraph();
      final state = SimulationState.initial(graph);

      expect(evaluator.availableActions(graph, state), hasLength(1));
    });

    test('an action is unavailable when its precondition fails', () {
      final graph = buildBasicGraph();

      final state = SimulationState.initial(
        graph,
      ).withValue(engineMode.key, 'Busy');

      expect(evaluator.availableActions(graph, state), isEmpty);
    });

    test('running an unavailable action changes nothing', () {
      final graph = buildBasicGraph();

      final state = SimulationState.initial(
        graph,
      ).withValue(engineMode.key, 'Busy');

      final result = evaluator.run(graph.actionDefinitions.first, graph, state);

      expect(result.actionWasAvailable, isFalse);
      expect(result.state, state);
      expect(result.trace.entries, isEmpty);
      expect(
        result.trace.termination,
        StudioTraceTermination.preconditionNotMet,
      );
    });

    test('availability can be filtered by initiator', () {
      final graph = buildBasicGraph();
      final state = SimulationState.initial(graph);

      expect(
        evaluator.availableActions(graph, state, initiator: actorRef),
        hasLength(1),
      );
      expect(
        evaluator.availableActions(graph, state, initiator: monitorRef),
        isEmpty,
      );
    });
  });

  group('outcome selection', () {
    test('selects the first matching outcome', () {
      final graph = buildBasicGraph();
      final state = SimulationState.initial(graph);

      final result = evaluator.run(graph.actionDefinitions.first, graph, state);

      final actionEntry = result.trace.entries.first;

      expect(actionEntry.outcomeIndex, 0);
      expect(actionEntry.usedOtherwise, isFalse);
    });

    test('falls back to otherwise when no condition matches', () {
      final graph = buildBasicGraph();

      // The monitor is already alerting, so its only conditional outcome
      // cannot match and the fallback must run.
      final state = SimulationState.initial(
        graph,
      ).withValue(monitorSignal.key, 'Alerting');

      final result = evaluator.run(graph.actionDefinitions.first, graph, state);

      final monitorEntry = result.trace.entries.last;

      expect(monitorEntry.definitionId, 'beh.notice');
      expect(monitorEntry.usedOtherwise, isTrue);
      expect(monitorEntry.outcomeIndex, -1);
      expect(monitorEntry.emittedEvents, isEmpty);
    });
  });

  group('effects and events', () {
    test('action effects change state and record both sides', () {
      final graph = buildBasicGraph();
      final state = SimulationState.initial(graph);

      final result = evaluator.run(graph.actionDefinitions.first, graph, state);

      expect(result.state.valueOf(engineMode), 'Busy');
      expect(
        state.valueOf(engineMode),
        'Ready',
        reason: 'the state passed in must not be mutated',
      );

      final change = result.trace.entries.first.stateChanges.single;

      expect(change.variableId, 'engine.mode');
      expect(change.previousValue, 'Ready');
      expect(change.newValue, 'Busy');
    });

    test('emitted events carry type, source and a unique sequence', () {
      final graph = buildBasicGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      final events = result.trace.allEvents;

      expect(events.map((event) => event.typeId), ['pinged', 'noticed']);
      expect(events.first.source, engineRef, reason: 'the action target');
      expect(events.last.source, monitorRef, reason: 'the behaviour owner');
      expect(events.map((event) => event.sequence).toSet(), hasLength(2));

      expect(
        events.first.participants,
        [actorRef, engineRef],
        reason: 'an action involves its initiator and its target',
      );
      expect(
        events.last.participants,
        [monitorRef],
        reason: 'a behaviour involves its owner',
      );
    });
  });

  group('behaviour triggering', () {
    test('a behaviour fires on its trigger event and propagates', () {
      final graph = buildBasicGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      expect(
        result.trace.entries.map((entry) => entry.definitionId),
        ['act.ping', 'beh.notice'],
      );

      expect(result.state.valueOf(monitorSignal), 'Alerting');
      expect(result.trace.termination, StudioTraceTermination.quiescence);
    });

    test('the behaviour records the event that triggered it', () {
      final graph = buildBasicGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      final behaviorEntry = result.trace.entries.last;

      expect(behaviorEntry.kind, StudioTraceCauseKind.behavior);
      expect(behaviorEntry.triggeringEvent?.typeId, 'pinged');
      expect(behaviorEntry.depth, 1);
    });
  });

  group('determinism', () {
    test('the same action from the same state repeats exactly', () {
      final graph = buildBasicGraph();
      final state = SimulationState.initial(graph);

      final first = evaluator.run(graph.actionDefinitions.first, graph, state);
      final second = evaluator.run(graph.actionDefinitions.first, graph, state);

      expect(first.state, second.state);
      expect(first.trace.entries.length, second.trace.entries.length);

      for (var index = 0; index < first.trace.entries.length; index++) {
        final a = first.trace.entries[index];
        final b = second.trace.entries[index];

        expect(a.definitionId, b.definitionId);
        expect(a.outcomeIndex, b.outcomeIndex);
        expect(a.usedOtherwise, b.usedOtherwise);
        expect(
          a.emittedEvents.map((event) => event.sequence),
          b.emittedEvents.map((event) => event.sequence),
        );
      }
    });
  });

  group('termination safeguards', () {
    test('a behaviour does not react to its own emission', () {
      final graph = buildSelfEmittingGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      // Action, then the echo behaviour once. Its own emission is ignored.
      expect(result.trace.entries, hasLength(2));
      expect(result.trace.termination, StudioTraceTermination.quiescence);
    });

    test('mutually triggering behaviours stop at the depth bound', () {
      final graph = buildPingPongGraph();

      const bounded = StudioPropagationEvaluator(maximumDepth: 3);

      final result = bounded.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      expect(result.trace.termination, StudioTraceTermination.depthLimit);
      expect(result.trace.notes, isNotEmpty);
      expect(result.trace.entries.length, lessThanOrEqualTo(5));
    });

    test('a trigger cycle is reported statically', () {
      final graph = buildPingPongGraph();

      const validator = StudioGraphValidator();

      final codes = validator
          .validate(graph)
          .issues
          .map((issue) => issue.code)
          .toSet();

      expect(codes, contains('behavior.trigger_cycle'));
    });
  });

  group('trace causality', () {
    test('every entry after the first names the event that caused it', () {
      final graph = buildBasicGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      expect(result.trace.entries.first.triggeringEvent, isNull);

      for (final entry in result.trace.entries.skip(1)) {
        expect(entry.triggeringEvent, isNotNull);
      }
    });

    test('an event can be traced back to the step that emitted it', () {
      final graph = buildBasicGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      final pinged = result.trace.allEvents.first;

      expect(result.trace.entryThatEmitted(pinged)?.definitionId, 'act.ping');
    });

    test('the causal chain reaches back to the chosen action', () {
      final graph = buildBasicGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      final chain = result.trace.causalChainTo(result.trace.entries.last);

      expect(
        chain.map((entry) => entry.definitionId),
        ['act.ping', 'beh.notice'],
      );
    });
  });

  group('observations', () {
    test('a run reports who perceived each occurrence', () {
      final graph = buildBasicGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      expect(result.observations, isNotEmpty);

      final observers = result.observations
          .map((observation) => observation.observer)
          .toSet();

      expect(observers, contains(actorRef));
      expect(observers, contains(monitorRef));
    });
  });
}

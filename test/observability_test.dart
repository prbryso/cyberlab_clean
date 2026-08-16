import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/information_flow.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/simulation/observability_index.dart';
import 'package:systems_studio/engine/simulation/propagation_evaluator.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';

import 'simulation_fixture.dart';

void main() {
  const evaluator = StudioPropagationEvaluator();

  group('information-flow classification', () {
    test('delivery types carry information forward', () {
      expect(
        StudioRelationshipType.sendsDataTo.informationFlow,
        StudioInformationFlow.forward,
      );
      expect(
        StudioRelationshipType.notifies.informationFlow,
        StudioInformationFlow.forward,
      );
    });

    test('watching types carry information backward', () {
      expect(
        StudioRelationshipType.monitors.informationFlow,
        StudioInformationFlow.backward,
      );
      expect(
        StudioRelationshipType.detects.informationFlow,
        StudioInformationFlow.backward,
      );
    });

    test('structural and intent types carry nothing', () {
      for (final type in [
        StudioRelationshipType.contains,
        StudioRelationshipType.dependsOn,
        StudioRelationshipType.protects,
        StudioRelationshipType.threatens,
        StudioRelationshipType.stores,
        StudioRelationshipType.participatesIn,
      ]) {
        expect(
          type.carriesInformation,
          isFalse,
          reason: '${type.name} should not carry information',
        );
      }
    });
  });

  group('directionality', () {
    test('a monitors edge carries information against its own direction', () {
      // monitor --monitors--> engine
      expect(
        monitorWatchesEngine.carriesInformationFrom('engine', 'monitor'),
        isTrue,
        reason: 'what happens at the engine reaches the monitor',
      );
      expect(
        monitorWatchesEngine.carriesInformationFrom('monitor', 'engine'),
        isFalse,
        reason: 'watching something does not tell it about you',
      );
    });

    test('a notifies edge carries information along its direction', () {
      expect(
        monitorNotifiesEngine.carriesInformationFrom('monitor', 'engine'),
        isTrue,
      );
      expect(
        monitorNotifiesEngine.carriesInformationFrom('engine', 'monitor'),
        isFalse,
      );
    });
  });

  group('observability index', () {
    test('reaches an observer with a direct line', () {
      final index = StudioObservabilityIndex.forGraph(buildBasicGraph());

      final route = index.routeBetween('engine', monitorRef);

      expect(route, isNotNull);
      expect(route!.distance, 1);
      expect(route.relationshipIds, ['monitor.monitors.engine']);
    });

    test('does not reach an observer with no line', () {
      final index = StudioObservabilityIndex.forGraph(
        buildUnobservableGraph(),
      );

      expect(index.routeBetween('engine', monitorRef), isNull);
    });

    test('an element is not a wire: no relaying by default', () {
      // monitor watches engine and notifies engine, so a naive traversal
      // would let information loop through. One hop is the default.
      final index = StudioObservabilityIndex.forGraph(buildPingPongGraph());

      expect(index.maximumDistance, 1);

      for (final route in index.routesFrom('engine')) {
        expect(route.distance, 1);
      }
    });
  });

  group('observation basis and fidelity', () {
    test('participants observe at full fidelity without a relationship', () {
      final index = StudioObservabilityIndex.forGraph(
        buildUnobservableGraph(),
      );

      const event = StudioEvent(
        sequence: 0,
        typeId: 'pinged',
        source: engineRef,
        participants: [actorRef, engineRef],
      );

      final observations = index.observationsOf(event);

      expect(observations, hasLength(2));
      expect(
        observations.every(
          (observation) =>
              observation.basis == StudioObservationBasis.participation &&
              observation.fidelity == StudioObservationFidelity.full,
        ),
        isTrue,
      );
    });

    test('a direct structural observer receives full fidelity', () {
      final index = StudioObservabilityIndex.forGraph(buildBasicGraph());

      const event = StudioEvent(
        sequence: 0,
        typeId: 'pinged',
        source: engineRef,
        participants: [engineRef],
      );

      final monitorObservation = index
          .observationsOf(event)
          .firstWhere((observation) => observation.observer == monitorRef);

      expect(
        monitorObservation.basis,
        StudioObservationBasis.informationFlow,
      );
      expect(monitorObservation.fidelity, StudioObservationFidelity.full);
      expect(monitorObservation.distance, 1);
    });

    test('a second-hand observer receives existence only', () {
      // Opt in to relaying, which the default deliberately forbids.
      final index = StudioObservabilityIndex.forGraph(
        buildRelayGraph(),
        maximumDistance: 2,
      );

      const event = StudioEvent(
        sequence: 0,
        typeId: 'ping',
        source: engineRef,
        participants: [engineRef],
      );

      final observations = index.observationsOf(event);

      final nearby = observations.singleWhere(
        (observation) => observation.observer == monitorRef,
      );

      final faraway = observations.singleWhere(
        (observation) => observation.observer == systemRef,
      );

      expect(nearby.distance, 1);
      expect(nearby.fidelity, StudioObservationFidelity.full);

      expect(faraway.distance, 2);
      expect(
        faraway.fidelity,
        StudioObservationFidelity.existenceOnly,
        reason: 'second-hand awareness carries no detail',
      );
      expect(faraway.channelRelationshipIds, [
        'engine.sends.monitor',
        'monitor.sends.sys',
      ]);
    });

    test('relaying does not happen at the default distance', () {
      final index = StudioObservabilityIndex.forGraph(buildRelayGraph());

      expect(index.routeBetween('engine', monitorRef), isNotNull);
      expect(
        index.routeBetween('engine', systemRef),
        isNull,
        reason: 'the monitor is not a wire',
      );
    });

    test('a notified observer receives full fidelity', () {
      final index = StudioObservabilityIndex.forGraph(buildPingPongGraph());

      const event = StudioEvent(
        sequence: 0,
        typeId: 'pong',
        source: monitorRef,
        participants: [monitorRef],
      );

      final engineObservation = index
          .observationsOf(event)
          .firstWhere((observation) => observation.observer == engineRef);

      expect(engineObservation.basis, StudioObservationBasis.notification);
      expect(engineObservation.fidelity, StudioObservationFidelity.full);
    });
  });

  group('behaviour gating', () {
    test('a behaviour triggers when its owner can observe the event', () {
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
    });

    test('the same behaviour does not trigger without a line of sight', () {
      final graph = buildUnobservableGraph();

      final result = evaluator.run(
        graph.actionDefinitions.first,
        graph,
        SimulationState.initial(graph),
      );

      // The trigger type still matches. Only observability changed.
      expect(
        result.trace.entries.map((entry) => entry.definitionId),
        ['act.ping'],
      );
      expect(result.state.valueOf(monitorSignal), 'Quiet');
    });
  });
}

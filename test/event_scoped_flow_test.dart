import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_event_type.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/observability_index.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';

/// A connection being able to carry information does not mean it carries
/// everything.
void main() {
  const validator = StudioGraphValidator();

  const engineRef = StudioElementRef.node('engine');
  const mfaRef = StudioElementRef.node('mfa');
  const monitorRef = StudioElementRef.node('monitor');
  const adminRef = StudioElementRef.node('admin');

  StudioGraphNode node(String id, [StudioGraphNodeType type =
      StudioGraphNodeType.component]) {
    return StudioGraphNode(
      id: id,
      label: id,
      type: type,
      parentId: id == 'sys' ? null : 'sys',
    );
  }

  /// An engine that can command an MFA service and is watched by a monitor,
  /// which in turn notifies an administrator.
  StudioSystemGraph buildGraph({
    List<String>? engineToMfaCarries,
    List<String>? monitorToAdminCarries,
    List<String>? engineToMonitorCarries,
    StudioRelationshipType containmentTypeFilterTarget =
        StudioRelationshipType.contains,
    List<String>? containmentCarries,
  }) {
    return StudioSystemGraph(
      systemId: 'sys',
      nodes: [
        node('sys', StudioGraphNodeType.system),
        node('engine'),
        node('mfa'),
        node('monitor'),
        node('admin', StudioGraphNodeType.actor),
      ],
      relationships: [
        StudioRelationship(
          id: 'engine_commands_mfa',
          sourceId: 'engine',
          targetId: 'mfa',
          type: StudioRelationshipType.sendsCommandTo,
          label: 'commands',
          carriedEventTypeIds: engineToMfaCarries,
        ),
        StudioRelationship(
          id: 'engine_sends_monitor',
          sourceId: 'engine',
          targetId: 'monitor',
          type: StudioRelationshipType.sendsDataTo,
          label: 'reports to',
          carriedEventTypeIds: engineToMonitorCarries,
        ),
        StudioRelationship(
          id: 'monitor_notifies_admin',
          sourceId: 'monitor',
          targetId: 'admin',
          type: StudioRelationshipType.notifies,
          label: 'notifies',
          carriedEventTypeIds: monitorToAdminCarries,
        ),
        StudioRelationship(
          id: 'sys_contains_engine',
          sourceId: 'sys',
          targetId: 'engine',
          type: containmentTypeFilterTarget,
          label: 'contains',
          carriedEventTypeIds: containmentCarries,
        ),
      ],
      eventTypes: const [
        StudioEventType(id: 'auth_failed', name: 'Authentication failed'),
        StudioEventType(id: 'mfa_required', name: 'MFA required'),
        StudioEventType(id: 'alert_raised', name: 'Alert raised'),
      ],
    );
  }

  StudioEvent eventOf(String typeId, StudioElementRef source) {
    return StudioEvent(
      sequence: 0,
      typeId: typeId,
      source: source,
      participants: [source],
    );
  }

  Set<String> observerIdsOf(
    StudioSystemGraph graph,
    String typeId,
    StudioElementRef source, {
    int maximumDistance = 1,
  }) {
    final index = StudioObservabilityIndex.forGraph(
      graph,
      maximumDistance: maximumDistance,
    );

    return index
        .observationsOf(eventOf(typeId, source))
        .map((observation) => observation.observer.id)
        .toSet();
  }

  group('an unrestricted relationship carries everything', () {
    test('every event reaches every structural observer, as before', () {
      final graph = buildGraph();

      expect(
        observerIdsOf(graph, 'auth_failed', engineRef),
        containsAll(['mfa', 'monitor']),
      );
      expect(
        observerIdsOf(graph, 'mfa_required', engineRef),
        containsAll(['mfa', 'monitor']),
      );
    });
  });

  group('a restricted relationship carries only what it lists', () {
    test('a listed event traverses', () {
      final graph = buildGraph(engineToMfaCarries: const ['mfa_required']);

      expect(observerIdsOf(graph, 'mfa_required', engineRef), contains('mfa'));
    });

    test('an unlisted event does not', () {
      final graph = buildGraph(engineToMfaCarries: const ['mfa_required']);

      expect(
        observerIdsOf(graph, 'auth_failed', engineRef),
        isNot(contains('mfa')),
        reason: 'being able to command MFA is not being told about failures',
      );
    });

    test('other channels from the same source are unaffected', () {
      final graph = buildGraph(engineToMfaCarries: const ['mfa_required']);

      expect(
        observerIdsOf(graph, 'auth_failed', engineRef),
        contains('monitor'),
        reason: 'restricting one channel must not restrict another',
      );
    });

    test('an empty list carries nothing at all', () {
      final graph = buildGraph(engineToMfaCarries: const []);

      for (final typeId in ['auth_failed', 'mfa_required', 'alert_raised']) {
        expect(
          observerIdsOf(graph, typeId, engineRef),
          isNot(contains('mfa')),
          reason: '$typeId must not traverse a channel that carries nothing',
        );
      }
    });
  });

  group('filtering removes the observation rather than weakening it', () {
    test('a blocked event produces no observation, not existenceOnly', () {
      final graph = buildGraph(engineToMfaCarries: const ['mfa_required']);

      final index = StudioObservabilityIndex.forGraph(graph);

      final observations = index.observationsOf(
        eventOf('auth_failed', engineRef),
      );

      expect(
        observations.where((each) => each.observer == mfaRef),
        isEmpty,
        reason: '"this channel does not carry that" is not "they heard '
            'something vague"',
      );

      // And nothing anywhere was quietly downgraded to compensate.
      expect(
        observations.every(
          (each) => each.fidelity == StudioObservationFidelity.full,
        ),
        isTrue,
      );
    });

    test('a behaviour cannot react to an event that cannot reach it', () {
      final graph = buildGraph(engineToMfaCarries: const ['mfa_required']);

      final index = StudioObservabilityIndex.forGraph(graph);

      expect(
        index.canObserve(mfaRef, eventOf('auth_failed', engineRef)),
        isFalse,
      );
      expect(
        index.canObserve(mfaRef, eventOf('mfa_required', engineRef)),
        isTrue,
      );
    });

    test('taking part still overrides any channel restriction', () {
      final graph = buildGraph(engineToMfaCarries: const []);

      final event = StudioEvent(
        sequence: 0,
        typeId: 'auth_failed',
        source: engineRef,
        participants: const [engineRef, mfaRef],
      );

      final index = StudioObservabilityIndex.forGraph(graph);

      expect(index.canObserve(mfaRef, event), isTrue);

      final observation = index
          .observationsOf(event)
          .firstWhere((each) => each.observer == mfaRef);

      expect(observation.basis, StudioObservationBasis.participation);
      expect(observation.fidelity, StudioObservationFidelity.full);
    });
  });

  group('existing semantics are untouched', () {
    test('directionality still decides who can hear anything', () {
      final graph = buildGraph(engineToMfaCarries: const ['mfa_required']);

      // The command channel points at MFA, so nothing travels back up it.
      expect(
        observerIdsOf(graph, 'mfa_required', mfaRef),
        isNot(contains('engine')),
      );
    });

    test('notification basis survives filtering', () {
      final graph = buildGraph(monitorToAdminCarries: const ['alert_raised']);

      final index = StudioObservabilityIndex.forGraph(graph);

      final observation = index
          .observationsOf(eventOf('alert_raised', monitorRef))
          .firstWhere((each) => each.observer == adminRef);

      expect(observation.basis, StudioObservationBasis.notification);
      expect(observation.fidelity, StudioObservationFidelity.full);
      expect(observation.channelRelationshipIds, ['monitor_notifies_admin']);
    });

    test('a notification channel delivers only what it carries', () {
      final graph = buildGraph(monitorToAdminCarries: const ['alert_raised']);

      expect(
        observerIdsOf(graph, 'auth_failed', monitorRef),
        isNot(contains('admin')),
        reason: 'notifying someone of alerts is not notifying them of '
            'everything',
      );
    });
  });

  group('multi-hop routes', () {
    test('every hop must permit the event', () {
      // engine -> monitor -> admin, both hops allowing the alert.
      final graph = buildGraph(
        engineToMonitorCarries: const ['alert_raised'],
        monitorToAdminCarries: const ['alert_raised'],
      );

      expect(
        observerIdsOf(graph, 'alert_raised', engineRef, maximumDistance: 2),
        contains('admin'),
      );
    });

    test('one restrictive hop blocks the whole route', () {
      // The far hop allows it; the near hop does not.
      final graph = buildGraph(
        engineToMonitorCarries: const ['mfa_required'],
        monitorToAdminCarries: const ['alert_raised'],
      );

      final observers = observerIdsOf(
        graph,
        'alert_raised',
        engineRef,
        maximumDistance: 2,
      );

      expect(
        observers,
        isNot(contains('admin')),
        reason: 'a chain is as permissive as its narrowest link',
      );
      expect(
        observers,
        isNot(contains('monitor')),
        reason: 'it could not complete the first leg either',
      );
    });

    test('a blocked far hop leaves the near observer intact', () {
      final graph = buildGraph(
        engineToMonitorCarries: const ['alert_raised'],
        monitorToAdminCarries: const ['mfa_required'],
      );

      final observers = observerIdsOf(
        graph,
        'alert_raised',
        engineRef,
        maximumDistance: 2,
      );

      expect(observers, contains('monitor'));
      expect(observers, isNot(contains('admin')));
    });
  });

  group('validation', () {
    Set<String> codesOf(StudioSystemGraph graph) {
      return validator
          .validate(graph)
          .issues
          .map((issue) => issue.code)
          .toSet();
    }

    test('an unknown event type is an error', () {
      final codes = codesOf(buildGraph(engineToMfaCarries: const ['nope']));

      expect(codes, contains('relationship.carries_unknown_event_type'));
    });

    test('a duplicate event type is an error', () {
      final codes = codesOf(
        buildGraph(
          engineToMfaCarries: const ['mfa_required', 'mfa_required'],
        ),
      );

      expect(codes, contains('relationship.duplicate_carried_event_type'));
    });

    test('a filter on a non-information-bearing relationship is an error', () {
      final codes = codesOf(buildGraph(containmentCarries: const ['alert_raised']));

      expect(codes, contains('relationship.filter_on_non_information_bearing'));
    });

    test('an empty list is a warning, not an error', () {
      final result = validator.validate(
        buildGraph(engineToMfaCarries: const []),
      );

      final codes = result.issues.map((issue) => issue.code).toSet();

      expect(codes, contains('relationship.carries_nothing'));

      expect(
        result.issues
            .where(
              (issue) => issue.code == 'relationship.carries_nothing',
            )
            .single
            .severity,
        StudioGraphValidationSeverity.warning,
      );
    });

    test('a legitimate filter raises nothing', () {
      final codes = codesOf(
        buildGraph(engineToMfaCarries: const ['mfa_required']),
      );

      expect(
        codes.where((code) => code.startsWith('relationship.carries')),
        isEmpty,
      );
      expect(
        codes,
        isNot(contains('relationship.filter_on_non_information_bearing')),
      );
    });

    test('saying nothing raises nothing', () {
      final codes = codesOf(buildGraph());

      expect(
        codes.where((code) => code.contains('carried')),
        isEmpty,
      );
      expect(
        codes.where((code) => code.startsWith('relationship.carries')),
        isEmpty,
      );
    });
  });
}

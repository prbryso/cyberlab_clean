import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// MFA answers the challenge. The engine decides the authentication.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const mfa = StudioElementRef.node('mfa_service');
  const authEngine = StudioElementRef.node('authentication_engine');
  const monitoring = StudioElementRef.node('security_monitoring');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  final attempt = graph.actionDefinitions.firstWhere(
    (action) => action.id == 'attacker.attempt_authentication',
  );

  String valueOf(SimulationRun run, String variableId) =>
      run.state.valueOf(graph.stateVariableById(variableId)!);

  /// A run in which the store cannot refuse the password, so the second
  /// factor is what decides.
  SimulationRun runWith({required bool trustedDevice}) {
    return SimulationRun.start(
      graph,
      scenario: StudioScenario(
        id: 'test.second_factor_decides',
        name: 'Second factor decides',
        initialActors: {attacker},
        initialStateOverrides: {
          'credential_store.integrity': 'Compromised',
          if (trustedDevice) 'user_device.trust': 'Trusted',
        },
      ),
    )..perform(attempt);
  }

  /// Which element emitted [typeId], by the trace entry that produced it.
  StudioElementRef emitterOf(SimulationRun run, String typeId) {
    for (final entry in run.trace) {
      for (final StudioEvent event in entry.emittedEvents) {
        if (event.typeId == typeId) {
          return event.source;
        }
      }
    }

    fail('nothing emitted "$typeId"');
  }

  Set<String> emittedBy(SimulationRun run) =>
      run.events.map((event) => event.typeId).toSet();

  group('MFA answers, and only answers', () {
    test('it reports an answer rather than a verdict', () {
      for (final trusted in [true, false]) {
        final run = runWith(trustedDevice: trusted);

        expect(emittedBy(run), contains('mfa_challenge_answered'));
        expect(emitterOf(run, 'mfa_challenge_answered'), mfa);
      }
    });

    test('it emits neither final authentication result', () {
      final approved = runWith(trustedDevice: true);
      final denied = runWith(trustedDevice: false);

      expect(emitterOf(approved, 'authentication_succeeded'), authEngine);
      expect(emitterOf(denied, 'authentication_failed'), authEngine);

      // Nothing MFA emitted was a final result.
      for (final run in [approved, denied]) {
        final fromMfa = <String>{
          for (final entry in run.trace)
            if (entry.subject == mfa)
              for (final event in entry.emittedEvents) event.typeId,
        };

        expect(fromMfa, {'mfa_challenge_answered'});
      }
    });

    test('it changes only its own state', () {
      for (final trusted in [true, false]) {
        final run = runWith(trustedDevice: trusted);

        final entry = run.trace.firstWhere(
          (each) => each.definitionId == 'mfa_service.answer_challenge',
        );

        expect(
          entry.stateChanges.map((change) => change.variableId).toSet(),
          {'mfa_service.challenge'},
          reason: 'validating a factor is not deciding an authentication',
        );

        expect(entry.stateChanges.single.owner, mfa);
      }
    });
  });

  group('the engine receives the answer and decides', () {
    test('it observes the answer through the return path', () {
      final run = runWith(trustedDevice: true);

      final observation = run
          .observationsFor(authEngine)
          .firstWhere(
            (each) => each.event.typeId == 'mfa_challenge_answered',
          );

      expect(observation.channelRelationshipIds, ['mfa_reports_to_engine']);
    });

    test('the engine is the one that completes the authentication', () {
      for (final trusted in [true, false]) {
        final run = runWith(trustedDevice: trusted);

        final entry = run.trace.firstWhere(
          (each) =>
              each.definitionId ==
              'authentication_engine.complete_authentication',
        );

        expect(entry.subject, authEngine);
      }
    });

    test('an approved factor grants access', () {
      final run = runWith(trustedDevice: true);

      expect(valueOf(run, 'mfa_service.challenge'), 'Approved');
      expect(valueOf(run, 'login_interface.stage'), 'Access granted');
      expect(valueOf(run, 'user_account.access'), 'Compromised');
      expect(valueOf(run, 'authentication_engine.mode'), 'Ready');
      expect(emittedBy(run), contains('authentication_succeeded'));
    });

    test('a denied factor refuses, and leaves the account alone', () {
      final run = runWith(trustedDevice: false);

      expect(valueOf(run, 'mfa_service.challenge'), 'Denied');
      expect(valueOf(run, 'login_interface.stage'), 'Access denied');
      expect(
        valueOf(run, 'user_account.access'),
        'Active',
        reason: 'the password was accepted and the account still held',
      );
      expect(valueOf(run, 'authentication_engine.mode'), 'Ready');
      expect(emittedBy(run), contains('authentication_failed'));
    });

    test('the engine returns to Ready either way, by its own effect', () {
      for (final trusted in [true, false]) {
        final run = runWith(trustedDevice: trusted);

        final entry = run.trace.firstWhere(
          (each) =>
              each.definitionId ==
              'authentication_engine.complete_authentication',
        );

        expect(
          entry.stateChanges.any(
            (change) =>
                change.variableId == 'authentication_engine.mode' &&
                change.newValue == 'Ready',
          ),
          isTrue,
          reason: 'the engine puts its own mode back, not the service',
        );
      }
    });
  });

  group('a refused second factor is noticed, without a new relationship', () {
    test('monitoring reacts because it watches the engine', () {
      final run = runWith(trustedDevice: false);

      expect(
        run
            .observationsFor(monitoring)
            .map((observation) => observation.event.typeId),
        contains('authentication_failed'),
      );

      expect(
        run.trace.map((entry) => entry.definitionId),
        contains('security_monitoring.notice_failure'),
      );

      expect(emittedBy(run), contains('security_alert_raised'));
      expect(valueOf(run, 'security_monitoring.signal'), 'Alerting');
    });

    test('and the administrator is drawn in', () {
      final run = runWith(trustedDevice: false);

      expect(
        run
            .observationsFor(administrator)
            .map((observation) => observation.event.typeId),
        {'security_alert_raised'},
      );

      expect(run.isRelevant(administrator), isTrue);
      expect(
        run.availableActionsFor(administrator).map((action) => action.id),
        contains('administrator.lock_account'),
      );
    });

    test('an approved factor raises nothing, though it is still seen', () {
      final run = runWith(trustedDevice: true);

      // Monitoring watches the engine, so it sees the success go past.
      expect(
        run
            .observationsFor(monitoring)
            .map((observation) => observation.event.typeId),
        contains('authentication_succeeded'),
      );

      // Its behaviour is about refusals, and there was none.
      expect(
        run.trace.map((entry) => entry.definitionId),
        isNot(contains('security_monitoring.notice_failure')),
      );
      expect(emittedBy(run), isNot(contains('security_alert_raised')));
      expect(run.isRelevant(administrator), isFalse);
    });

    test('MFA is never told about the failure it caused', () {
      final run = runWith(trustedDevice: false);

      expect(
        run
            .observationsFor(mfa)
            .map((observation) => observation.event.typeId),
        isNot(contains('authentication_failed')),
        reason: 'the engine refused the attempt; the service is not told '
            'what was concluded from its answer',
      );
    });

    test('what reaches MFA arrives by the command channel', () {
      final run = runWith(trustedDevice: false);

      final challenge = run
          .observationsFor(mfa)
          .firstWhere(
            (each) => each.event.typeId == 'mfa_challenge_required',
          );

      expect(challenge.basis, StudioObservationBasis.informationFlow);
      expect(challenge.channelRelationshipIds, ['engine_requests_mfa']);
    });

    test('and its own answer is not something it was told', () {
      final run = runWith(trustedDevice: false);

      final answer = run
          .observationsFor(mfa)
          .firstWhere(
            (each) => each.event.typeId == 'mfa_challenge_answered',
          );

      // Emitting something is a way of knowing it happened. That is not the
      // same as a channel having delivered it.
      expect(answer.basis, StudioObservationBasis.participation);
      expect(
        answer.channelRelationshipIds,
        isEmpty,
        reason: 'nothing carried it to MFA; MFA is where it came from',
      );
    });

    test('the command edge carries challenges and nothing else', () {
      final command = graph.relationshipById('engine_requests_mfa')!;

      expect(command.carriedEventTypeIds, ['mfa_challenge_required']);
      expect(command.sourceId, 'authentication_engine');
      expect(command.targetId, 'mfa_service');
    });
  });

  group('the causal record shows the round trip', () {
    test('out to the service and back to the engine', () {
      final causal = SimulationCausalGraph.fromRun(
        runWith(trustedDevice: false),
      );

      final out = causal.links.firstWhere((link) => link.to == mfa);

      expect(out.from, authEngine);
      expect(out.eventTypeId, 'mfa_challenge_required');
      expect(out.kind, StudioCausalLinkKind.automaticBehavior);

      final back = causal.links.firstWhere((link) => link.from == mfa);

      expect(back.to, authEngine);
      expect(back.eventTypeId, 'mfa_challenge_answered');
      expect(back.kind, StudioCausalLinkKind.automaticBehavior);

      // And the chain continues past the engine to the people who care.
      expect(
        causal.nodes.map((node) => node.element.id),
        containsAll(['security_monitoring', 'administrator']),
      );
    });

    test('the approved chain ends without an alert', () {
      final causal = SimulationCausalGraph.fromRun(
        runWith(trustedDevice: true),
      );

      expect(causal.links.any((link) => link.from == mfa), isTrue);
      expect(
        causal.nodes.map((node) => node.element.id),
        isNot(contains('administrator')),
      );
    });
  });

  group('the authored situations still behave', () {
    test('the takeover never reaches MFA', () {
      final takeover = graph.scenarios.firstWhere(
        (scenario) => scenario.id == 'attempted_account_takeover',
      );

      final run = SimulationRun.start(graph, scenario: takeover)
        ..perform(attempt);

      expect(emittedBy(run), isNot(contains('mfa_challenge_required')));
      expect(emittedBy(run), isNot(contains('mfa_challenge_answered')));
      expect(run.observationsFor(mfa), isEmpty);

      expect(run.isRelevant(administrator), isTrue);
      expect(valueOf(run, 'security_monitoring.signal'), 'Alerting');
    });

    test('the compromised store still completes through MFA', () {
      final compromised = graph.scenarios.firstWhere(
        (scenario) => scenario.id == 'compromised_credential_store',
      );

      final run = SimulationRun.start(graph, scenario: compromised)
        ..perform(attempt);

      expect(emittedBy(run), contains('mfa_challenge_answered'));
      expect(emitterOf(run, 'authentication_succeeded'), authEngine);
      expect(valueOf(run, 'login_interface.stage'), 'Access granted');
      expect(run.isRelevant(administrator), isFalse);
    });
  });
}

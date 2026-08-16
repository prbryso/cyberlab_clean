import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The third situation: the password is accepted and the second factor is not.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const mfa = StudioElementRef.node('mfa_service');
  const authEngine = StudioElementRef.node('authentication_engine');
  const monitoring = StudioElementRef.node('security_monitoring');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioScenario scenarioById(String id) =>
      graph.scenarios.firstWhere((scenario) => scenario.id == id);

  final takeover = scenarioById('attempted_account_takeover');
  final approved = scenarioById('compromised_credential_store');
  final denied = scenarioById('compromised_store_unrecognised_device');

  final attempt = graph.actionDefinitions.firstWhere(
    (action) => action.id == 'attacker.attempt_authentication',
  );

  String valueOf(SimulationRun run, String variableId) =>
      run.state.valueOf(graph.stateVariableById(variableId)!);

  SimulationRun runOf(StudioScenario scenario, {bool act = true}) {
    final run = SimulationRun.start(graph, scenario: scenario);

    if (act) {
      run.perform(attempt);
    }

    return run;
  }

  Set<String> emittedBy(SimulationRun run) =>
      run.events.map((event) => event.typeId).toSet();

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

  group('the situation as authored', () {
    test('three situations, uniquely identified, in a stable order', () {
      expect(graph.scenarios, hasLength(3));

      expect(
        graph.scenarios.map((scenario) => scenario.id),
        [
          'attempted_account_takeover',
          'compromised_credential_store',
          'compromised_store_unrecognised_device',
        ],
      );

      expect(
        graph.scenarios.map((scenario) => scenario.id).toSet(),
        hasLength(3),
      );
    });

    test('it establishes exactly the two facts it needs', () {
      expect(denied.initialStateOverrides, {
        'credential_store.integrity': 'Compromised',
        'user_device.trust': 'Untrusted',
      });

      expect(denied.initialActors, {attacker});
    });

    test('its starting state matches those facts', () {
      final run = runOf(denied, act: false);

      expect(valueOf(run, 'credential_store.integrity'), 'Compromised');
      expect(valueOf(run, 'user_device.trust'), 'Untrusted');
    });

    test('it differs from the approved situation in one fact only', () {
      final differing = <String>{
        for (final key in {
          ...approved.initialStateOverrides.keys,
          ...denied.initialStateOverrides.keys,
        })
          if (approved.initialStateOverrides[key] !=
              denied.initialStateOverrides[key])
            key,
      };

      expect(differing, {'user_device.trust'});
    });

    test('its name and description forecast nothing', () {
      for (final word in [
        'denied',
        'fail',
        'stops',
        'blocked',
        'refused',
        'will',
      ]) {
        expect(
          '${denied.name} ${denied.description}'.toLowerCase(),
          isNot(contains(word)),
          reason: 'a situation says where things stand, not how they end',
        );
      }
    });
  });

  group('the learner reaches it by acting', () {
    test('the same action is the one available', () {
      final run = runOf(denied, act: false);

      expect(
        run.availableActionsFor(attacker).map((action) => action.id),
        contains('attacker.attempt_authentication'),
      );
    });

    test('the password is accepted and a factor is asked for', () {
      final run = runOf(denied);

      expect(emittedBy(run), contains('mfa_challenge_required'));
      expect(emitterOf(run, 'mfa_challenge_required'), authEngine);
    });

    test('MFA answers, and refuses', () {
      final run = runOf(denied);

      expect(
        run
            .observationsFor(mfa)
            .map((observation) => observation.event.typeId),
        contains('mfa_challenge_required'),
      );

      expect(
        run.trace.map((entry) => entry.definitionId),
        contains('mfa_service.answer_challenge'),
      );

      expect(valueOf(run, 'mfa_service.challenge'), 'Denied');
      expect(emittedBy(run), contains('mfa_challenge_answered'));
      expect(emitterOf(run, 'mfa_challenge_answered'), mfa);
    });

    test('the engine receives the answer and refuses the attempt', () {
      final run = runOf(denied);

      expect(
        run
            .observationsFor(authEngine)
            .map((observation) => observation.event.typeId),
        contains('mfa_challenge_answered'),
      );

      expect(
        run.trace.map((entry) => entry.definitionId),
        contains('authentication_engine.complete_authentication'),
      );

      expect(emitterOf(run, 'authentication_failed'), authEngine);
    });
  });

  group('the refusal is noticed', () {
    test('monitoring observes it and reacts', () {
      final run = runOf(denied);

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
    });

    test('the administrator is drawn in and can act', () {
      final run = runOf(denied);

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

    test('the account survives, and everything settles', () {
      final run = runOf(denied);

      expect(valueOf(run, 'login_interface.stage'), 'Access denied');
      expect(valueOf(run, 'user_account.access'), 'Active');
      expect(valueOf(run, 'authentication_engine.mode'), 'Ready');
      expect(valueOf(run, 'security_monitoring.signal'), 'Alerting');
    });
  });

  group('reset', () {
    test('restores the situation, including the fact it depends on', () {
      final run = runOf(denied);

      expect(valueOf(run, 'mfa_service.challenge'), 'Denied');

      run.reset();

      expect(run.trace, isEmpty);
      expect(valueOf(run, 'credential_store.integrity'), 'Compromised');
      expect(valueOf(run, 'user_device.trust'), 'Untrusted');
      expect(valueOf(run, 'mfa_service.challenge'), 'Available');
      expect(valueOf(run, 'security_monitoring.signal'), 'Quiet');
      expect(run.relevantActors, {attacker});
    });

    test('and the branch is reachable again', () {
      final run = runOf(denied)..reset();

      run.perform(attempt);

      expect(valueOf(run, 'mfa_service.challenge'), 'Denied');
      expect(run.isRelevant(administrator), isTrue);
    });
  });

  group('switching between all three leaks nothing', () {
    test('each situation starts from its own facts', () {
      final controller = StudioSimulationController(
        graph: graph,
        runId: 'test',
        scenario: denied,
      );

      addTearDown(controller.dispose);

      controller.perform(attempt);

      expect(controller.isRelevant(administrator), isTrue);

      // Into the approved situation: trust must come back as Trusted.
      controller.restart(scenario: approved);

      expect(controller.isAtStart, isTrue);
      expect(controller.relevantActors, {attacker});
      expect(
        controller.state.valueOf(
          graph.stateVariableById('user_device.trust')!,
        ),
        'Trusted',
      );
      expect(
        controller.state.valueOf(
          graph.stateVariableById('security_monitoring.signal')!,
        ),
        'Quiet',
      );

      // Into the takeover: the store must be intact again.
      controller.restart(scenario: takeover);

      expect(
        controller.state.valueOf(
          graph.stateVariableById('credential_store.integrity')!,
        ),
        'Available',
      );
      expect(
        controller.state.valueOf(
          graph.stateVariableById('user_device.trust')!,
        ),
        'Untrusted',
      );

      // And back again, still behaving as itself.
      controller.restart(scenario: denied);
      controller.perform(attempt);

      expect(
        controller.state.valueOf(
          graph.stateVariableById('mfa_service.challenge')!,
        ),
        'Denied',
      );
      expect(controller.isRelevant(administrator), isTrue);
    });
  });

  group('the other two situations are unchanged', () {
    test('the takeover never involves MFA', () {
      final run = runOf(takeover);

      expect(emittedBy(run), isNot(contains('mfa_challenge_required')));
      expect(run.observationsFor(mfa), isEmpty);
      expect(run.isRelevant(administrator), isTrue);
    });

    test('the approved situation still succeeds, alone', () {
      final run = runOf(approved);

      expect(valueOf(run, 'mfa_service.challenge'), 'Approved');
      expect(valueOf(run, 'login_interface.stage'), 'Access granted');
      expect(emitterOf(run, 'authentication_succeeded'), authEngine);
      expect(run.isRelevant(administrator), isFalse);
    });
  });

  group('three situations, three causal records', () {
    Set<String> participantsOf(StudioScenario scenario) {
      return SimulationCausalGraph.fromRun(runOf(scenario))
          .nodes
          .map((node) => node.element.id)
          .toSet();
    }

    test('the same action produces three different chains', () {
      final one = participantsOf(takeover);
      final two = participantsOf(approved);
      final three = participantsOf(denied);

      // No MFA at all.
      expect(one, isNot(contains('mfa_service')));
      expect(one, containsAll(['security_monitoring', 'administrator']));

      // MFA, and nobody alerted.
      expect(two, contains('mfa_service'));
      expect(two, isNot(contains('administrator')));

      // MFA, and the alert reaches the administrator.
      expect(three, contains('mfa_service'));
      expect(three, containsAll(['security_monitoring', 'administrator']));

      // All three genuinely differ.
      expect({one, two, three}, hasLength(3));
    });

    test('the denied chain runs out to MFA and back before the alert', () {
      final causal = SimulationCausalGraph.fromRun(runOf(denied));

      final out = causal.links.firstWhere((link) => link.to == mfa);
      final back = causal.links.firstWhere((link) => link.from == mfa);

      expect(out.eventTypeId, 'mfa_challenge_required');
      expect(back.to, authEngine);
      expect(back.eventTypeId, 'mfa_challenge_answered');

      final alert = causal.links.firstWhere(
        (link) => link.to == administrator,
      );

      expect(alert.eventTypeId, 'security_alert_raised');
      expect(
        alert.sequence,
        greaterThan(back.sequence),
        reason: 'the alert follows the answer that caused it',
      );
    });
  });
}

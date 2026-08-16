import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';
import 'package:systems_studio/engine/simulation/studio_situation_snapshot.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// Authentication finishes when the second factor answers, not when the
/// password is accepted.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const mfa = StudioElementRef.node('mfa_service');
  const monitoring = StudioElementRef.node('security_monitoring');
  const authEngine = StudioElementRef.node('authentication_engine');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  String valueOf(SimulationRun run, String variableId) =>
      run.state.valueOf(graph.stateVariableById(variableId)!);

  /// The run as authored: the store is intact, so the password is refused.
  SimulationRun invalidCredentials() {
    return SimulationRun.start(graph, initialActors: {attacker})
      ..perform(actionById('attacker.attempt_authentication'));
  }

  /// A situation where the store can no longer refuse the offered evidence,
  /// which is what makes primary authentication succeed. Expressed as a
  /// scenario because that is the existing mechanism for establishing a
  /// starting state — no new content is authored for it.
  SimulationRun validCredentials({required bool trustedDevice}) {
    final overrides = <String, String>{
      'credential_store.integrity': 'Compromised',
      if (trustedDevice) 'user_device.trust': 'Trusted',
    };

    return SimulationRun.start(
      graph,
      scenario: StudioScenario(
        id: 'test.valid_primary',
        name: 'Valid primary credentials',
        initialActors: {attacker},
        initialStateOverrides: overrides,
      ),
    )..perform(actionById('attacker.attempt_authentication'));
  }

  Set<String> emittedTypeIdsOf(SimulationRun run) =>
      run.events.map((event) => event.typeId).toSet();

  Set<String> observedTypeIdsBy(SimulationRun run, StudioElementRef observer) {
    return run
        .observationsFor(observer)
        .map((observation) => observation.event.typeId)
        .toSet();
  }

  group('invalid primary credentials', () {
    test('no challenge is required, because nothing was accepted', () {
      expect(
        emittedTypeIdsOf(invalidCredentials()),
        isNot(contains('mfa_challenge_required')),
      );
    });

    test('MFA is not told about the refusal', () {
      final run = invalidCredentials();

      expect(emittedTypeIdsOf(run), contains('authentication_failed'));

      expect(
        observedTypeIdsBy(run, mfa),
        isNot(contains('authentication_failed')),
        reason: 'being reachable by command is not being on a feed',
      );

      expect(
        run.observationsFor(mfa),
        isEmpty,
        reason: 'MFA has no part in a refused password at all',
      );
    });

    test('monitoring still sees the refusal', () {
      expect(
        observedTypeIdsBy(invalidCredentials(), monitoring),
        contains('authentication_failed'),
      );
    });

    test('the administrator receives the alert and nothing else', () {
      final run = invalidCredentials();

      expect(
        observedTypeIdsBy(run, administrator),
        {'security_alert_raised'},
        reason: 'a notification channel delivers alerts, not everything '
            'monitoring ever notices',
      );
    });

    test('the account is untouched and the attempt is denied', () {
      final run = invalidCredentials();

      expect(valueOf(run, 'login_interface.stage'), 'Access denied');
      expect(valueOf(run, 'user_account.access'), 'Active');
      expect(valueOf(run, 'mfa_service.challenge'), 'Available');
    });
  });

  group('the canonical demonstration is unchanged', () {
    test('attacker to alert to administrator, with MFA absent', () {
      final run = invalidCredentials();

      expect(run.isRelevant(administrator), isTrue);
      expect(valueOf(run, 'security_monitoring.signal'), 'Alerting');

      expect(
        run.availableActionsFor(administrator).map((action) => action.id),
        contains('administrator.lock_account'),
      );

      // MFA appears nowhere in what happened.
      final causal = SimulationCausalGraph.fromRun(run);

      expect(
        causal.nodes.map((node) => node.element.id),
        isNot(contains('mfa_service')),
        reason: 'MFA had no part in this, so it is not in the record of it',
      );

      expect(
        causal.links.any((link) => link.to == mfa),
        isFalse,
      );
    });

    test('locking the account still works afterwards', () {
      final run = invalidCredentials()
        ..perform(actionById('administrator.lock_account'));

      expect(valueOf(run, 'user_account.access'), 'Locked');
    });
  });

  group('valid primary credentials require a second factor', () {
    test('a challenge is required rather than access granted', () {
      final run = validCredentials(trustedDevice: false);

      expect(emittedTypeIdsOf(run), contains('mfa_challenge_required'));

      expect(
        emittedTypeIdsOf(run),
        isNot(contains('authentication_succeeded')),
        reason: 'passing the password is not being let in',
      );
    });

    test('MFA observes the challenge through the command channel', () {
      final run = validCredentials(trustedDevice: false);

      final observation = run
          .observationsFor(mfa)
          .firstWhere(
            (each) => each.event.typeId == 'mfa_challenge_required',
          );

      expect(observation.channelRelationshipIds, ['engine_requests_mfa']);
      expect(observation.basis, StudioObservationBasis.informationFlow);
      expect(observation.fidelity, StudioObservationFidelity.full);
    });

    test('the MFA behaviour runs and moves the challenge state', () {
      final run = validCredentials(trustedDevice: false);

      expect(
        run.trace.map((entry) => entry.definitionId),
        contains('mfa_service.answer_challenge'),
      );

      expect(valueOf(run, 'mfa_service.challenge'), 'Denied');
    });
  });

  group('the second factor decides the outcome', () {
    test('an untrusted device is refused, and the account is safe', () {
      final run = validCredentials(trustedDevice: false);

      expect(valueOf(run, 'mfa_service.challenge'), 'Denied');
      expect(valueOf(run, 'login_interface.stage'), 'Access denied');
      expect(
        valueOf(run, 'user_account.access'),
        'Active',
        reason: 'the password was right and the account still held',
      );
      expect(valueOf(run, 'authentication_engine.mode'), 'Ready');
    });

    test('a trusted device satisfies it, and access completes', () {
      final run = validCredentials(trustedDevice: true);

      expect(valueOf(run, 'mfa_service.challenge'), 'Approved');
      expect(valueOf(run, 'login_interface.stage'), 'Access granted');
      expect(valueOf(run, 'user_account.access'), 'Compromised');
      expect(valueOf(run, 'authentication_engine.mode'), 'Ready');

      expect(emittedTypeIdsOf(run), contains('authentication_succeeded'));
    });

    test('the engine is left ready either way', () {
      for (final trusted in [true, false]) {
        expect(
          valueOf(
            validCredentials(trustedDevice: trusted),
            'authentication_engine.mode',
          ),
          'Ready',
          reason: 'a challenge that has answered is no longer outstanding',
        );
      }
    });
  });

  group('the causal record follows from the observations', () {
    test('MFA is a participant only when it was actually involved', () {
      final refused = SimulationCausalGraph.fromRun(invalidCredentials());
      final challenged = SimulationCausalGraph.fromRun(
        validCredentials(trustedDevice: false),
      );

      expect(refused.nodes.map((node) => node.element.id),
          isNot(contains('mfa_service')));

      expect(
        challenged.nodes.map((node) => node.element.id),
        contains('mfa_service'),
      );

      // And it arrived by the channel that carries challenges.
      final step = challenged.links.firstWhere((link) => link.to == mfa);

      expect(step.from, authEngine);
      expect(step.eventTypeId, 'mfa_challenge_required');
    });

    test('the overlay reports the same run, with no special casing', () {
      final run = validCredentials(trustedDevice: true);
      final situation = StudioSituationSnapshot.of(graph, run);

      expect(
        situation.overlay.steps.length,
        situation.causal.links.length,
      );

      expect(situation.overlay.involves('mfa_service'), isTrue);

      // The differences are measured against where this situation began, so
      // the compromised store it started from is not reported as a change.
      expect(
        situation.differenceFor('credential_store.integrity'),
        isNull,
      );
      expect(
        situation.differenceFor('mfa_service.challenge')?.isNow,
        'Approved',
      );
    });
  });

  group('the model still validates', () {
    test('the system opens without error', () {
      expect(() => engine.open(passwordSecurityDetail), returnsNormally);
    });

    test('the filters name event types the system declares', () {
      final declared = graph.eventTypes.map((type) => type.id).toSet();

      for (final relationship in graph.relationships) {
        for (final carried in relationship.carriedEventTypeIds ?? const []) {
          expect(
            declared,
            contains(carried),
            reason: '${relationship.id} carries "$carried"',
          );
        }
      }
    });
  });
}

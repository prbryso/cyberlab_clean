import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The same action, in the same system, taking a different path because the
/// situation began differently.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const mfa = StudioElementRef.node('mfa_service');
  const monitoring = StudioElementRef.node('security_monitoring');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioScenario scenarioById(String id) =>
      graph.scenarios.firstWhere((scenario) => scenario.id == id);

  final takeover = scenarioById('attempted_account_takeover');
  final compromised = scenarioById('compromised_credential_store');

  final attempt = graph.actionDefinitions.firstWhere(
    (action) => action.id == 'attacker.attempt_authentication',
  );

  String valueOf(SimulationRun run, String variableId) =>
      run.state.valueOf(graph.stateVariableById(variableId)!);

  /// A run of an authored situation, driven only through the public API a
  /// learner's actions go through.
  SimulationRun runOf(StudioScenario scenario, {bool act = true}) {
    final run = SimulationRun.start(graph, scenario: scenario);

    if (act) {
      run.perform(attempt);
    }

    return run;
  }

  Set<String> emittedBy(SimulationRun run) =>
      run.events.map((event) => event.typeId).toSet();

  group('the two situations are distinct and complete', () {
    test('all are authored, with unique identities', () {
      expect(graph.scenarios, hasLength(3));
      expect(
        graph.scenarios.map((scenario) => scenario.id).toSet(),
        hasLength(3),
      );
    });

    test('the new one says what is established, not what will happen', () {
      expect(compromised.name, 'Compromised Credential Store');
      expect(compromised.description, isNotEmpty);

      // A situation describes a starting point. Naming an outcome here would
      // tell the learner the answer before they had explored anything.
      for (final word in [
        'will',
        'granted',
        'denied',
        'succeed',
        'fail',
        'MFA',
      ]) {
        expect(
          compromised.description.toLowerCase(),
          isNot(contains(word.toLowerCase())),
          reason: 'the description must not forecast the path',
        );
      }
    });

    test('the attacker is present in both, and nobody else', () {
      expect(takeover.initialActors, {attacker});
      expect(compromised.initialActors, {attacker});
    });
  });

  group('the takeover situation is unchanged', () {
    test('the password is refused and monitoring raises the alarm', () {
      final run = runOf(takeover);

      expect(emittedBy(run), contains('authentication_failed'));
      expect(emittedBy(run), contains('security_alert_raised'));

      expect(valueOf(run, 'login_interface.stage'), 'Access denied');
      expect(valueOf(run, 'security_monitoring.signal'), 'Alerting');
      expect(valueOf(run, 'user_account.access'), 'Active');
    });

    test('the administrator becomes involved and can act', () {
      final run = runOf(takeover);

      expect(run.isRelevant(administrator), isTrue);
      expect(
        run.availableActionsFor(administrator).map((action) => action.id),
        contains('administrator.lock_account'),
      );
    });

    test('MFA takes no part in it at all', () {
      final run = runOf(takeover);

      expect(emittedBy(run), isNot(contains('mfa_challenge_required')));
      expect(run.observationsFor(mfa), isEmpty);

      expect(
        SimulationCausalGraph.fromRun(run).nodes.map((n) => n.element.id),
        isNot(contains('mfa_service')),
      );
    });
  });

  group('the compromised-store situation reaches the MFA branch', () {
    test('the same action is the one available to take', () {
      final run = runOf(compromised, act: false);

      expect(
        run.availableActionsFor(attacker).map((action) => action.id),
        contains('attacker.attempt_authentication'),
        reason: 'the learner reaches this branch by acting, not by set-up',
      );
    });

    test('primary authentication is accepted and a factor is asked for', () {
      final run = runOf(compromised);

      expect(emittedBy(run), contains('authentication_attempted'));
      expect(emittedBy(run), contains('mfa_challenge_required'));
      expect(
        emittedBy(run),
        isNot(contains('authentication_failed')),
        reason: 'nothing was refused in this situation',
      );
    });

    test('MFA observes the challenge and becomes a real participant', () {
      final run = runOf(compromised);

      final observation = run
          .observationsFor(mfa)
          .firstWhere((each) => each.event.typeId == 'mfa_challenge_required');

      expect(observation.channelRelationshipIds, ['engine_requests_mfa']);

      expect(
        run.trace.map((entry) => entry.definitionId),
        contains('mfa_service.answer_challenge'),
      );

      final causal = SimulationCausalGraph.fromRun(run);

      expect(causal.nodes.map((n) => n.element.id), contains('mfa_service'));

      final step = causal.links.firstWhere((link) => link.to == mfa);

      expect(step.eventTypeId, 'mfa_challenge_required');
    });

    test('the authored MFA outcome occurs, and access completes', () {
      final run = runOf(compromised);

      expect(valueOf(run, 'mfa_service.challenge'), 'Approved');
      expect(valueOf(run, 'login_interface.stage'), 'Access granted');
      expect(valueOf(run, 'user_account.access'), 'Compromised');
      expect(valueOf(run, 'authentication_engine.mode'), 'Ready');

      expect(emittedBy(run), contains('authentication_succeeded'));
    });

    test('monitoring sees the challenge, because it watches the engine', () {
      final run = runOf(compromised);

      // The monitors relationship is unfiltered, so everything the engine
      // emits reaches monitoring. Watching something means watching it.
      expect(
        run
            .observationsFor(monitoring)
            .map((observation) => observation.event.typeId),
        contains('mfa_challenge_required'),
      );
    });

    test('seeing it is not reacting to it', () {
      final run = runOf(compromised);

      // Monitoring's behaviour triggers on a refusal, and there was none.
      expect(
        run.trace.map((entry) => entry.definitionId),
        isNot(contains('security_monitoring.notice_failure')),
        reason: 'observing an event is not the same as having a response to '
            'it',
      );

      expect(emittedBy(run), isNot(contains('security_alert_raised')));
      expect(valueOf(run, 'security_monitoring.signal'), 'Quiet');
    });

    test('and nothing reaches the administrator, who stays uninvolved', () {
      final run = runOf(compromised);

      expect(
        run.observationsFor(administrator),
        isEmpty,
        reason: 'the notification channel carries alerts, and none was raised',
      );

      expect(
        run.isRelevant(administrator),
        isFalse,
        reason: 'relevance arrives because an occurrence reached someone',
      );
    });
  });

  group('reset restores the situation that was chosen', () {
    test('the overrides come back, not the system defaults', () {
      final run = runOf(compromised);

      expect(valueOf(run, 'user_account.access'), 'Compromised');

      run.reset();

      expect(run.trace, isEmpty);

      // Both overrides restored.
      expect(valueOf(run, 'credential_store.integrity'), 'Compromised');
      expect(valueOf(run, 'user_device.trust'), 'Trusted');

      // And everything the situation did not establish is back where the
      // system says it starts.
      expect(valueOf(run, 'user_account.access'), 'Active');
      expect(valueOf(run, 'login_interface.stage'), 'Idle');
      expect(valueOf(run, 'mfa_service.challenge'), 'Available');
      expect(run.relevantActors, {attacker});
    });

    test('the branch is reachable again after resetting', () {
      final run = runOf(compromised)..reset();

      run.perform(attempt);

      expect(emittedBy(run), contains('mfa_challenge_required'));
      expect(valueOf(run, 'mfa_service.challenge'), 'Approved');
    });
  });

  group('switching situations does not leak the previous one', () {
    test('moving to the takeover starts from its own state', () {
      final controller = StudioSimulationController(
        graph: graph,
        runId: 'test',
        scenario: compromised,
      );

      addTearDown(controller.dispose);

      controller.perform(attempt);

      expect(
        controller.state.valueOf(
          graph.stateVariableById('user_account.access')!,
        ),
        'Compromised',
      );

      controller.restart(scenario: takeover);

      expect(controller.scenario.id, 'attempted_account_takeover');
      expect(controller.isAtStart, isTrue);

      // The store is intact again, because this situation never said it was
      // not — nothing carries over from the run before it.
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
      expect(
        controller.state.valueOf(
          graph.stateVariableById('user_account.access')!,
        ),
        'Active',
      );
    });

    test('and the takeover then behaves as the takeover', () {
      final controller = StudioSimulationController(
        graph: graph,
        runId: 'test',
        scenario: compromised,
      );

      addTearDown(controller.dispose);

      controller.perform(attempt);
      controller.restart(scenario: takeover);
      controller.perform(attempt);

      expect(
        controller.events.map((event) => event.typeId),
        contains('authentication_failed'),
      );
      expect(
        controller.events.map((event) => event.typeId),
        isNot(contains('mfa_challenge_required')),
      );
      expect(controller.isRelevant(administrator), isTrue);
    });
  });

  group('the same action, two paths', () {
    test('one action, two different causal chains', () {
      final refused = SimulationCausalGraph.fromRun(runOf(takeover));
      final accepted = SimulationCausalGraph.fromRun(runOf(compromised));

      final refusedIds = refused.nodes.map((n) => n.element.id).toSet();
      final acceptedIds = accepted.nodes.map((n) => n.element.id).toSet();

      // The situation, not the action, decided who took part.
      expect(refusedIds, contains('security_monitoring'));
      expect(refusedIds, contains('administrator'));
      expect(refusedIds, isNot(contains('mfa_service')));

      expect(acceptedIds, contains('mfa_service'));
      expect(
        acceptedIds,
        isNot(contains('administrator')),
        reason: 'nothing reached them, so they are not in the record',
      );
    });

    test('taking part and merely seeing are different kinds of step', () {
      final accepted = SimulationCausalGraph.fromRun(runOf(compromised));

      // Monitoring is present, because the challenge did reach it — but as
      // something that watched, not something that did anything.
      final watching = accepted.links.firstWhere(
        (link) => link.to == monitoring,
      );

      expect(watching.kind, StudioCausalLinkKind.observation);
      expect(watching.eventTypeId, 'mfa_challenge_required');

      // MFA is the element that actually responded to it.
      final reacting = accepted.links.firstWhere((link) => link.to == mfa);

      expect(reacting.kind, StudioCausalLinkKind.automaticBehavior);
      expect(reacting.eventTypeId, 'mfa_challenge_required');

      // Neither of them acted by choice.
      expect(
        accepted.links.where((link) => link.isChosen).map((link) => link.from),
        [attacker],
      );
    });

    test('in the refused situation monitoring is the one that responds', () {
      final refused = SimulationCausalGraph.fromRun(runOf(takeover));

      final reacting = refused.links.firstWhere(
        (link) => link.to == monitoring,
      );

      expect(
        reacting.kind,
        StudioCausalLinkKind.automaticBehavior,
        reason: 'the same element watches in one situation and responds in '
            'the other, and the record says which',
      );
    });
  });
}

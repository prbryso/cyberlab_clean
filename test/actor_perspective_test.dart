import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_builder.dart';
import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/perspectives/actor/actor_perspective.dart';
import 'package:systems_studio/engine/perspectives/actor/actor_perspective_view.dart';
import 'package:systems_studio/engine/perspectives/overview/overview_perspective.dart';
import 'package:systems_studio/engine/perspectives/studio_perspective.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The distinctive claim of the product model: one graph, one run, and
/// genuinely different knowledge for different participants.
void main() {
  const engine = StudioGraphEngine();
  const actorPerspective = ActorPerspective();
  const overviewPerspective = OverviewPerspective();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const monitoring = StudioElementRef.node('security_monitoring');
  const loginInterface = StudioElementRef.node('login_interface');

  final graph = const StudioGraphBuilder().build(passwordSecurityDetail);
  final session = engine.open(passwordSecurityDetail);

  StudioActionDefinition attackerAction() {
    return graph.actionDefinitions.firstWhere(
      (action) => action.id == 'attacker.attempt_authentication',
    );
  }

  SimulationRun startRun() {
    return SimulationRun.start(graph, initialActors: {attacker});
  }

  ActorPerspectiveView viewFor(StudioElementRef actor, SimulationRun run) {
    final result = actorPerspective.view(
      StudioPerspectiveRequest(
        session: session,
        selectedElement: actor,
        run: run,
      ),
    );

    return result as ActorPerspectiveView;
  }

  group('before anything happens', () {
    test('the administrator is not relevant and knows nothing', () {
      final run = startRun();

      final view = viewFor(administrator, run);

      expect(view.isRelevant, isFalse);
      expect(view.observedEvents, isEmpty);
      expect(view.availableActions, isEmpty);
      expect(
        view.knownElements,
        [administrator],
        reason: 'an actor always knows itself and nothing more to begin with',
      );
    });

    test('the attacker is relevant but has not yet observed anything', () {
      final run = startRun();

      final view = viewFor(attacker, run);

      expect(view.isRelevant, isTrue);
      expect(view.observedEvents, isEmpty);
      expect(view.availableActions.map((action) => action.id), [
        'attacker.attempt_authentication',
      ]);
    });
  });

  group('after the attack', () {
    test('the administrator becomes relevant through the alert', () {
      final run = startRun()..perform(attackerAction());

      final view = viewFor(administrator, run);

      expect(view.isRelevant, isTrue);
      expect(view.observedEventTypeIds, ['security_alert_raised']);
      expect(view.availableActions.map((action) => action.id), [
        'administrator.lock_account',
      ]);
    });

    test('the administrator did not learn about the failure', () {
      final run = startRun()..perform(attackerAction());

      final view = viewFor(administrator, run);

      expect(
        view.observedEventTypeIds,
        isNot(contains('authentication_failed')),
        reason: 'monitoring reported the alert, not everything it saw',
      );
      expect(
        view.observedEventTypeIds,
        isNot(contains('authentication_attempted')),
      );
    });

    test('the attacker sees its own attempt and not the alert', () {
      final run = startRun()..perform(attackerAction());

      final view = viewFor(attacker, run);

      expect(view.observedEventTypeIds, ['authentication_attempted']);
      expect(
        view.observedEventTypeIds,
        isNot(contains('security_alert_raised')),
        reason: 'the alert exists in the run, but not for the attacker',
      );
      expect(view.performedActionIds, [
        'attacker.attempt_authentication',
      ]);
    });
  });

  group('the same run produces different knowledge', () {
    test('attacker and administrator views diverge semantically', () {
      final run = startRun()..perform(attackerAction());

      final attackerView = viewFor(attacker, run);
      final administratorView = viewFor(administrator, run);

      // Different occurrences.
      expect(
        attackerView.observedEventTypeIds,
        isNot(administratorView.observedEventTypeIds),
      );

      // Different parts of the system known.
      expect(attackerView.knownElements, contains(loginInterface));
      expect(administratorView.knownElements, isNot(contains(loginInterface)));

      expect(administratorView.knownElements, contains(monitoring));
      expect(attackerView.knownElements, isNot(contains(monitoring)));

      // Different state visible.
      final attackerState = attackerView.visibleState
          .map((entry) => entry.variableId)
          .toSet();

      final administratorState = administratorView.visibleState
          .map((entry) => entry.variableId)
          .toSet();

      expect(attackerState, contains('login_interface.stage'));
      expect(administratorState, contains('security_monitoring.signal'));
      expect(attackerState, isNot(contains('security_monitoring.signal')));

      // Different things to do.
      expect(
        attackerView.availableActions.map((action) => action.id),
        isNot(administratorView.availableActions.map((action) => action.id)),
      );
    });

    test('the difference comes from observation, not from labels', () {
      final run = startRun()..perform(attackerAction());

      final attackerView = viewFor(attacker, run);
      final administratorView = viewFor(administrator, run);

      // Every difference traces back to an observation the other did not get.
      expect(
        attackerView.observations.map((o) => o.event.sequence).toSet(),
        isNot(
          administratorView.observations
              .map((o) => o.event.sequence)
              .toSet(),
        ),
      );

      // The administrator knows second-hand; the attacker knows by doing.
      expect(administratorView.knowsBySecondHand, isTrue);
      expect(
        attackerView.observedEvents.single.basis,
        StudioObservationBasis.participation,
      );
    });
  });

  group('fidelity shapes what a view carries', () {
    test('a full observation carries source, channel and explanation', () {
      final run = startRun()..perform(attackerAction());

      final alert = viewFor(administrator, run).observedEvents.single;

      expect(alert.fidelity, StudioObservationFidelity.full);
      expect(alert.source, monitoring);
      expect(alert.channelRelationshipIds, [
        'monitoring_notifies_administrator',
      ]);
      expect(alert.description, isNotNull);
      expect(alert.explanation, isNotNull);
    });

    test('an existence-only observation withholds the detail', () {
      final run = startRun()..perform(attackerAction());

      final observation = run.observationsFor(administrator).single;

      // Re-shape the same observation at reduced fidelity and confirm the
      // view model simply does not carry what the observer cannot know.
      final reduced = StudioObservation(
        observer: observation.observer,
        event: observation.event,
        basis: observation.basis,
        fidelity: StudioObservationFidelity.existenceOnly,
        channelRelationshipIds: observation.channelRelationshipIds,
        distance: observation.distance,
      );

      final view = ObservedEventView(
        sequence: reduced.event.sequence,
        eventTypeId: reduced.event.typeId,
        eventTypeName: 'Security alert raised',
        fidelity: reduced.fidelity,
        basis: reduced.basis,
      );

      expect(view.isExistenceOnly, isTrue);
      expect(view.source, isNull);
      expect(view.description, isNull);
      expect(view.explanation, isNull);
      expect(view.channelRelationshipIds, isEmpty);
      expect(view.payload, isEmpty);

      expect(
        view.eventTypeName,
        isNotEmpty,
        reason: 'awareness that something of this kind happened is retained',
      );
    });
  });

  group('goals and identity', () {
    test('goals come from the declared facet, not from the perspective', () {
      final run = startRun();

      final view = viewFor(attacker, run);

      expect(view.actorName, 'Attacker');
      expect(view.goalsAreKnown, isTrue);
      expect(view.goals, contains('Bypass MFA'));
    });
  });

  group('determinism', () {
    test('the same run yields the same view twice', () {
      final run = startRun()..perform(attackerAction());

      final first = viewFor(administrator, run);
      final second = viewFor(administrator, run);

      expect(first.observedEventTypeIds, second.observedEventTypeIds);
      expect(first.knownElements, second.knownElements);
      expect(first.observableElements, second.observableElements);
      expect(
        first.visibleState.map((entry) => entry.variableId),
        second.visibleState.map((entry) => entry.variableId),
      );
      expect(
        first.availableActions.map((action) => action.id),
        second.availableActions.map((action) => action.id),
      );
    });
  });

  group('reset', () {
    test('restores the initial perspective state', () {
      final run = startRun()..perform(attackerAction());

      expect(viewFor(administrator, run).isRelevant, isTrue);

      run.reset();

      final view = viewFor(administrator, run);

      expect(view.isRelevant, isFalse);
      expect(view.observedEvents, isEmpty);
      expect(view.availableActions, isEmpty);
      expect(view.knownElements, [administrator]);
    });
  });

  group('perspective contract', () {
    test('a relationship is declined, not silently substituted', () {
      final run = startRun();

      const relationship = StudioElementRef.relationship(
        'monitoring_notifies_administrator',
      );

      for (final perspective in [actorPerspective, overviewPerspective]) {
        final result = perspective.view(
          StudioPerspectiveRequest(
            session: session,
            selectedElement: relationship,
            run: run,
          ),
        );

        expect(
          result,
          isA<StudioPerspectiveUnsupported>(),
          reason: '${perspective.id} must not describe something else instead',
        );

        final unsupported = result as StudioPerspectiveUnsupported;

        expect(
          unsupported.reason,
          StudioPerspectiveUnsupportedReason.relationshipNotSupported,
        );
        expect(unsupported.requestedElement, relationship);
      }
    });

    test('a non-actor element is declined by the actor perspective', () {
      final run = startRun();

      final result = actorPerspective.view(
        StudioPerspectiveRequest(
          session: session,
          selectedElement: loginInterface,
          run: run,
        ),
      );

      expect(result, isA<StudioPerspectiveUnsupported>());
      expect(
        (result as StudioPerspectiveUnsupported).reason,
        StudioPerspectiveUnsupportedReason.wrongElementKind,
      );
    });

    test('the actor perspective requires a run', () {
      final result = actorPerspective.view(
        StudioPerspectiveRequest(session: session, selectedElement: attacker),
      );

      expect(
        (result as StudioPerspectiveUnsupported).reason,
        StudioPerspectiveUnsupportedReason.runRequired,
      );
    });

    test('overview produces a view model for a node', () {
      final result = overviewPerspective.view(
        StudioPerspectiveRequest(
          session: session,
          selectedElement: loginInterface,
        ),
      );

      expect(result, isA<OverviewPerspectiveView>());
      expect(
        (result as OverviewPerspectiveView).model.selectedNode.id,
        'login_interface',
      );
    });
  });
}

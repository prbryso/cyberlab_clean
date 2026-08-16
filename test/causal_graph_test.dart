import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_focus.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/perspectives/actor/actor_perspective.dart';
import 'package:systems_studio/engine/perspectives/actor/actor_perspective_view.dart';
import 'package:systems_studio/engine/perspectives/studio_perspective.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The What Happened causal record, derived from the run.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const loginInterface = StudioElementRef.node('login_interface');
  const authEngine = StudioElementRef.node('authentication_engine');
  const monitoring = StudioElementRef.node('security_monitoring');
  const userAccount = StudioElementRef.node('user_account');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  SimulationRun startRun() =>
      SimulationRun.start(graph, initialActors: {attacker});

  SimulationCausalGraph after(SimulationRun run) =>
      SimulationCausalGraph.fromRun(run);

  bool hasLink(
    SimulationCausalGraph causal,
    StudioElementRef from,
    StudioElementRef to,
  ) {
    return causal.links.any((link) => link.from == from && link.to == to);
  }

  StudioCausalLink linkBetween(
    SimulationCausalGraph causal,
    StudioElementRef from,
    StudioElementRef to,
  ) {
    return causal.links.firstWhere(
      (link) => link.from == from && link.to == to,
    );
  }

  group('an empty run has no causal record', () {
    test('nothing has happened, so there is nothing to show', () {
      final causal = after(startRun());

      expect(causal.isEmpty, isTrue);
      expect(causal.links, isEmpty);
      expect(causal.nodes, isEmpty);
    });
  });

  group('the record is derived, not authored', () {
    test('it comes from the trace and disappears with it', () {
      final run = startRun();

      expect(after(run).isEmpty, isTrue);

      run.perform(actionById('attacker.attempt_authentication'));

      expect(after(run).isNotEmpty, isTrue);

      run.reset();

      expect(
        after(run).isEmpty,
        isTrue,
        reason: 'no authored sequence survives a reset',
      );
    });

    test('every link points back at a trace entry', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final causal = after(run);

      final entrySequences = run.trace.map((entry) => entry.sequence).toSet();

      for (final link in causal.links) {
        expect(
          entrySequences,
          contains(link.traceEntrySequence),
          reason: '${link.label} must come from something that happened',
        );
      }
    });
  });

  group('the attacker action produces the causal chain', () {
    late SimulationCausalGraph causal;

    setUp(() {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      causal = after(run);
    });

    test('the requested participants all appear', () {
      final elements = causal.nodes.map((node) => node.element).toSet();

      expect(elements, containsAll([
        attacker,
        loginInterface,
        authEngine,
        monitoring,
        administrator,
      ]));
    });

    test('the chain runs end to end without expanding anything', () {
      expect(hasLink(causal, attacker, loginInterface), isTrue);
      expect(hasLink(causal, loginInterface, authEngine), isTrue);
      expect(hasLink(causal, authEngine, monitoring), isTrue);
      expect(hasLink(causal, monitoring, administrator), isTrue);
    });

    test('the engine appears because an occurrence reached it', () {
      final link = linkBetween(causal, loginInterface, authEngine);

      expect(link.kind, StudioCausalLinkKind.automaticBehavior);
      expect(link.eventTypeId, 'authentication_attempted');
      expect(link.label, 'Authentication attempted');
    });

    test('monitoring appears because a failure reached it', () {
      final link = linkBetween(causal, authEngine, monitoring);

      expect(link.kind, StudioCausalLinkKind.automaticBehavior);
      expect(link.eventTypeId, 'authentication_failed');
    });

    test('the administrator appears because of a notification', () {
      final link = linkBetween(causal, monitoring, administrator);

      expect(link.kind, StudioCausalLinkKind.observation);
      expect(link.eventTypeId, 'security_alert_raised');
      expect(link.channelRelationshipIds, [
        'monitoring_notifies_administrator',
      ]);
    });

    test('becoming involved is not acting', () {
      final node = causal.nodeFor(administrator)!;

      expect(node.becameInvolvedByObservation, isTrue);
      expect(node.hasActed, isFalse);

      expect(
        causal.links.any(
          (link) =>
              link.from == administrator &&
              link.kind == StudioCausalLinkKind.chosenAction,
        ),
        isFalse,
        reason: 'the administrator has done nothing yet',
      );
    });

    test('chosen and automatic occurrences are distinguishable', () {
      final chosen = linkBetween(causal, attacker, loginInterface);

      expect(chosen.kind, StudioCausalLinkKind.chosenAction);
      expect(chosen.isChosen, isTrue);
      expect(chosen.label, 'Attempt authentication');

      expect(
        linkBetween(causal, authEngine, monitoring).isChosen,
        isFalse,
      );

      expect(
        causal.links.map((link) => link.kind).toSet(),
        containsAll([
          StudioCausalLinkKind.chosenAction,
          StudioCausalLinkKind.automaticBehavior,
          StudioCausalLinkKind.observation,
        ]),
      );
    });

    test('runtime state changes are carried, and only runtime ones', () {
      final changes = causal.nodeFor(monitoring)!.stateChanges;

      expect(changes, hasLength(1));
      expect(changes.single.previousValue, 'Quiet');
      expect(changes.single.newValue, 'Alerting');

      // Elements whose declared values never changed carry nothing, so a
      // starting value is never shown as though it had changed.
      expect(causal.nodeFor(attacker)!.stateChanges, isEmpty);
      expect(causal.nodeFor(administrator)!.stateChanges, isEmpty);
    });

    test('a causal element resolves to the real system element', () {
      for (final node in causal.nodes) {
        expect(
          graph.containsElement(node.element),
          isTrue,
          reason: '${node.element} must be a real element, not a stand-in',
        );

        expect(node.label, graph.labelForElement(node.element));
      }
    });

    test('links are ordered causally', () {
      final sequences = causal.links.map((link) => link.sequence).toList();

      expect(sequences, List.generate(sequences.length, (index) => index));
    });
  });

  group('the administrator action extends the record', () {
    test('history is added to, not replaced', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final before = after(run);

      run.perform(actionById('administrator.lock_account'));

      final extended = after(run);

      expect(extended.links.length, greaterThan(before.links.length));

      // Everything that was there is still there.
      for (final link in before.links) {
        expect(
          extended.links.any(
            (candidate) =>
                candidate.from == link.from &&
                candidate.to == link.to &&
                candidate.label == link.label,
          ),
          isTrue,
          reason: '${link.label} disappeared from the record',
        );
      }
    });

    test('the administrator acting shows the account change', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'))
        ..perform(actionById('administrator.lock_account'));

      final causal = after(run);

      final link = linkBetween(causal, administrator, userAccount);

      expect(link.kind, StudioCausalLinkKind.chosenAction);
      expect(link.label, 'Lock the account');

      expect(link.stateChanges, hasLength(1));
      expect(link.stateChanges.single.previousValue, 'Active');
      expect(link.stateChanges.single.newValue, 'Locked');

      expect(causal.nodeFor(administrator)!.hasActed, isTrue);
    });
  });

  group('actor knowledge is overlaid without changing system truth', () {
    test('the record is complete regardless of who knew what', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final causal = after(run);

      // The attacker never learned about the alert, but the record shows it.
      expect(hasLink(causal, monitoring, administrator), isTrue);

      final observedByAttacker = causal.linksObservedBy(attacker);

      expect(observedByAttacker, isNotEmpty);
      expect(
        observedByAttacker.any(
          (link) => link.eventTypeId == 'security_alert_raised',
        ),
        isFalse,
      );
    });

    test('the overlay reveals nothing through the actor perspective', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      const perspective = ActorPerspective();

      final view =
          perspective.view(
                StudioPerspectiveRequest(
                  session: session,
                  selectedElement: attacker,
                  run: run,
                ),
              )
              as ActorPerspectiveView;

      // The causal record is complete; the perspective is not, and stays so.
      expect(
        view.observedEventTypeIds,
        ['authentication_attempted'],
        reason: 'the causal view must not widen what an actor knows',
      );
      expect(
        view.observedEventTypeIds,
        isNot(contains('security_alert_raised')),
      );
    });

    test('an actor with no observation of a link is not marked on it', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final causal = after(run);

      final alert = linkBetween(causal, monitoring, administrator);

      expect(alert.observers, contains(administrator));
      expect(alert.observers, isNot(contains(attacker)));
    });
  });

  group('architecture is untouched', () {
    test('deriving the record does not change the authored graph', () {
      final nodesBefore = graph.nodes.length;
      final relationshipsBefore = graph.relationships.length;

      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      after(run);

      expect(graph.nodes.length, nodesBefore);
      expect(graph.relationships.length, relationshipsBefore);
    });

    test('architecture focus still answers how the system is built', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      after(run);

      // The architecture question is unchanged by anything having happened.
      final focused = session.query.focusedSubgraph(
        StudioGraphFocus.node('authentication_engine'),
      );

      expect(focused.nodes.map((node) => node.id), contains('identity_service'),
          reason: 'architecture still shows containment, not causality');
      expect(
        focused.nodes.map((node) => node.id),
        isNot(contains('attacker')),
        reason: 'the attacker is causally related, not architecturally near',
      );
    });
  });
}

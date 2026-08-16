import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_focus.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_overlay.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The run, expressed as something drawable on top of the architecture.
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

  SimulationGraphOverlay overlayOf(SimulationRun run) =>
      SimulationGraphOverlay.fromRun(run);

  /// The view the graph surfaces ask for when nothing in particular is
  /// focused: the system and its immediate contents.
  StudioGraphFocus rootFocus() =>
      StudioGraphFocus.node(graph.systemId, depth: 0);

  StudioOverlayStep stepBetween(
    SimulationGraphOverlay overlay,
    StudioElementRef from,
    StudioElementRef to,
  ) {
    return overlay.steps.firstWhere(
      (step) => step.from == from && step.to == to,
    );
  }

  group('an overlay only exists once something has happened', () {
    test('a run that has not started draws nothing', () {
      final overlay = overlayOf(startRun());

      expect(overlay.isEmpty, isTrue);
      expect(overlay.steps, isEmpty);
      expect(overlay.involvedNodeIds, isEmpty);
      expect(overlay.revealNodeIds, isEmpty);
      expect(overlay.expandNodeIds, isEmpty);
    });

    test('reset removes the overlay entirely', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      expect(overlayOf(run).isNotEmpty, isTrue);

      run.reset();

      expect(
        overlayOf(run).isEmpty,
        isTrue,
        reason: 'nothing of the run may survive on the architecture',
      );
    });
  });

  group('the causal path is placed onto real architecture', () {
    late SimulationGraphOverlay overlay;

    setUp(() {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      overlay = overlayOf(run);
    });

    test('the acceptance path appears as consecutive steps', () {
      const path = [
        attacker,
        loginInterface,
        authEngine,
        monitoring,
        administrator,
      ];

      for (var index = 0; index < path.length - 1; index++) {
        expect(
          overlay.steps.any(
            (step) => step.from == path[index] && step.to == path[index + 1],
          ),
          isTrue,
          reason: '${path[index].id} -> ${path[index + 1].id} must be drawn',
        );
      }
    });

    test('steps are highlighted in causal order', () {
      final sequences = overlay.steps.map((step) => step.sequence).toList();

      expect(sequences, List.generate(sequences.length, (index) => index));

      // What a learner reads counts from one.
      expect(overlay.steps.first.position, 1);
    });

    test('information-bearing steps name the relationship that carried them', () {
      expect(
        stepBetween(overlay, loginInterface, authEngine).relationshipIds,
        ['login_interface_sends_to_engine'],
      );

      // Direction of the relationship and direction of the information differ,
      // and the overlay follows the information.
      expect(
        stepBetween(overlay, authEngine, monitoring).relationshipIds,
        ['monitoring_monitors_engine'],
      );

      expect(
        stepBetween(overlay, monitoring, administrator).relationshipIds,
        ['monitoring_notifies_administrator'],
      );
    });

    test('chosen actions and automatic behaviour stay distinguishable', () {
      expect(
        stepBetween(overlay, attacker, loginInterface).kind,
        StudioCausalLinkKind.chosenAction,
      );
      expect(
        stepBetween(overlay, loginInterface, authEngine).kind,
        StudioCausalLinkKind.automaticBehavior,
      );
      expect(
        stepBetween(overlay, monitoring, administrator).kind,
        StudioCausalLinkKind.observation,
      );
    });

    test('a step no relationship carries is reported, not invented', () {
      final step = stepBetween(overlay, attacker, loginInterface);

      expect(step.relationshipIds, isEmpty);
      expect(step.carrier, StudioOverlayCarrier.undeclared);
      expect(step.isCarriedByArchitecture, isFalse);

      expect(overlay.undeclaredSteps, contains(step));

      // Nothing was added to the architecture to make the picture tidy.
      expect(
        graph.relationships.any(
          (relationship) =>
              relationship.involves('attacker') &&
              relationship.involves('login_interface'),
        ),
        isFalse,
      );
    });

    test('every named relationship is one the system actually declares', () {
      for (final id in overlay.carryingRelationshipIds) {
        expect(
          graph.relationshipById(id),
          isNotNull,
          reason: '$id must be a real relationship, not a stand-in',
        );
      }
    });

    test('runtime state changes are carried to their element', () {
      final state = overlay.stateFor('security_monitoring');

      expect(state, hasLength(1));
      expect(state.single.initialValue, 'Quiet');
      expect(state.single.currentValue, 'Alerting');
      expect(state.single.changeCount, 1);
      expect(state.single.changedMoreThanOnce, isFalse);

      // Elements whose declared values never moved carry nothing.
      expect(overlay.stateFor('attacker'), isEmpty);
    });

    test('a variable that moves twice is summarised once, end to end', () {
      // The login interface goes Idle -> Collecting credentials when the
      // attempt is made, then -> Access denied when the engine refuses it.
      final state = overlay.stateFor('login_interface');

      final stage = state.where(
        (summary) => summary.variableId == 'login_interface.stage',
      );

      expect(
        stage,
        hasLength(1),
        reason: 'an element summarises each variable once, however many times '
            'the run moved it',
      );

      expect(stage.single.initialValue, 'Idle');
      expect(stage.single.currentValue, 'Access denied');
      expect(stage.single.changeCount, 2);
      expect(stage.single.changedMoreThanOnce, isTrue);
      expect(stage.single.returnedToStart, isFalse);
    });

    test('summarising at the element does not cost the causal record', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final causal = SimulationCausalGraph.fromRun(run);

      // Both transitions are still individually present, each attached to the
      // step that caused it.
      final transitions = [
        for (final link in causal.links)
          for (final change in link.stateChanges)
            if (change.variableId == 'login_interface.stage') change,
      ];

      expect(transitions, hasLength(2));
      expect(transitions.first.newValue, 'Collecting credentials');
      expect(transitions.last.newValue, 'Access denied');
    });
  });

  group('the path is revealed without anyone expanding hierarchy', () {
    late SimulationGraphOverlay overlay;

    setUp(() {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      overlay = overlayOf(run);
    });

    test('participants nested inside subsystems are revealed', () {
      expect(
        overlay.revealNodeIds,
        containsAll([
          'attacker',
          'login_interface',
          'authentication_engine',
          'security_monitoring',
          'administrator',
        ]),
      );
    });

    test('the containers holding them are opened', () {
      expect(
        overlay.expandNodeIds,
        containsAll([
          'credential_entry',
          'identity_service',
          'monitoring_and_recovery',
        ]),
        reason: 'the chain crosses these, so they cannot stay closed',
      );
    });

    test('participants are revealed but not themselves forced open', () {
      // Opening a participant would expand parts of the system that had no
      // part in the run.
      expect(overlay.expandNodeIds, isNot(contains('login_interface')));
      expect(overlay.expandNodeIds, isNot(contains('attacker')));
    });

    test('containers are revealed without being counted as participants', () {
      expect(overlay.revealNodeIds, contains('identity_service'));

      expect(
        overlay.involves('identity_service'),
        isFalse,
        reason: 'containing something that acted is not acting',
      );
    });
  });

  group('the architecture is added to, never replaced', () {
    test('nothing the focus already chose is dropped', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final overlay = overlayOf(run);

      final focused = session.query.focusedSubgraph(rootFocus());
      final revealed = overlay.revealWithin(graph, focused);

      // The invariant is preservation of what Architecture chose, not of the
      // whole system. Elements focus had already excluded — anything nested
      // below the focused level — are not owed a place here.
      expect(
        revealed.nodes.map((node) => node.id).toSet(),
        containsAll(focused.nodes.map((node) => node.id)),
      );

      expect(
        revealed.relationships.map((relationship) => relationship.id).toSet(),
        containsAll(
          focused.relationships.map((relationship) => relationship.id),
        ),
      );
    });

    test('architecture with no part in the run is kept, not removed', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final overlay = overlayOf(run);

      final focused = session.query.focusedSubgraph(rootFocus());
      final revealed = overlay.revealWithin(graph, focused);

      const bystander = 'credentials';

      // Chosen by focus before the run existed, and untouched by it: exactly
      // the element that should end up drawn and dimmed rather than dropped.
      expect(
        focused.nodes.map((node) => node.id),
        contains(bystander),
        reason: 'the fixture must actually exercise the case being asserted',
      );
      expect(overlay.involves(bystander), isFalse);

      expect(revealed.nodes.map((node) => node.id), contains(bystander));
    });

    test('deriving and revealing never modify the authored graph', () {
      final nodesBefore = graph.nodes.length;
      final relationshipsBefore = graph.relationships.length;

      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      overlayOf(run).revealWithin(
        graph,
        session.query.focusedSubgraph(rootFocus()),
      );

      expect(graph.nodes.length, nodesBefore);
      expect(graph.relationships.length, relationshipsBefore);
    });

    test('an empty overlay leaves a focused view exactly as it was', () {
      final focused = session.query.focusedSubgraph(rootFocus());

      final unchanged = SimulationGraphOverlay.empty.revealWithin(
        graph,
        focused,
      );

      expect(identical(unchanged, focused), isTrue);
    });
  });

  group('actor knowledge marks the overlay without narrowing it', () {
    test('what an actor saw is a subset of what is drawn', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final overlay = overlayOf(run);

      final seenByAdministrator = overlay.stepsObservedBy(administrator);

      expect(seenByAdministrator, isNotEmpty);
      expect(seenByAdministrator.length, lessThan(overlay.steps.length));

      // The alert is the only part of this chain that reached them.
      expect(
        seenByAdministrator.every(
          (step) => step.eventTypeId == 'security_alert_raised',
        ),
        isTrue,
      );

      // And the rest of the run is still drawn.
      expect(
        overlay.steps.any((step) => step.to == authEngine),
        isTrue,
        reason: 'system truth stays complete regardless of who knew what',
      );
    });

    test('the attacker is not marked on what never reached them', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final overlay = overlayOf(run);

      final alert = stepBetween(overlay, monitoring, administrator);

      expect(alert.wasObservedBy(administrator), isTrue);
      expect(alert.wasObservedBy(attacker), isFalse);
    });
  });

  group('a later action extends the overlay', () {
    test('locking the account adds a step and keeps the earlier ones', () {
      final run = startRun()
        ..perform(actionById('attacker.attempt_authentication'));

      final before = overlayOf(run);

      run.perform(actionById('administrator.lock_account'));

      final after = overlayOf(run);

      expect(after.steps.length, greaterThan(before.steps.length));

      final step = stepBetween(after, administrator, userAccount);

      expect(step.kind, StudioCausalLinkKind.chosenAction);
      expect(step.stateChanges.single.newValue, 'Locked');

      expect(after.involves('user_account'), isTrue);

      final account = after.stateFor('user_account');

      expect(account, hasLength(1));
      expect(account.single.currentValue, 'Locked');

      // Everything that was already drawn is still drawn.
      expect(after.involvedNodeIds, containsAll(before.involvedNodeIds));
    });
  });
}

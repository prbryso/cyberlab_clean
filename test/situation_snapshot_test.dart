import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_situation_snapshot.dart';
import 'package:systems_studio/engine/ui/widgets/state/node_state_view.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// What is true now, and how that differs from where the situation began.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  final takeover = graph.scenarios.firstWhere(
    (scenario) => scenario.id == 'attempted_account_takeover',
  );

  SimulationRun runOf(StudioScenario scenario) =>
      SimulationRun.start(graph, scenario: scenario);

  StudioSituationSnapshot snapshotOf(SimulationRun run) =>
      StudioSituationSnapshot.of(graph, run);

  group('at the start of a situation', () {
    test('nothing differs', () {
      final situation = snapshotOf(runOf(takeover));

      expect(situation.differences, isEmpty);
      expect(situation.hasDifferences, isFalse);
      expect(situation.isAtStart, isTrue);
    });

    test('a scenario override is the starting value, not a difference', () {
      final situation = snapshotOf(
        runOf(
          StudioScenario(
            id: 'locked',
            name: 'Account already locked',
            initialActors: {administrator},
            initialStateOverrides: {'user_account.access': 'Locked'},
          ),
        ),
      );

      // It is where this situation began, so nothing has changed from it.
      expect(situation.differences, isEmpty);
      expect(situation.differenceFor('user_account.access'), isNull);

      // And the starting state carries the override, not the system default.
      expect(
        situation.startingState.valueOf(
          graph.stateVariableById('user_account.access')!,
        ),
        'Locked',
      );
    });
  });

  group('once something has happened', () {
    test('runtime changes appear as differences', () {
      final run = runOf(takeover)
        ..perform(actionById('attacker.attempt_authentication'));

      final situation = snapshotOf(run);

      expect(situation.hasDifferences, isTrue);

      final signal = situation.differenceFor('security_monitoring.signal')!;

      expect(signal.startedAs, 'Quiet');
      expect(signal.isNow, 'Alerting');
      expect(signal.owner, const StudioElementRef.node('security_monitoring'));
    });

    test('a variable that never moved is not reported', () {
      final run = runOf(takeover)
        ..perform(actionById('attacker.attempt_authentication'));

      expect(
        snapshotOf(run).differenceFor('user_device.trust'),
        isNull,
        reason: 'nothing touched it, so nothing about it has changed',
      );
    });

    test('differences are measured from the scenario, not system defaults', () {
      // The situation begins where the system does not.
      final run = runOf(
        StudioScenario(
          id: 'trusted_device',
          name: 'Trusted device',
          initialActors: {attacker},
          initialStateOverrides: {'user_device.trust': 'Trusted'},
        ),
      )..perform(actionById('attacker.attempt_authentication'));

      final situation = snapshotOf(run);

      // Trust is where the scenario put it and nothing moved it, so it is not
      // a difference — even though it differs from the system's declaration.
      expect(situation.differenceFor('user_device.trust'), isNull);

      // What the run actually changed still is one.
      expect(
        situation.differenceFor('security_monitoring.signal'),
        isNotNull,
      );
    });
  });

  group('reset', () {
    test('removes every difference', () {
      final run = runOf(takeover)
        ..perform(actionById('attacker.attempt_authentication'));

      expect(snapshotOf(run).hasDifferences, isTrue);

      run.reset();

      final situation = snapshotOf(run);

      expect(situation.differences, isEmpty);
      expect(situation.isAtStart, isTrue);
      expect(situation.causal.isEmpty, isTrue);
      expect(situation.overlay.isEmpty, isTrue);
    });
  });

  group('a value that returns to where it began', () {
    test('is no longer a difference, though the history still records it', () {
      // Locking the account moves access away from its starting value; a
      // scenario that starts from Locked and then locks again ends where it
      // began.
      final run = runOf(
        StudioScenario(
          id: 'already_locked',
          name: 'Already locked',
          initialActors: {administrator},
          initialStateOverrides: {'user_account.access': 'Locked'},
        ),
      );

      final situation = snapshotOf(run);

      expect(situation.differences, isEmpty);

      // The general invariant, stated directly: a snapshot compares two
      // endpoints. Whatever route the value took between them is the causal
      // record's business, not the difference list's.
      final moved = runOf(takeover)
        ..perform(actionById('attacker.attempt_authentication'));

      final movedSituation = snapshotOf(moved);

      final changedVariableIds = {
        for (final link in movedSituation.causal.links)
          for (final change in link.stateChanges) change.variableId,
      };

      final differingVariableIds = {
        for (final difference in movedSituation.differences)
          difference.variableId,
      };

      // History is a superset of the present difference: everything that
      // differs now was changed at some point, but not everything changed
      // still differs.
      expect(changedVariableIds, containsAll(differingVariableIds));
    });
  });

  group('one derivation feeds both views', () {
    test('causal and overlay describe the same run', () {
      final run = runOf(takeover)
        ..perform(actionById('attacker.attempt_authentication'));

      final situation = snapshotOf(run);

      expect(situation.overlay.steps, hasLength(situation.causal.links.length));

      for (var index = 0; index < situation.causal.links.length; index++) {
        final link = situation.causal.links[index];
        final step = situation.overlay.steps[index];

        expect(step.sequence, link.sequence);
        expect(step.from, link.from);
        expect(step.to, link.to);
      }
    });

    test('the snapshot reports the situation it was derived from', () {
      final situation = snapshotOf(runOf(takeover));

      expect(situation.scenario.id, takeover.id);
    });

    test('deriving one changes nothing about the run', () {
      final run = runOf(takeover)
        ..perform(actionById('attacker.attempt_authentication'));

      final before = run.trace.length;
      final stateBefore = run.state.values;

      snapshotOf(run);
      snapshotOf(run);

      expect(run.trace.length, before);
      expect(run.state.values, stateBefore);
    });
  });

  group('node state display', () {
    Future<void> pumpState(
      WidgetTester tester, {
      StudioSituationSnapshot? situation,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NodeStateView(
              variables: graph.stateVariablesFor(
                const StudioElementRef.node('user_account'),
              ),
              situation: situation,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('without a situation, start is the system default', (
      tester,
    ) async {
      await pumpState(tester);

      expect(find.text('Active  · start'), findsOneWidget);
      expect(find.text('Locked  · start'), findsNothing);
    });

    testWidgets('with a situation, start is where that situation began', (
      tester,
    ) async {
      final situation = snapshotOf(
        runOf(
          StudioScenario(
            id: 'locked',
            name: 'Account already locked',
            initialActors: {administrator},
            initialStateOverrides: {'user_account.access': 'Locked'},
          ),
        ),
      );

      await pumpState(tester, situation: situation);

      expect(
        find.text('Locked  · start'),
        findsOneWidget,
        reason: 'the run began here, whatever the system declares',
      );
      expect(find.text('Active  · start'), findsNothing);
    });
  });
}

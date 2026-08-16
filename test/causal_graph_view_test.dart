import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/ui/simulation/simulation_panel.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/causal_graph_view.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The What Happened graph, as the learner sees it inside Simulate.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  StudioSimulationController makeController() {
    return StudioSimulationController(
      graph: graph,
      runId: 'test',
      initialActors: {attacker},
    );
  }

  Future<void> pumpPanel(
    WidgetTester tester,
    StudioSimulationController controller, {
    StudioElementRef? selected,
  }) async {
    tester.view.physicalSize = const Size(1800, 3000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SimulationPanel(
            controller: controller,
            session: session,
            selectedElement: selected,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Password Security now offers a situation, so a panel opened before
    // anything has happened asks which one to explore. Tests that act first
    // never see the question; those that do not, answer it and carry on.
    if (find.byKey(const Key('scenario-chooser')).evaluate().isNotEmpty) {
      await tester.tap(
        find.byKey(const Key('scenario-option-attempted_account_takeover')),
      );

      await tester.pumpAndSettle();
    }
  }

  group('before anything happens', () {
    testWidgets('the causal graph is empty', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      expect(find.byKey(const Key('causal-graph-empty')), findsOneWidget);
      expect(find.byKey(const Key('causal-graph')), findsNothing);
    });
  });

  group('after the attacker action', () {
    testWidgets('the whole chain appears without expanding anything', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: attacker);

      expect(find.byKey(const Key('causal-graph')), findsOneWidget);

      // Every participant needed to explain the chain, straight away.
      for (final id in [
        'attacker',
        'login_interface',
        'authentication_engine',
        'security_monitoring',
        'administrator',
      ]) {
        expect(
          find.byKey(Key('causal-element-$id')),
          findsWidgets,
          reason: '$id should be visible without any hierarchy expansion',
        );
      }
    });

    testWidgets('chosen and automatic occurrences are labelled', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: attacker);

      expect(
        find.byKey(const Key('causal-kind-chosenAction')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('causal-kind-automaticBehavior')),
        findsWidgets,
      );
      expect(
        find.byKey(const Key('causal-kind-observation')),
        findsWidgets,
      );
    });

    testWidgets('runtime state changes are shown on the chain', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: attacker);

      // Scoped: the detailed record below renders the same change, prefixed
      // with the owning element.
      final causal = find.byType(CausalGraphView);

      expect(
        find.descendant(
          of: causal,
          matching: find.textContaining('signal: Quiet → Alerting'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: causal,
          matching: find.textContaining('stage: Idle → Collecting credentials'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the administrator is shown as involved but not acting', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: attacker);

      final involved = find.byKey(const Key('causal-involved-administrator'));

      expect(involved, findsOneWidget);

      // Asserted through the administrator's own key. The user also became
      // involved without acting, so the wording alone appears more than once
      // and is not, by itself, a statement about the administrator.
      expect(
        tester.widget<Text>(involved).data,
        'Became involved. Has not acted.',
      );
    });
  });

  group('actor overlay', () {
    testWidgets('marks what the selected participant witnessed', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: administrator);

      // The administrator saw exactly one occurrence in this chain.
      expect(find.byKey(const Key('causal-witnessed')), findsOneWidget);

      // And the rest of the chain is still shown, unhidden.
      expect(
        find.byKey(const Key('causal-element-authentication_engine')),
        findsWidgets,
      );
    });

    testWidgets('a different participant is marked differently', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: attacker);

      // The attacker took part in the attempt, so the occurrences that
      // carried it are marked for them. More than one mark is the behaviour
      // being tested here: they saw the start of the chain.
      expect(find.byKey(const Key('causal-witnessed')), findsWidgets);

      // But the alert that followed never reached them, so the step that
      // raised it carries no mark. The step is located from the run rather
      // than by a fixed position, so this stays true if the chain grows.
      final alert = SimulationCausalGraph.fromRun(
        controller.run,
      ).links.firstWhere((link) => link.eventTypeId == 'security_alert_raised');

      expect(
        find.descendant(
          of: find.byKey(Key('causal-step-${alert.sequence}')),
          matching: find.byKey(const Key('causal-witnessed')),
        ),
        findsNothing,
        reason: 'the attacker was never told about the alert',
      );
    });
  });

  group('selection', () {
    testWidgets('selecting a causal element selects the real element', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: attacker);

      final chip = find.byKey(const Key('causal-element-administrator')).first;

      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();

      // The administrator's own perspective is now on screen, which only
      // happens if the tap resolved to the administrator element itself.
      expect(find.byKey(const Key('actor-perspective')), findsOneWidget);
      expect(find.byKey(const Key('relevance-active')), findsOneWidget);
    });
  });

  group('extending and clearing', () {
    testWidgets('the administrator action extends the chain', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: administrator);

      expect(find.byKey(const Key('causal-element-user_account')), findsNothing);

      controller.perform(actionById('administrator.lock_account'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('causal-element-user_account')),
        findsWidgets,
      );
      expect(
        find.descendant(
          of: find.byType(CausalGraphView),
          matching: find.textContaining('access: Active → Locked'),
        ),
        findsOneWidget,
      );

      // The earlier history is still present.
      expect(
        find.byKey(const Key('causal-element-security_monitoring')),
        findsWidgets,
      );
    });

    testWidgets('reset clears the causal graph completely', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: attacker);

      expect(find.byKey(const Key('causal-graph')), findsOneWidget);

      await tester.tap(find.byKey(const Key('reset-run')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('causal-graph')), findsNothing);
      expect(find.byKey(const Key('causal-graph-empty')), findsOneWidget);
    });
  });

  group('both views are available', () {
    testWidgets('the causal graph and the detailed record sit together', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      await pumpPanel(tester, controller, selected: attacker);

      expect(find.text('What happened'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);

      expect(find.byKey(const Key('causal-graph')), findsOneWidget);
      expect(find.byKey(const Key('trace-view')), findsOneWidget);
    });
  });
}

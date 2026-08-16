import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/ui/simulation/simulation_panel.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/trace_view.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// Drives the Password Security demonstration through the learner UI.
///
/// Nothing here stages an outcome. Every assertion is about what the engine
/// produced and the widgets displayed.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioSimulationController makeController() {
    return StudioSimulationController(
      graph: graph,
      runId: 'test',
      initialActors: {attacker},
    );
  }

  Widget harness(
    StudioSimulationController controller, {
    StudioElementRef? selected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SimulationPanel(
          controller: controller,
          session: session,
          selectedElement: selected,
        ),
      ),
    );
  }

  /// Password Security now offers a situation, so a panel opened before
  /// anything has happened asks which one to explore. These tests are about
  /// what happens inside a situation, so they answer the question and carry
  /// on. Scenario selection itself is covered in scenario_selection_test.dart.
  Future<void> enterScenarioIfOffered(WidgetTester tester) async {
    if (find.byKey(const Key('scenario-chooser')).evaluate().isEmpty) {
      return;
    }

    await tester.tap(
      find.byKey(const Key('scenario-option-attempted_account_takeover')),
    );

    await tester.pumpAndSettle();
  }

  /// Pumps on a surface large enough that nothing needs scrolling into view.
  Future<void> pumpPanel(
    WidgetTester tester,
    StudioSimulationController controller, {
    StudioElementRef? selected,
  }) async {
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(harness(controller, selected: selected));
    await tester.pumpAndSettle();

    await enterScenarioIfOffered(tester);
  }

  group('actor selection', () {
    testWidgets('lists every actor, involved or not', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);

      expect(find.byKey(const Key('actor-chip-attacker')), findsOneWidget);
      expect(
        find.byKey(const Key('actor-chip-administrator')),
        findsOneWidget,
        reason: 'uninvolved actors are still shown; relevance is the model',
      );
      expect(find.byKey(const Key('actor-chip-user')), findsOneWidget);
    });

    testWidgets('selecting an actor shows their perspective', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);

      await tester.tap(find.byKey(const Key('actor-chip-attacker')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('actor-perspective')), findsOneWidget);
      expect(find.text('Attacker'), findsWidgets);
      expect(find.text('Knows about'), findsOneWidget);
      expect(
        find.text('Could observe'),
        findsOneWidget,
        reason: 'knowing and being able to observe stay separate',
      );
    });

    testWidgets('a non-actor selection is declined, not substituted', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: const StudioElementRef.node('login_interface'),
      );

      expect(find.byKey(const Key('perspective-unsupported')), findsOneWidget);
      expect(find.byKey(const Key('actor-perspective')), findsNothing);
    });

    testWidgets('a relationship selection stays truthful', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: const StudioElementRef.relationship(
          'monitoring_notifies_administrator',
        ),
      );

      expect(find.byKey(const Key('perspective-unsupported')), findsOneWidget);
      expect(
        find.textContaining('not a participant'),
        findsOneWidget,
        reason: 'it must say what it cannot show, not show something else',
      );
    });
  });

  group('ACTIONS control', () {
    testWidgets('opens a list of the actor available actions', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('action-list-sheet')), findsOneWidget);
      expect(
        find.byKey(const Key('action-attacker.attempt_authentication')),
        findsOneWidget,
      );

      // Name, description and target are all present. Scoped to the sheet:
      // the causal view names the same action once one has been performed.
      expect(
        find.descendant(
          of: find.byKey(const Key('action-list-sheet')),
          matching: find.text('Attempt authentication'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Against: Login Interface'), findsOneWidget);
    });

    testWidgets('says so clearly when nothing is available', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: administrator);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('action-list-empty')), findsOneWidget);
      expect(find.byKey(const Key('action-list')), findsNothing);
    });

    testWidgets('an uninvolved actor is offered nothing', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: administrator);

      expect(controller.isRelevant(administrator), isFalse);
      expect(find.text('ACTIONS'), findsOneWidget);
      expect(
        find.textContaining('not involved yet'),
        findsWidgets,
      );
    });
  });

  group('performing an action', () {
    testWidgets('runs the engine and shows the causal trace', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      expect(find.byKey(const Key('trace-empty')), findsOneWidget);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('action-attacker.attempt_authentication')),
      );
      await tester.pumpAndSettle();

      // The sheet closed and the trace appeared.
      expect(find.byKey(const Key('action-list-sheet')), findsNothing);
      expect(find.byKey(const Key('trace-view')), findsOneWidget);

      // Three steps, produced by the engine: action, engine, monitoring.
      expect(controller.trace, hasLength(3));
      expect(find.byKey(const Key('trace-entry-0')), findsOneWidget);
      expect(find.byKey(const Key('trace-entry-1')), findsOneWidget);
      expect(find.byKey(const Key('trace-entry-2')), findsOneWidget);

      expect(find.text('Evaluate authentication attempt'), findsOneWidget);
      expect(find.text('Notice a failed authentication'), findsOneWidget);

      // Emitted occurrences are named from the typed declarations.
      // Scoped: the causal graph beside the record names them too.
      expect(
        find.descendant(
          of: find.byType(TraceView),
          matching: find.text('Security alert raised'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('state changes are shown with both sides', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('action-attacker.attempt_authentication')),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TraceView),
          matching: find.textContaining('Quiet → Alerting'),
        ),
        findsOneWidget,
      );
    });
  });

  group('administrator relevance', () {
    testWidgets('becomes involved after the alert and gains an action', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      expect(controller.isRelevant(administrator), isFalse);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('action-attacker.attempt_authentication')),
      );
      await tester.pumpAndSettle();

      expect(
        controller.isRelevant(administrator),
        isTrue,
        reason: 'the alert reached them; nothing scheduled it',
      );

      // Now look at what the administrator knows.
      await pumpPanel(tester, controller, selected: administrator);

      expect(find.byKey(const Key('relevance-active')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('actor-perspective')),
          matching: find.text('Security alert raised'),
        ),
        findsOneWidget,
      );

      // And they can act.
      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('action-administrator.lock_account')),
        findsOneWidget,
      );
    });

    testWidgets('the administrator learns only what reached them', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(
        graph.actionDefinitions.firstWhere(
          (action) => action.id == 'attacker.attempt_authentication',
        ),
      );

      await pumpPanel(tester, controller, selected: administrator);

      final perspective = find.byKey(const Key('actor-perspective'));

      expect(
        find.descendant(
          of: perspective,
          matching: find.text('Security alert raised'),
        ),
        findsWidgets,
      );

      // Scoped to the perspective: the trace beside it is deliberately
      // omniscient, and shows everything the system did.
      expect(
        find.descendant(
          of: perspective,
          matching: find.text('Authentication failed'),
        ),
        findsNothing,
        reason: 'monitoring reported the alert, not everything it saw',
      );
      expect(
        find.descendant(
          of: perspective,
          matching: find.text('Authentication attempted'),
        ),
        findsNothing,
      );
    });

    testWidgets('locking the account changes the run state', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(
        graph.actionDefinitions.firstWhere(
          (action) => action.id == 'attacker.attempt_authentication',
        ),
      );

      await pumpPanel(tester, controller, selected: administrator);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('action-administrator.lock_account')),
      );
      await tester.pumpAndSettle();

      expect(
        controller.state.valueOf(
          graph.stateVariableById('user_account.access')!,
        ),
        'Locked',
      );
      expect(
        find.descendant(
          of: find.byType(TraceView),
          matching: find.textContaining('Active → Locked'),
        ),
        findsOneWidget,
      );
    });
  });

  group('fidelity', () {
    testWidgets('a full observation shows its channel and source', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(
        graph.actionDefinitions.firstWhere(
          (action) => action.id == 'attacker.attempt_authentication',
        ),
      );

      await pumpPanel(tester, controller, selected: administrator);

      final perspective = find.byKey(const Key('actor-perspective'));

      expect(find.text('Full detail'), findsWidgets);
      expect(
        find.descendant(
          of: perspective,
          matching: find.textContaining('At Security Monitoring'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: perspective,
          matching: find.textContaining('monitoring_notifies_administrator'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('nothing unobserved leaks into a perspective', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      controller.perform(
        graph.actionDefinitions.firstWhere(
          (action) => action.id == 'attacker.attempt_authentication',
        ),
      );

      await pumpPanel(tester, controller, selected: attacker);
      await tester.pumpAndSettle();

      // The alert exists in the run, but not for the attacker.
      expect(controller.events.map((event) => event.typeId),
          contains('security_alert_raised'));

      final perspective = find.byKey(const Key('actor-perspective'));

      expect(
        find.descendant(
          of: perspective,
          matching: find.text('Security alert raised'),
        ),
        findsNothing,
        reason: 'the attacker was never told',
      );
    });
  });

  group('reset', () {
    testWidgets('returns the run and the perspectives to the start', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('action-attacker.attempt_authentication')),
      );
      await tester.pumpAndSettle();

      expect(controller.isRelevant(administrator), isTrue);
      expect(find.byKey(const Key('trace-view')), findsOneWidget);

      await tester.tap(find.byKey(const Key('reset-run')));
      await tester.pumpAndSettle();

      expect(controller.trace, isEmpty);
      expect(controller.isRelevant(administrator), isFalse);
      expect(find.byKey(const Key('trace-empty')), findsOneWidget);
    });
  });

  group('the authored graph is never modified', () {
    testWidgets('running and resetting leaves declarations untouched', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      final before = graph.stateVariables
          .map((variable) => variable.initialValue)
          .toList();

      await pumpPanel(tester, controller, selected: attacker);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('action-attacker.attempt_authentication')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset-run')));
      await tester.pumpAndSettle();

      expect(
        graph.stateVariables.map((variable) => variable.initialValue).toList(),
        before,
      );
    });
  });
}

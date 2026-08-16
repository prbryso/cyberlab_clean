import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/graphs/system_graph_canvas.dart';
import 'package:systems_studio/engine/ui/workspace/system_workspace.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The system graph while a run is being explored.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');

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

  Future<void> pumpWorkspace(
    WidgetTester tester, {
    StudioSimulationController? simulation,
    String? selectedNodeId,
  }) async {
    tester.view.physicalSize = const Size(2200, 3000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SystemWorkspace(
            graph: graph,
            simulation: simulation,
            initialSelectedNodeId: selectedNodeId,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  /// The elements the canvas is actually drawing.
  Set<String> drawnNodeIds(WidgetTester tester) {
    final canvas = tester.widget<SystemGraphCanvas>(
      find.byType(SystemGraphCanvas),
    );

    return canvas.graph.nodes.map((node) => node.id).toSet();
  }

  group('architecture without a run is unchanged', () {
    testWidgets('no overlay is applied and nothing extra is revealed', (
      tester,
    ) async {
      await pumpWorkspace(tester);

      expect(find.byKey(const Key('system-graph-canvas')), findsOneWidget);
      expect(
        find.byKey(const Key('system-graph-canvas-simulation')),
        findsNothing,
      );
      expect(find.byKey(const Key('workspace-run-banner')), findsNothing);

      final canvas = tester.widget<SystemGraphCanvas>(
        find.byType(SystemGraphCanvas),
      );

      expect(canvas.overlay, isNull);

      // The nested participants are not drawn until someone opens their
      // containers, exactly as before.
      expect(drawnNodeIds(tester), isNot(contains('authentication_engine')));
    });

    testWidgets('a run that has not started leaves it unchanged too', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      expect(find.byKey(const Key('system-graph-canvas')), findsOneWidget);
      expect(find.byKey(const Key('workspace-run-banner')), findsNothing);

      expect(
        tester
            .widget<SystemGraphCanvas>(find.byType(SystemGraphCanvas))
            .overlay,
        isNull,
        reason: 'an empty run is not something to draw',
      );
    });
  });

  group('after the attacker action', () {
    testWidgets('the whole causal path is drawn without expanding anything', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      // No expand arrow is tapped anywhere in this test. These labels are
      // asserted inside the canvas, so they prove the elements survived the
      // hierarchy filter and are genuinely drawn — not merely present in the
      // graph handed to it.
      final canvas = find.byType(SystemGraphCanvas);

      for (final label in [
        'Attacker',
        'Login Interface',
        'Authentication Engine',
        'Security Monitoring',
        'Administrator',
      ]) {
        expect(
          find.descendant(of: canvas, matching: find.text(label)),
          findsOneWidget,
          reason: '$label is on the causal path and must be visible '
              'without expanding anything',
        );
      }
    });

    testWidgets('nested participants are drawn without their containers '
        'being opened by hand', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      // Before the run, the engine is buried inside a collapsed subsystem.
      expect(
        find.descendant(
          of: find.byType(SystemGraphCanvas),
          matching: find.text('Authentication Engine'),
        ),
        findsNothing,
      );

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SystemGraphCanvas),
          matching: find.text('Authentication Engine'),
        ),
        findsOneWidget,
        reason: 'running the system is what revealed it',
      );
    });

    testWidgets('the elements that took part are marked in order', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      for (final id in [
        'attacker',
        'login_interface',
        'authentication_engine',
        'security_monitoring',
        'administrator',
      ]) {
        expect(
          find.byKey(Key('overlay-order-$id')),
          findsOneWidget,
          reason: '$id took part and should carry its position in the chain',
        );
      }
    });

    testWidgets('runtime state changes are shown on the elements', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const Key('overlay-change-security_monitoring-'
              'security_monitoring.signal'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a variable moved twice yields one chip, not two', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      // login_interface.stage moves Idle -> Collecting credentials -> Access
      // denied during this one action. Two chips here would be two widgets
      // claiming the same identity.
      expect(
        find.byKey(
          const Key('overlay-change-login_interface-login_interface.stage'),
        ),
        findsOneWidget,
      );

      // And it reports the span it actually covered, saying that it is one.
      expect(
        find.descendant(
          of: find.byType(SystemGraphCanvas),
          matching: find.text('stage: Idle → Access denied (2 changes)'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('unrelated architecture is still drawn, not removed', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      final drawn = drawnNodeIds(tester);
      final canvas = tester.widget<SystemGraphCanvas>(
        find.byType(SystemGraphCanvas),
      );

      expect(drawn, containsAll(['credentials', 'monitoring_and_recovery']));

      // Drawn, and with no part in the run: the de-emphasised case. Faded is
      // not the same as gone.
      expect(canvas.overlay!.involves('credentials'), isFalse);

      expect(
        find.descendant(
          of: find.byType(SystemGraphCanvas),
          matching: find.text('Credentials'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('overlay-order-credentials')), findsNothing);
    });

    testWidgets('the graph says it is showing a run', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('workspace-run-banner')), findsOneWidget);
      expect(
        find.byKey(const Key('system-graph-canvas-simulation')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('workspace-run-banner')),
          matching: find.textContaining('dimmed, not hidden'),
        ),
        findsOneWidget,
        reason: 'a learner should not have to infer why elements faded',
      );
    });
  });

  group('the administrator action extends the drawing', () {
    testWidgets('the account appears once it is acted upon', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('overlay-order-user_account')), findsNothing);

      controller.perform(actionById('administrator.lock_account'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('overlay-order-user_account')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('overlay-change-user_account-user_account.access'),
        ),
        findsOneWidget,
      );

      // The earlier chain is still drawn.
      expect(
        find.byKey(const Key('overlay-order-security_monitoring')),
        findsOneWidget,
      );
    });
  });

  group('reset clears the overlay', () {
    testWidgets('the architecture returns to answering only its own question', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('workspace-run-banner')), findsOneWidget);

      controller.reset();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('workspace-run-banner')), findsNothing);
      expect(find.byKey(const Key('system-graph-canvas')), findsOneWidget);
      expect(
        find.byKey(const Key('overlay-order-security_monitoring')),
        findsNothing,
      );
      expect(
        tester
            .widget<SystemGraphCanvas>(find.byType(SystemGraphCanvas))
            .overlay,
        isNull,
      );
    });
  });

  group('ordinary selection still works', () {
    testWidgets('an element with no part in the run can still be selected', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      final canvas = tester.widget<SystemGraphCanvas>(
        find.byType(SystemGraphCanvas),
      );

      // Named rather than discovered, so this cannot quietly land on the
      // element that was already selected and prove nothing.
      const uninvolved = StudioElementRef.node('credentials');

      expect(canvas.overlay!.involves(uninvolved.id), isFalse);
      expect(canvas.selectedElement, isNot(uninvolved));

      final target = find
          .descendant(
            of: find.byType(SystemGraphCanvas),
            matching: find.text('Credentials'),
          )
          .first;

      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<SystemGraphCanvas>(find.byType(SystemGraphCanvas))
            .selectedElement,
        uninvolved,
        reason: 'dimming must not cost an element its selectability',
      );
    });

    testWidgets('selecting an actor marks what that actor witnessed', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(
        tester,
        simulation: controller,
        selectedNodeId: 'administrator',
      );

      controller.perform(actionById('attacker.attempt_authentication'));
      await tester.pumpAndSettle();

      final canvas = tester.widget<SystemGraphCanvas>(
        find.byType(SystemGraphCanvas),
      );

      expect(canvas.overlayActor, const StudioElementRef.node('administrator'));

      // Marking is additive: the rest of the chain is still there.
      expect(
        canvas.overlay!.steps.length,
        greaterThan(
          canvas.overlay!
              .stepsObservedBy(const StudioElementRef.node('administrator'))
              .length,
        ),
      );
    });
  });
}

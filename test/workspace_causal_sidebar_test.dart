import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/graphs/system_graph_canvas.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/causal_graph_view.dart';
import 'package:systems_studio/engine/ui/workspace/system_workspace.dart';
import 'package:systems_studio/engine/ui/workspace/workspace_details_panel.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The Workspace when a run is being explored: the architecture with the run
/// drawn on it, and the causal record beside it.
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

  Future<void> act(
    WidgetTester tester,
    StudioSimulationController controller,
  ) async {
    controller.perform(actionById('attacker.attempt_authentication'));
    await tester.pumpAndSettle();
  }

  group('no run', () {
    testWidgets('the sidebar is the inspector, with nothing added', (
      tester,
    ) async {
      await pumpWorkspace(tester);

      expect(find.byType(WorkspaceDetailsPanel), findsOneWidget);

      // No switch, no causal panel: the workspace is what it was before
      // simulation existed.
      expect(find.byKey(const Key('workspace-sidebar-switch')), findsNothing);
      expect(find.byKey(const Key('workspace-causal-panel')), findsNothing);
      expect(find.byType(CausalGraphView), findsNothing);
    });

    testWidgets('a run that has not started changes nothing either', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);

      expect(find.byType(WorkspaceDetailsPanel), findsOneWidget);
      expect(find.byKey(const Key('workspace-sidebar-switch')), findsNothing);
      expect(find.byType(CausalGraphView), findsNothing);
    });
  });

  group('a run exists', () {
    testWidgets('What Happened appears beside the graph and is shown first', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);
      await act(tester, controller);

      expect(find.byKey(const Key('workspace-sidebar-switch')), findsOneWidget);
      expect(find.byKey(const Key('workspace-causal-panel')), findsOneWidget);
      expect(find.byType(CausalGraphView), findsOneWidget);

      // Chosen for the learner, not merely available.
      expect(find.byType(WorkspaceDetailsPanel), findsNothing);
      expect(find.byKey(const Key('causal-graph')), findsOneWidget);

      // The sidebar is far narrower than the panel this view was built for,
      // so it has to fit rather than spill.
      expect(tester.takeException(), isNull);
    });

    testWidgets('the causal record fits the sidebar it is given', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      // Selecting an actor adds the witness marks, which is the widest the
      // step header ever gets.
      await pumpWorkspace(
        tester,
        simulation: controller,
        selectedNodeId: 'administrator',
      );
      await act(tester, controller);

      expect(tester.takeException(), isNull);

      final panel = tester.getSize(
        find.byKey(const Key('workspace-causal-panel')),
      );
      final graph = tester.getSize(find.byKey(const Key('causal-graph')));

      expect(
        graph.width,
        lessThanOrEqualTo(panel.width),
        reason: 'the chain must lay itself out inside the sidebar',
      );
    });

    testWidgets('the overlaid architecture and the causal chain are both '
        'on screen at once', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);
      await act(tester, controller);

      // The graph, still carrying the run.
      expect(
        find.byKey(const Key('system-graph-canvas-simulation')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('overlay-order-security_monitoring')),
        findsOneWidget,
      );

      // And the record of it, beside the graph rather than instead of it.
      expect(find.byKey(const Key('causal-graph')), findsOneWidget);

      // Beside, not instead of: the record occupies the right-hand sidebar
      // while the graph keeps the main area. Asserted against the workspace
      // rather than the canvas, whose own rect is a pannable drawing surface
      // larger than the viewport showing it.
      final workspace = tester.getRect(find.byType(SystemWorkspace));
      final panel = tester.getRect(
        find.byKey(const Key('workspace-causal-panel')),
      );

      expect(find.byType(SystemGraphCanvas), findsOneWidget);
      expect(panel.left, greaterThan(workspace.center.dx));
    });

    testWidgets('the causal panel scrolls without moving the graph', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);
      await act(tester, controller);

      final scrollable = find.descendant(
        of: find.byKey(const Key('workspace-causal-panel')),
        matching: find.byType(Scrollable),
      );

      expect(
        scrollable,
        findsWidgets,
        reason: 'a long chain must not be capped by the height of the graph',
      );
    });

    testWidgets('the causal record derives from the same run as the overlay', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);
      await act(tester, controller);

      final causal = tester.widget<CausalGraphView>(
        find.byType(CausalGraphView),
      );
      final canvas = tester.widget<SystemGraphCanvas>(
        find.byType(SystemGraphCanvas),
      );

      expect(
        causal.causalGraph.links.length,
        canvas.overlay!.steps.length,
        reason: 'one derivation feeds both, so they cannot disagree',
      );
    });
  });

  group('actor selection', () {
    testWidgets('the whole chain stays, and what the actor saw is marked', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(
        tester,
        simulation: controller,
        selectedNodeId: 'administrator',
      );
      await act(tester, controller);

      final causal = tester.widget<CausalGraphView>(
        find.byType(CausalGraphView),
      );

      expect(causal.selectedActor, administrator);

      // Every step is still rendered — selecting an actor narrows nothing.
      expect(
        causal.causalGraph.links.length,
        greaterThan(causal.causalGraph.linksObservedBy(administrator).length),
      );

      for (final id in [
        'attacker',
        'authentication_engine',
        'security_monitoring',
      ]) {
        expect(
          find.descendant(
            of: find.byKey(const Key('workspace-causal-panel')),
            matching: find.byKey(Key('causal-element-$id')),
          ),
          findsWidgets,
          reason: '$id must remain visible regardless of who was watching',
        );
      }

      // And the one occurrence that reached them is marked.
      expect(
        find.descendant(
          of: find.byKey(const Key('workspace-causal-panel')),
          matching: find.byKey(const Key('causal-witnessed')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a non-actor selection marks nothing', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(
        tester,
        simulation: controller,
        selectedNodeId: 'credentials',
      );
      await act(tester, controller);

      final causal = tester.widget<CausalGraphView>(
        find.byType(CausalGraphView),
      );

      expect(
        causal.selectedActor,
        isNull,
        reason: 'asking what a component saw borrows actor language',
      );
    });
  });

  group('ordinary details remain reachable', () {
    testWidgets('the inspector is one tap away and still works', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(
        tester,
        simulation: controller,
        selectedNodeId: 'authentication_engine',
      );
      await act(tester, controller);

      expect(find.byType(WorkspaceDetailsPanel), findsNothing);

      await tester.tap(find.byKey(const Key('sidebar-details')));
      await tester.pumpAndSettle();

      expect(find.byType(WorkspaceDetailsPanel), findsOneWidget);
      expect(find.byType(CausalGraphView), findsNothing);

      // The inspector is intact, describing the current selection.
      expect(
        find.descendant(
          of: find.byType(WorkspaceDetailsPanel),
          matching: find.text('Authentication Engine'),
        ),
        findsWidgets,
      );

      // And the choice is reversible.
      await tester.tap(find.byKey(const Key('sidebar-what-happened')));
      await tester.pumpAndSettle();

      expect(find.byType(CausalGraphView), findsOneWidget);
    });

    testWidgets('the graph keeps its overlay while Details is open', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);
      await act(tester, controller);

      await tester.tap(find.byKey(const Key('sidebar-details')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('system-graph-canvas-simulation')),
        findsOneWidget,
        reason: 'the sidebar question does not change what the graph shows',
      );
    });
  });

  group('reset', () {
    testWidgets('the causal sidebar goes and the inspector returns', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);
      await act(tester, controller);

      expect(find.byType(CausalGraphView), findsOneWidget);

      controller.reset();
      await tester.pumpAndSettle();

      expect(find.byType(CausalGraphView), findsNothing);
      expect(find.byKey(const Key('workspace-sidebar-switch')), findsNothing);
      expect(find.byKey(const Key('workspace-causal-panel')), findsNothing);

      expect(find.byType(WorkspaceDetailsPanel), findsOneWidget);
      expect(find.byKey(const Key('system-graph-canvas')), findsOneWidget);
    });

    testWidgets('a new run starts on What Happened again', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpWorkspace(tester, simulation: controller);
      await act(tester, controller);

      // The learner switches to Details during the first run.
      await tester.tap(find.byKey(const Key('sidebar-details')));
      await tester.pumpAndSettle();

      expect(find.byType(WorkspaceDetailsPanel), findsOneWidget);

      controller.reset();
      await tester.pumpAndSettle();

      await act(tester, controller);

      expect(
        find.byType(CausalGraphView),
        findsOneWidget,
        reason: 'a reset starts over, including which question is asked first',
      );
    });
  });
}

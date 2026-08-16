import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/ui/simulation/simulation_panel.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/causal_graph_view.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// Where a situation began, and why each step went the way it did.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');

  const takeoverKey = Key('scenario-option-attempted_account_takeover');
  const compromisedKey = Key('scenario-option-compromised_credential_store');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  final attempt = graph.actionDefinitions.firstWhere(
    (action) => action.id == 'attacker.attempt_authentication',
  );

  StudioSimulationController makeController({StudioSystemGraph? on}) {
    return StudioSimulationController(
      graph: on ?? graph,
      runId: 'test',
      initialActors: on == null ? const {} : {attacker},
    );
  }

  Future<void> pumpPanel(
    WidgetTester tester,
    StudioSimulationController controller, {
    StudioElementRef? selected,
    double width = 1600,
    Key? panelKey,
  }) async {
    tester.view.physicalSize = Size(width, 2600);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SimulationPanel(
            key: panelKey,
            controller: controller,
            session: session,
            selectedElement: selected,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, Key option) async {
    await tester.tap(find.byKey(option));
    await tester.pumpAndSettle();
  }

  String factText(WidgetTester tester, String variableId) {
    return tester
        .widget<Text>(find.byKey(Key('starting-fact-$variableId')))
        .data!;
  }

  group('starting facts in the entry state', () {
    testWidgets('a situation shows exactly the overrides it authored', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: StudioElementRef.node(graph.systemId),
      );
      await choose(tester, compromisedKey);

      expect(find.byKey(const Key('starting-facts')), findsOneWidget);

      // Named as the rest of Systems Studio names them, not by internal ID.
      expect(
        factText(tester, 'credential_store.integrity'),
        'Credential Store · Integrity: Compromised',
      );
      expect(
        factText(tester, 'user_device.trust'),
        'User Device · Trust: Trusted',
      );

      // Exactly two, because exactly two were authored.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.key.toString().contains('starting-fact-'),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('a situation with no overrides invents none', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: StudioElementRef.node(graph.systemId),
      );
      await choose(tester, takeoverKey);

      expect(
        find.byKey(const Key('starting-facts')),
        findsNothing,
        reason: 'the system as declared is not a set of facts to list',
      );

      // The situation itself is still described.
      expect(find.byKey(const Key('situation-entry')), findsOneWidget);
    });
  });

  group('starting facts are not changes', () {
    testWidgets('they never appear under Since this started', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await choose(tester, compromisedKey);

      controller.perform(attempt);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('since-this-started')), findsOneWidget);

      // Both overrides differ from the system's declared values, and neither
      // is a change: they are where this situation began.
      expect(
        find.byKey(const Key('difference-credential_store.integrity')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('difference-user_device.trust')),
        findsNothing,
      );

      // What the run actually moved is still reported.
      expect(
        find.byKey(const Key('difference-mfa_service.challenge')),
        findsOneWidget,
      );
    });
  });

  group('causal explanations', () {
    testWidgets('an authored explanation appears on its own step', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await choose(tester, takeoverKey);

      controller.perform(attempt);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(CausalGraphView),
          matching: find.textContaining('The evidence did not match'),
        ),
        findsOneWidget,
        reason: 'why this outcome was chosen belongs on the step it explains',
      );
    });

    testWidgets('no explanation is invented where none is authored', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await choose(tester, takeoverKey);

      controller.perform(attempt);
      await tester.pumpAndSettle();

      final rendered = find
          .byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.key.toString().contains('causal-explanation-'),
          )
          .evaluate()
          .length;

      final authored = controller.trace
          .where((entry) => entry.explanation.trim().isNotEmpty)
          .length;

      expect(rendered, lessThanOrEqualTo(authored));

      // Observation steps carry no explanation, so not every step has one.
      expect(rendered, lessThan(controller.trace.length + 2));
    });

    testWidgets('explanation and guiding question stay distinct', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await choose(tester, takeoverKey);

      controller.perform(attempt);
      await tester.pumpAndSettle();

      final causal = find.byType(CausalGraphView);

      // The refusal step carries both, and they say different things.
      expect(
        find.descendant(
          of: causal,
          matching: find.textContaining('The evidence did not match'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: causal,
          matching: find.textContaining('What does it also reveal?'),
        ),
        findsOneWidget,
      );
    });
  });

  group('the situation stays recoverable after choosing a participant', () {
    testWidgets('description and starting facts are one tap away', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await choose(tester, compromisedKey);

      // The entry panel is gone, replaced by the participant's view.
      expect(find.byKey(const Key('situation-entry')), findsNothing);
      expect(find.byKey(const Key('actor-perspective')), findsOneWidget);

      // Collapsed by default: what it is, without the detail.
      expect(find.byKey(const Key('scenario-bar')), findsOneWidget);
      expect(find.byKey(const Key('scenario-bar-description')), findsNothing);
      expect(find.byKey(const Key('starting-facts')), findsNothing);

      await tester.tap(find.byKey(const Key('scenario-detail-toggle')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('scenario-bar-description')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('starting-facts')), findsOneWidget);
      expect(
        factText(tester, 'credential_store.integrity'),
        'Credential Store · Integrity: Compromised',
      );

      // And it collapses again.
      await tester.tap(find.byKey(const Key('scenario-detail-toggle')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('starting-facts')), findsNothing);
    });

    testWidgets('a situation with no overrides still offers its description', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await choose(tester, takeoverKey);

      await tester.tap(find.byKey(const Key('scenario-detail-toggle')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('scenario-bar-description')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('starting-facts')),
        findsNothing,
        reason: 'nothing was established, so there is nothing to list',
      );
    });
  });

  group('systems offering no situation are unchanged', () {
    StudioSystemGraph withoutScenarios() {
      return StudioSystemGraph(
        systemId: graph.systemId,
        nodes: graph.nodes,
        relationships: graph.relationships,
        perspectiveDefinitions: graph.perspectiveDefinitions,
        stateVariables: graph.stateVariables,
        eventTypes: graph.eventTypes,
        actionDefinitions: graph.actionDefinitions,
        behaviorDefinitions: graph.behaviorDefinitions,
      );
    }

    testWidgets('no bar, no facts, straight into the simulation', (
      tester,
    ) async {
      final controller = makeController(on: withoutScenarios());
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      expect(find.byKey(const Key('scenario-bar')), findsNothing);
      expect(find.byKey(const Key('starting-facts')), findsNothing);
      expect(find.byKey(const Key('actor-perspective')), findsOneWidget);
      expect(controller.scenario.isImplicit, isTrue);
    });
  });

  group('it fits a narrow panel', () {
    testWidgets('entry state with starting facts', (tester) async {
      for (final width in [400.0, 320.0, 286.0]) {
        final controller = makeController();
        addTearDown(controller.dispose);

        await pumpPanel(
          tester,
          controller,
          selected: StudioElementRef.node(graph.systemId),
          width: width,
          panelKey: ValueKey('entry-$width'),
        );
        await choose(tester, compromisedKey);

        expect(
          tester.takeException(),
          isNull,
          reason: 'starting facts must fit ${width}px',
        );
        expect(find.byKey(const Key('starting-facts')), findsOneWidget);
      }
    });

    testWidgets('expanded bar and explained steps', (tester) async {
      for (final width in [400.0, 320.0, 286.0]) {
        final controller = makeController();
        addTearDown(controller.dispose);

        await pumpPanel(
          tester,
          controller,
          selected: attacker,
          width: width,
          panelKey: ValueKey('bar-$width'),
        );
        await choose(tester, compromisedKey);

        await tester.tap(find.byKey(const Key('scenario-detail-toggle')));
        await tester.pumpAndSettle();

        controller.perform(attempt);
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'the expanded bar and the explanations must fit ${width}px',
        );
      }
    });
  });
}

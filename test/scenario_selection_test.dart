import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/ui/simulation/simulation_panel.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// Choosing a situation to explore, and what that does and does not do.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const takeoverKey = Key('scenario-option-attempted_account_takeover');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioSimulationController makeController({
    Set<StudioElementRef> initialActors = const {},
  }) {
    return StudioSimulationController(
      graph: graph,
      runId: 'test',
      initialActors: initialActors,
    );
  }

  Future<void> pumpPanel(
    WidgetTester tester,
    StudioSimulationController controller, {
    StudioElementRef? selected,
    double width = 1600,
  }) async {
    tester.view.physicalSize = Size(width, 2400);
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
  }

  Future<void> chooseTakeover(WidgetTester tester) async {
    await tester.tap(find.byKey(takeoverKey));
    await tester.pumpAndSettle();
  }

  final takeover = graph.scenarios.firstWhere(
    (scenario) => scenario.id == 'attempted_account_takeover',
  );

  group('the authored situations', () {
    test('Password Security offers three, with distinct identities', () {
      expect(graph.scenarios, hasLength(3));

      // Authored order, which is what the chooser presents.
      expect(
        graph.scenarios.map((scenario) => scenario.id),
        [
          'attempted_account_takeover',
          'compromised_credential_store',
          'compromised_store_unrecognised_device',
        ],
      );

      expect(
        graph.scenarios.map((scenario) => scenario.id).toSet(),
        hasLength(3),
        reason: 'situations cannot share an identity',
      );

      for (final scenario in graph.scenarios) {
        expect(scenario.name, isNotEmpty);
        expect(scenario.description, isNotEmpty);
      }
    });

    test('the attacker is already present in all of them', () {
      for (final scenario in graph.scenarios) {
        expect(scenario.initialActors, {attacker});
      }
    });

    test('the takeover situation starts where the system says it starts', () {
      // No overrides, so the system's declared values remain authoritative.
      expect(takeover.initialStateOverrides, isEmpty);

      expect(
        SimulationState.forScenario(graph, takeover).values,
        SimulationState.initial(graph).values,
      );
    });

    test('the canonical chain is unchanged under the scenario', () {
      final action = graph.actionDefinitions.firstWhere(
        (candidate) => candidate.id == 'attacker.attempt_authentication',
      );

      final scenarioRun = SimulationRun.start(
        graph,
        scenario: takeover,
      )..perform(action);

      // The same run as before scenarios existed, seeded the old way.
      final legacyRun = SimulationRun.start(graph, initialActors: {attacker})
        ..perform(action);

      final scenarioChain = SimulationCausalGraph.fromRun(scenarioRun);
      final legacyChain = SimulationCausalGraph.fromRun(legacyRun);

      expect(
        scenarioChain.links.map((link) => '${link.from.id}>${link.to.id}'),
        legacyChain.links.map((link) => '${link.from.id}>${link.to.id}'),
      );

      expect(scenarioRun.state.values, legacyRun.state.values);
      expect(scenarioRun.relevantActors, legacyRun.relevantActors);
    });
  });

  group('Simulate opens on the choice', () {
    testWidgets('the chooser is shown instead of actor controls', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);

      expect(find.byKey(const Key('scenario-chooser')), findsOneWidget);
      expect(find.text('Choose a scenario'), findsOneWidget);

      // The simulation proper is not yet on screen.
      expect(find.byKey(const Key('actions-button')), findsNothing);
      expect(find.byKey(const Key('reset-run')), findsNothing);
      expect(find.byKey(const Key('scenario-bar')), findsNothing);
    });

    testWidgets('the name and description are both readable', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);

      expect(find.text('Attempted Account Takeover'), findsOneWidget);
      expect(
        find.textContaining('attacker tries to get into an account'),
        findsOneWidget,
      );
    });

    testWidgets('choosing nothing performs nothing', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);

      expect(controller.isAtStart, isTrue);
      expect(controller.trace, isEmpty);
    });
  });

  group('entering the situation', () {
    testWidgets('the actor and action simulation appears', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await chooseTakeover(tester);

      expect(find.byKey(const Key('scenario-chooser')), findsNothing);
      expect(find.byKey(const Key('actor-perspective')), findsOneWidget);
      expect(find.byKey(const Key('actions-button')), findsOneWidget);
      expect(find.byKey(const Key('reset-run')), findsOneWidget);
    });

    testWidgets('selecting it takes no action of its own', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await chooseTakeover(tester);

      expect(
        controller.trace,
        isEmpty,
        reason: 'a scenario establishes the situation; it does not act',
      );
      expect(controller.isAtStart, isTrue);

      // But the attacker is present and has something they could do.
      expect(controller.isRelevant(attacker), isTrue);
      expect(controller.availableActionsFor(attacker), isNotEmpty);
      expect(controller.isRelevant(administrator), isFalse);
    });

    testWidgets('the situation is named while inside it', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await chooseTakeover(tester);

      expect(find.byKey(const Key('scenario-bar')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('scenario-bar')),
          matching: find.text('Attempted Account Takeover'),
        ),
        findsOneWidget,
      );

      expect(controller.scenario.id, 'attempted_account_takeover');
    });

    testWidgets('acting inside it works as it always did', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await chooseTakeover(tester);

      await tester.tap(find.byKey(const Key('actions-button')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('action-attacker.attempt_authentication')),
      );
      await tester.pumpAndSettle();

      expect(controller.trace, isNotEmpty);
      expect(controller.isRelevant(administrator), isTrue);
    });
  });

  group('reset stays inside the situation', () {
    testWidgets('it restores the start without asking to choose again', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await chooseTakeover(tester);

      controller.perform(
        graph.actionDefinitions.firstWhere(
          (action) => action.id == 'attacker.attempt_authentication',
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.trace, isNotEmpty);

      await tester.tap(find.byKey(const Key('reset-run')));
      await tester.pumpAndSettle();

      // Back to the start of this situation, still in it.
      expect(controller.isAtStart, isTrue);
      expect(controller.scenario.id, 'attempted_account_takeover');
      expect(controller.relevantActors, {attacker});

      expect(
        find.byKey(const Key('scenario-chooser')),
        findsNothing,
        reason: 'reset is not a way back to choosing a situation',
      );
      expect(find.byKey(const Key('scenario-bar')), findsOneWidget);
    });
  });

  group('changing the situation', () {
    testWidgets('it returns to the choice', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await chooseTakeover(tester);

      await tester.tap(find.byKey(const Key('change-scenario')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('scenario-chooser')), findsOneWidget);
      expect(find.byKey(const Key('scenario-bar')), findsNothing);
      expect(find.byKey(const Key('actions-button')), findsNothing);
    });

    testWidgets('re-entering starts a fresh run', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await chooseTakeover(tester);

      controller.perform(
        graph.actionDefinitions.firstWhere(
          (action) => action.id == 'attacker.attempt_authentication',
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.trace, isNotEmpty);

      await tester.tap(find.byKey(const Key('change-scenario')));
      await tester.pumpAndSettle();

      await chooseTakeover(tester);

      expect(
        controller.trace,
        isEmpty,
        reason: 'coming back to a situation begins it again',
      );
      expect(controller.relevantActors, {attacker});
      expect(controller.isRelevant(administrator), isFalse);
    });
  });

  group('systems that offer no situation', () {
    /// The same system with its scenarios removed — everything else identical.
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

    testWidgets('are never shown an empty chooser', (tester) async {
      final controller = StudioSimulationController(
        graph: withoutScenarios(),
        runId: 'test',
        initialActors: {attacker},
      );

      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      expect(find.byKey(const Key('scenario-chooser')), findsNothing);
      expect(find.byKey(const Key('scenario-bar')), findsNothing);

      // Straight into the simulation, exactly as before scenarios existed.
      expect(find.byKey(const Key('actor-perspective')), findsOneWidget);
      expect(find.byKey(const Key('actions-button')), findsOneWidget);
      expect(controller.scenario.isImplicit, isTrue);
    });
  });

  group('an exploration already under way', () {
    testWidgets('is not interrupted to ask where it should have started', (
      tester,
    ) async {
      final controller = makeController(initialActors: {attacker});
      addTearDown(controller.dispose);

      controller.perform(
        graph.actionDefinitions.firstWhere(
          (action) => action.id == 'attacker.attempt_authentication',
        ),
      );

      await pumpPanel(tester, controller, selected: attacker);

      expect(find.byKey(const Key('scenario-chooser')), findsNothing);
      expect(find.byKey(const Key('actor-perspective')), findsOneWidget);
      expect(controller.trace, isNotEmpty);
    });
  });

  group('the chooser fits narrow panels', () {
    testWidgets('no overflow at the widths Simulate actually reports', (
      tester,
    ) async {
      for (final width in [400.0, 320.0, 286.0]) {
        final controller = makeController();
        addTearDown(controller.dispose);

        await pumpPanel(tester, controller, width: width);

        expect(
          tester.takeException(),
          isNull,
          reason: 'the chooser must fit ${width}px without spilling',
        );

        expect(find.text('Attempted Account Takeover'), findsOneWidget);
      }
    });

    testWidgets('the scenario bar wraps rather than overflowing', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker, width: 320);
      await chooseTakeover(tester);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('scenario-bar')), findsOneWidget);
      expect(find.byKey(const Key('change-scenario')), findsOneWidget);
    });
  });
}

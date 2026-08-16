import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/ui/simulation/simulation_panel.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/causal_graph_view.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// Entering a situation, and what the screen says about it without being told.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const takeoverKey = Key('scenario-option-attempted_account_takeover');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  StudioSimulationController makeController({
    StudioSystemGraph? on,
    Set<StudioElementRef> initialActors = const {},
  }) {
    return StudioSimulationController(
      graph: on ?? graph,
      runId: 'test',
      initialActors: initialActors,
    );
  }

  Future<void> pumpPanel(
    WidgetTester tester,
    StudioSimulationController controller, {
    StudioElementRef? selected,
    double width = 1600,
    Key? panelKey,
  }) async {
    tester.view.physicalSize = Size(width, 2400);
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

  Future<void> enter(WidgetTester tester) async {
    await tester.tap(find.byKey(takeoverKey));
    await tester.pumpAndSettle();
  }

  /// The status line rendered for [actorId].
  ///
  /// Read directly: the key is on the status Text, and find.descendant does
  /// not include the widget it starts from.
  String statusOf(WidgetTester tester, String actorId) {
    return tester.widget<Text>(find.byKey(Key('actor-status-$actorId'))).data!;
  }

  Future<void> act(
    WidgetTester tester,
    StudioSimulationController controller,
  ) async {
    controller.perform(actionById('attacker.attempt_authentication'));
    await tester.pumpAndSettle();
  }

  group('the entry state describes the situation', () {
    testWidgets('no unsupported-perspective message on arrival', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      // The screen carries a non-actor selection, as the explorer does.
      await pumpPanel(
        tester,
        controller,
        selected: StudioElementRef.node(graph.systemId),
      );
      await enter(tester);

      expect(find.byKey(const Key('perspective-unsupported')), findsNothing);
      expect(find.byKey(const Key('situation-entry')), findsOneWidget);
    });

    testWidgets('the description survives being chosen', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: StudioElementRef.node(graph.systemId),
      );
      await enter(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('situation-entry')),
          matching: find.textContaining('attacker tries to get into an account'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('it invites without choosing', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: StudioElementRef.node(graph.systemId),
      );
      await enter(tester);

      expect(find.textContaining('Select a participant'), findsOneWidget);

      // Nobody was picked for the learner.
      expect(controller.trace, isEmpty);
      expect(find.byKey(const Key('actor-perspective')), findsNothing);
    });

    testWidgets('selecting a participant replaces it with their view', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await enter(tester);

      expect(find.byKey(const Key('situation-entry')), findsNothing);
      expect(find.byKey(const Key('actor-perspective')), findsOneWidget);
    });
  });

  group('participant status is said in words', () {
    testWidgets('the situation names who is present at start', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);
      await enter(tester);

      expect(statusOf(tester, 'attacker'), contains('Present at start'));
    });

    testWidgets('everyone else is not currently involved', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);
      await enter(tester);

      for (final id in ['administrator', 'user']) {
        expect(
          statusOf(tester, id),
          'Not currently involved',
          reason: '$id has no part in this situation as it stands',
        );
      }
    });

    testWidgets('no status promises future involvement', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);
      await enter(tester);

      // Scoped to the statuses themselves. The run header legitimately says
      // "Nothing has happened yet", which is a fact about the run rather than
      // a forecast about anybody.
      for (final id in ['attacker', 'administrator', 'user']) {
        expect(
          statusOf(tester, id),
          isNot(contains('yet')),
          reason: 'relevance arrives because something reached someone, and '
              'nothing guarantees anything will',
        );
      }
    });

    testWidgets('an actor drawn in during the run reads as involved', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await enter(tester);
      await act(tester, controller);

      expect(controller.isRelevant(administrator), isTrue);

      final status = statusOf(tester, 'administrator');

      expect(status, contains('Involved'));

      // And still distinguishable from having been placed there.
      expect(status, isNot(contains('Present at start')));
    });

    testWidgets('the action count matches the engine', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller);
      await enter(tester);

      final count = controller.availableActionsFor(attacker).length;

      expect(count, greaterThan(0));

      expect(statusOf(tester, 'attacker'), contains('$count available'));

      // Nobody uninvolved is given a count, because it would always be none.
      expect(statusOf(tester, 'user'), isNot(contains('available')));
    });
  });

  group('guiding questions', () {
    testWidgets('appear on the step they belong to', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await enter(tester);
      await act(tester, controller);

      // Password Security authors one on the alert step.
      final alert = controller.trace.firstWhere(
        (entry) => entry.guidingQuestion.contains('in a position to see'),
      );

      expect(alert.guidingQuestion, isNotEmpty);

      expect(
        find.descendant(
          of: find.byType(CausalGraphView),
          matching: find.textContaining('in a position to see it'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('none is invented where an author wrote none', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await enter(tester);
      await act(tester, controller);

      final authored = controller.trace
          .where((entry) => entry.guidingQuestion.trim().isNotEmpty)
          .length;

      final rendered = find
          .descendant(
            of: find.byType(CausalGraphView),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Text &&
                  widget.key.toString().contains('causal-question-'),
            ),
          )
          .evaluate()
          .length;

      expect(rendered, lessThanOrEqualTo(authored));
    });
  });

  group('since this started', () {
    testWidgets('is absent when nothing differs', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await enter(tester);

      expect(
        find.byKey(const Key('since-this-started')),
        findsNothing,
        reason: 'a change of nothing is not worth a heading',
      );
    });

    testWidgets('measures from the scenario start', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await enter(tester);
      await act(tester, controller);

      expect(find.byKey(const Key('since-this-started')), findsOneWidget);

      expect(
        find.byKey(const Key('difference-security_monitoring.signal')),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('since-this-started')),
          matching: find.textContaining('Quiet → Alerting'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('goes away on reset, as does everything else it described', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);
      await enter(tester);
      await act(tester, controller);

      expect(find.byKey(const Key('since-this-started')), findsOneWidget);

      await tester.tap(find.byKey(const Key('reset-run')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('since-this-started')), findsNothing);

      // Back to the situation, not back to choosing one.
      expect(find.byKey(const Key('scenario-chooser')), findsNothing);
      expect(find.byKey(const Key('scenario-bar')), findsOneWidget);
      expect(statusOf(tester, 'administrator'), 'Not currently involved');
    });
  });

  group('reset returns to the entry state', () {
    testWidgets('with no participant selected, the situation is described', (
      tester,
    ) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: StudioElementRef.node(graph.systemId),
      );
      await enter(tester);
      await act(tester, controller);

      await tester.tap(find.byKey(const Key('reset-run')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('situation-entry')), findsOneWidget);
      expect(find.byKey(const Key('perspective-unsupported')), findsNothing);
      expect(find.byKey(const Key('scenario-chooser')), findsNothing);
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

    testWidgets('a non-actor selection still says so plainly', (tester) async {
      final controller = makeController(
        on: withoutScenarios(),
        initialActors: {attacker},
      );

      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: StudioElementRef.node(graph.systemId),
      );

      // No situation to describe, so the perspective's refusal stands.
      expect(find.byKey(const Key('perspective-unsupported')), findsOneWidget);
      expect(find.byKey(const Key('situation-entry')), findsNothing);
      expect(find.byKey(const Key('scenario-bar')), findsNothing);
    });

    testWidgets('status still reads from the implicit scenario', (
      tester,
    ) async {
      final controller = makeController(
        on: withoutScenarios(),
        initialActors: {attacker},
      );

      addTearDown(controller.dispose);

      await pumpPanel(tester, controller, selected: attacker);

      expect(statusOf(tester, 'attacker'), contains('Present at start'));
    });
  });

  group('it all fits a narrow panel', () {
    testWidgets('no overflow at the widths Simulate reports', (tester) async {
      for (final width in [400.0, 320.0, 286.0]) {
        final controller = makeController();
        addTearDown(controller.dispose);

        // A distinct key per width, so each case gets a fresh panel state and
        // genuinely starts at the chooser. Without it the panel from the
        // previous width is reused, still holding the situation it was given,
        // and the chooser is no longer there to answer.
        await pumpPanel(
          tester,
          controller,
          selected: attacker,
          width: width,
          panelKey: ValueKey('panel-$width'),
        );

        await enter(tester);
        await act(tester, controller);

        expect(
          tester.takeException(),
          isNull,
          reason: 'the entry state, chips, question and differences must all '
              'fit ${width}px',
        );
      }
    });

    testWidgets('the entry state itself fits', (tester) async {
      final controller = makeController();
      addTearDown(controller.dispose);

      await pumpPanel(
        tester,
        controller,
        selected: StudioElementRef.node(graph.systemId),
        width: 286,
      );
      await enter(tester);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('situation-entry')), findsOneWidget);
    });
  });
}

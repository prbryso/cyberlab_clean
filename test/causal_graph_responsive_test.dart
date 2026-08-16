import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/causal_graph_view.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// The causal record has to read in a wide panel and in a narrow sidebar.
///
/// A RenderFlex overflow is reported through FlutterError, which the test
/// binding records. `tester.takeException()` returning null is therefore the
/// assertion that nothing was forced off the edge.
void main() {
  const engine = StudioGraphEngine();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  /// The full chain, including the administrator acting, so every kind of
  /// step and every badge combination is present.
  SimulationCausalGraph fullChain() {
    final run = SimulationRun.start(graph, initialActors: {attacker})
      ..perform(actionById('attacker.attempt_authentication'))
      ..perform(actionById('administrator.lock_account'));

    return SimulationCausalGraph.fromRun(run);
  }

  Future<void> pumpAtWidth(
    WidgetTester tester,
    double width, {
    StudioElementRef? selectedActor,
    SimulationCausalGraph? causalGraph,
  }) async {
    // Tall enough that vertical space never becomes the constraint under test.
    tester.view.physicalSize = Size(width + 200, 4000);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: CausalGraphView(
                  causalGraph: causalGraph ?? fullChain(),
                  selectedActor: selectedActor,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('it fits the width it is given', () {
    testWidgets('at the Simulate panel width', (tester) async {
      await pumpAtWidth(tester, 720);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('causal-graph')), findsOneWidget);
    });

    testWidgets('at a workspace sidebar width', (tester) async {
      await pumpAtWidth(tester, 300);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('causal-graph')), findsOneWidget);
    });

    testWidgets('at the narrowest width the sidebar actually reported', (
      tester,
    ) async {
      // The failures came in at 254 and 286 logical pixels.
      for (final width in [254.0, 286.0]) {
        await pumpAtWidth(tester, width);

        expect(
          tester.takeException(),
          isNull,
          reason: 'nothing may be forced off the edge at ${width}px',
        );
      }
    });
  });

  group('nothing is dropped to make it fit', () {
    testWidgets('the longest label and both badges still all appear', (
      tester,
    ) async {
      // The administrator saw the alert, so this step carries the event name,
      // the "reached them" kind and the "they saw this" mark at once — the
      // widest combination the view currently produces.
      await pumpAtWidth(tester, 300, selectedActor: administrator);

      expect(tester.takeException(), isNull);

      expect(find.text('Security alert raised'), findsWidgets);
      expect(find.text('reached them'), findsWidgets);
      expect(find.text('they saw this'), findsOneWidget);
    });

    testWidgets('the notification channel is still named at narrow width', (
      tester,
    ) async {
      await pumpAtWidth(tester, 300, selectedActor: administrator);

      expect(tester.takeException(), isNull);

      expect(
        find.textContaining('monitoring_notifies_administrator'),
        findsOneWidget,
        reason: 'how the administrator came to know it must survive resizing',
      );
    });

    testWidgets('every participant is still named at narrow width', (
      tester,
    ) async {
      await pumpAtWidth(tester, 254);

      expect(tester.takeException(), isNull);

      for (final id in [
        'attacker',
        'login_interface',
        'authentication_engine',
        'security_monitoring',
        'administrator',
        'user_account',
      ]) {
        expect(
          find.byKey(Key('causal-element-$id')),
          findsWidgets,
          reason: '$id must not be squeezed out of the chain',
        );
      }
    });

    testWidgets('state changes are still shown at narrow width', (
      tester,
    ) async {
      await pumpAtWidth(tester, 254);

      expect(tester.takeException(), isNull);

      expect(
        find.textContaining('Quiet → Alerting'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Active → Locked'),
        findsOneWidget,
      );
    });
  });

  group('the badges wrap rather than the row overflowing', () {
    testWidgets('a narrow step is taller than the same step when wide', (
      tester,
    ) async {
      final chain = fullChain();

      await pumpAtWidth(tester, 720, selectedActor: administrator,
          causalGraph: chain);

      final wide = tester.getSize(find.byKey(const Key('causal-graph'))).height;

      await pumpAtWidth(tester, 300, selectedActor: administrator,
          causalGraph: chain);

      final narrow = tester
          .getSize(find.byKey(const Key('causal-graph')))
          .height;

      expect(
        narrow,
        greaterThan(wide),
        reason: 'content that no longer fits across should stack downwards, '
            'which is the whole point of wrapping instead of clipping',
      );
    });
  });
}

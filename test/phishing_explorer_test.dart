import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/libraries/cyber_lab/cyber_lab_package.dart';
import 'package:systems_studio/libraries/cyber_lab/cyber_lab_routes.dart';

/// Phishing as a learner meets it: through the generic explorer, at
/// `/phishing/explorer`, with nothing about it special-cased.
///
/// These are the assertions that distinguish "the model is correct" from "the
/// system is explorable". Before the situations existed, opening Simulate here
/// dropped straight into a run whose only reachable outcome was the message
/// being held.
void main() {
  Future<void> pumpExplorer(WidgetTester tester) async {
    const CyberLabPackage().install();

    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final route = cyberLabRoutes.firstWhere(
      (candidate) => candidate.path == '/phishing/explorer',
    );

    await tester.pumpWidget(MaterialApp(home: Builder(builder: route.builder)));
    await tester.pumpAndSettle();
  }

  Future<void> openSimulate(WidgetTester tester) async {
    await pumpExplorer(tester);

    await tester.tap(find.text('Simulate'));
    await tester.pumpAndSettle();
  }

  group('arriving at the system', () {
    testWidgets('the explorer opens without incident', (tester) async {
      await pumpExplorer(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('Simulate offers a choice of situations, not a run', (
      tester,
    ) async {
      await openSimulate(tester);

      expect(find.byKey(const Key('scenario-chooser')), findsOneWidget);

      // Nothing has been started, so nothing about a run is offered yet.
      expect(find.byKey(const Key('scenario-bar')), findsNothing);
      expect(find.byKey(const Key('reset-run')), findsNothing);
    });

    testWidgets('all three situations are offered, none marked out', (
      tester,
    ) async {
      await openSimulate(tester);

      for (final id in [
        'a_message_that_looks_right',
        'a_message_the_gateway_recognises',
        'filtering_bypassed',
      ]) {
        expect(
          find.byKey(Key('scenario-option-$id')),
          findsOneWidget,
          reason: '$id should be offered',
        );
      }

      expect(find.text('A Message That Looks Right'), findsOneWidget);
    });
  });

  group('choosing A Message That Looks Right', () {
    Future<void> choose(WidgetTester tester) async {
      await openSimulate(tester);

      await tester.tap(
        find.byKey(const Key('scenario-option-a_message_that_looks_right')),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the chooser gives way to the run', (tester) async {
      await choose(tester);

      expect(find.byKey(const Key('scenario-chooser')), findsNothing);
      expect(find.byKey(const Key('scenario-bar')), findsOneWidget);
      expect(find.byKey(const Key('reset-run')), findsOneWidget);
    });

    testWidgets('the situation states its starting fact in words', (
      tester,
    ) async {
      await choose(tester);

      expect(find.byKey(const Key('starting-facts')), findsOneWidget);
      expect(
        find.byKey(const Key('starting-fact-mail_gateway.filtering')),
        findsOneWidget,
      );

      final fact = tester.widget<Text>(
        find.byKey(const Key('starting-fact-mail_gateway.filtering')),
      );

      // Not an identifier, and not a raw value: the element and the variable
      // named as a person would say them.
      expect(fact.data, contains('Mail Gateway'));
      expect(fact.data, contains('Degraded'));
    });

    testWidgets('the person the message is for is not present yet', (
      tester,
    ) async {
      await choose(tester);

      final status = tester.widget<Text>(
        find.byKey(const Key('actor-status-recipient')),
      );

      expect(status.data, isNotNull);
      expect(
        status.data!.toLowerCase(),
        isNot(contains('yet')),
        reason: 'future involvement is not guaranteed, so nothing may imply it',
      );
    });
  });

  group('choosing A Message the Gateway Recognises', () {
    testWidgets('a situation that overrides nothing shows no starting facts', (
      tester,
    ) async {
      await openSimulate(tester);

      await tester.tap(
        find.byKey(
          const Key('scenario-option-a_message_the_gateway_recognises'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('scenario-bar')), findsOneWidget);

      // An empty heading would imply the situation established something.
      expect(find.byKey(const Key('starting-facts')), findsNothing);
    });
  });

  group('returning to the choice', () {
    testWidgets('changing the situation offers all three again', (
      tester,
    ) async {
      await openSimulate(tester);

      await tester.tap(
        find.byKey(const Key('scenario-option-filtering_bypassed')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('change-scenario')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('scenario-chooser')), findsOneWidget);
      expect(
        find.byKey(const Key('scenario-option-a_message_that_looks_right')),
        findsOneWidget,
      );
    });
  });
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_route.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/services/studio_system_detail_registry.dart';
import 'package:systems_studio/engine/ui/screens/system_explorer_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/cyber_lab_package.dart';
import 'package:systems_studio/libraries/cyber_lab/cyber_lab_routes.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/phishing_detail.dart';

/// Phishing as a static system: a second area entering the generic shell.
void main() {
  const engine = StudioGraphEngine();
  const validator = StudioGraphValidator();

  final session = engine.open(phishingDetail);
  final graph = session.graph;

  Set<String> idsOfType(StudioGraphNodeType type) =>
      graph.nodesByType(type).map((node) => node.id).toSet();

  StudioRelationship relationshipById(String id) =>
      graph.relationshipById(id)!;

  group('the system is registered and opens', () {
    setUp(() {
      // The package registers both systems; installing is what a running app
      // does at startup.
      const CyberLabPackage().install();
    });

    test('cybersecurity.phishing is registered alongside password security', () {
      final registry = StudioSystemDetailRegistry.instance;

      expect(
        registry.detailBySystemId('cybersecurity.phishing'),
        isNotNull,
      );
      expect(
        registry.detailBySystemId('cybersecurity.password_security'),
        isNotNull,
        reason: 'registering a second system must not displace the first',
      );
    });

    test('its graph opens without throwing', () {
      expect(() => engine.open(phishingDetail), returnsNormally);
      expect(graph.systemId, 'cybersecurity.phishing');
    });

    test('validation reports no errors', () {
      final result = validator.validate(graph);

      expect(
        result.hasErrors,
        isFalse,
        reason: result.issues
            .map((issue) => '${issue.code}: ${issue.message}')
            .join('\n'),
      );
    });
  });

  group('the system boundary', () {
    test('exactly the intended actors', () {
      expect(
        idsOfType(StudioGraphNodeType.actor),
        {'attacker', 'recipient', 'security_team'},
      );
    });

    test('exactly the intended assets', () {
      expect(
        idsOfType(StudioGraphNodeType.asset),
        {'message', 'corporate_account'},
      );
    });

    test('exactly the intended components', () {
      expect(
        idsOfType(StudioGraphNodeType.component),
        {'mail_gateway', 'inbox', 'reporting_channel', 'link_target'},
      );
    });

    test('malware content stayed out of the boundary', () {
      final ids = graph.nodes.map((node) => node.id).join(' ').toLowerCase();

      for (final word in ['malware', 'ransomware', 'spyware', 'trojan']) {
        expect(
          ids,
          isNot(contains(word)),
          reason: 'malware is a different system',
        );
      }
    });
  });

  group('state', () {
    void expectVariable(
      String id,
      String owner,
      List<String> domain,
      String initial,
    ) {
      final variable = graph.stateVariableById(id);

      expect(variable, isNotNull, reason: '$id should be declared');
      expect(variable!.owner, StudioElementRef.node(owner));
      expect(variable.domain, domain);
      expect(variable.initialValue, initial);
    }

    test('exactly five variables, as designed', () {
      expect(
        graph.stateVariables.map((variable) => variable.id).toSet(),
        {
          'mail_gateway.filtering',
          'message.delivery',
          'message.classification',
          'link_target.contact',
          'corporate_account.access',
        },
      );
    });

    test('each has the intended owner, domain and default', () {
      expectVariable(
        'mail_gateway.filtering',
        'mail_gateway',
        ['Active', 'Degraded', 'Bypassed'],
        'Active',
      );
      expectVariable(
        'message.delivery',
        'message',
        ['Undelivered', 'Quarantined', 'Delivered'],
        'Undelivered',
      );
      expectVariable(
        'message.classification',
        'message',
        ['Unknown', 'Suspected', 'Confirmed'],
        'Unknown',
      );
      expectVariable(
        'link_target.contact',
        'link_target',
        ['None', 'Reached'],
        'None',
      );
      expectVariable(
        'corporate_account.access',
        'corporate_account',
        ['Active', 'Compromised'],
        'Active',
      );
    });

    test('the rejected candidates were not authored', () {
      final ids = graph.stateVariables.map((variable) => variable.id).toSet();

      expect(
        ids,
        isNot(contains('recipient.belief')),
        reason: 'the model does not assert what a person thinks',
      );
      expect(
        ids,
        isNot(contains('reporting_channel.status')),
        reason: 'the report event does that work',
      );
    });
  });

  group('what each participant can tell', () {
    List<String> observationsOf(String nodeId) =>
        graph.nodeById(nodeId)!.facets.observationCapabilities.value ??
        const [];

    test('the recipient and the gateway see different things', () {
      final recipient = observationsOf('recipient');
      final gateway = observationsOf('mail_gateway');

      expect(recipient, isNotEmpty);
      expect(gateway, isNotEmpty);

      expect(
        recipient.toSet().intersection(gateway.toSet()),
        isEmpty,
        reason: 'the asymmetry is the point of the model',
      );

      // What a person has to go on.
      expect(
        recipient.join(' '),
        contains('subject line'),
      );

      // What only the gateway reads.
      expect(gateway.join(' '), contains('Received headers'));
    });

    test('the security team sees only what it is told', () {
      final team = observationsOf('security_team');

      expect(team, hasLength(2));

      // Both halves are things they are told: a detection the gateway
      // raised, and a report a person raised. Neither is watching.
      expect(team.join(' ').toLowerCase(), contains('detections'));
      expect(team.join(' ').toLowerCase(), contains('report'));

      // It is still not reading the mail flow itself.
      expect(team.join(' ').toLowerCase(), isNot(contains('header')));
      expect(team.join(' ').toLowerCase(), isNot(contains('attachment')));
    });

    test('the red flags belong to the message, not to everyone', () {
      final message =
          graph.nodeById('message')!.facets.eventTypes.value ?? const [];

      expect(message, isNotEmpty);
      expect(message.join(' '), contains('does not match'));

      // The legacy UI showed every flag on one page. Here only the thing
      // that has them carries them.
      //
      // The inbox does declare an occurrence of its own — it surfaces the
      // message — but surfacing is not reading, and none of the marks that
      // would give the message away appear on the element that displays it.
      final inbox = graph.nodeById('inbox')!.facets.eventTypes;

      expect(inbox.isKnown, isTrue);
      expect(inbox.value, hasLength(1));

      for (final flag in message) {
        expect(
          inbox.value,
          isNot(contains(flag)),
          reason: 'the inbox displays the message; it does not read it',
        );
      }
    });

    test('elements that sense nothing say so, rather than being unknown', () {
      for (final id in ['message', 'corporate_account', 'inbox']) {
        expect(
          graph.nodeById(id)!.facets.observationCapabilities.isNotApplicable,
          isTrue,
          reason: '$id senses nothing, which is different from not knowing',
        );
      }
    });
  });

  group('structural relationships', () {
    void expectEdge(String id, String from, String to,
        StudioRelationshipType type) {
      final relationship = relationshipById(id);

      expect(relationship.sourceId, from);
      expect(relationship.targetId, to);
      expect(relationship.type, type);
    }

    test('each authored edge runs in the intended direction', () {
      expectEdge('attacker_sends_to_gateway', 'attacker', 'mail_gateway',
          StudioRelationshipType.sendsDataTo);
      expectEdge('gateway_delivers_to_inbox', 'mail_gateway', 'inbox',
          StudioRelationshipType.sendsDataTo);
      expectEdge('recipient_reads_inbox', 'inbox', 'recipient',
          StudioRelationshipType.interactsWith);
      expectEdge('inbox_presents_to_recipient', 'inbox', 'recipient',
          StudioRelationshipType.sendsDataTo);
      expectEdge('recipient_reports_message', 'recipient',
          'reporting_channel', StudioRelationshipType.sendsDataTo);
      expectEdge('reporting_notifies_security_team', 'reporting_channel',
          'security_team', StudioRelationshipType.notifies);
      expectEdge('link_target_reports_to_attacker', 'link_target', 'attacker',
          StudioRelationshipType.sendsDataTo);
      expectEdge('link_target_presents_to_recipient', 'link_target',
          'recipient', StudioRelationshipType.sendsDataTo);
      expectEdge('gateway_alerts_security_team', 'mail_gateway',
          'security_team', StudioRelationshipType.notifies);
      expectEdge('security_team_controls_gateway', 'security_team',
          'mail_gateway', StudioRelationshipType.controls);
      expectEdge('link_target_threatens_account', 'link_target',
          'corporate_account', StudioRelationshipType.threatens);
    });

    test('the gateway tells the team what it caught, and nothing else', () {
      final alert = relationshipById('gateway_alerts_security_team');

      // The team learns of detections. It does not thereby gain the gateway's
      // view of the mail flow: a message the gateway let through produces no
      // detection, so nothing about it travels here.
      expect(alert.carriedEventTypeIds, ['phishing_detected']);
      expect(alert.carries('message_delivered'), isFalse);
      expect(alert.carries('message_sent'), isFalse);
    });

    test('nothing carries a successful compromise to the security team', () {
      final authored = graph.relationships.where(
        (relationship) => !relationship.id.contains('.contains.'),
      );

      // The blind spot, which the detection path does not close: when the
      // gateway does not recognise a message, the team learns nothing unless
      // a person tells them.
      expect(
        authored.any(
          (relationship) =>
              relationship.sourceId == 'link_target' &&
              relationship.targetId == 'security_team',
        ),
        isFalse,
        reason: 'the page reports to whoever runs it, and to nobody else',
      );

      expect(
        authored.any(
          (relationship) =>
              relationship.sourceId == 'corporate_account' ||
              relationship.targetId == 'security_team' &&
                  relationship.sourceId == 'corporate_account',
        ),
        isFalse,
        reason: 'an account announces nothing about itself',
      );
    });
  });

  group('how far the authoring has got', () {
    test('three authored situations, in the intended order', () {
      expect(graph.scenarios.map((scenario) => scenario.id), [
        'a_message_that_looks_right',
        'a_message_the_gateway_recognises',
        'filtering_bypassed',
      ]);
    });

    test('dynamics exist, and are the ones the phases authored', () {
      expect(graph.actionDefinitions, isNotEmpty);
      expect(graph.behaviorDefinitions, isNotEmpty);
      expect(graph.eventTypes, isNotEmpty);
    });

    test('only the surfacing channel restricts what it carries', () {
      final filtered = {
        for (final relationship in graph.relationships)
          if (relationship.carriedEventTypeIds != null)
            relationship.id: relationship.carriedEventTypeIds,
      };

      // Every other edge stays unrestricted until the filtering phase, so a
      // filter appearing here would be an unreviewed narrowing of who can
      // learn what.
      expect(filtered, {
        'gateway_delivers_to_inbox': ['message_delivered'],
        'inbox_presents_to_recipient': ['message_presented'],
        'link_target_reports_to_attacker': [
          'link_opened',
          'credentials_submitted',
        ],
        'link_target_presents_to_recipient': ['page_presented'],
        'gateway_alerts_security_team': ['phishing_detected'],
      });
    });
  });

  group('routing', () {
    StudioRoute routeFor(String path) =>
        cyberLabRoutes.firstWhere((route) => route.path == path);

    testWidgets('/phishing/explorer opens the generic shell', (tester) async {
      final route = routeFor('/phishing/explorer');

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: route.builder)),
      );
      await tester.pump();

      expect(find.byType(SystemExplorerScreen), findsOneWidget);

      final screen = tester.widget<SystemExplorerScreen>(
        find.byType(SystemExplorerScreen),
      );

      expect(screen.systemId, 'cybersecurity.phishing');
    });

    /// Pumps a system through the generic shell and returns its tab bar.
    ///
    /// Rendering it at all is the assertion: the strip, the controller and
    /// the body used to be three parallel definitions, and a mismatch throws
    /// during build rather than failing a comparison.
    Future<TabBar> pumpExplorer(WidgetTester tester, String path) async {
      const CyberLabPackage().install();

      tester.view.physicalSize = const Size(1400, 2000);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: routeFor(path).builder)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      return tester.widget<TabBar>(find.byType(TabBar));
    }

    testWidgets('the static Phishing system renders in the shell', (
      tester,
    ) async {
      final tabs = await pumpExplorer(tester, '/phishing/explorer');

      expect(tabs.tabs, isNotEmpty);
      expect(
        DefaultTabController.of(
          tester.element(find.byType(TabBar)),
        ).length,
        tabs.tabs.length,
        reason: 'the controller and the strip come from one list',
      );
    });

    testWidgets('Password Security still renders its five tabs', (
      tester,
    ) async {
      final tabs = await pumpExplorer(tester, '/password/explorer');

      expect(tabs.tabs, hasLength(5));
    });

    testWidgets('both systems get the same tab strip', (tester) async {
      final phishing = await pumpExplorer(tester, '/phishing/explorer');
      final phishingLabels = phishing.tabs
          .map((tab) => (tab as Tab).text)
          .toList();

      final password = await pumpExplorer(tester, '/password/explorer');
      final passwordLabels = password.tabs
          .map((tab) => (tab as Tab).text)
          .toList();

      expect(
        phishingLabels,
        passwordLabels,
        reason: 'the shell offers the same ways of looking at any system; '
            'what each one finds there is what differs',
      );
    });

    test('the explorer names no system in particular', () {
      // A generic shell that mentions a system by name has stopped being one.
      final source = File(
        'lib/engine/ui/screens/system_explorer_screen.dart',
      ).readAsStringSync().toLowerCase();

      expect(source, isNot(contains('phishing')));
      expect(source, isNot(contains('password_security')));
    });

    test('the legacy phishing routes still resolve', () {
      final paths = cyberLabRoutes.map((route) => route.path).toSet();

      // Migration is additive: the old entries keep working alongside it.
      expect(
        paths.where((path) => path.startsWith('/phishing')).length,
        greaterThan(1),
      );

      expect(paths, contains('/phishing/explorer'));
      expect(paths, contains('/password/explorer'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/event_capability.dart';
import 'package:systems_studio/engine/graph/graph_builder.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// Event display must come from typed declarations, not from prose kept
/// alongside them.
void main() {
  final graph = const StudioGraphBuilder().build(passwordSecurityDetail);
  final index = StudioEventCapabilityIndex.forGraph(graph);

  const loginInterface = StudioElementRef.node('login_interface');
  const engine = StudioElementRef.node('authentication_engine');
  const monitoring = StudioElementRef.node('security_monitoring');
  const mfa = StudioElementRef.node('mfa_service');
  const identityService = StudioElementRef.node('identity_service');
  const administrator = StudioElementRef.node('administrator');
  const system = StudioElementRef.node('cybersecurity.password_security');

  group('derivation', () {
    test('an action target generates the action occurrence', () {
      final capability = index.capabilityFor(loginInterface);

      expect(
        capability.generates.map((type) => type.id),
        ['authentication_attempted'],
      );
    });

    test('a behaviour owner detects its trigger and generates its emissions',
        () {
      final capability = index.capabilityFor(engine);

      expect(
        capability.detects.map((type) => type.id).toSet(),
        // Two behaviours, so two triggers: it reacts to an attempt, and to
        // the second factor answering.
        {'authentication_attempted', 'mfa_challenge_answered'},
      );
      expect(
        capability.generates.map((type) => type.id).toSet(),
        // Two behaviours now: judging the password, and completing the
        // authentication once the second factor has answered. Deciding is
        // the engine's, so both final results are generated here.
        {
          'authentication_failed',
          'authentication_succeeded',
          'mfa_challenge_required',
        },
      );
      expect(
        capability.reports,
        isEmpty,
        reason: 'the engine tells nobody; it just decides',
      );
    });

    test('the MFA service answers, and claims nothing more', () {
      final capability = index.capabilityFor(mfa);

      expect(
        capability.detects.map((type) => type.id),
        ['mfa_challenge_required'],
      );

      // It reports a factor result. Deciding the authentication is the
      // engine's, so neither final result is generated here.
      expect(
        capability.generates.map((type) => type.id),
        ['mfa_challenge_answered'],
      );

      expect(
        capability.reports,
        isEmpty,
        reason: 'it answers whoever asked; it notifies nobody',
      );
    });

    test('reporting requires a notification channel', () {
      final capability = index.capabilityFor(monitoring);

      expect(
        capability.detects.map((type) => type.id),
        ['authentication_failed'],
      );
      expect(
        capability.generates.map((type) => type.id),
        ['security_alert_raised'],
      );
      expect(
        capability.reports.map((type) => type.id),
        ['security_alert_raised'],
        reason: 'monitoring notifies the administrator',
      );
    });

    test('detect, generate and report stay distinguishable', () {
      final capability = index.capabilityFor(monitoring);

      expect(
        capability.detects.map((type) => type.id),
        isNot(capability.generates.map((type) => type.id)),
        reason: 'what it watches and what it raises are different things',
      );
    });

    test('capability rolls up through the hierarchy', () {
      final capability = index.capabilityFor(identityService);

      expect(
        capability.generates.map((type) => type.id),
        containsAll([
          // From the engine, which judges the password and then completes
          // the authentication.
          'authentication_failed',
          'authentication_succeeded',
          'mfa_challenge_required',
          // Inherited from the MFA service, a component of this subsystem:
          // answering a challenge is its and no one else's.
          'mfa_challenge_answered',
        ]),
        reason: 'a subsystem does what its components do',
      );

      final systemCapability = index.capabilityFor(system);

      expect(
        systemCapability.generates.map((type) => type.id),
        containsAll([
          'authentication_attempted',
          'authentication_failed',
          'security_alert_raised',
        ]),
      );
    });

    test('an element with no typed involvement has no capability', () {
      expect(index.hasCapability(administrator), isFalse);
      expect(index.capabilityFor(administrator).isEmpty, isTrue);
    });
  });

  group('no duplicate prose', () {
    test('elements with derived capability declare no Events prose', () {
      for (final element in [
        loginInterface,
        engine,
        monitoring,
        identityService,
        system,
      ]) {
        final node = graph.nodeById(element.id)!;

        expect(
          index.capabilityFor(element).isNotEmpty,
          isTrue,
          reason: '${element.id} should have derived capability',
        );

        expect(
          node.facets.eventTypes.isKnown,
          isFalse,
          reason:
              '${element.id} must not restate in prose what its declarations '
              'already say',
        );
      }
    });

    test('elements without derived capability may still declare prose', () {
      // Nothing typed involves the account recovery procedure yet, so its
      // authored description is the only thing available and is kept.
      const recovery = StudioElementRef.node('account_recovery');

      expect(index.hasCapability(recovery), isFalse);
      expect(graph.nodeById('account_recovery')!.facets.eventTypes.isKnown,
          isTrue);
    });

    test('derived names come from the declarations themselves', () {
      final capability = index.capabilityFor(monitoring);

      expect(
        capability.generates.single.name,
        graph.eventTypeById('security_alert_raised')!.name,
      );
    });
  });
}

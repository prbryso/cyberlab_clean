import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_condition.dart';
import 'package:systems_studio/engine/models/studio_effect.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/phishing_detail.dart';

/// Phishing dynamics: what can be done, what follows automatically, and what
/// deliberately does not follow.
void main() {
  const engine = StudioGraphEngine();
  const validator = StudioGraphValidator();

  const attacker = StudioElementRef.node('attacker');
  const recipient = StudioElementRef.node('recipient');
  const securityTeam = StudioElementRef.node('security_team');

  final session = engine.open(phishingDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  String valueOf(SimulationRun run, String variableId) =>
      run.state.valueOf(graph.stateVariableById(variableId)!);

  Set<String> emittedBy(SimulationRun run) =>
      run.events.map((event) => event.typeId).toSet();

  /// A run with every actor already present.
  ///
  /// Phase 2 needed this because the recipient could not otherwise arrive:
  /// `message_delivered` is emitted by the gateway and reaches the inbox,
  /// which is one hop further from the recipient than observation travels.
  /// The surfacing behaviour added afterwards closes that gap properly, and
  /// `phishing_presentation_test.dart` proves it by seeding only the attacker.
  ///
  /// Seeding stays here so these tests keep saying what they were written to
  /// say — the security team still has no route by which to arrive, and these
  /// are tests about dynamics rather than about who becomes involved.
  SimulationRun runWith({String filtering = 'Active'}) {
    return SimulationRun.start(
      graph,
      scenario: StudioScenario(
        id: 'test.dynamics',
        name: 'Dynamics under test',
        initialActors: {attacker, recipient, securityTeam},
        initialStateOverrides: {'mail_gateway.filtering': filtering},
      ),
    );
  }

  group('the authored dynamics', () {
    test('exactly nine event types', () {
      expect(
        graph.eventTypes.map((type) => type.id).toSet(),
        {
          'message_sent',
          'message_delivered',
          'message_presented',
          'phishing_detected',
          'link_opened',
          'page_presented',
          'credentials_submitted',
          'message_reported',
          'sender_blocked',
        },
      );
    });

    test('each event is declared by something that produces it', () {
      final declaredBy = {
        for (final type in graph.eventTypes) type.id: type.declaredBy?.id,
      };

      expect(declaredBy, {
        'message_sent': 'attacker',
        'message_delivered': 'mail_gateway',
        'message_presented': 'inbox',
        'phishing_detected': 'mail_gateway',
        'link_opened': 'recipient',
        'page_presented': 'link_target',
        'credentials_submitted': 'link_target',
        'message_reported': 'recipient',
        'sender_blocked': 'security_team',
      });
    });

    test('exactly five actions, owned as designed', () {
      final owners = {
        for (final action in graph.actionDefinitions)
          action.id: '${action.initiator.id} -> ${action.target.id}',
      };

      expect(owners, {
        'attacker.send_message': 'attacker -> mail_gateway',
        'recipient.open_link': 'recipient -> link_target',
        'recipient.submit_credentials': 'recipient -> link_target',
        'recipient.report_message': 'recipient -> reporting_channel',
        'security_team.block_sender': 'security_team -> mail_gateway',
      });
    });

    test('exactly four automatic behaviours', () {
      final behaviours = {
        for (final behaviour in graph.behaviorDefinitions)
          behaviour.id: '${behaviour.owner.id} on ${behaviour.trigger}',
      };

      expect(behaviours, {
        'mail_gateway.screen_message': 'mail_gateway on message_sent',
        'inbox.present_message': 'inbox on message_delivered',
        'link_target.present_page': 'link_target on link_opened',
        'link_target.harvest': 'link_target on credentials_submitted',
      });
    });

    test('the model still validates', () {
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

  group('sending', () {
    test('the attacker can send, and only before it has been sent', () {
      final run = runWith();

      expect(
        run.availableActionsFor(attacker).map((action) => action.id),
        contains('attacker.send_message'),
      );

      run.perform(actionById('attacker.send_message'));

      expect(
        run.availableActionsFor(attacker).map((action) => action.id),
        isNot(contains('attacker.send_message')),
      );
    });

    test('active filtering holds the message, and announces nothing', () {
      final run = runWith(filtering: 'Active')
        ..perform(actionById('attacker.send_message'));

      expect(valueOf(run, 'message.delivery'), 'Quarantined');
      expect(valueOf(run, 'message.classification'), 'Suspected');

      expect(emittedBy(run), contains('message_sent'));
      expect(
        emittedBy(run),
        isNot(contains('message_delivered')),
        reason: 'a message held back is not an occurrence anyone witnessed',
      );
    });

    test('filtering that cannot judge it lets it through', () {
      for (final filtering in ['Degraded', 'Bypassed']) {
        final run = runWith(filtering: filtering)
          ..perform(actionById('attacker.send_message'));

        expect(valueOf(run, 'message.delivery'), 'Delivered');
        expect(emittedBy(run), contains('message_delivered'));

        // Nothing has judged it either way.
        expect(valueOf(run, 'message.classification'), 'Unknown');
      }
    });

    test('a quarantined message offers the recipient nothing', () {
      final run = runWith(filtering: 'Active')
        ..perform(actionById('attacker.send_message'));

      expect(run.availableActionsFor(recipient), isEmpty);
    });
  });

  group('after delivery, the choice is open', () {
    SimulationRun delivered() =>
        runWith(filtering: 'Degraded')
          ..perform(actionById('attacker.send_message'));

    test('both recipient actions are available at once', () {
      final available = delivered()
          .availableActionsFor(recipient)
          .map((action) => action.id)
          .toSet();

      expect(available, {'recipient.open_link', 'recipient.report_message'});
    });

    test('nothing in the model prefers one over the other', () {
      final open = actionById('recipient.open_link');
      final report = actionById('recipient.report_message');

      // Opening is gated on two facts, and both are about the situation
      // rather than about the person: the message has arrived, and this link
      // has not already been followed. Read exactly, so that a third
      // condition appearing here has to be a deliberate act.
      expect(open.precondition, isA<StudioAllOf>());

      final openGates = (open.precondition! as StudioAllOf).conditions;

      expect(openGates, hasLength(2));
      expect(openGates.every((gate) => gate is StudioStateEquals), isTrue);

      expect(
        openGates
            .cast<StudioStateEquals>()
            .map((gate) => '${gate.variableId}=${gate.value}')
            .toList(),
        ['message.delivery=Delivered', 'link_target.contact=None'],
      );

      // Reporting is gated on the arrival alone. It stays available whatever
      // the person has done since, which is what stops the model treating
      // having followed the link as a point of no return.
      expect(report.precondition, isA<StudioStateEquals>());
      expect(
        (report.precondition! as StudioStateEquals).variableId,
        'message.delivery',
      );
      expect((report.precondition! as StudioStateEquals).value, 'Delivered');

      // The extra condition on opening is not a preference. It removes an
      // action that has already been taken; it does not rank the two.
      final available = delivered()
          .availableActionsFor(recipient)
          .map((action) => action.id)
          .toSet();

      expect(available, {'recipient.open_link', 'recipient.report_message'});

      // And no wording ranks them.
      for (final action in [open, report]) {
        final words =
            '${action.name} ${action.description} '
                    '${action.otherwise.explanation}'
                .toLowerCase();

        for (final loaded in [
          'should',
          'correct',
          'recommend',
          'safer',
          'best',
          'mistake',
          'wrong',
        ]) {
          expect(
            words,
            isNot(contains(loaded)),
            reason: '${action.id} must not grade the learner\'s choice',
          );
        }
      }
    });

    test('no automatic behaviour decides between them', () {
      // Delivery does trigger something — surfacing — but surfacing is not a
      // decision: it changes no state, so it cannot move either action's
      // precondition, and both remain equally available afterwards.
      final onDelivery = graph.behaviorDefinitions
          .where((behaviour) => behaviour.trigger == 'message_delivered')
          .toList();

      expect(onDelivery.map((behaviour) => behaviour.id), [
        'inbox.present_message',
      ]);

      for (final outcome in [
        ...onDelivery.single.outcomes,
        onDelivery.single.otherwise,
      ]) {
        expect(
          outcome.effects,
          isEmpty,
          reason: 'a message arriving still settles nothing',
        );
      }
    });
  });

  group('opening', () {
    SimulationRun opened() =>
        runWith(filtering: 'Degraded')
          ..perform(actionById('attacker.send_message'))
          ..perform(actionById('recipient.open_link'));

    test('the page is reached and shows itself, and nothing is given', () {
      final run = opened();

      expect(valueOf(run, 'link_target.contact'), 'Reached');
      expect(emittedBy(run), contains('link_opened'));
      expect(emittedBy(run), contains('page_presented'));

      // Arriving is not submitting. This is the distinction the whole
      // system turns on, and it used to be collapsed into one step.
      expect(emittedBy(run), isNot(contains('credentials_submitted')));
      expect(
        valueOf(run, 'corporate_account.access'),
        'Active',
        reason: 'following a link hands nothing over',
      );

      // Nobody said anything, so nothing is suspected.
      expect(valueOf(run, 'message.classification'), 'Unknown');
    });

    test('submitting is what compromises the account', () {
      final run = opened()
        ..perform(actionById('recipient.submit_credentials'));

      expect(emittedBy(run), contains('credentials_submitted'));
      expect(valueOf(run, 'corporate_account.access'), 'Compromised');
    });

    test('and cannot be done before arriving at the page', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'));

      expect(valueOf(run, 'link_target.contact'), 'None');
      expect(
        run.availableActionsFor(recipient).map((action) => action.id),
        isNot(contains('recipient.submit_credentials')),
      );
    });

    test('reporting stays available after the page has been seen', () {
      // Arriving at a page is not a commitment. Nothing about having
      // followed the link removes the other thing a person could do.
      expect(
        opened().availableActionsFor(recipient).map((action) => action.id),
        contains('recipient.report_message'),
      );
    });

    test('what is on offer changes as the situation does', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'));

      // Before opening: a link that has not been followed, and the report.
      expect(
        run.availableActionsFor(recipient).map((action) => action.id).toSet(),
        {'recipient.open_link', 'recipient.report_message'},
      );

      run.perform(actionById('recipient.open_link'));

      // After: the decision that follows from being at the page, and still
      // the report. Following the link again is not a thing left to do.
      expect(
        run.availableActionsFor(recipient).map((action) => action.id).toSet(),
        {'recipient.submit_credentials', 'recipient.report_message'},
      );
    });

    test('a link already followed is not offered again', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'))
        ..perform(actionById('recipient.open_link'));

      expect(valueOf(run, 'link_target.contact'), 'Reached');
      expect(
        run.availableActionsFor(recipient).map((action) => action.id),
        isNot(contains('recipient.open_link')),
      );
    });
  });

  group('reporting', () {
    test('it makes the message suspected without touching the account', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'))
        ..perform(actionById('recipient.report_message'));

      expect(valueOf(run, 'message.classification'), 'Suspected');
      expect(
        valueOf(run, 'corporate_account.access'),
        'Active',
        reason: 'reporting is not opening',
      );

      expect(emittedBy(run), contains('message_reported'));
      expect(emittedBy(run), isNot(contains('credentials_submitted')));
    });
  });

  group('blocking', () {
    test('it needs something to have been suspected first', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'));

      expect(
        run.availableActionsFor(securityTeam),
        isEmpty,
        reason: 'nothing has been reported, so there is nothing to block',
      );

      run.perform(actionById('recipient.report_message'));

      expect(
        run.availableActionsFor(securityTeam).map((action) => action.id),
        contains('security_team.block_sender'),
      );
    });

    test('it restores filtering, and says so', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'))
        ..perform(actionById('recipient.report_message'))
        ..perform(actionById('security_team.block_sender'));

      expect(valueOf(run, 'mail_gateway.filtering'), 'Active');
      expect(emittedBy(run), contains('sender_blocked'));

      // It changes what happens next time, not what already happened.
      expect(valueOf(run, 'message.delivery'), 'Delivered');
    });
  });

  group('what the model refuses to say', () {
    test('no outcome assigns a state nobody declared', () {
      final assigned = <String>{};

      for (final action in graph.actionDefinitions) {
        for (final outcome in [...action.outcomes, action.otherwise]) {
          for (final effect in outcome.effects) {
            if (effect is StudioAssignState) {
              assigned.add(effect.variableId);
            }
          }
        }
      }

      for (final behaviour in graph.behaviorDefinitions) {
        for (final outcome in [...behaviour.outcomes, behaviour.otherwise]) {
          for (final effect in outcome.effects) {
            if (effect is StudioAssignState) {
              assigned.add(effect.variableId);
            }
          }
        }
      }

      final declared =
          graph.stateVariables.map((variable) => variable.id).toSet();

      expect(assigned.difference(declared), isEmpty);

      // In particular, nothing writes a belief.
      expect(
        assigned.where((id) => id.contains('belief')),
        isEmpty,
        reason: 'the model does not decide what a person thinks',
      );
    });
  });

  group('authored wording sits on the right outcome', () {
    test('the gateway explains holding and delivering differently', () {
      final screening = graph.behaviorDefinitions.firstWhere(
        (behaviour) => behaviour.id == 'mail_gateway.screen_message',
      );

      final held = screening.outcomes.single;

      expect(held.explanation, contains('held the message before anyone saw'));
      expect(
        held.guidingQuestion,
        contains('had the gateway not recognised it'),
        reason: 'the team is told now, so the open question is the other one',
      );

      expect(
        screening.otherwise.explanation,
        contains('arrived looking like any other'),
      );
      expect(
        screening.otherwise.guidingQuestion,
        contains('What can they actually see about it?'),
      );
    });

    test('the page explains itself, and asks who found out', () {
      final harvest = graph.behaviorDefinitions.firstWhere(
        (behaviour) => behaviour.id == 'link_target.harvest',
      );

      expect(harvest.outcomes, isEmpty, reason: 'the page judges nobody');
      expect(
        harvest.otherwise.explanation,
        contains('kept what it was given'),
      );
      expect(harvest.otherwise.guidingQuestion, 'Who found out that this happened?');
    });

    test('showing the page and keeping what it is given read differently', () {
      final showing = graph.behaviorDefinitions.firstWhere(
        (behaviour) => behaviour.id == 'link_target.present_page',
      );

      // Arriving settles nothing, and the wording must not imply otherwise.
      expect(showing.otherwise.effects, isEmpty);
      expect(
        showing.otherwise.explanation,
        contains('Nothing has been given to it'),
      );
      expect(showing.otherwise.guidingQuestion, isNotEmpty);

      for (final verdict in ['too late', 'mistake', 'should have', 'safe']) {
        expect(
          showing.otherwise.explanation.toLowerCase(),
          isNot(contains(verdict)),
        );
      }
    });
  });

  group('who observes what, exactly', () {
    // The full matrix, recorded rather than assumed, so that any later change
    // to a relationship or a filter is visible instead of silent.
    Set<String> observersOf(SimulationRun run, String typeId) {
      return run.observations
          .where((observation) => observation.event.typeId == typeId)
          .map((observation) => observation.observer.id)
          .toSet();
    }

    test('the attacker learns the attempt worked', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'))
        ..perform(actionById('recipient.open_link'))
        ..perform(actionById('recipient.submit_credentials'));

      // Two separate pieces of news: somebody arrived, and somebody gave the
      // page something. Whoever runs a page can tell both apart.
      expect(observersOf(run, 'link_opened'), contains('attacker'));
      expect(
        observersOf(run, 'credentials_submitted'),
        contains('attacker'),
      );

      // The page displaying itself is not separately reported: it would tell
      // the attacker nothing the arrival did not.
      expect(
        observersOf(run, 'page_presented'),
        isNot(contains('attacker')),
      );

      expect(
        observersOf(run, 'credentials_submitted'),
        isNot(contains('security_team')),
        reason: 'nothing carries that fact to anyone defending the account',
      );
    });

    test('a report reaches the security team', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'))
        ..perform(actionById('recipient.report_message'));

      expect(observersOf(run, 'message_reported'), contains('security_team'));
    });

    test('delivery reaches the inbox but not the person reading it', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'));

      final observers = observersOf(run, 'message_delivered');

      expect(observers, contains('inbox'));
      expect(
        observers,
        isNot(contains('recipient')),
        reason: 'the gateway announces delivery to the inbox, and an element '
            'is not a wire: the recipient is one hop further away than '
            'observation travels',
      );
    });

    test('the inbox is not party to the screening', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'));

      expect(observersOf(run, 'message_sent'), {'attacker', 'mail_gateway'});
      expect(
        observersOf(run, 'message_sent'),
        isNot(contains('inbox')),
        reason: 'a message arriving to be screened is not a handover. The '
            'gateway has not decided anything yet',
      );
    });

    test('and is not told how the gateway is configured', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'))
        ..perform(actionById('recipient.report_message'))
        ..perform(actionById('security_team.block_sender'));

      expect(observersOf(run, 'sender_blocked'), {
        'security_team',
        'mail_gateway',
      });
      expect(
        observersOf(run, 'sender_blocked'),
        isNot(contains('inbox')),
        reason: 'the delivery channel carries deliveries, not configuration',
      );
    });

    test('the delivery channel says what it carries', () {
      final channel = graph.relationshipById('gateway_delivers_to_inbox')!;

      expect(channel.carriedEventTypeIds, ['message_delivered']);
    });

    test('the person at the page sees it, and only it', () {
      final run = runWith(filtering: 'Degraded')
        ..perform(actionById('attacker.send_message'))
        ..perform(actionById('recipient.open_link'));

      final seen = run
          .observationsFor(recipient)
          .map((observation) => observation.event.typeId)
          .toSet();

      expect(seen, contains('page_presented'));

      // The page's own view of the mail system is not theirs to inherit.
      expect(seen, isNot(contains('message_delivered')));
      expect(seen, isNot(contains('message_sent')));
    });

    test('the gateway tells the team what it caught, and only that', () {
      final run = runWith(filtering: 'Active')
        ..perform(actionById('attacker.send_message'));

      expect(observersOf(run, 'phishing_detected'), {
        'mail_gateway',
        'security_team',
      });

      // The inbox is on the other channel, which carries deliveries only.
      expect(
        observersOf(run, 'phishing_detected'),
        isNot(contains('inbox')),
      );
    });

    test('a compromise still reaches nobody who could act on it', () {
      // Deliberately not runWith: that helper seeds every actor, which would
      // make the security team present regardless of what reached them, and
      // the claim under test is precisely that nothing does. The recipient is
      // not seeded either — surfacing brings them in.
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'test.blind_spot',
          name: 'Blind spot under test',
          initialActors: {attacker},
          initialStateOverrides: {'mail_gateway.filtering': 'Degraded'},
        ),
      )
        ..perform(actionById('attacker.send_message'))
        ..perform(actionById('recipient.open_link'))
        ..perform(actionById('recipient.submit_credentials'));

      // The detection path does not close the blind spot. When the gateway
      // did not recognise the message, there was nothing to detect.
      expect(emittedBy(run), isNot(contains('phishing_detected')));
      // The recipient does observe it — they submitted. Participating in
      // something is not the same as anyone being in a position to respond
      // to it, and the defenders are the ones who would be.
      expect(observersOf(run, 'credentials_submitted'), {
        'recipient',
        'link_target',
        'attacker',
      });
      expect(run.isRelevant(securityTeam), isFalse);

      // The one route that could still bring them in is a person choosing to
      // use it. Nothing does it for them.
      expect(
        run.availableActionsFor(recipient).map((action) => action.id),
        contains('recipient.report_message'),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_situation_snapshot.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/phishing_detail.dart';

/// The Phishing situations, and what a run through each of them shows.
///
/// Before these existed the system had exactly one reachable path. Filtering
/// starts Active, so screening quarantined the message and emitted nothing,
/// and the entire lower half of the architecture — inbox, recipient, the
/// choice, both consequences, the security team — could not be reached at all.
///
/// These situations are what make the system explorable. They establish
/// starting facts and nothing else: no situation performs an action, prefers a
/// branch, or says what should happen next.
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

  StudioScenario scenarioById(String id) =>
      graph.scenarios.firstWhere((scenario) => scenario.id == id);

  SimulationRun runOf(String scenarioId) =>
      SimulationRun.start(graph, scenario: scenarioById(scenarioId));

  String valueOf(SimulationRun run, String variableId) =>
      run.state.valueOf(graph.stateVariableById(variableId)!);

  Set<String> emittedBy(SimulationRun run) =>
      run.events.map((event) => event.typeId).toSet();

  Set<String> observersOf(SimulationRun run, String typeId) => run.observations
      .where((observation) => observation.event.typeId == typeId)
      .map((observation) => observation.observer.id)
      .toSet();

  Set<String> actionsFor(SimulationRun run, StudioElementRef actor) =>
      run.availableActionsFor(actor).map((action) => action.id).toSet();

  group('the situations themselves', () {
    test('the model validates with all three authored', () {
      final result = validator.validate(graph);

      expect(
        result.hasErrors,
        isFalse,
        reason: result.issues
            .map((issue) => '${issue.code}: ${issue.message}')
            .join('\n'),
      );
    });

    test('each establishes only starting facts', () {
      for (final scenario in graph.scenarios) {
        // Everything a situation may say is a fact about where things stand.
        for (final entry in scenario.initialStateOverrides.entries) {
          final variable = graph.stateVariableById(entry.key);

          expect(variable, isNotNull, reason: '${entry.key} is not declared');
          expect(variable!.domain, contains(entry.value));
        }

        for (final actor in scenario.initialActors) {
          expect(graph.nodeById(actor.id), isNotNull);
        }
      }
    });

    test('only the attacker is ever present at the start', () {
      for (final scenario in graph.scenarios) {
        expect(
          scenario.initialActors,
          {attacker},
          reason: 'everyone else has to arrive by being reached, which is the '
              'thing worth showing',
        );
      }
    });

    test('the descriptions say where things stand, not what follows', () {
      for (final scenario in graph.scenarios) {
        final description = scenario.description.toLowerCase();

        expect(description, isNotEmpty);

        for (final word in [
          'you should',
          'will then',
          'correct',
          'mistake',
          'safe',
          'dangerous',
          'learn how',
          'next you',
        ]) {
          expect(
            description,
            isNot(contains(word)),
            reason: '"${scenario.id}" describes a situation, not a lesson',
          );
        }
      }
    });

    test('the recognised situation deliberately overrides nothing', () {
      // The declared defaults already describe a gateway filtering normally.
      // Restating them would duplicate the system's own declarations.
      expect(
        scenarioById('a_message_the_gateway_recognises').initialStateOverrides,
        isEmpty,
      );
    });

    test('two situations differ in exactly one fact', () {
      final looksRight =
          scenarioById('a_message_that_looks_right').initialStateOverrides;
      final bypassed =
          scenarioById('filtering_bypassed').initialStateOverrides;

      expect(looksRight.keys, bypassed.keys);
      expect(looksRight['mail_gateway.filtering'], 'Degraded');
      expect(bypassed['mail_gateway.filtering'], 'Bypassed');
    });
  });

  group('A Message That Looks Right — the whole arc', () {
    SimulationRun delivered() =>
        runOf('a_message_that_looks_right')
          ..perform(actionById('attacker.send_message'));

    test('one action reaches the person the message was written for', () {
      final run = delivered();

      expect(run.events.map((event) => event.typeId), [
        'message_sent',
        'message_delivered',
        'message_presented',
      ]);

      expect(valueOf(run, 'message.delivery'), 'Delivered');
      expect(
        run.isRelevant(recipient),
        isTrue,
        reason: 'the recipient arrives because something reached them',
      );
    });

    test('the causal record runs gateway, inbox, person', () {
      final causal = SimulationCausalGraph.fromRun(delivered());
      final order = causal.nodes.map((node) => node.element.id).toList();

      expect(order, containsAllInOrder(['mail_gateway', 'inbox', 'recipient']));
    });

    test('every step of that record explains itself', () {
      final causal = SimulationCausalGraph.fromRun(delivered());

      final explained = causal.links.where(
        (link) => (link.explanation ?? '').isNotEmpty,
      );

      expect(explained, isNotEmpty);

      // The surfacing step is the one that says a person is now looking at
      // this, and it carries the question worth sitting with.
      final surfacing = causal.links.firstWhere(
        (link) => link.eventTypeId == 'message_presented',
      );

      expect(surfacing.observers, contains(recipient));
    });

    test('both choices arrive together, and neither is marked', () {
      final run = delivered();

      expect(actionsFor(run, recipient), {
        'recipient.open_link',
        'recipient.report_message',
      });

      for (final id in ['recipient.open_link', 'recipient.report_message']) {
        final outcome = actionById(id).otherwise;

        expect(outcome.explanation, isNotEmpty);
        expect(
          outcome.guidingQuestion,
          isNotEmpty,
          reason: 'a consequence without a question is just an announcement',
        );

        for (final verdict in [
          'success',
          'failed',
          'correct',
          'should have',
          'safe',
          'danger',
          'unfortunately',
        ]) {
          expect(
            '${outcome.explanation} ${outcome.guidingQuestion}'.toLowerCase(),
            isNot(contains(verdict)),
          );
        }
      }
    });

    group('the branch where the link is opened', () {
      SimulationRun opened() =>
          delivered()..perform(actionById('recipient.open_link'));

      SimulationRun submitted() =>
          opened()..perform(actionById('recipient.submit_credentials'));

      test('following the link hands nothing over', () {
        final run = opened();

        expect(valueOf(run, 'link_target.contact'), 'Reached');
        expect(emittedBy(run), contains('page_presented'));
        expect(
          valueOf(run, 'corporate_account.access'),
          'Active',
          reason: 'arriving at a page is not giving it anything',
        );
      });

      test('a second, separate decision is what compromises the account', () {
        final run = opened();

        expect(
          actionsFor(run, recipient),
          {'recipient.submit_credentials', 'recipient.report_message'},
          reason: 'still two ways to go, and neither is marked',
        );

        run.perform(actionById('recipient.submit_credentials'));

        expect(valueOf(run, 'corporate_account.access'), 'Compromised');
        expect(observersOf(run, 'credentials_submitted'), contains('attacker'));
      });

      test('and nobody defending it finds out — the blind spot', () {
        final run = submitted();

        expect(
          observersOf(run, 'credentials_submitted'),
          isNot(contains('security_team')),
        );
        expect(
          run.isRelevant(securityTeam),
          isFalse,
          reason: 'the gateway did not recognise this message, so there was '
              'no detection to raise, and nobody said anything',
        );
        expect(valueOf(run, 'message.classification'), 'Unknown');
      });
    });

    group('the branch where it is reported', () {
      SimulationRun reported() =>
          delivered()..perform(actionById('recipient.report_message'));

      test('the system now holds what one person doubted', () {
        final run = reported();

        expect(valueOf(run, 'message.classification'), 'Suspected');
        expect(observersOf(run, 'message_reported'), contains('security_team'));
        expect(run.isRelevant(securityTeam), isTrue);
      });

      test('which is what makes anything available to them', () {
        final run = reported();

        expect(actionsFor(run, securityTeam), {
          'security_team.block_sender',
        });
      });

      test('the account was never reached', () {
        expect(valueOf(reported(), 'corporate_account.access'), 'Active');
      });
    });
  });

  group('A Message the Gateway Recognises — where nothing happens', () {
    SimulationRun screened() =>
        runOf('a_message_the_gateway_recognises')
          ..perform(actionById('attacker.send_message'));

    test('the message is held before anyone sees it', () {
      final run = screened();

      expect(valueOf(run, 'message.delivery'), 'Quarantined');
      expect(valueOf(run, 'message.classification'), 'Suspected');
      expect(emittedBy(run), {'message_sent', 'phishing_detected'});

      // Nothing was handed over, so nothing downstream happens.
      expect(emittedBy(run), isNot(contains('message_delivered')));
      expect(emittedBy(run), isNot(contains('message_presented')));
    });

    test('the person it was written for never becomes involved', () {
      final run = screened();

      expect(run.isRelevant(recipient), isFalse);
      expect(actionsFor(run, recipient), isEmpty);
    });

    test('but the people responsible are told, and can act', () {
      final run = screened();

      expect(observersOf(run, 'phishing_detected'), contains('security_team'));
      expect(run.isRelevant(securityTeam), isTrue);

      // The classification the gateway set is what makes blocking possible.
      expect(actionsFor(run, securityTeam), {'security_team.block_sender'});
    });

    test('the outcome asks what would have happened otherwise', () {
      final screening = graph.behaviorDefinitions.firstWhere(
        (behaviour) => behaviour.id == 'mail_gateway.screen_message',
      );

      expect(
        screening.outcomes.single.guidingQuestion,
        contains('had the gateway not recognised it'),
      );
    });
  });

  group('Filtering Bypassed — the same arrival, a different reason', () {
    test('the message arrives, as in the first situation', () {
      final run = runOf('filtering_bypassed')
        ..perform(actionById('attacker.send_message'));

      expect(valueOf(run, 'message.delivery'), 'Delivered');
      expect(run.isRelevant(recipient), isTrue);
    });

    test('but the situation the learner started from is not the same', () {
      final looksRight = runOf('a_message_that_looks_right');
      final bypassed = runOf('filtering_bypassed');

      expect(valueOf(looksRight, 'mail_gateway.filtering'), 'Degraded');
      expect(valueOf(bypassed, 'mail_gateway.filtering'), 'Bypassed');
    });
  });

  group('what the situation surfaces will show', () {
    test('a starting fact is present to display, and is truthful', () {
      final run = runOf('a_message_that_looks_right');
      final snapshot = StudioSituationSnapshot.of(graph, run);

      expect(snapshot.scenario.initialStateOverrides, {
        'mail_gateway.filtering': 'Degraded',
      });
      expect(snapshot.isAtStart, isTrue);
      expect(snapshot.hasDifferences, isFalse);
    });

    test('and differences appear only once something has happened', () {
      final run = runOf('a_message_that_looks_right')
        ..perform(actionById('attacker.send_message'));

      final snapshot = StudioSituationSnapshot.of(graph, run);

      expect(snapshot.isAtStart, isFalse);
      expect(snapshot.hasDifferences, isTrue);

      // Measured against where this situation began, not against the
      // system's declared defaults.
      final delivery = snapshot.differenceFor('message.delivery');

      expect(delivery, isNotNull);
      expect(
        snapshot.differenceFor('mail_gateway.filtering'),
        isNull,
        reason: 'filtering was Degraded when this began and has not moved',
      );
    });
  });
}

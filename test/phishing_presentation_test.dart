import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_condition.dart';
import 'package:systems_studio/engine/models/studio_effect.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/phishing_detail.dart';

/// Surfacing: the step between a message arriving and a person acting on it.
///
/// Phase 2 left a gap. Delivery is emitted by the gateway and reaches the
/// inbox; the recipient is one hop further away than observation travels, so
/// nothing ever put the message in front of the person it was addressed to,
/// and the dynamics tests had to seed the recipient as present to say
/// anything at all.
///
/// The gap was real, and closing it by lengthening observation would have been
/// the wrong repair: it would have made every element in every system a relay,
/// and handed the recipient a vague awareness of a message they are meant to
/// read in full. The inbox does not conduct the gateway's event onward. It
/// produces its own — which is what a human-facing surface does.
///
/// This is the same idiom Password Security already uses, where monitoring
/// does not relay a failure but raises its own alert. Password Security hid
/// the need for it by accident: `login_interface` is both the surface a person
/// looks at and the target of the action, so the two roles were one node.
/// Phishing separates them, which is what made the pattern visible.
void main() {
  const engine = StudioGraphEngine();
  const validator = StudioGraphValidator();

  const attacker = StudioElementRef.node('attacker');
  const recipient = StudioElementRef.node('recipient');
  const inbox = StudioElementRef.node('inbox');
  const mailGateway = StudioElementRef.node('mail_gateway');

  final session = engine.open(phishingDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  String valueOf(SimulationRun run, String variableId) =>
      run.state.valueOf(graph.stateVariableById(variableId)!);

  /// A run that seeds **only** the attacker.
  ///
  /// The recipient's presence is what this phase is about, so granting it in
  /// advance would assume the thing under test. Filtering is degraded so the
  /// message gets through; that is the branch where a person matters.
  SimulationRun sentMessage() {
    return SimulationRun.start(
      graph,
      scenario: StudioScenario(
        id: 'test.surfacing',
        name: 'Surfacing under test',
        initialActors: {attacker},
        initialStateOverrides: {'mail_gateway.filtering': 'Degraded'},
      ),
    )..perform(actionById('attacker.send_message'));
  }

  List<String> observersOf(SimulationRun run, String typeId) {
    return run.observations
        .where((observation) => observation.event.typeId == typeId)
        .map((observation) => observation.observer.id)
        .toList();
  }

  group('the event', () {
    test('message_presented exists and belongs to the inbox', () {
      final type = graph.eventTypeById('message_presented');

      expect(type, isNotNull);
      expect(
        type!.declaredBy,
        inbox,
        reason: 'the inbox presents the message; the gateway\'s part ended '
            'when it handed the message over',
      );
    });

    test('it is distinct from delivery, which the gateway still owns', () {
      expect(
        graph.eventTypeById('message_delivered')!.declaredBy,
        mailGateway,
      );
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

  group('the behaviour', () {
    final behaviour = phishingDetail.behaviorDefinitions.firstWhere(
      (definition) => definition.id == 'inbox.present_message',
    );

    test('present_message is the only behaviour delivery triggers', () {
      expect(
        graph.behaviorDefinitions
            .where((definition) => definition.trigger == 'message_delivered')
            .map((definition) => definition.id),
        ['inbox.present_message'],
      );
    });

    test('surfacing is now used twice, by the two human-facing surfaces', () {
      expect(
        graph.behaviorDefinitions.map((definition) => definition.id).toSet(),
        {
          'mail_gateway.screen_message',
          'inbox.present_message',
          'link_target.present_page',
          'link_target.harvest',
        },
      );

      // Both surfacing behaviours have the same shape: no branch, no effect,
      // one emission. That shape is what makes them surfaces rather than
      // decisions.
      for (final id in ['inbox.present_message', 'link_target.present_page']) {
        final surface = graph.behaviorDefinitions.firstWhere(
          (definition) => definition.id == id,
        );

        expect(surface.outcomes, isEmpty);
        expect(surface.otherwise.effects, isEmpty);
        expect(surface.otherwise.emits, hasLength(1));
      }
    });

    test('the inbox owns it, and delivery triggers it', () {
      expect(behaviour.owner, inbox);
      expect(behaviour.trigger, 'message_delivered');
    });

    test('it changes no state and takes no branch', () {
      expect(
        behaviour.outcomes,
        isEmpty,
        reason: 'a surface does not judge what it is showing',
      );

      expect(behaviour.otherwise.effects, isEmpty);
      expect(behaviour.otherwise.emits, ['message_presented']);
    });

    test('its wording describes an occurrence, not a result', () {
      final explanation = behaviour.otherwise.explanation.toLowerCase();

      expect(
        behaviour.otherwise.explanation,
        'The message appeared in the recipient\'s view. What happens next '
        'depends on what they decide to do.',
      );
      expect(
        behaviour.otherwise.guidingQuestion,
        'The message is now in front of someone. What can they see before '
        'acting?',
      );

      // Surfacing is neither good nor bad news. Saying so would grade the
      // situation before the person has done anything.
      for (final verdict in [
        'success',
        'failed',
        'failure',
        'correct',
        'should',
        'unfortunately',
        'safe',
        'danger',
      ]) {
        expect(explanation, isNot(contains(verdict)));
      }
    });

    test('surfacing leaves the run in exactly the state delivery left it', () {
      final run = sentMessage();

      expect(run.events.map((event) => event.typeId), [
        'message_sent',
        'message_delivered',
        'message_presented',
      ]);

      // The only variable delivery writes is the delivery variable. Nothing
      // moved afterwards.
      expect(valueOf(run, 'message.delivery'), 'Delivered');
      expect(valueOf(run, 'message.classification'), 'Unknown');
      expect(valueOf(run, 'corporate_account.access'), 'Active');
      expect(valueOf(run, 'mail_gateway.filtering'), 'Degraded');
    });
  });

  group('what reaches the person, and what does not', () {
    test('the recipient learns that the message was surfaced', () {
      final run = sentMessage();

      expect(observersOf(run, 'message_presented'), contains('recipient'));
    });

    test('and learns it through the surfacing channel, at one hop', () {
      final run = sentMessage();

      final observation = run.observations.firstWhere(
        (candidate) =>
            candidate.event.typeId == 'message_presented' &&
            candidate.observer == recipient,
      );

      expect(observation.distance, 1);
      expect(observation.channelRelationshipIds, [
        'inbox_presents_to_recipient',
      ]);
    });

    test('the recipient does not learn that the gateway delivered it', () {
      final run = sentMessage();

      final observers = observersOf(run, 'message_delivered');

      expect(observers, contains('inbox'));
      expect(
        observers,
        isNot(contains('recipient')),
        reason: 'delivery is the mail system\'s knowledge. A person knows a '
            'message is in front of them, not how it got there',
      );
    });

    test('the surfacing channel says so itself, not by accident of distance', () {
      final channel = graph.relationshipById('inbox_presents_to_recipient')!;

      expect(channel.carriedEventTypeIds, ['message_presented']);
      expect(channel.carries('message_delivered'), isFalse);
    });
  });

  group('becoming relevant', () {
    test('the recipient was not seeded, and becomes present by observing', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'test.relevance',
          name: 'Relevance under test',
          initialActors: {attacker},
          initialStateOverrides: {'mail_gateway.filtering': 'Degraded'},
        ),
      );

      expect(
        run.isRelevant(recipient),
        isFalse,
        reason: 'nothing has happened to them yet',
      );

      run.perform(actionById('attacker.send_message'));

      expect(
        run.isRelevant(recipient),
        isTrue,
        reason: 'something reached them, which is the whole basis on which '
            'anyone in this engine becomes part of a run',
      );
    });

    test('a held message surfaces nothing, and nobody arrives', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'test.held',
          name: 'Held under test',
          initialActors: {attacker},
          initialStateOverrides: {'mail_gateway.filtering': 'Active'},
        ),
      )..perform(actionById('attacker.send_message'));

      // The gateway recognises it and raises a detection, but nothing is
      // surfaced, because nothing was delivered.
      expect(run.events.map((event) => event.typeId), [
        'message_sent',
        'phishing_detected',
      ]);
      expect(run.isRelevant(recipient), isFalse);
    });

    test('both recipient actions are available once delivered', () {
      final run = sentMessage();

      expect(
        run.availableActionsFor(recipient).map((action) => action.id).toSet(),
        {'recipient.open_link', 'recipient.report_message'},
        reason: 'nothing about surfacing narrows the choice',
      );
    });

    test('the actions are gated on delivery, not on being seen', () {
      /// Every state variable a precondition reads, flattened.
      ///
      /// Structural rather than textual: it walks the condition tree, so a
      /// gate added inside an AllOf cannot slip past by not being at the top.
      List<StudioStateEquals> gatesOf(StudioCondition? condition) {
        return switch (condition) {
          null => const [],
          StudioStateEquals() => [condition],
          StudioAllOf() => [
            for (final inner in condition.conditions) ...gatesOf(inner),
          ],
          _ => throw StateError('unexpected condition kind: $condition'),
        };
      }

      String describe(String id) => gatesOf(actionById(id).precondition)
          .map((gate) => '${gate.variableId}=${gate.value}')
          .join(', ');

      // Both depend on the message having arrived. Neither depends on
      // message_presented: a delivered message can exist without anyone
      // having seen it, and availability and awareness are separate.
      expect(describe('recipient.report_message'), 'message.delivery=Delivered');
      expect(
        describe('recipient.open_link'),
        'message.delivery=Delivered, link_target.contact=None',
      );

      // Nothing reads an event, and nothing reads relevance. Preconditions
      // are about the state of the system, which is why an actor who is
      // present for the wrong reasons still gets a truthful answer.
      for (final id in ['recipient.open_link', 'recipient.report_message']) {
        for (final gate in gatesOf(actionById(id).precondition)) {
          expect(
            graph.stateVariableById(gate.variableId),
            isNotNull,
            reason: '${gate.variableId} must be declared state, not an event',
          );
          expect(gate.variableId, isNot(contains('presented')));
          expect(gate.variableId, isNot(contains('relevan')));
        }
      }
    });
  });

  group('the causal record', () {
    test('now runs gateway, inbox, person', () {
      final run = sentMessage();
      final causal = SimulationCausalGraph.fromRun(run);

      final order = causal.nodes.map((node) => node.element).toList();

      expect(order, contains(mailGateway));
      expect(order, contains(inbox));
      expect(order, contains(recipient));

      expect(
        order.indexOf(mailGateway),
        lessThan(order.indexOf(inbox)),
      );
      expect(
        order.indexOf(inbox),
        lessThan(order.indexOf(recipient)),
        reason: 'the person now enters the record because something reached '
            'them, rather than appearing beside a step nothing connects to',
      );
    });

    test('a link carries the surfacing occurrence to the recipient', () {
      final run = sentMessage();
      final causal = SimulationCausalGraph.fromRun(run);

      final surfacing = causal.links.where(
        (link) => link.eventTypeId == 'message_presented',
      );

      expect(surfacing, isNotEmpty);
      expect(
        surfacing.any((link) => link.observers.contains(recipient)),
        isTrue,
      );
    });

    test('the recipient can see the surfacing step from their own side', () {
      final run = sentMessage();
      final causal = SimulationCausalGraph.fromRun(run);

      expect(
        causal
            .linksObservedBy(recipient)
            .map((link) => link.eventTypeId)
            .toSet(),
        contains('message_presented'),
      );
    });
  });

  group('what this phase did not do', () {
    test('no belief, awareness or seen state variable was added', () {
      final ids = graph.stateVariables.map((variable) => variable.id).toSet();

      expect(ids, {
        'mail_gateway.filtering',
        'message.delivery',
        'message.classification',
        // A fact about the page, not about the person at it: it records that
        // someone arrived, and says nothing about what they make of it.
        'link_target.contact',
        'corporate_account.access',
      });

      for (final word in ['belief', 'aware', 'seen', 'read', 'presented']) {
        expect(
          ids.where((id) => id.toLowerCase().contains(word)),
          isEmpty,
          reason: 'surfacing is an occurrence. Recording it as state would '
              'invite gating a person\'s choices on it',
        );
      }
    });

    test('no outcome anywhere writes a belief', () {
      final assigned = <String>{};

      for (final outcome in [
        for (final action in graph.actionDefinitions)
          ...[...action.outcomes, action.otherwise],
        for (final behaviour in graph.behaviorDefinitions)
          ...[...behaviour.outcomes, behaviour.otherwise],
      ]) {
        for (final effect in outcome.effects) {
          if (effect is StudioAssignState) {
            assigned.add(effect.variableId);
          }
        }
      }

      expect(assigned.where((id) => id.contains('belief')), isEmpty);
    });

    test('no scenario is required for surfacing to work', () {
      // The situations authored later establish starting facts; none of them
      // seeds the recipient, because surfacing is what brings them in.
      for (final scenario in graph.scenarios) {
        expect(
          scenario.initialActors.map((actor) => actor.id),
          isNot(contains('recipient')),
        );
      }
    });

    test('only the surfacing channel restricts what it carries', () {
      expect(
        {
          for (final relationship in graph.relationships)
            if (relationship.carriedEventTypeIds != null) relationship.id,
        },
        {
          'gateway_delivers_to_inbox',
          'inbox_presents_to_recipient',
          'link_target_reports_to_attacker',
          'link_target_presents_to_recipient',
          'gateway_alerts_security_team',
        },
        reason: 'every channel whose purpose is specific says so; the rest '
            'carry whatever reaches them',
      );
    });

    test('the engine knows nothing about any of this', () {
      // The whole point of the pattern is that it is authored content. If a
      // Phishing name, or the surfacing vocabulary, had to be taught to the
      // engine, it would not be a general pattern.
      final engineSources = Directory('lib/engine')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in engineSources) {
        final source = file.readAsStringSync().toLowerCase();

        for (final term in ['message_presented', 'present_message']) {
          expect(
            source,
            isNot(contains(term)),
            reason: '${file.path} should not know "$term"',
          );
        }
      }
    });

    test('observation still stops at one hop', () {
      final source = File(
        'lib/engine/simulation/observability_index.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('maximumDistance = 1'),
        reason: 'an element is not a wire. Surfacing exists precisely so that '
            'this did not have to change',
      );
    });
  });
}

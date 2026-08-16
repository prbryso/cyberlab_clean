import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/models/studio_state_variable.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

import 'simulation_fixture.dart';

/// A scenario establishes the situation. Actors decide what happens.
void main() {
  const engine = StudioGraphEngine();
  const validator = StudioGraphValidator();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');
  const loginInterface = StudioElementRef.node('login_interface');

  final session = engine.open(passwordSecurityDetail);
  final graph = session.graph;

  StudioActionDefinition actionById(String id) =>
      graph.actionDefinitions.firstWhere((action) => action.id == id);

  StudioStateVariable variableById(String id) =>
      graph.stateVariableById(id)!;

  /// A graph carrying [scenarios], for validation cases. The system itself is
  /// untouched — only the situations offered for it differ.
  StudioSystemGraph withScenarios(List<StudioScenario> scenarios) {
    return StudioSystemGraph(
      systemId: graph.systemId,
      nodes: graph.nodes,
      relationships: graph.relationships,
      perspectiveDefinitions: graph.perspectiveDefinitions,
      stateVariables: graph.stateVariables,
      eventTypes: graph.eventTypes,
      actionDefinitions: graph.actionDefinitions,
      behaviorDefinitions: graph.behaviorDefinitions,
      scenarios: scenarios,
    );
  }

  Set<String> codesFor(List<StudioScenario> scenarios) {
    return validator
        .validate(withScenarios(scenarios))
        .issues
        .map((issue) => issue.code)
        .toSet();
  }

  group('a scenario establishes a starting point', () {
    test('its actors are present from the outset', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'response',
          name: 'Security response',
          initialActors: {administrator},
        ),
      );

      expect(run.isRelevant(administrator), isTrue);

      // And nobody else is. Presence is established, not assumed.
      expect(run.isRelevant(attacker), isFalse);
      expect(run.relevantActors, {administrator});
    });

    test('an empty actor set means nobody is present yet', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(id: 'quiet', name: 'Quiet system'),
      );

      expect(run.relevantActors, isEmpty);
      expect(run.availableActions(), isEmpty);
    });

    test('overrides change only what they name', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'locked',
          name: 'Account already locked',
          initialActors: {administrator},
          initialStateOverrides: {'user_account.access': 'Locked'},
        ),
      );

      expect(run.state.valueOf(variableById('user_account.access')), 'Locked');

      // Everything the scenario said nothing about still begins where the
      // system says it begins.
      expect(run.state.valueOf(variableById('login_interface.stage')), 'Idle');
      expect(
        run.state.valueOf(variableById('security_monitoring.signal')),
        'Quiet',
      );
    });

    test('the situation is established without anything having happened', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'locked',
          name: 'Account already locked',
          initialActors: {administrator},
          initialStateOverrides: {'user_account.access': 'Locked'},
        ),
      );

      // A starting point is not a history. Nothing was performed to reach it.
      expect(run.trace, isEmpty);
      expect(run.events, isEmpty);
      expect(run.observations, isEmpty);
    });

    test('a scenario changes what actors may do, without doing it', () {
      // Attempting authentication is barred while the account is locked.
      final locked = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'locked',
          name: 'Account already locked',
          initialActors: {attacker},
          initialStateOverrides: {'user_account.access': 'Locked'},
        ),
      );

      final open = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'open',
          name: 'Ordinary system',
          initialActors: {attacker},
        ),
      );

      expect(
        open.availableActionsFor(attacker).map((action) => action.id),
        contains('attacker.attempt_authentication'),
      );
      expect(
        locked.availableActionsFor(attacker).map((action) => action.id),
        isNot(contains('attacker.attempt_authentication')),
        reason: 'the situation decides what is possible; it takes no action',
      );
    });
  });

  group('state is defaults first, then overrides', () {
    test('with no overrides it equals the declared starting state', () {
      final scenarioState = SimulationState.forScenario(
        graph,
        StudioScenario(id: 'plain', name: 'Plain'),
      );

      final declared = SimulationState.initial(graph);

      expect(scenarioState.values, declared.values);
    });

    test('an unknown override is ignored rather than throwing', () {
      // Validation is where this is reported, with the scenario named. The
      // runtime must not fail obscurely part-way through building a state.
      final state = SimulationState.forScenario(
        graph,
        StudioScenario(
          id: 'broken',
          name: 'Broken',
          initialStateOverrides: {'no.such.variable': 'Whatever'},
        ),
      );

      expect(state.values, SimulationState.initial(graph).values);
    });
  });

  group('reset returns to the scenario, not to the system defaults', () {
    test('state and relevance both return to where the scenario put them', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'takeover',
          name: 'Attempted takeover',
          initialActors: {attacker},
          // Trust takes no part in any condition, so the situation differs
          // from the system's declared values without altering what the run
          // does. Overriding the monitoring signal instead would silence the
          // alert — monitoring only reports when it is not already alerting —
          // and the administrator would never become relevant, so there would
          // be no earned relevance left to prove was cleared.
          initialStateOverrides: {'user_device.trust': 'Trusted'},
        ),
      );

      run.perform(actionById('attacker.attempt_authentication'));

      expect(run.trace, isNotEmpty);
      expect(run.isRelevant(administrator), isTrue);

      run.reset();

      expect(run.trace, isEmpty);
      expect(run.observations, isEmpty);

      // Back to the situation the scenario established — including its
      // override, which is not the system's declared value.
      expect(
        run.state.valueOf(variableById('user_device.trust')),
        'Trusted',
      );

      // And the values it said nothing about are back at the system's.
      expect(
        run.state.valueOf(variableById('security_monitoring.signal')),
        'Quiet',
      );
      expect(run.relevantActors, {attacker});
      expect(
        run.isRelevant(administrator),
        isFalse,
        reason: 'relevance earned by observing is undone when it never '
            'happened',
      );
    });

    test('the scenario itself survives a reset', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'takeover',
          name: 'Attempted takeover',
          initialActors: {attacker},
        ),
      )..perform(actionById('attacker.attempt_authentication'));

      run.reset();

      expect(run.scenarioId, 'takeover');
    });
  });

  group('run identity is scenario-scoped', () {
    test('two situations in one system are distinguishable', () {
      final first = SimulationRun.start(
        graph,
        runId: 'password_security',
        scenario: StudioScenario(id: 'takeover', name: 'Takeover'),
      );

      final second = SimulationRun.start(
        graph,
        runId: 'password_security',
        scenario: StudioScenario(id: 'recovery', name: 'Recovery'),
      );

      expect(first.runId, isNot(second.runId));
      expect(first.runId, contains('takeover'));
      expect(second.runId, contains('recovery'));
    });
  });

  group('the controller can change situation', () {
    test('restart moves to a different scenario', () {
      final controller = StudioSimulationController(
        graph: graph,
        runId: 'password_security',
        scenario: StudioScenario(
          id: 'takeover',
          name: 'Takeover',
          initialActors: {attacker},
        ),
      );

      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));

      expect(controller.trace, isNotEmpty);

      controller.restart(
        scenario: StudioScenario(
          id: 'response',
          name: 'Security response',
          initialActors: {administrator},
          initialStateOverrides: {'user_account.access': 'Locked'},
        ),
      );

      expect(controller.scenario.id, 'response');
      expect(controller.isAtStart, isTrue);
      expect(controller.relevantActors, {administrator});
      expect(
        controller.state.valueOf(variableById('user_account.access')),
        'Locked',
      );
      expect(controller.runId, contains('response'));
    });

    test('reset stays in the current scenario', () {
      final controller = StudioSimulationController(
        graph: graph,
        scenario: StudioScenario(
          id: 'takeover',
          name: 'Takeover',
          initialActors: {attacker},
        ),
      );

      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));
      controller.reset();

      expect(controller.isAtStart, isTrue);
      expect(
        controller.scenario.id,
        'takeover',
        reason: 'reset is not a way back to choosing a situation',
      );
    });
  });

  group('validation rejects situations the system cannot be in', () {
    test('duplicate scenario IDs', () {
      expect(
        codesFor([
          StudioScenario(id: 'takeover', name: 'One'),
          StudioScenario(id: 'takeover', name: 'Two'),
        ]),
        contains('scenario.duplicate_id'),
      );
    });

    test('an actor that is not part of the system', () {
      expect(
        codesFor([
          StudioScenario(
            id: 'ghost',
            name: 'Ghost',
            initialActors: {StudioElementRef.node('nobody')},
          ),
        ]),
        contains('scenario.missing_actor'),
      );
    });

    test('a present element that is not an actor', () {
      expect(
        codesFor([
          StudioScenario(
            id: 'component',
            name: 'Component',
            initialActors: {loginInterface},
          ),
        ]),
        contains('scenario.initial_actor_not_actor'),
      );
    });

    test('an override naming an unknown state variable', () {
      expect(
        codesFor([
          StudioScenario(
            id: 'unknown',
            name: 'Unknown',
            initialStateOverrides: {'no.such.variable': 'Locked'},
          ),
        ]),
        contains('scenario.missing_state_variable'),
      );
    });

    test('an override outside the declared domain', () {
      final codes = codesFor([
        StudioScenario(
          id: 'impossible',
          name: 'Impossible',
          initialStateOverrides: {'user_account.access': 'Evaporated'},
        ),
      ]);

      expect(codes, contains('scenario.state_value_outside_domain'));
    });

    test('a legitimate scenario raises nothing', () {
      final codes = codesFor([
        StudioScenario(
          id: 'locked',
          name: 'Account already locked',
          initialActors: {administrator},
          initialStateOverrides: {'user_account.access': 'Locked'},
        ),
      ]);

      expect(codes.where((code) => code.startsWith('scenario.')), isEmpty);
    });
  });

  group('Password Security authors two situations', () {
    StudioScenario scenarioById(String id) =>
        graph.scenarios.firstWhere((scenario) => scenario.id == id);

    test('a takeover attempt and two compromised-store situations', () {
      expect(graph.scenarios, hasLength(3));

      expect(
        graph.scenarios.map((scenario) => scenario.id).toSet(),
        {
          'attempted_account_takeover',
          'compromised_credential_store',
          'compromised_store_unrecognised_device',
        },
      );

      for (final scenario in graph.scenarios) {
        expect(scenario.initialActors, {attacker});
      }
    });

    test('authoring them does not make the system invalid', () {
      expect(validator.validate(graph).hasErrors, isFalse);
    });

    test('the takeover starts where the system says it starts', () {
      final takeover = scenarioById('attempted_account_takeover');

      expect(takeover.initialStateOverrides, isEmpty);
      expect(
        SimulationState.forScenario(graph, takeover).values,
        SimulationState.initial(graph).values,
      );
    });

    test('the compromised store differs only where it says it does', () {
      final compromised = scenarioById('compromised_credential_store');

      expect(compromised.initialStateOverrides, {
        'credential_store.integrity': 'Compromised',
        'user_device.trust': 'Trusted',
      });

      final state = SimulationState.forScenario(graph, compromised);
      final declared = SimulationState.initial(graph);

      // Two facts differ; everything else is the system as declared.
      final differing = graph.stateVariables
          .where(
            (variable) => state.valueOf(variable) != declared.valueOf(variable),
          )
          .map((variable) => variable.id)
          .toSet();

      expect(differing, {'credential_store.integrity', 'user_device.trust'});
    });
  });

  group('systems with no authored scenarios are unaffected', () {
    // A system that offers no situations, so the backward-compatibility
    // proof no longer depends on Password Security continuing to author
    // none — which it no longer does.
    final plainGraph = buildBasicGraph();

    final pingAction = plainGraph.actionDefinitions.firstWhere(
      (action) => action.id == 'act.ping',
    );

    test('the fixture genuinely offers none', () {
      expect(plainGraph.scenarios, isEmpty);

      expect(
        validator.validate(plainGraph).hasErrors,
        isFalse,
        reason: 'declaring no situations is not a modelling error',
      );
    });

    test('a run without a scenario behaves exactly as before', () {
      final run = SimulationRun.start(
        plainGraph,
        runId: 'plain',
        initialActors: {actorRef},
      );

      expect(run.relevantActors, {actorRef});
      expect(run.state.values, SimulationState.initial(plainGraph).values);

      // Identity is unchanged for systems that never mention a scenario.
      expect(run.runId, 'plain');
      expect(run.scenario.isImplicit, isTrue);
    });

    test('acting and resetting still work without a scenario', () {
      final run = SimulationRun.start(
        plainGraph,
        initialActors: {actorRef},
      )..perform(pingAction);

      expect(run.trace, isNotEmpty);

      run.reset();

      expect(run.trace, isEmpty);
      expect(run.state.values, SimulationState.initial(plainGraph).values);
      expect(run.relevantActors, {actorRef});
    });

    test('the canonical chain is unchanged without a scenario', () {
      final run = SimulationRun.start(graph, initialActors: {attacker})
        ..perform(actionById('attacker.attempt_authentication'));

      expect(run.isRelevant(administrator), isTrue);
      expect(
        run.state.valueOf(variableById('security_monitoring.signal')),
        'Alerting',
      );
    });

    test('reset without a scenario restores the declared values', () {
      final run = SimulationRun.start(graph, initialActors: {attacker})
        ..perform(actionById('attacker.attempt_authentication'));

      run.reset();

      expect(run.state.values, SimulationState.initial(graph).values);
      expect(run.relevantActors, {attacker});
    });

    test('restart without a scenario keeps the original participants', () {
      final controller = StudioSimulationController(
        graph: graph,
        initialActors: {attacker},
      );

      addTearDown(controller.dispose);

      controller.perform(actionById('attacker.attempt_authentication'));
      controller.restart();

      expect(controller.relevantActors, {attacker});
      expect(controller.isAtStart, isTrue);
      expect(controller.scenario.isImplicit, isTrue);
    });
  });

  group('a scenario is not a script', () {
    test('it carries no sequence and no notion of an outcome', () {
      final scenario = StudioScenario(
        id: 'takeover',
        name: 'Attempted takeover',
        description: 'Someone is trying credentials that are not theirs.',
        initialActors: {attacker},
      );

      // The whole authored surface: identity, wording, who is present, and
      // what is already true. Anything ordered or judged would make
      // exploration into a lesson with a right answer.
      expect(scenario.initialActors, {attacker});
      expect(scenario.initialStateOverrides, isEmpty);
      expect(scenario.description, isNotEmpty);
    });

    test('what happens still comes only from actors acting', () {
      final run = SimulationRun.start(
        graph,
        scenario: StudioScenario(
          id: 'takeover',
          name: 'Attempted takeover',
          initialActors: {attacker},
        ),
      );

      expect(run.trace, isEmpty);

      run.perform(actionById('attacker.attempt_authentication'));

      expect(run.trace, isNotEmpty);
    });
  });
}

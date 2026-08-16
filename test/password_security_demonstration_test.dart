import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/graph/graph_builder.dart';
import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/simulation/propagation_evaluator.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/authentication/password_security_detail.dart';

/// Runs the authored Password Security dynamics end to end.
///
/// The fixture tests prove the engine works. This proves the *content* works
/// through the real authoring pipeline: detail -> builder -> graph -> run.
void main() {
  final graph = const StudioGraphBuilder().build(passwordSecurityDetail);

  const evaluator = StudioPropagationEvaluator();
  const validator = StudioGraphValidator();

  const attacker = StudioElementRef.node('attacker');
  const administrator = StudioElementRef.node('administrator');

  StudioActionDefinition attackerAction() {
    return graph.actionDefinitions.firstWhere(
      (action) => action.id == 'attacker.attempt_authentication',
    );
  }

  test('the authored system validates without errors', () {
    final result = validator.validate(graph);

    expect(
      result.errors.map((issue) => '${issue.code}: ${issue.message}'),
      isEmpty,
    );
  });

  test('declared state initialises from the authored declarations', () {
    final state = SimulationState.initial(graph);

    expect(
      state.valueOf(graph.stateVariableById('login_interface.stage')!),
      'Idle',
    );
    expect(
      state.valueOf(graph.stateVariableById('authentication_engine.mode')!),
      'Ready',
    );
    expect(
      state.valueOf(graph.stateVariableById('security_monitoring.signal')!),
      'Quiet',
    );
  });

  test('an attacker attempt propagates through to a security alert', () {
    final action = attackerAction();

    expect(action.initiator, attacker);

    final state = SimulationState.initial(graph);

    expect(evaluator.isAvailable(action, graph, state), isTrue);

    final result = evaluator.run(action, graph, state);

    // Attempt -> engine evaluates -> monitoring notices.
    expect(
      result.trace.entries.map((entry) => entry.definitionId),
      [
        'attacker.attempt_authentication',
        'authentication_engine.evaluate_attempt',
        'security_monitoring.notice_failure',
      ],
    );

    expect(
      result.trace.allEvents.map((event) => event.typeId),
      ['authentication_attempted', 'authentication_failed', 'security_alert_raised'],
    );

    // The engine's conditional outcome needs a compromised store, which has
    // not happened, so the refusal comes from its fallback outcome.
    expect(result.trace.entries[1].usedOtherwise, isTrue);

    // Monitoring had been quiet, so its first conditional outcome matched.
    expect(result.trace.entries[2].usedOtherwise, isFalse);
    expect(result.trace.entries[2].outcomeIndex, 0);

    expect(
      result.state.valueOf(
        graph.stateVariableById('security_monitoring.signal')!,
      ),
      'Alerting',
    );
    expect(
      result.state.valueOf(graph.stateVariableById('login_interface.stage')!),
      'Access denied',
    );

    expect(result.trace.termination, StudioTraceTermination.quiescence);
  });

  test('no behaviour reacts to the alert; only an actor observes it', () {
    final result = evaluator.run(
      attackerAction(),
      graph,
      SimulationState.initial(graph),
    );

    final alert = result.trace.allEvents.last;

    expect(alert.typeId, 'security_alert_raised');
    expect(
      graph.behaviorDefinitions.where(
        (behavior) => behavior.trigger == 'security_alert_raised',
      ),
      isEmpty,
      reason: 'the chain ends at the alert; nothing automates the response',
    );
  });

  group('the administrator becomes relevant by observing', () {
    test('the alert reaches the administrator through a notification', () {
      final run = SimulationRun.start(graph, initialActors: {attacker});

      expect(
        run.isRelevant(administrator),
        isFalse,
        reason: 'nothing has reached the administrator yet',
      );
      expect(run.availableActionsFor(administrator), isEmpty);

      run.perform(attackerAction());

      final alertObservation = run
          .observationsFor(administrator)
          .singleWhere(
            (observation) => observation.event.typeId == 'security_alert_raised',
          );

      expect(alertObservation.basis, StudioObservationBasis.notification);
      expect(alertObservation.fidelity, StudioObservationFidelity.full);
      expect(
        alertObservation.channelRelationshipIds,
        ['monitoring_notifies_administrator'],
        reason: 'the observation names the edge it travelled along',
      );

      expect(run.isRelevant(administrator), isTrue);
    });

    test('relevance comes from the alert, not from the failure', () {
      final run = SimulationRun.start(graph, initialActors: {attacker});

      run.perform(attackerAction());

      final observed = run
          .observationsFor(administrator)
          .map((observation) => observation.event.typeId)
          .toSet();

      // Monitoring watches the engine, but it does not relay what it sees.
      // The administrator learns only what monitoring chose to report.
      expect(observed, {'security_alert_raised'});
      expect(observed, isNot(contains('authentication_failed')));
    });

    test('a relevant administrator has an action available', () {
      final run = SimulationRun.start(graph, initialActors: {attacker});

      run.perform(attackerAction());

      final available = run.availableActionsFor(administrator);

      expect(available, hasLength(1));
      expect(available.single.id, 'administrator.lock_account');
    });

    test('the administrator does not act on their own', () {
      final run = SimulationRun.start(graph, initialActors: {attacker});

      run.perform(attackerAction());

      // Becoming relevant produced no trace entry for the administrator.
      expect(
        run.trace.where((entry) => entry.subject == administrator),
        isEmpty,
      );

      // The account is still open until someone chooses to close it.
      expect(
        run.state.valueOf(graph.stateVariableById('user_account.access')!),
        'Active',
      );
    });

    test('the administrator can then take that action', () {
      final run = SimulationRun.start(graph, initialActors: {attacker});

      run.perform(attackerAction());
      run.perform(run.availableActionsFor(administrator).single);

      expect(
        run.state.valueOf(graph.stateVariableById('user_account.access')!),
        'Locked',
      );
    });

    test('resetting the run makes the administrator irrelevant again', () {
      final run = SimulationRun.start(graph, initialActors: {attacker});

      run.perform(attackerAction());
      expect(run.isRelevant(administrator), isTrue);

      run.reset();

      expect(run.isRelevant(administrator), isFalse);
      expect(run.relevantActors, {attacker});
    });
  });

  test('the alert can be traced back to the attacker action', () {
    final result = evaluator.run(
      attackerAction(),
      graph,
      SimulationState.initial(graph),
    );

    final chain = result.trace.causalChainTo(result.trace.entries.last);

    expect(chain.first.definitionId, 'attacker.attempt_authentication');
    expect(chain, hasLength(3));
  });

  test('a second attempt takes the fallback path', () {
    final action = attackerAction();

    final first = evaluator.run(action, graph, SimulationState.initial(graph));

    // The login interface is no longer idle, so the action's conditional
    // outcome cannot match and nothing propagates.
    final second = evaluator.run(action, graph, first.state);

    expect(second.actionWasAvailable, isTrue);
    expect(second.trace.entries, hasLength(1));
    expect(second.trace.entries.single.usedOtherwise, isTrue);
    expect(second.trace.allEvents, isEmpty);
  });
}

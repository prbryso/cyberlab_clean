import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/models/studio_condition.dart';
import 'package:systems_studio/engine/models/studio_effect.dart';
import 'package:systems_studio/engine/simulation/condition_evaluator.dart';
import 'package:systems_studio/engine/simulation/simulation_state.dart';

import 'simulation_fixture.dart';

/// Tests for the Phase 4 runtime foundation.
///
/// These exercise the layer the propagation evaluator is built on, so a
/// failure here points at state or conditions rather than at execution.
void main() {
  final graph = buildBasicGraph();

  const evaluator = StudioConditionEvaluator();

  group('SimulationState.initial', () {
    test('assigns every declared variable its declared initial value', () {
      final state = SimulationState.initial(graph);

      expect(state.length, 2);
      expect(state.valueOf(engineMode), 'Ready');
      expect(state.valueOf(monitorSignal), 'Quiet');
    });

    test('is keyed by owning element and variable identity', () {
      final state = SimulationState.initial(graph);

      expect(state.valueAt(engineMode.key), 'Ready');
      expect(state.values.keys, contains(monitorSignal.key));
    });
  });

  group('assignment', () {
    test('returns a new state and leaves the original untouched', () {
      final original = SimulationState.initial(graph);
      final updated = original.withValue(engineMode.key, 'Busy');

      expect(updated.valueOf(engineMode), 'Busy');
      expect(
        original.valueOf(engineMode),
        'Ready',
        reason: 'the original state must not be mutated',
      );
      expect(identical(original, updated), isFalse);
    });

    test('assigning the same value returns the same instance', () {
      final original = SimulationState.initial(graph);
      final updated = original.withValue(engineMode.key, 'Ready');

      expect(identical(original, updated), isTrue);
    });
  });

  group('reset', () {
    test('restores declared initial values', () {
      final changed = SimulationState.initial(
        graph,
      ).withValue(engineMode.key, 'Busy').withValue(monitorSignal.key, 'Alerting');

      final reset = changed.reset(graph);

      expect(reset.valueOf(engineMode), 'Ready');
      expect(reset.valueOf(monitorSignal), 'Quiet');
      expect(reset, SimulationState.initial(graph));
    });
  });

  group('equality', () {
    test('states with the same assignments are equal', () {
      final a = SimulationState.initial(graph).withValue(engineMode.key, 'Busy');
      final b = SimulationState.initial(graph).withValue(engineMode.key, 'Busy');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('states with different assignments are not equal', () {
      final a = SimulationState.initial(graph);
      final b = a.withValue(engineMode.key, 'Busy');

      expect(a, isNot(b));
    });
  });

  group('condition evaluation', () {
    final state = SimulationState.initial(graph);

    test('equals and not-equals', () {
      expect(
        evaluator.evaluate(
          const StudioStateEquals(variableId: 'engine.mode', value: 'Ready'),
          state,
          graph,
        ),
        isTrue,
      );

      expect(
        evaluator.evaluate(
          const StudioStateNotEquals(variableId: 'engine.mode', value: 'Ready'),
          state,
          graph,
        ),
        isFalse,
      );
    });

    test('allOf, anyOf and not', () {
      const bothTrue = StudioAllOf([
        StudioStateEquals(variableId: 'engine.mode', value: 'Ready'),
        StudioStateEquals(variableId: 'monitor.signal', value: 'Quiet'),
      ]);

      const oneTrue = StudioAnyOf([
        StudioStateEquals(variableId: 'engine.mode', value: 'Busy'),
        StudioStateEquals(variableId: 'monitor.signal', value: 'Quiet'),
      ]);

      expect(evaluator.evaluate(bothTrue, state, graph), isTrue);
      expect(evaluator.evaluate(oneTrue, state, graph), isTrue);
      expect(
        evaluator.evaluate(const StudioNot(bothTrue), state, graph),
        isFalse,
      );
    });

    test('empty allOf is true and empty anyOf is false', () {
      expect(
        evaluator.evaluate(const StudioAllOf([]), state, graph),
        isTrue,
      );
      expect(
        evaluator.evaluate(const StudioAnyOf([]), state, graph),
        isFalse,
      );
    });

    test('throws on a reference to an undeclared variable', () {
      expect(
        () => evaluator.evaluate(
          const StudioStateEquals(variableId: 'nope', value: 'Ready'),
          state,
          graph,
        ),
        throwsStateError,
      );
    });
  });

  group('effect application', () {
    test('assigns a legal value and leaves the source state untouched', () {
      final before = SimulationState.initial(graph);

      final after = before.applyEffect(
        const StudioAssignState(variableId: 'engine.mode', value: 'Busy'),
        graph,
      );

      expect(after.valueOf(engineMode), 'Busy');
      expect(before.valueOf(engineMode), 'Ready');
    });

    test('applies a sequence in order', () {
      final after = SimulationState.initial(graph).applyAll(
        const [
          StudioAssignState(variableId: 'engine.mode', value: 'Busy'),
          StudioAssignState(variableId: 'engine.mode', value: 'Ready'),
        ],
        graph,
      );

      expect(after.valueOf(engineMode), 'Ready');
    });

    test('throws on an undeclared variable', () {
      expect(
        () => SimulationState.initial(graph).applyEffect(
          const StudioAssignState(variableId: 'nope', value: 'Busy'),
          graph,
        ),
        throwsStateError,
      );
    });

    test('throws on a value outside the declared domain', () {
      expect(
        () => SimulationState.initial(graph).applyEffect(
          const StudioAssignState(
            variableId: 'engine.mode',
            value: 'Elsewhere',
          ),
          graph,
        ),
        throwsStateError,
      );
    });
  });
}

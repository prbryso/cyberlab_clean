import 'studio_condition.dart';
import 'studio_element_ref.dart';
import 'studio_outcome.dart';

/// Something a system element does automatically when an event occurs.
///
/// A behaviour is **not a choice**. No actor decides to take it; an element
/// performs it because something happened and the conditions were right. An
/// authentication engine evaluating an attempt, or a monitor noticing a
/// pattern, are behaviours.
///
/// The boundary between an action and a behaviour has a consequence authors
/// will feel as pacing: a run continues on its own through behaviours and
/// pauses only when the next move is an actor's choice. Anything the learner
/// should not have to decide belongs here.
///
/// [trigger] names an event *type*. In this phase a behaviour is considered
/// for every occurrence of that type, wherever it happened. Narrowing that by
/// what the owner can actually observe is Phase 6 work; until then, triggering
/// is deliberately unrestricted rather than half-restricted by a rule that
/// would later have to be unpicked.
///
/// This file is intentionally free of Flutter dependencies.
class StudioBehaviorDefinition {
  const StudioBehaviorDefinition({
    required this.id,
    required this.name,
    required this.owner,
    required this.trigger,
    required this.otherwise,
    this.description = '',
    this.condition,
    this.outcomes = const [],
  });

  /// Unique within the system.
  final String id;

  /// Human-readable name, such as "Evaluate authentication attempt".
  final String name;

  /// What this behaviour does.
  final String description;

  /// The element that performs this behaviour.
  final StudioElementRef owner;

  /// ID of the event type that triggers this behaviour.
  final String trigger;

  /// Whether this behaviour engages at all when triggered.
  ///
  /// Null means it always engages. This gates the whole behaviour; outcome
  /// conditions then decide which result follows.
  final StudioCondition? condition;

  /// Candidate outcomes, evaluated in order.
  final List<StudioOutcome> outcomes;

  /// The result when no candidate outcome matched.
  final StudioOutcome otherwise;

  @override
  String toString() => 'StudioBehaviorDefinition($id)';
}

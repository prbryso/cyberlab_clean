import 'studio_condition.dart';
import 'studio_element_ref.dart';
import 'studio_outcome.dart';

/// Something an actor can deliberately choose to do.
///
/// An action is **intentional**. An actor decides to take it. That is what
/// separates it from a behaviour, which an element performs automatically in
/// response to something happening. The distinction is not cosmetic: it
/// determines when a run pauses for a decision and when it simply continues.
///
/// A target may be a node or a relationship. Intercepting a channel is an
/// action against the relationship between two elements, not against either
/// endpoint, which is why [target] is a [StudioElementRef].
///
/// This is a definition, not an invocation. Running it produces trace entries;
/// the definition itself never changes.
///
/// This file is intentionally free of Flutter dependencies.
class StudioActionDefinition {
  const StudioActionDefinition({
    required this.id,
    required this.name,
    required this.initiator,
    required this.target,
    required this.otherwise,
    this.description = '',
    this.precondition,
    this.outcomes = const [],
  });

  /// Unique within the system.
  final String id;

  /// Learner-facing name, such as "Attempt credential stuffing".
  final String name;

  /// What taking this action means.
  final String description;

  /// The actor who chooses this action.
  final StudioElementRef initiator;

  /// The element this action is taken against.
  final StudioElementRef target;

  /// Whether this action is currently available.
  ///
  /// Null means always available. A precondition determines availability only;
  /// it never selects an outcome.
  final StudioCondition? precondition;

  /// Candidate outcomes, evaluated in order.
  ///
  /// May be empty, in which case [otherwise] always runs.
  final List<StudioOutcome> outcomes;

  /// The result when no candidate outcome matched.
  ///
  /// Mandatory, so an action can never run and produce nothing.
  final StudioOutcome otherwise;

  @override
  String toString() => 'StudioActionDefinition($id)';
}

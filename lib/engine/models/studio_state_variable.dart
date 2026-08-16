import 'studio_element_ref.dart';

/// A declared state slot belonging to one element of a system.
///
/// A state variable says: *this element has a condition that can change, and
/// these are the values it may take.*
///
/// The engine treats every value as an **opaque symbol**. It compares values
/// and assigns them; it never interprets them. "Locked", "Degraded" and
/// "Compromised" mean nothing to the engine — only the authored content knows
/// what they mean. This is what keeps the engine domain-independent while
/// still allowing content to describe behaviour.
///
/// State variables are declarations, not runtime values. The value a variable
/// currently holds lives in a run-scoped SimulationState overlay and never
/// touches the authored graph.
///
/// This file is intentionally free of Flutter dependencies.
class StudioStateVariable {
  const StudioStateVariable({
    required this.id,
    required this.name,
    required this.owner,
    required this.domain,
    required this.initialValue,
    this.description = '',
  });

  /// Unique within the system.
  final String id;

  /// Human-readable name, such as "Mode" or "Integrity".
  final String name;

  /// The element this state belongs to.
  ///
  /// A [StudioElementRef] rather than a node ID, so that a relationship can
  /// own state as well as a node.
  final StudioElementRef owner;

  /// Every value this variable is allowed to take.
  ///
  /// Values are opaque to the engine. The domain is closed: assigning a value
  /// outside it is a modelling error, caught by validation.
  final List<String> domain;

  /// The value this variable holds when a run begins.
  ///
  /// Must be a member of [domain].
  final String initialValue;

  /// Optional explanation of what this state represents.
  final String description;

  /// True when [value] is a member of this variable's domain.
  bool allows(String value) => domain.contains(value);

  /// Identifies this variable's slot in a SimulationState.
  StudioStateKey get key => StudioStateKey(owner: owner, variableId: id);

  @override
  String toString() => 'StudioStateVariable($id on $owner)';
}

/// Identifies one state slot: an element plus a variable declared on it.
///
/// State is keyed by element *and* variable identity rather than by variable
/// ID alone. Variable IDs are unique within a system today, but keying by the
/// pair keeps the overlay meaningful if the same variable name is ever
/// declared on many elements.
class StudioStateKey {
  const StudioStateKey({required this.owner, required this.variableId});

  final StudioElementRef owner;
  final String variableId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StudioStateKey &&
            other.owner == owner &&
            other.variableId == variableId;
  }

  @override
  int get hashCode => Object.hash(owner, variableId);

  @override
  String toString() => '$owner#$variableId';
}

/// Addressing for elements of a system graph.
///
/// Systems Studio needs to refer to, select, focus, and inspect two different
/// kinds of thing: graph nodes and graph relationships. Both carry stable IDs,
/// but those ID spaces are separate, so a bare string is not enough to say what
/// is being addressed.
///
/// [StudioElementRef] carries the kind explicitly. Callers must never infer
/// whether an ID names a node or a relationship by searching for it — an ID
/// that appears in both spaces would resolve ambiguously, and a lookup miss
/// would be indistinguishable from a wrong-kind reference.
///
/// This file is intentionally free of Flutter dependencies.
library;

/// What kind of graph element a [StudioElementRef] addresses.
enum StudioElementKind {
  /// A StudioGraphNode.
  node,

  /// A StudioRelationship.
  relationship,
}

/// A reference to one element of a system graph.
///
/// A reference is a *name*, not a resolved object. It stays valid across graph
/// rebuilds and can be held in immutable state. Resolve it against a graph
/// when a concrete node or relationship is needed.
class StudioElementRef {
  /// Addresses the node with [id].
  const StudioElementRef.node(this.id) : kind = StudioElementKind.node;

  /// Addresses the relationship with [id].
  const StudioElementRef.relationship(this.id)
    : kind = StudioElementKind.relationship;

  /// Which ID space [id] belongs to.
  ///
  /// Always explicit. Never derived from the value of [id].
  final StudioElementKind kind;

  /// Unique within the ID space named by [kind].
  final String id;

  bool get isNode => kind == StudioElementKind.node;

  bool get isRelationship => kind == StudioElementKind.relationship;

  /// True when this reference addresses a node with [nodeId].
  ///
  /// Convenience for the common "is this the node I am drawing?" comparison.
  bool referencesNode(String nodeId) => isNode && id == nodeId;

  /// True when this reference addresses a relationship with [relationshipId].
  bool referencesRelationship(String relationshipId) =>
      isRelationship && id == relationshipId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StudioElementRef && other.kind == kind && other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => '${kind.name}:$id';
}

import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// Describes the portion of a system graph that should be visible.
///
/// A focus is centered on one element — a node or a relationship — and may
/// include hierarchy context, incoming and outgoing relationship neighbors,
/// and optional type filters.
///
/// When the center is a relationship, both of its endpoints act as the
/// traversal seeds and the relationship itself is always retained.
class StudioGraphFocus {
  const StudioGraphFocus({
    required this.center,
    this.depth = 1,
    this.includeParents = true,
    this.includeChildren = true,
    this.includeIncoming = true,
    this.includeOutgoing = true,
    this.allowedNodeTypes,
    this.allowedRelationshipTypes,
  });

  /// Convenience constructor for the common node-centred focus.
  ///
  /// Not const: wrapping [nodeId] in a [StudioElementRef] is a constructor
  /// invocation, which is not a potentially-constant expression in an
  /// initializer list. Use the unnamed constructor with an explicitly const
  /// ref when a const focus is required.
  StudioGraphFocus.node(
    String nodeId, {
    this.depth = 1,
    this.includeParents = true,
    this.includeChildren = true,
    this.includeIncoming = true,
    this.includeOutgoing = true,
    this.allowedNodeTypes,
    this.allowedRelationshipTypes,
  }) : center = StudioElementRef.node(nodeId);

  /// The element at the center of the focused view.
  final StudioElementRef center;

  /// Maximum relationship-traversal distance from the center node.
  ///
  /// A depth of zero includes the center node and any requested hierarchy
  /// context, but does not traverse relationships.
  final int depth;

  /// Whether to include the center node's ancestor hierarchy.
  final bool includeParents;

  /// Whether to include the center node's direct children.
  final bool includeChildren;

  /// Whether incoming relationships may be traversed.
  final bool includeIncoming;

  /// Whether outgoing relationships may be traversed.
  final bool includeOutgoing;

  /// Optional node-type filter.
  ///
  /// The graph root and the center's seed nodes are retained even when their
  /// types are not present in this set.
  final Set<StudioGraphNodeType>? allowedNodeTypes;

  /// Optional relationship-type filter.
  final Set<StudioRelationshipType>? allowedRelationshipTypes;
}

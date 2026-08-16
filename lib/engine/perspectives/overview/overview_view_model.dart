import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_facets.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// Presentation-ready information used by the Overview perspective.
///
/// This model contains no Flutter widgets. It converts graph information into
/// categories that can be rendered, exported, narrated, or used by future
/// AI-assisted explanations.
class OverviewViewModel {
  const OverviewViewModel({
    required this.selectedNode,
    required this.parent,
    required this.ancestors,
    required this.architecturalChildren,
    required this.actors,
    required this.assets,
    required this.inputs,
    required this.outputs,
    required this.interfaces,
    required this.boundaries,
    required this.failureModes,
    required this.controls,
    required this.simulations,
    required this.incidents,
    required this.references,
    required this.incomingRelationships,
    required this.outgoingRelationships,
    required this.otherRelationships,
  });

  final StudioGraphNode selectedNode;

  /// Direct hierarchy parent of the selected node.
  final StudioGraphNode? parent;

  /// Parent hierarchy beginning with the direct parent.
  final List<StudioGraphNode> ancestors;

  /// Subsystems, components, and processes directly contained by this node.
  final List<StudioGraphNode> architecturalChildren;

  final List<StudioGraphNode> actors;
  final List<StudioGraphNode> assets;
  final List<StudioGraphNode> inputs;
  final List<StudioGraphNode> outputs;
  final List<StudioGraphNode> interfaces;
  final List<StudioGraphNode> boundaries;
  final List<StudioGraphNode> failureModes;
  final List<StudioGraphNode> controls;
  final List<StudioGraphNode> simulations;
  final List<StudioGraphNode> incidents;
  final List<StudioGraphNode> references;

  final List<StudioRelationship> incomingRelationships;
  final List<StudioRelationship> outgoingRelationships;

  /// Bidirectional, undirected, or otherwise uncategorized relationships.
  final List<StudioRelationship> otherRelationships;

  factory OverviewViewModel.fromSession({
    required StudioGraphSession session,
    required StudioGraphNode selectedNode,
  }) {
    final query = session.query;
    final graph = session.graph;

    final children = query.childrenOf(selectedNode.id);

    final architecturalChildren =
        children
            .where(
              (node) =>
                  node.type == StudioGraphNodeType.subsystem ||
                  node.type == StudioGraphNodeType.component ||
                  node.type == StudioGraphNodeType.process,
            )
            .toList()
          ..sort(_sortNodes);

    List<StudioGraphNode> childrenByType(StudioGraphNodeType type) {
      final matches = children.where((node) => node.type == type).toList()
        ..sort(_sortNodes);

      return List<StudioGraphNode>.unmodifiable(matches);
    }

    final incoming = query.incomingTo(selectedNode.id).toList()
      ..sort(_sortRelationships);

    final outgoing = query.outgoingFrom(selectedNode.id).toList()
      ..sort(_sortRelationships);

    final incomingIds = incoming.map((relationship) => relationship.id).toSet();

    final outgoingIds = outgoing.map((relationship) => relationship.id).toSet();

    final other =
        graph
            .relationshipsFor(selectedNode.id)
            .where(
              (relationship) =>
                  !incomingIds.contains(relationship.id) &&
                  !outgoingIds.contains(relationship.id),
            )
            .toList()
          ..sort(_sortRelationships);

    final ancestors = query.ancestorsOf(selectedNode.id);

    return OverviewViewModel(
      selectedNode: selectedNode,
      parent: selectedNode.parentId == null
          ? null
          : graph.nodeById(selectedNode.parentId!),
      ancestors: List<StudioGraphNode>.unmodifiable(ancestors),
      architecturalChildren: List<StudioGraphNode>.unmodifiable(
        architecturalChildren,
      ),
      actors: childrenByType(StudioGraphNodeType.actor),
      assets: childrenByType(StudioGraphNodeType.asset),
      inputs: childrenByType(StudioGraphNodeType.input),
      outputs: childrenByType(StudioGraphNodeType.output),
      interfaces: childrenByType(StudioGraphNodeType.interface),
      boundaries: childrenByType(StudioGraphNodeType.boundary),
      failureModes: childrenByType(StudioGraphNodeType.failureMode),
      controls: childrenByType(StudioGraphNodeType.control),
      simulations: childrenByType(StudioGraphNodeType.simulation),
      incidents: childrenByType(StudioGraphNodeType.incident),
      references: childrenByType(StudioGraphNodeType.reference),
      incomingRelationships: List<StudioRelationship>.unmodifiable(incoming),
      outgoingRelationships: List<StudioRelationship>.unmodifiable(outgoing),
      otherRelationships: List<StudioRelationship>.unmodifiable(other),
    );
  }

  bool get hasDescription => selectedNode.description.trim().isNotEmpty;

  /// Package metadata plus the selected node's typed semantics.
  ///
  /// Presentation only. Perspectives that reason about facets should read
  /// [StudioGraphNode.facets] directly.
  Map<String, Object?> get systemInformation => {
    ...selectedNode.metadata,
    ...selectedNode.semanticSummary(),
  };

  bool get hasSystemInformation => systemInformation.isNotEmpty;

  /// The selected node's declared facets.
  StudioNodeFacets get facets => selectedNode.facets;

  bool get hasHierarchy => parent != null || architecturalChildren.isNotEmpty;

  bool get hasContextElements =>
      actors.isNotEmpty ||
      assets.isNotEmpty ||
      inputs.isNotEmpty ||
      outputs.isNotEmpty ||
      interfaces.isNotEmpty ||
      boundaries.isNotEmpty;

  bool get hasAnalysisElements =>
      failureModes.isNotEmpty ||
      controls.isNotEmpty ||
      incidents.isNotEmpty ||
      simulations.isNotEmpty ||
      references.isNotEmpty;

  bool get hasRelationships =>
      incomingRelationships.isNotEmpty ||
      outgoingRelationships.isNotEmpty ||
      otherRelationships.isNotEmpty;

  static int _sortNodes(StudioGraphNode left, StudioGraphNode right) {
    return left.label.toLowerCase().compareTo(right.label.toLowerCase());
  }

  static int _sortRelationships(
    StudioRelationship left,
    StudioRelationship right,
  ) {
    return left.label.toLowerCase().compareTo(right.label.toLowerCase());
  }
}

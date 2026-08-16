import 'dart:collection';

import 'package:systems_studio/engine/graph/graph_focus.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// Read-only query helper for a StudioSystemGraph.
///
/// This class provides reusable graph navigation and filtering operations for:
///
/// - UI views;
/// - search;
/// - analysis;
/// - diagram generation;
/// - future AI-assisted explanations.
class StudioGraphQuery {
  const StudioGraphQuery(this.graph);

  final StudioSystemGraph graph;

  /// Returns all nodes matching [type].
  List<StudioGraphNode> nodesByType(StudioGraphNodeType type) {
    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where((node) => node.type == type),
    );
  }

  /// Returns all nodes containing [tag], case-insensitively.
  List<StudioGraphNode> nodesByTag(String tag) {
    final normalizedTag = tag.trim().toLowerCase();

    if (normalizedTag.isEmpty) {
      return const [];
    }

    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where((node) {
        return node.tags.any(
          (nodeTag) => nodeTag.toLowerCase() == normalizedTag,
        );
      }),
    );
  }

  /// Searches node IDs, labels, descriptions, tags, and metadata values.
  List<StudioGraphNode> searchNodes(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return List<StudioGraphNode>.unmodifiable(graph.nodes);
    }

    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where((node) => _nodeMatches(node, normalizedQuery)),
    );
  }

  /// Returns all direct child nodes of [parentId].
  List<StudioGraphNode> childrenOf(String parentId) {
    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where((node) => node.parentId == parentId),
    );
  }

  /// Returns all descendants of [nodeId] in depth-first order.
  List<StudioGraphNode> descendantsOf(String nodeId) {
    final descendants = <StudioGraphNode>[];
    final visited = <String>{};

    void visit(String parentId) {
      for (final child in childrenOf(parentId)) {
        if (!visited.add(child.id)) {
          continue;
        }

        descendants.add(child);
        visit(child.id);
      }
    }

    visit(nodeId);

    return List<StudioGraphNode>.unmodifiable(descendants);
  }

  /// Returns all ancestors of [nodeId], beginning with its parent.
  List<StudioGraphNode> ancestorsOf(String nodeId) {
    final ancestors = <StudioGraphNode>[];
    final visited = <String>{};

    var current = graph.nodeById(nodeId);

    while (current?.parentId != null) {
      final parentId = current!.parentId!;

      if (!visited.add(parentId)) {
        break;
      }

      final parent = graph.nodeById(parentId);

      if (parent == null) {
        break;
      }

      ancestors.add(parent);
      current = parent;
    }

    return List<StudioGraphNode>.unmodifiable(ancestors);
  }

  /// Returns all relationships of [type].
  List<StudioRelationship> relationshipsByType(StudioRelationshipType type) {
    return List<StudioRelationship>.unmodifiable(
      graph.relationships.where((relationship) => relationship.type == type),
    );
  }

  /// Returns all relationships matching [strength].
  List<StudioRelationship> relationshipsByStrength(
    StudioRelationshipStrength strength,
  ) {
    return List<StudioRelationship>.unmodifiable(
      graph.relationships.where(
        (relationship) => relationship.strength == strength,
      ),
    );
  }

  /// Returns outgoing relationships from [nodeId].
  ///
  /// Reverse relationships are interpreted so their effective direction is
  /// respected.
  List<StudioRelationship> outgoingFrom(String nodeId) {
    return List<StudioRelationship>.unmodifiable(
      graph.relationships.where(
        (relationship) => _isEffectivelyOutgoing(relationship, nodeId),
      ),
    );
  }

  /// Returns incoming relationships to [nodeId].
  ///
  /// Reverse relationships are interpreted so their effective direction is
  /// respected.
  List<StudioRelationship> incomingTo(String nodeId) {
    return List<StudioRelationship>.unmodifiable(
      graph.relationships.where(
        (relationship) => _isEffectivelyIncoming(relationship, nodeId),
      ),
    );
  }

  /// Returns all nodes directly connected to [nodeId].
  List<StudioGraphNode> neighborsOf(
    String nodeId, {
    StudioRelationshipType? relationshipType,
  }) {
    final neighborIds = <String>{};

    for (final relationship in graph.relationships) {
      if (relationshipType != null && relationship.type != relationshipType) {
        continue;
      }

      final otherId = relationship.otherEndpoint(nodeId);

      if (otherId != null) {
        neighborIds.add(otherId);
      }
    }

    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where((node) => neighborIds.contains(node.id)),
    );
  }

  /// Returns nodes connected to [nodeId] through outgoing relationships.
  List<StudioGraphNode> outgoingNeighbors(
    String nodeId, {
    StudioRelationshipType? relationshipType,
  }) {
    final neighborIds = <String>{};

    for (final relationship in outgoingFrom(nodeId)) {
      if (relationshipType != null && relationship.type != relationshipType) {
        continue;
      }

      final targetId = _effectiveTarget(relationship, nodeId);

      if (targetId != null) {
        neighborIds.add(targetId);
      }
    }

    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where((node) => neighborIds.contains(node.id)),
    );
  }

  /// Returns nodes connected to [nodeId] through incoming relationships.
  List<StudioGraphNode> incomingNeighbors(
    String nodeId, {
    StudioRelationshipType? relationshipType,
  }) {
    final neighborIds = <String>{};

    for (final relationship in incomingTo(nodeId)) {
      if (relationshipType != null && relationship.type != relationshipType) {
        continue;
      }

      final sourceId = _effectiveSource(relationship, nodeId);

      if (sourceId != null) {
        neighborIds.add(sourceId);
      }
    }

    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where((node) => neighborIds.contains(node.id)),
    );
  }

  /// Finds the shortest path between [startId] and [endId].
  ///
  /// The default search treats all relationships as traversable in either
  /// direction. Set [respectDirection] to true for directed traversal.
  ///
  /// Returns an empty list when no path exists.
  List<StudioGraphNode> shortestPath(
    String startId,
    String endId, {
    bool respectDirection = false,
    Set<StudioRelationshipType>? allowedTypes,
  }) {
    final start = graph.nodeById(startId);
    final end = graph.nodeById(endId);

    if (start == null || end == null) {
      return const [];
    }

    if (startId == endId) {
      return [start];
    }

    final queue = Queue<String>()..add(startId);
    final visited = <String>{startId};
    final previous = <String, String>{};

    while (queue.isNotEmpty) {
      final currentId = queue.removeFirst();

      for (final neighborId in _traversableNeighborIds(
        currentId,
        respectDirection: respectDirection,
        allowedTypes: allowedTypes,
      )) {
        if (!visited.add(neighborId)) {
          continue;
        }

        previous[neighborId] = currentId;

        if (neighborId == endId) {
          return _reconstructPath(
            startId: startId,
            endId: endId,
            previous: previous,
          );
        }

        queue.add(neighborId);
      }
    }

    return const [];
  }

  /// Returns every node reachable from [startId].
  List<StudioGraphNode> reachableFrom(
    String startId, {
    bool respectDirection = true,
    Set<StudioRelationshipType>? allowedTypes,
  }) {
    if (graph.nodeById(startId) == null) {
      return const [];
    }

    final queue = Queue<String>()..add(startId);
    final visited = <String>{startId};

    while (queue.isNotEmpty) {
      final currentId = queue.removeFirst();

      for (final neighborId in _traversableNeighborIds(
        currentId,
        respectDirection: respectDirection,
        allowedTypes: allowedTypes,
      )) {
        if (visited.add(neighborId)) {
          queue.add(neighborId);
        }
      }
    }

    visited.remove(startId);

    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where((node) => visited.contains(node.id)),
    );
  }

  /// Creates a smaller graph centered on the element described by [focus].
  ///
  /// The focused graph retains the original root system node so the result
  /// remains a valid StudioSystemGraph.
  ///
  /// The focused graph may include:
  ///
  /// - the selected center node;
  /// - its ancestors;
  /// - its direct children;
  /// - incoming relationship neighbors;
  /// - outgoing relationship neighbors;
  /// - additional relationship neighbors up to [StudioGraphFocus.depth].
  StudioSystemGraph focusedSubgraph(StudioGraphFocus focus) {
    if (focus.depth < 0) {
      throw ArgumentError.value(
        focus.depth,
        'focus.depth',
        'Focus depth cannot be negative.',
      );
    }

    // Seed nodes are the traversal starting points. A node centre seeds one
    // node; a relationship centre seeds both of its endpoints.
    final seedNodeIds = <String>{};

    StudioRelationship? centerRelationship;

    switch (focus.center.kind) {
      case StudioElementKind.node:
        final centerNode = graph.nodeById(focus.center.id);

        if (centerNode == null) {
          throw ArgumentError.value(
            focus.center.id,
            'focus.center',
            'No graph node exists with this ID.',
          );
        }

        seedNodeIds.add(centerNode.id);

      case StudioElementKind.relationship:
        final relationship = graph.relationshipById(focus.center.id);

        if (relationship == null) {
          throw ArgumentError.value(
            focus.center.id,
            'focus.center',
            'No graph relationship exists with this ID.',
          );
        }

        centerRelationship = relationship;

        seedNodeIds.add(relationship.sourceId);
        seedNodeIds.add(relationship.targetId);
    }

    final includedNodeIds = <String>{graph.systemId, ...seedNodeIds};

    bool nodeTypeAllowed(StudioGraphNode node) {
      final allowedTypes = focus.allowedNodeTypes;

      return allowedTypes == null ||
          node.id == graph.systemId ||
          seedNodeIds.contains(node.id) ||
          allowedTypes.contains(node.type);
    }

    bool relationshipAllowed(StudioRelationship relationship) {
      final allowedTypes = focus.allowedRelationshipTypes;

      return allowedTypes == null || allowedTypes.contains(relationship.type);
    }

    void includeNode(String nodeId) {
      final node = graph.nodeById(nodeId);

      if (node != null && nodeTypeAllowed(node)) {
        includedNodeIds.add(node.id);
      }
    }

    if (focus.includeParents) {
      for (final seedId in seedNodeIds) {
        for (final ancestor in ancestorsOf(seedId)) {
          includeNode(ancestor.id);
        }
      }
    }

    if (focus.includeChildren) {
      for (final seedId in seedNodeIds) {
        for (final child in childrenOf(seedId)) {
          includeNode(child.id);
        }
      }
    }

    final visitedDepth = <String, int>{
      for (final seedId in seedNodeIds) seedId: 0,
    };

    final queue = Queue<_FocusTraversalEntry>()
      ..addAll(
        seedNodeIds.map(
          (seedId) => _FocusTraversalEntry(nodeId: seedId, depth: 0),
        ),
      );

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.depth >= focus.depth) {
        continue;
      }

      for (final relationship in graph.relationships) {
        if (!relationshipAllowed(relationship)) {
          continue;
        }

        final candidateIds = <String>{};

        if (focus.includeOutgoing &&
            _isEffectivelyOutgoing(relationship, current.nodeId)) {
          final targetId = _effectiveTarget(relationship, current.nodeId);

          if (targetId != null) {
            candidateIds.add(targetId);
          }
        }

        if (focus.includeIncoming &&
            _isEffectivelyIncoming(relationship, current.nodeId)) {
          final sourceId = _effectiveSource(relationship, current.nodeId);

          if (sourceId != null) {
            candidateIds.add(sourceId);
          }
        }

        for (final candidateId in candidateIds) {
          final candidateNode = graph.nodeById(candidateId);

          if (candidateNode == null || !nodeTypeAllowed(candidateNode)) {
            continue;
          }

          includedNodeIds.add(candidateId);

          final nextDepth = current.depth + 1;
          final previousDepth = visitedDepth[candidateId];

          if (previousDepth == null || nextDepth < previousDepth) {
            visitedDepth[candidateId] = nextDepth;

            queue.add(
              _FocusTraversalEntry(nodeId: candidateId, depth: nextDepth),
            );
          }
        }
      }
    }

    // Retain the hierarchy path back to the original root for every visible
    // node. This prevents focused nodes from becoming detached from their
    // subsystem or system context.
    final currentNodeIds = includedNodeIds.toList();

    for (final nodeId in currentNodeIds) {
      final node = graph.nodeById(nodeId);

      if (node == null) {
        continue;
      }

      var parentId = node.parentId;

      while (parentId != null) {
        includedNodeIds.add(parentId);

        final parent = graph.nodeById(parentId);
        parentId = parent?.parentId;
      }
    }

    final focusedNodes = graph.nodes
        .where((node) => includedNodeIds.contains(node.id))
        .toList();

    final focusedRelationships = graph.relationships.where((relationship) {
      // A relationship at the centre of the focus is always retained, even if
      // a relationship-type filter would otherwise exclude it.
      if (relationship.id == centerRelationship?.id) {
        return true;
      }

      return relationshipAllowed(relationship) &&
          includedNodeIds.contains(relationship.sourceId) &&
          includedNodeIds.contains(relationship.targetId);
    }).toList();

    return StudioSystemGraph(
      systemId: graph.systemId,
      nodes: List<StudioGraphNode>.unmodifiable(focusedNodes),
      relationships: List<StudioRelationship>.unmodifiable(
        focusedRelationships,
      ),
      // A focused view narrows which elements are visible. It does not change
      // which viewpoints exist for the system, nor what state it declares.
      perspectiveDefinitions: graph.perspectiveDefinitions,
      stateVariables: graph.stateVariables,
      eventTypes: graph.eventTypes,
      actionDefinitions: graph.actionDefinitions,
      behaviorDefinitions: graph.behaviorDefinitions,
    );
  }

  /// Returns interface nodes marked as trust boundaries.
  List<StudioGraphNode> trustBoundaryInterfaces() {
    return List<StudioGraphNode>.unmodifiable(
      graph.nodes.where(
        (node) =>
            node.type == StudioGraphNodeType.interface &&
            node.crossesTrustBoundary,
      ),
    );
  }

  /// Returns boundary nodes and trust-boundary interface nodes.
  List<StudioGraphNode> boundaryNodes() {
    final matches = <StudioGraphNode>[];

    for (final node in graph.nodes) {
      if (node.type == StudioGraphNodeType.boundary ||
          (node.type == StudioGraphNodeType.interface &&
              node.crossesTrustBoundary)) {
        matches.add(node);
      }
    }

    return List<StudioGraphNode>.unmodifiable(matches);
  }

  /// Returns root-level nodes directly contained by the system.
  List<StudioGraphNode> topLevelNodes() {
    return childrenOf(graph.systemId);
  }

  bool _nodeMatches(StudioGraphNode node, String query) {
    final values = <String>[
      node.id,
      node.label,
      node.description,
      ...node.tags,
      ...node.semanticSearchValues(),
      ..._stateStrings(node.id),
      ..._metadataStrings(node.metadata),
    ];

    return values.any((value) => value.toLowerCase().contains(query));
  }

  /// State-variable names and values declared on [nodeId].
  ///
  /// State lives on the graph rather than on the node, so search reaches it
  /// through the graph.
  Iterable<String> _stateStrings(String nodeId) sync* {
    for (final variable in graph.stateVariablesFor(
      StudioElementRef.node(nodeId),
    )) {
      yield variable.name;
      yield* variable.domain;
    }
  }

  Iterable<String> _metadataStrings(Map<String, Object?> metadata) sync* {
    for (final entry in metadata.entries) {
      yield entry.key;
      yield* _objectStrings(entry.value);
    }
  }

  Iterable<String> _objectStrings(Object? value) sync* {
    if (value == null) {
      return;
    }

    if (value is String) {
      yield value;
      return;
    }

    if (value is num || value is bool || value is Enum) {
      yield value.toString();
      return;
    }

    if (value is Iterable) {
      for (final item in value) {
        yield* _objectStrings(item);
      }

      return;
    }

    if (value is Map) {
      for (final entry in value.entries) {
        yield entry.key.toString();
        yield* _objectStrings(entry.value);
      }

      return;
    }

    yield value.toString();
  }

  Iterable<String> _traversableNeighborIds(
    String nodeId, {
    required bool respectDirection,
    required Set<StudioRelationshipType>? allowedTypes,
  }) sync* {
    for (final relationship in graph.relationships) {
      if (allowedTypes != null && !allowedTypes.contains(relationship.type)) {
        continue;
      }

      if (!respectDirection) {
        final otherId = relationship.otherEndpoint(nodeId);

        if (otherId != null) {
          yield otherId;
        }

        continue;
      }

      switch (relationship.direction) {
        case StudioRelationshipDirection.forward:
          if (relationship.sourceId == nodeId) {
            yield relationship.targetId;
          }

        case StudioRelationshipDirection.reverse:
          if (relationship.targetId == nodeId) {
            yield relationship.sourceId;
          }

        case StudioRelationshipDirection.bidirectional:
        case StudioRelationshipDirection.undirected:
          final otherId = relationship.otherEndpoint(nodeId);

          if (otherId != null) {
            yield otherId;
          }
      }
    }
  }

  List<StudioGraphNode> _reconstructPath({
    required String startId,
    required String endId,
    required Map<String, String> previous,
  }) {
    final pathIds = <String>[endId];
    var currentId = endId;

    while (currentId != startId) {
      final previousId = previous[currentId];

      if (previousId == null) {
        return const [];
      }

      pathIds.add(previousId);
      currentId = previousId;
    }

    return List<StudioGraphNode>.unmodifiable(
      pathIds.reversed.map(graph.nodeById).whereType<StudioGraphNode>(),
    );
  }

  bool _isEffectivelyOutgoing(StudioRelationship relationship, String nodeId) {
    return switch (relationship.direction) {
      StudioRelationshipDirection.forward => relationship.sourceId == nodeId,
      StudioRelationshipDirection.reverse => relationship.targetId == nodeId,
      StudioRelationshipDirection.bidirectional ||
      StudioRelationshipDirection.undirected => relationship.involves(nodeId),
    };
  }

  bool _isEffectivelyIncoming(StudioRelationship relationship, String nodeId) {
    return switch (relationship.direction) {
      StudioRelationshipDirection.forward => relationship.targetId == nodeId,
      StudioRelationshipDirection.reverse => relationship.sourceId == nodeId,
      StudioRelationshipDirection.bidirectional ||
      StudioRelationshipDirection.undirected => relationship.involves(nodeId),
    };
  }

  String? _effectiveTarget(StudioRelationship relationship, String nodeId) {
    return switch (relationship.direction) {
      StudioRelationshipDirection.forward =>
        relationship.sourceId == nodeId ? relationship.targetId : null,
      StudioRelationshipDirection.reverse =>
        relationship.targetId == nodeId ? relationship.sourceId : null,
      StudioRelationshipDirection.bidirectional ||
      StudioRelationshipDirection.undirected => relationship.otherEndpoint(
        nodeId,
      ),
    };
  }

  String? _effectiveSource(StudioRelationship relationship, String nodeId) {
    return switch (relationship.direction) {
      StudioRelationshipDirection.forward =>
        relationship.targetId == nodeId ? relationship.sourceId : null,
      StudioRelationshipDirection.reverse =>
        relationship.sourceId == nodeId ? relationship.targetId : null,
      StudioRelationshipDirection.bidirectional ||
      StudioRelationshipDirection.undirected => relationship.otherEndpoint(
        nodeId,
      ),
    };
  }
}

class _FocusTraversalEntry {
  const _FocusTraversalEntry({required this.nodeId, required this.depth});

  final String nodeId;
  final int depth;
}

import 'studio_action_definition.dart';
import 'studio_behavior_definition.dart';
import 'studio_element_ref.dart';
import 'studio_event_type.dart';
import 'studio_facets.dart';
import 'studio_perspective_definition.dart';
import 'studio_relationship.dart';
import 'studio_scenario.dart';
import 'studio_state_variable.dart';

/// Graph representation of a system.
///
/// The graph contains:
///
/// - nodes representing actors, assets, subsystems, components, failures,
///   incidents, simulations, and external systems;
/// - relationships connecting those nodes.
///
/// The engine can later use this model to generate:
///
/// - system diagrams;
/// - dependency views;
/// - attack paths;
/// - failure-propagation views;
/// - trust-boundary views;
/// - relationship maps.
class StudioSystemGraph {
  const StudioSystemGraph({
    required this.systemId,
    this.nodes = const [],
    this.relationships = const [],
    this.perspectiveDefinitions = const [],
    this.stateVariables = const [],
    this.eventTypes = const [],
    this.actionDefinitions = const [],
    this.behaviorDefinitions = const [],
    this.scenarios = const [],
  });

  /// ID of the StudioSystem represented by this graph.
  final String systemId;

  /// All elements participating in the graph.
  final List<StudioGraphNode> nodes;

  /// Typed connections between graph nodes.
  final List<StudioRelationship> relationships;

  /// Viewpoints authored for this system.
  ///
  /// Perspective definitions are carried through the build rather than
  /// discarded. They are not graph nodes: a perspective is a way of examining
  /// the system, not an element of it.
  ///
  /// The final home for these definitions is an open question. A later phase
  /// may derive perspectives from actors instead of authoring them separately.
  /// Until that is decided, preserving them here guarantees that authored
  /// content is not lost during graph construction.
  final List<StudioPerspectiveDefinition> perspectiveDefinitions;

  /// State variables declared by this system.
  ///
  /// Declarations only. The value a variable currently holds lives in a
  /// run-scoped SimulationState overlay and never appears here — the graph
  /// stays immutable for the life of the application.
  ///
  /// State is not represented as graph nodes. A state variable is a property
  /// of an element, and promoting every value to a node would multiply graph
  /// size and clutter every traversal.
  final List<StudioStateVariable> stateVariables;

  /// Event types this system declares can occur.
  ///
  /// Declarations. A runtime occurrence is a StudioEvent, produced during a
  /// run and never stored here.
  final List<StudioEventType> eventTypes;

  /// Actions actors may deliberately choose.
  final List<StudioActionDefinition> actionDefinitions;

  /// Behaviours elements perform automatically when events occur.
  final List<StudioBehaviorDefinition> behaviorDefinitions;

  /// Situations this system offers for exploration.
  ///
  /// Carried on the graph for the same reason state and dynamics are: a
  /// scenario is authored content about the system that is not an element of
  /// it, and dropping it during the build would lose it. It establishes a
  /// starting point only — it never describes a sequence.
  ///
  /// May be empty, which means the system offers no particular situation and
  /// is explored from its declared starting values.
  final List<StudioScenario> scenarios;

  /// Returns the scenario with [scenarioId], or null when none exists.
  StudioScenario? scenarioById(String scenarioId) {
    for (final scenario in scenarios) {
      if (scenario.id == scenarioId) {
        return scenario;
      }
    }

    return null;
  }

  /// Returns the event type with [eventTypeId], or null when none exists.
  StudioEventType? eventTypeById(String eventTypeId) {
    for (final eventType in eventTypes) {
      if (eventType.id == eventTypeId) {
        return eventType;
      }
    }

    return null;
  }

  /// Returns the action definition with [actionId], or null when none exists.
  StudioActionDefinition? actionDefinitionById(String actionId) {
    for (final action in actionDefinitions) {
      if (action.id == actionId) {
        return action;
      }
    }

    return null;
  }

  /// Returns the behaviour definition with [behaviorId], or null.
  StudioBehaviorDefinition? behaviorDefinitionById(String behaviorId) {
    for (final behavior in behaviorDefinitions) {
      if (behavior.id == behaviorId) {
        return behavior;
      }
    }

    return null;
  }

  /// Returns the state variable with [variableId], or null when none exists.
  StudioStateVariable? stateVariableById(String variableId) {
    for (final variable in stateVariables) {
      if (variable.id == variableId) {
        return variable;
      }
    }

    return null;
  }

  /// Returns every state variable owned by [ref].
  List<StudioStateVariable> stateVariablesFor(StudioElementRef ref) {
    return List<StudioStateVariable>.unmodifiable(
      stateVariables.where((variable) => variable.owner == ref),
    );
  }

  /// Returns the perspective definition with [perspectiveId], or null.
  StudioPerspectiveDefinition? perspectiveDefinitionById(String perspectiveId) {
    for (final perspective in perspectiveDefinitions) {
      if (perspective.id == perspectiveId) {
        return perspective;
      }
    }

    return null;
  }

  /// Returns the node with [nodeId], or null when no node exists.
  StudioGraphNode? nodeById(String nodeId) {
    for (final node in nodes) {
      if (node.id == nodeId) {
        return node;
      }
    }

    return null;
  }

  /// Returns the relationship with [relationshipId], or null when none exists.
  StudioRelationship? relationshipById(String relationshipId) {
    for (final relationship in relationships) {
      if (relationship.id == relationshipId) {
        return relationship;
      }
    }

    return null;
  }

  /// True when [ref] resolves to an element of this graph.
  ///
  /// The reference's kind selects which ID space is searched. An ID is never
  /// looked up in both.
  bool containsElement(StudioElementRef ref) {
    return switch (ref.kind) {
      StudioElementKind.node => nodeById(ref.id) != null,
      StudioElementKind.relationship => relationshipById(ref.id) != null,
    };
  }

  /// Human-readable label for [ref], or null when it does not resolve.
  String? labelForElement(StudioElementRef ref) {
    return switch (ref.kind) {
      StudioElementKind.node => nodeById(ref.id)?.label,
      StudioElementKind.relationship => relationshipById(ref.id)?.label,
    };
  }

  /// Returns all nodes of [type].
  List<StudioGraphNode> nodesByType(StudioGraphNodeType type) {
    return List<StudioGraphNode>.unmodifiable(
      nodes.where((node) => node.type == type),
    );
  }

  /// Returns all relationships involving [nodeId].
  List<StudioRelationship> relationshipsFor(String nodeId) {
    return List<StudioRelationship>.unmodifiable(
      relationships.where((relationship) => relationship.involves(nodeId)),
    );
  }

  /// Returns nodes directly connected to [nodeId].
  List<StudioGraphNode> neighborsOf(String nodeId) {
    final neighborIds = <String>{};

    for (final relationship in relationshipsFor(nodeId)) {
      final otherId = relationship.otherEndpoint(nodeId);

      if (otherId != null) {
        neighborIds.add(otherId);
      }
    }

    return List<StudioGraphNode>.unmodifiable(
      nodes.where((node) => neighborIds.contains(node.id)),
    );
  }

  /// Returns relationships originating at [nodeId].
  List<StudioRelationship> outgoingRelationships(String nodeId) {
    return List<StudioRelationship>.unmodifiable(
      relationships.where(
        (relationship) =>
            relationship.sourceId == nodeId &&
            relationship.direction != StudioRelationshipDirection.reverse,
      ),
    );
  }

  /// Returns relationships terminating at [nodeId].
  List<StudioRelationship> incomingRelationships(String nodeId) {
    return List<StudioRelationship>.unmodifiable(
      relationships.where(
        (relationship) =>
            relationship.targetId == nodeId &&
            relationship.direction != StudioRelationshipDirection.reverse,
      ),
    );
  }

  /// Performs structural validation of this graph.
  ///
  /// Returns an empty list when the graph is valid.
  List<String> validate() {
    final errors = <String>[];

    if (systemId.trim().isEmpty) {
      errors.add('Graph systemId cannot be empty.');
    }

    final nodeIds = <String>{};

    for (final node in nodes) {
      if (node.id.trim().isEmpty) {
        errors.add('Graph nodes cannot have empty IDs.');
        continue;
      }

      if (!nodeIds.add(node.id)) {
        errors.add('Duplicate graph node ID "${node.id}".');
      }

      if (node.label.trim().isEmpty) {
        errors.add('Graph node "${node.id}" must have a label.');
      }

      if (node.parentId != null && node.parentId == node.id) {
        errors.add('Graph node "${node.id}" cannot be its own parent.');
      }
    }

    for (final node in nodes) {
      final parentId = node.parentId;

      if (parentId != null && !nodeIds.contains(parentId)) {
        errors.add(
          'Graph node "${node.id}" references missing parent "$parentId".',
        );
      }
    }

    final relationshipIds = <String>{};

    for (final relationship in relationships) {
      if (relationship.id.trim().isEmpty) {
        errors.add('Graph relationships cannot have empty IDs.');
        continue;
      }

      if (!relationshipIds.add(relationship.id)) {
        errors.add('Duplicate relationship ID "${relationship.id}".');
      }

      if (!nodeIds.contains(relationship.sourceId)) {
        errors.add(
          'Relationship "${relationship.id}" references missing source '
          '"${relationship.sourceId}".',
        );
      }

      if (!nodeIds.contains(relationship.targetId)) {
        errors.add(
          'Relationship "${relationship.id}" references missing target '
          '"${relationship.targetId}".',
        );
      }

      if (relationship.sourceId == relationship.targetId) {
        errors.add(
          'Relationship "${relationship.id}" cannot connect a node '
          'to itself.',
        );
      }
    }

    return List<String>.unmodifiable(errors);
  }

  /// Throws a StateError when the graph is invalid.
  void validateOrThrow() {
    final errors = validate();

    if (errors.isEmpty) {
      return;
    }

    throw StateError(
      'Invalid StudioSystemGraph for "$systemId":\n'
      '${errors.map((error) => '- $error').join('\n')}',
    );
  }
}

/// One element in a system graph.
///
/// A graph node is deliberately generic about *subject matter*, but not about
/// *semantics*. Meaning that the engine understands — the declared facets of
/// PRODUCT_PRINCIPLES.md, declared states, and trust-boundary crossing — is
/// held in typed fields.
///
/// [metadata] remains available for genuinely package-specific extension data
/// that the engine does not interpret.
class StudioGraphNode {
  const StudioGraphNode({
    required this.id,
    required this.label,
    required this.type,
    this.description = '',
    this.parentId,
    this.tags = const [],
    this.facets = StudioNodeFacets.unknown,
    this.crossesTrustBoundary = false,
    this.metadata = const {},
  });

  /// Unique within the graph.
  final String id;

  /// Human-readable name displayed in diagrams and lists.
  final String label;

  /// General kind of system element represented by this node.
  final StudioGraphNodeType type;

  /// Longer explanation of this element.
  final String description;

  /// Optional parent node used for hierarchy and containment.
  ///
  /// Examples:
  ///
  /// - a component belongs to a subsystem;
  /// - a subsystem belongs to another subsystem;
  /// - an asset belongs to a protected service.
  final String? parentId;

  /// Search and discovery terms.
  final List<String> tags;

  /// The four declared facets of this element.
  ///
  /// Actions, Goals, Observations, and Events. The fifth facet —
  /// Relationships — is derived from the graph rather than declared here.
  ///
  /// Defaults to all-unknown, which is the honest position for an element
  /// whose behaviour has not been described.
  final StudioNodeFacets facets;

  /// True when this element crosses a security, authority, safety, privacy,
  /// organizational, or operational boundary.
  ///
  /// Meaningful for interface nodes. The engine depends on this, which is why
  /// it is a typed field rather than a metadata key.
  final bool crossesTrustBoundary;

  /// Optional extension data supplied by a content package.
  ///
  /// The engine must not depend on package-specific keys. Anything the engine
  /// reasons about belongs in a typed field instead.
  final Map<String, Object?> metadata;

  /// Display-ready view of this node's typed semantics, excluding facets.
  ///
  /// This exists so that generic key/value presentation surfaces can show
  /// typed semantics alongside package metadata without reintroducing
  /// string-keyed lookups into engine logic.
  ///
  /// Facets are deliberately excluded. They carry epistemic status, which a
  /// flat key/value list cannot express, and are rendered by a dedicated
  /// surface instead.
  ///
  /// Presentation only. Engine logic must read the typed fields directly.
  Map<String, Object?> semanticSummary() {
    final summary = <String, Object?>{};

    if (type == StudioGraphNodeType.interface) {
      summary['trustBoundary'] = crossesTrustBoundary;
    }

    return summary;
  }

  /// Every searchable string carried by this node's typed semantics.
  ///
  /// State-variable names and values are not here: they belong to the graph,
  /// not to the node, so search surfaces index them through the graph.
  Iterable<String> semanticSearchValues() sync* {
    yield* facets.knownValues();
  }
}

/// General categories supported by the graph engine.
///
/// Additional subject-specific meaning should be stored in node metadata
/// rather than expanding this enumeration for every library.
enum StudioGraphNodeType {
  system,
  subsystem,
  component,
  actor,
  asset,
  interface,
  boundary,
  input,
  output,
  failureMode,
  control,
  simulation,
  incident,
  reference,
  externalSystem,
  process,
  state,
  custom,
}

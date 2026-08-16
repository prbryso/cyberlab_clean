import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_subsystem.dart';
import 'package:systems_studio/engine/models/studio_system_detail.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// Converts the typed StudioSystemDetail authoring model into a generic graph.
///
/// Content authors can describe a system using actors, assets, subsystems,
/// components, interfaces, failures, simulations, and incidents. The builder
/// turns those elements into graph nodes that can later be queried, analyzed,
/// exported, and visualized.
///
/// When [StudioSystemDetail.graph] is supplied, that explicit graph is used
/// instead of generating one.
///
/// The builder is a semantics-preserving translator, not a flattener. Meaning
/// that the engine understands is carried into typed fields on
/// [StudioGraphNode] — declared facets and trust-boundary crossing — and
/// authored perspective definitions and state declarations are carried onto
/// the graph. Only genuinely package-specific data is placed in node metadata.
class StudioGraphBuilder {
  const StudioGraphBuilder();

  StudioSystemGraph build(StudioSystemDetail detail) {
    final explicitGraph = detail.graph;

    if (explicitGraph != null) {
      if (explicitGraph.systemId != detail.systemId) {
        throw StateError(
          'The explicit graph system ID "${explicitGraph.systemId}" does not '
          'match StudioSystemDetail.systemId "${detail.systemId}".',
        );
      }

      // An explicit graph must not silently discard perspectives authored on
      // the detail record. A graph that declares its own perspectives wins.
      if (detail.perspectives.isEmpty ||
          explicitGraph.perspectiveDefinitions.isNotEmpty) {
        return explicitGraph;
      }

      return StudioSystemGraph(
        systemId: explicitGraph.systemId,
        nodes: explicitGraph.nodes,
        relationships: explicitGraph.relationships,
        perspectiveDefinitions: List.unmodifiable(detail.perspectives),
        stateVariables: explicitGraph.stateVariables,
        eventTypes: explicitGraph.eventTypes,
        actionDefinitions: explicitGraph.actionDefinitions,
        behaviorDefinitions: explicitGraph.behaviorDefinitions,
        // Scenarios are authored on the detail rather than on an explicit
        // graph, so they come from the detail in both paths.
        scenarios: List.unmodifiable(detail.scenarios),
      );
    }

    final nodes = <StudioGraphNode>[];
    final relationships = <StudioRelationship>[];

    final nodeIds = <String>{};
    final relationshipIds = <String>{};

    void addNode(StudioGraphNode node) {
      if (!nodeIds.add(node.id)) {
        throw StateError(
          'Duplicate graph node ID "${node.id}" while building '
          '"${detail.systemId}".',
        );
      }

      nodes.add(node);
    }

    void addRelationship(StudioRelationship relationship) {
      if (!relationshipIds.add(relationship.id)) {
        throw StateError(
          'Duplicate relationship ID "${relationship.id}" while building '
          '"${detail.systemId}".',
        );
      }

      relationships.add(relationship);
    }

    addNode(
      StudioGraphNode(
        id: detail.systemId,
        label: detail.systemId,
        type: StudioGraphNodeType.system,
        description: detail.summary,
        tags: detail.tags,
        facets: detail.facets,
        metadata: {
          'purpose': detail.purpose,
          'guidingQuestions': detail.guidingQuestions,
        },
      ),
    );

    for (final actor in detail.actors) {
      addNode(
        StudioGraphNode(
          id: actor.id,
          label: actor.name,
          type: StudioGraphNodeType.actor,
          description: actor.description,
          parentId: detail.systemId,
          facets: actor.facets,
        ),
      );

      addRelationship(
        StudioRelationship(
          id: '${actor.id}.participates_in.${detail.systemId}',
          sourceId: actor.id,
          targetId: detail.systemId,
          type: StudioRelationshipType.participatesIn,
          label: 'participates in',
        ),
      );
    }

    for (final asset in detail.assets) {
      addNode(
        StudioGraphNode(
          id: asset.id,
          label: asset.name,
          type: StudioGraphNodeType.asset,
          description: asset.description,
          parentId: detail.systemId,
          facets: asset.facets,
          metadata: {'protectionGoals': asset.protectionGoals},
        ),
      );
    }

    for (var index = 0; index < detail.boundaries.length; index++) {
      final boundaryId = '${detail.systemId}.boundary.$index';

      addNode(
        StudioGraphNode(
          id: boundaryId,
          label: detail.boundaries[index],
          type: StudioGraphNodeType.boundary,
          parentId: detail.systemId,
        ),
      );
    }

    for (var index = 0; index < detail.inputs.length; index++) {
      final inputId = '${detail.systemId}.input.$index';

      addNode(
        StudioGraphNode(
          id: inputId,
          label: detail.inputs[index],
          type: StudioGraphNodeType.input,
          parentId: detail.systemId,
        ),
      );

      addRelationship(
        StudioRelationship(
          id: '$inputId.consumed_by.${detail.systemId}',
          sourceId: inputId,
          targetId: detail.systemId,
          type: StudioRelationshipType.consumes,
          label: 'enters',
        ),
      );
    }

    for (var index = 0; index < detail.outputs.length; index++) {
      final outputId = '${detail.systemId}.output.$index';

      addNode(
        StudioGraphNode(
          id: outputId,
          label: detail.outputs[index],
          type: StudioGraphNodeType.output,
          parentId: detail.systemId,
        ),
      );

      addRelationship(
        StudioRelationship(
          id: '${detail.systemId}.produces.$outputId',
          sourceId: detail.systemId,
          targetId: outputId,
          type: StudioRelationshipType.produces,
          label: 'produces',
        ),
      );
    }

    for (final subsystem in detail.subsystems) {
      _addSubsystem(
        subsystem: subsystem,
        parentId: detail.systemId,
        addNode: addNode,
        addRelationship: addRelationship,
      );
    }

    for (final failure in detail.failureModes) {
      addNode(
        StudioGraphNode(
          id: failure.id,
          label: failure.title,
          type: StudioGraphNodeType.failureMode,
          description: failure.description,
          parentId: detail.systemId,
          metadata: {
            'causes': failure.causes,
            'effects': failure.effects,
            'controls': failure.controls,
          },
        ),
      );

      addRelationship(
        StudioRelationship(
          id: '${failure.id}.affects.${detail.systemId}',
          sourceId: failure.id,
          targetId: detail.systemId,
          type: StudioRelationshipType.affects,
          label: 'affects',
        ),
      );
    }

    for (final simulation in detail.simulations) {
      addNode(
        StudioGraphNode(
          id: simulation.id,
          label: simulation.title,
          type: StudioGraphNodeType.simulation,
          description: simulation.description,
          parentId: detail.systemId,
          tags: simulation.tags,
          metadata: {
            'route': simulation.route,
            'explorationQuestions': simulation.explorationQuestions,
          },
        ),
      );
    }

    for (final incident in detail.incidents) {
      addNode(
        StudioGraphNode(
          id: incident.id,
          label: incident.title,
          type: StudioGraphNodeType.incident,
          description: incident.summary,
          parentId: detail.systemId,
          metadata: {
            'year': incident.year,
            'systemEffects': incident.systemEffects,
            'lessons': incident.lessons,
            'relatedSystemIds': incident.relatedSystemIds,
            'referenceIds': incident.referenceIds,
          },
        ),
      );

      addRelationship(
        StudioRelationship(
          id: '${incident.id}.affects.${detail.systemId}',
          sourceId: incident.id,
          targetId: detail.systemId,
          type: StudioRelationshipType.affects,
          label: 'illustrates',
        ),
      );
    }

    for (final reference in detail.references) {
      addNode(
        StudioGraphNode(
          id: reference.id,
          label: reference.title,
          type: StudioGraphNodeType.reference,
          description: reference.description,
          parentId: detail.systemId,
          metadata: {
            'source': reference.source,
            'url': reference.url?.toString(),
            'referenceType': reference.referenceType.name,
          },
        ),
      );
    }

    for (final relationship in detail.relationships) {
      addRelationship(relationship);
    }

    final graph = StudioSystemGraph(
      systemId: detail.systemId,
      nodes: List.unmodifiable(nodes),
      relationships: List.unmodifiable(relationships),
      // Perspectives are viewpoints on the system, not elements of it, so they
      // do not become nodes. They are carried onto the graph so that authored
      // content survives the build.
      perspectiveDefinitions: List.unmodifiable(detail.perspectives),
      // State declarations are properties of elements, not elements. They are
      // carried onto the graph rather than becoming nodes.
      stateVariables: List.unmodifiable(detail.stateVariables),
      // Dynamics describe how the system behaves. Like state, they belong to
      // the system rather than being elements of it.
      eventTypes: List.unmodifiable(detail.eventTypes),
      actionDefinitions: List.unmodifiable(detail.actionDefinitions),
      behaviorDefinitions: List.unmodifiable(detail.behaviorDefinitions),
      // Situations to explore the system in. Like state and dynamics, they
      // are about the system without being elements of it, so they are
      // carried rather than turned into nodes.
      scenarios: List.unmodifiable(detail.scenarios),
    );

    return graph;
  }

  void _addSubsystem({
    required StudioSubsystem subsystem,
    required String parentId,
    required void Function(StudioGraphNode node) addNode,
    required void Function(StudioRelationship relationship) addRelationship,
  }) {
    addNode(
      StudioGraphNode(
        id: subsystem.id,
        label: subsystem.name,
        type: StudioGraphNodeType.subsystem,
        description: subsystem.description,
        parentId: parentId,
        tags: subsystem.tags,
        facets: subsystem.facets,
        metadata: {
          'purpose': subsystem.purpose,
          'inputs': subsystem.inputs,
          'outputs': subsystem.outputs,
        },
      ),
    );

    addRelationship(
      StudioRelationship(
        id: '$parentId.contains.${subsystem.id}',
        sourceId: parentId,
        targetId: subsystem.id,
        type: StudioRelationshipType.contains,
        label: 'contains',
      ),
    );

    for (final component in subsystem.components) {
      _addComponent(
        component: component,
        parentId: subsystem.id,
        addNode: addNode,
        addRelationship: addRelationship,
      );
    }

    for (final interface in subsystem.interfaces) {
      addNode(
        StudioGraphNode(
          id: interface.id,
          label: interface.name,
          type: StudioGraphNodeType.interface,
          description: interface.description,
          parentId: subsystem.id,
          tags: interface.tags,
          crossesTrustBoundary: interface.trustBoundary,
          metadata: {
            'interfaceType': interface.interfaceType.name,
            'direction': interface.direction.name,
            'exchanges': interface.exchanges,
            'protocols': interface.protocols,
          },
        ),
      );

      addRelationship(
        StudioRelationship(
          id: '${interface.id}.source.${interface.sourceId}',
          sourceId: interface.sourceId,
          targetId: interface.id,
          type: StudioRelationshipType.communicatesWith,
          label: 'connects through',
        ),
      );

      addRelationship(
        StudioRelationship(
          id: '${interface.id}.target.${interface.targetId}',
          sourceId: interface.id,
          targetId: interface.targetId,
          type: StudioRelationshipType.communicatesWith,
          label: 'connects to',
        ),
      );
    }

    for (final failure in subsystem.failureModes) {
      addNode(
        StudioGraphNode(
          id: failure.id,
          label: failure.title,
          type: StudioGraphNodeType.failureMode,
          description: failure.description,
          parentId: subsystem.id,
          metadata: {
            'causes': failure.causes,
            'localEffects': failure.localEffects,
            'systemEffects': failure.systemEffects,
            'controls': failure.controls,
          },
        ),
      );

      addRelationship(
        StudioRelationship(
          id: '${failure.id}.affects.${subsystem.id}',
          sourceId: failure.id,
          targetId: subsystem.id,
          type: StudioRelationshipType.affects,
          label: 'affects',
        ),
      );
    }

    for (final child in subsystem.childSubsystems) {
      _addSubsystem(
        subsystem: child,
        parentId: subsystem.id,
        addNode: addNode,
        addRelationship: addRelationship,
      );
    }
  }

  void _addComponent({
    required StudioComponent component,
    required String parentId,
    required void Function(StudioGraphNode node) addNode,
    required void Function(StudioRelationship relationship) addRelationship,
  }) {
    addNode(
      StudioGraphNode(
        id: component.id,
        label: component.name,
        type: StudioGraphNodeType.component,
        description: component.description,
        parentId: parentId,
        tags: component.tags,
        facets: component.facets,
        // responsibilities stays in metadata and is never promoted to the
        // Actions facet. A responsibility is an obligation assigned by the
        // design; an action is a capability. They are separate concepts and
        // neither is derived from the other.
        metadata: {
          'componentType': component.componentType.name,
          'responsibilities': component.responsibilities,
          'inputs': component.inputs,
          'outputs': component.outputs,
        },
      ),
    );

    addRelationship(
      StudioRelationship(
        id: '$parentId.contains.${component.id}',
        sourceId: parentId,
        targetId: component.id,
        type: StudioRelationshipType.contains,
        label: 'contains',
      ),
    );
  }
}

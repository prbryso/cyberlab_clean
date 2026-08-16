import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_behavior_definition.dart';
import 'package:systems_studio/engine/models/studio_condition.dart';
import 'package:systems_studio/engine/models/studio_effect.dart';
import 'package:systems_studio/engine/models/studio_event_type.dart';
import 'package:systems_studio/engine/models/studio_outcome.dart';
import 'package:systems_studio/engine/models/studio_facets.dart';
import 'package:systems_studio/engine/graph/information_flow.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/models/studio_state_variable.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// Performs structural validation of a StudioSystemGraph.
///
/// The validator is intentionally separate from the graph model so additional
/// validation rules can be added without making StudioSystemGraph responsible
/// for every graph-engine concern.
class StudioGraphValidator {
  const StudioGraphValidator();

  /// Validates [graph] and returns every issue found.
  ///
  /// An empty result means the graph is structurally valid.
  StudioGraphValidationResult validate(StudioSystemGraph graph) {
    final issues = <StudioGraphValidationIssue>[];

    _validateSystemId(graph, issues);

    final nodeIds = _validateNodes(graph, issues);

    _validateParentReferences(graph, nodeIds, issues);

    _validateParentCycles(graph, issues);

    _validateRelationships(graph, nodeIds, issues);

    _validateConnectivity(graph, issues);

    _validateFacets(graph, issues);

    _validateStateVariables(graph, issues);

    _validateDynamics(graph, issues);

    _validateScenarios(graph, issues);

    _validateCarriedEventTypes(graph, issues);

    return StudioGraphValidationResult(
      graphSystemId: graph.systemId,
      issues: List.unmodifiable(issues),
    );
  }

  /// Validates [graph] and throws when errors are found.
  void validateOrThrow(StudioSystemGraph graph) {
    final result = validate(graph);

    if (!result.hasErrors) {
      return;
    }

    throw StateError(result.format());
  }

  void _validateSystemId(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    if (graph.systemId.trim().isEmpty) {
      issues.add(
        const StudioGraphValidationIssue(
          code: 'graph.empty_system_id',
          severity: StudioGraphValidationSeverity.error,
          message: 'Graph systemId cannot be empty.',
        ),
      );
    }
  }

  Set<String> _validateNodes(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    final nodeIds = <String>{};

    for (final node in graph.nodes) {
      final nodeId = node.id.trim();

      if (nodeId.isEmpty) {
        issues.add(
          const StudioGraphValidationIssue(
            code: 'node.empty_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Graph nodes cannot have empty IDs.',
          ),
        );

        continue;
      }

      if (!nodeIds.add(nodeId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'node.duplicate_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Duplicate graph node ID "$nodeId".',
            elementId: nodeId,
          ),
        );
      }

      if (node.label.trim().isEmpty) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'node.empty_label',
            severity: StudioGraphValidationSeverity.error,
            message: 'Graph node "$nodeId" must have a label.',
            elementId: nodeId,
          ),
        );
      }

      if (node.parentId == node.id) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'node.self_parent',
            severity: StudioGraphValidationSeverity.error,
            message: 'Graph node "$nodeId" cannot be its own parent.',
            elementId: nodeId,
          ),
        );
      }
    }

    if (!nodeIds.contains(graph.systemId)) {
      issues.add(
        StudioGraphValidationIssue(
          code: 'graph.missing_root_node',
          severity: StudioGraphValidationSeverity.error,
          message:
              'Graph must contain a root node with ID "${graph.systemId}".',
          elementId: graph.systemId,
        ),
      );
    }

    final rootNode = graph.nodeById(graph.systemId);

    if (rootNode != null && rootNode.type != StudioGraphNodeType.system) {
      issues.add(
        StudioGraphValidationIssue(
          code: 'graph.invalid_root_type',
          severity: StudioGraphValidationSeverity.error,
          message:
              'Root node "${graph.systemId}" must have type '
              'StudioGraphNodeType.system.',
          elementId: graph.systemId,
        ),
      );
    }

    return nodeIds;
  }

  void _validateParentReferences(
    StudioSystemGraph graph,
    Set<String> nodeIds,
    List<StudioGraphValidationIssue> issues,
  ) {
    for (final node in graph.nodes) {
      final parentId = node.parentId;

      if (parentId == null) {
        if (node.id != graph.systemId) {
          issues.add(
            StudioGraphValidationIssue(
              code: 'node.missing_parent',
              severity: StudioGraphValidationSeverity.warning,
              message:
                  'Graph node "${node.id}" has no parent and is not the '
                  'root system node.',
              elementId: node.id,
            ),
          );
        }

        continue;
      }

      if (!nodeIds.contains(parentId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'node.missing_parent_reference',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Graph node "${node.id}" references missing parent '
                '"$parentId".',
            elementId: node.id,
          ),
        );
      }
    }
  }

  void _validateParentCycles(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    final nodesById = {for (final node in graph.nodes) node.id: node};

    for (final node in graph.nodes) {
      final visited = <String>{};
      var current = node;

      while (current.parentId != null) {
        if (!visited.add(current.id)) {
          issues.add(
            StudioGraphValidationIssue(
              code: 'node.parent_cycle',
              severity: StudioGraphValidationSeverity.error,
              message:
                  'Parent hierarchy contains a cycle involving '
                  '"${current.id}".',
              elementId: current.id,
            ),
          );

          break;
        }

        final parent = nodesById[current.parentId];

        if (parent == null) {
          break;
        }

        current = parent;
      }
    }
  }

  void _validateRelationships(
    StudioSystemGraph graph,
    Set<String> nodeIds,
    List<StudioGraphValidationIssue> issues,
  ) {
    final relationshipIds = <String>{};

    for (final relationship in graph.relationships) {
      final relationshipId = relationship.id.trim();

      if (relationshipId.isEmpty) {
        issues.add(
          const StudioGraphValidationIssue(
            code: 'relationship.empty_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Graph relationships cannot have empty IDs.',
          ),
        );

        continue;
      }

      if (!relationshipIds.add(relationshipId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'relationship.duplicate_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Duplicate graph relationship ID "$relationshipId".',
            elementId: relationshipId,
          ),
        );
      }

      if (!nodeIds.contains(relationship.sourceId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'relationship.missing_source',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Relationship "$relationshipId" references missing source '
                '"${relationship.sourceId}".',
            elementId: relationshipId,
          ),
        );
      }

      if (!nodeIds.contains(relationship.targetId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'relationship.missing_target',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Relationship "$relationshipId" references missing target '
                '"${relationship.targetId}".',
            elementId: relationshipId,
          ),
        );
      }

      if (relationship.sourceId == relationship.targetId) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'relationship.self_reference',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Relationship "$relationshipId" cannot connect a node '
                'to itself.',
            elementId: relationshipId,
          ),
        );
      }

      _validateRelationshipDirection(relationship, issues);
    }
  }

  void _validateRelationshipDirection(
    StudioRelationship relationship,
    List<StudioGraphValidationIssue> issues,
  ) {
    if (relationship.direction == StudioRelationshipDirection.undirected &&
        _isNormallyDirectional(relationship.type)) {
      issues.add(
        StudioGraphValidationIssue(
          code: 'relationship.unusual_direction',
          severity: StudioGraphValidationSeverity.warning,
          message:
              'Relationship "${relationship.id}" uses an undirected '
              'direction for the directional type '
              '"${relationship.type.name}".',
          elementId: relationship.id,
        ),
      );
    }
  }

  bool _isNormallyDirectional(StudioRelationshipType type) {
    return switch (type) {
      StudioRelationshipType.contains ||
      StudioRelationshipType.participatesIn ||
      StudioRelationshipType.sendsDataTo ||
      StudioRelationshipType.sendsCommandTo ||
      StudioRelationshipType.controls ||
      StudioRelationshipType.monitors ||
      StudioRelationshipType.notifies ||
      StudioRelationshipType.dependsOn ||
      StudioRelationshipType.supports ||
      StudioRelationshipType.protects ||
      StudioRelationshipType.exposes ||
      StudioRelationshipType.threatens ||
      StudioRelationshipType.exploits ||
      StudioRelationshipType.mitigates ||
      StudioRelationshipType.detects ||
      StudioRelationshipType.prevents ||
      StudioRelationshipType.recovers ||
      StudioRelationshipType.causes ||
      StudioRelationshipType.contributesTo ||
      StudioRelationshipType.propagatesTo ||
      StudioRelationshipType.affects ||
      StudioRelationshipType.produces ||
      StudioRelationshipType.consumes ||
      StudioRelationshipType.transforms ||
      StudioRelationshipType.authenticates ||
      StudioRelationshipType.authorizes ||
      StudioRelationshipType.verifies ||
      StudioRelationshipType.stores ||
      StudioRelationshipType.crossesBoundary => true,
      _ => false,
    };
  }

  void _validateConnectivity(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    if (graph.nodes.isEmpty) {
      return;
    }

    final connectedNodeIds = <String>{graph.systemId};
    final pendingNodeIds = <String>[graph.systemId];

    while (pendingNodeIds.isNotEmpty) {
      final currentId = pendingNodeIds.removeLast();

      for (final relationship in graph.relationshipsFor(currentId)) {
        final otherId = relationship.otherEndpoint(currentId);

        if (otherId != null && connectedNodeIds.add(otherId)) {
          pendingNodeIds.add(otherId);
        }
      }

      for (final child in graph.nodes.where(
        (node) => node.parentId == currentId,
      )) {
        if (connectedNodeIds.add(child.id)) {
          pendingNodeIds.add(child.id);
        }
      }

      final currentNode = graph.nodeById(currentId);
      final parentId = currentNode?.parentId;

      if (parentId != null && connectedNodeIds.add(parentId)) {
        pendingNodeIds.add(parentId);
      }
    }

    for (final node in graph.nodes) {
      if (!connectedNodeIds.contains(node.id)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'node.disconnected',
            severity: StudioGraphValidationSeverity.warning,
            message:
                'Graph node "${node.id}" is disconnected from the root '
                'system node.',
            elementId: node.id,
          ),
        );
      }
    }
  }

  /// Checks the declared facets of every node.
  ///
  /// Two rules, with very different intent:
  ///
  /// - A facet marked known must carry a value. "Known and empty" is a
  ///   contradiction: an empty list would silently become a third, unlabelled
  ///   epistemic state. This is an error.
  /// - Unknown facets are reported at info severity. They are not defects.
  ///   They are the open questions in a system model, and reporting them is
  ///   how Systems Studio surfaces places worth investigating.
  void _validateFacets(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    final undescribedNodeIds = <String>[];

    for (final node in graph.nodes) {
      for (final entry in node.facets.entries()) {
        final StudioFacetKind kind = entry.key;
        final StudioFacet<List<String>> facet = entry.value;

        final List<String>? value = facet.value;

        if (facet.isKnown && (value == null || value.isEmpty)) {
          issues.add(
            StudioGraphValidationIssue(
              code: 'facet.known_but_empty',
              severity: StudioGraphValidationSeverity.error,
              message:
                  'Node "${node.id}" declares ${kind.label} as known but '
                  'supplies no value. Use notApplicable or unknown instead of '
                  'an empty list.',
              elementId: node.id,
            ),
          );
        }
      }

      if (node.facets.isEntirelyUnknown) {
        undescribedNodeIds.add(node.id);
        continue;
      }

      // Partially described elements are the interesting case: someone began
      // describing this element and stopped. Report each open question.
      for (final kind in node.facets.unknownFacets()) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'facet.unknown',
            severity: StudioGraphValidationSeverity.info,
            message:
                'Node "${node.id}" does not yet answer: ${kind.question}',
            elementId: node.id,
          ),
        );
      }
    }

    if (undescribedNodeIds.isNotEmpty) {
      issues.add(
        StudioGraphValidationIssue(
          code: 'graph.undescribed_elements',
          severity: StudioGraphValidationSeverity.info,
          message:
              '${undescribedNodeIds.length} of ${graph.nodes.length} elements '
              'have no declared facets yet.',
        ),
      );
    }
  }

  /// Checks every declared state variable.
  ///
  /// A state declaration is only useful if it is unambiguous: unique identity,
  /// a real owner, a non-empty domain, and an initial value drawn from that
  /// domain. Anything else would leave a run undefined before it started.
  /// Checks what relationships say they carry.
  ///
  /// A restriction that names something the system does not declare, or that
  /// sits on a connection carrying no information at all, cannot do what its
  /// author meant. Both fail silently at runtime — an event simply never
  /// arrives, or a filter simply never applies — which is the hardest kind of
  /// modelling error to notice.
  void _validateCarriedEventTypes(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    final eventTypeIds = <String>{
      for (final StudioEventType eventType in graph.eventTypes) eventType.id,
    };

    for (final StudioRelationship relationship in graph.relationships) {
      final carried = relationship.carriedEventTypeIds;

      if (carried == null) {
        continue;
      }

      // A restriction only ever narrows what already flows. On a connection
      // that carries nothing, there is nothing to narrow, so the declaration
      // would read as meaningful while doing nothing at all.
      if (relationship.type.informationFlow == StudioInformationFlow.none) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'relationship.filter_on_non_information_bearing',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Relationship "${relationship.id}" lists carried event types, '
                'but a "${relationship.type.name}" relationship carries no '
                'information for them to travel on.',
            elementId: relationship.id,
          ),
        );
      }

      if (carried.isEmpty) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'relationship.carries_nothing',
            severity: StudioGraphValidationSeverity.warning,
            message:
                'Relationship "${relationship.id}" carries no event types. '
                'That is a legitimate statement, and indistinguishable from '
                'having meant to list some.',
            elementId: relationship.id,
          ),
        );

        continue;
      }

      final seen = <String>{};

      for (final eventTypeId in carried) {
        if (!eventTypeIds.contains(eventTypeId)) {
          issues.add(
            StudioGraphValidationIssue(
              code: 'relationship.carries_unknown_event_type',
              severity: StudioGraphValidationSeverity.error,
              message:
                  'Relationship "${relationship.id}" carries unknown event '
                  'type "$eventTypeId".',
              elementId: relationship.id,
            ),
          );
        }

        if (!seen.add(eventTypeId)) {
          issues.add(
            StudioGraphValidationIssue(
              code: 'relationship.duplicate_carried_event_type',
              severity: StudioGraphValidationSeverity.error,
              message:
                  'Relationship "${relationship.id}" lists event type '
                  '"$eventTypeId" more than once.',
              elementId: relationship.id,
            ),
          );
        }
      }
    }
  }

  /// Checks that every scenario establishes a situation the system can be in.
  ///
  /// A scenario that names a missing actor or an impossible value would put a
  /// run into a state the system says cannot exist, and every later question —
  /// what is available, what an actor observes — would be answered against a
  /// system that was never authored. These are caught here rather than at
  /// runtime so the failure names the scenario instead of surfacing much later
  /// as inexplicable behaviour.
  void _validateScenarios(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    final scenarioIds = <String>{};

    for (final StudioScenario scenario in graph.scenarios) {
      final scenarioId = scenario.id.trim();

      if (scenarioId.isEmpty) {
        issues.add(
          const StudioGraphValidationIssue(
            code: 'scenario.empty_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Scenarios cannot have empty IDs.',
          ),
        );

        continue;
      }

      if (!scenarioIds.add(scenarioId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'scenario.duplicate_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Duplicate scenario ID "$scenarioId".',
            elementId: scenarioId,
          ),
        );
      }

      _validateScenarioActors(graph, scenario, scenarioId, issues);
      _validateScenarioOverrides(graph, scenario, scenarioId, issues);
    }
  }

  void _validateScenarioActors(
    StudioSystemGraph graph,
    StudioScenario scenario,
    String scenarioId,
    List<StudioGraphValidationIssue> issues,
  ) {
    for (final actor in scenario.initialActors) {
      if (!graph.containsElement(actor)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'scenario.missing_actor',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Scenario "$scenarioId" starts with "${actor.id}", which is '
                'not an element of this system.',
            elementId: scenarioId,
          ),
        );

        continue;
      }

      // Presence is an actor idea. A component cannot be "already there" in
      // the sense that matters, because relevance is what decides who is
      // offered actions, and only actors are ever offered any.
      final node = actor.isNode ? graph.nodeById(actor.id) : null;

      if (node == null || node.type != StudioGraphNodeType.actor) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'scenario.initial_actor_not_actor',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Scenario "$scenarioId" starts with "${actor.id}", which is '
                'not an actor.',
            elementId: scenarioId,
          ),
        );
      }
    }
  }

  void _validateScenarioOverrides(
    StudioSystemGraph graph,
    StudioScenario scenario,
    String scenarioId,
    List<StudioGraphValidationIssue> issues,
  ) {
    for (final entry in scenario.initialStateOverrides.entries) {
      final variable = graph.stateVariableById(entry.key);

      if (variable == null) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'scenario.missing_state_variable',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Scenario "$scenarioId" sets unknown state variable '
                '"${entry.key}".',
            elementId: scenarioId,
          ),
        );

        continue;
      }

      if (!variable.allows(entry.value)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'scenario.state_value_outside_domain',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Scenario "$scenarioId" sets "${entry.key}" to '
                '"${entry.value}", which is not one of its declared values '
                '(${variable.domain.join(", ")}).',
            elementId: scenarioId,
          ),
        );
      }
    }
  }

  void _validateStateVariables(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    final variableIds = <String>{};

    for (final StudioStateVariable variable in graph.stateVariables) {
      final variableId = variable.id.trim();

      if (variableId.isEmpty) {
        issues.add(
          const StudioGraphValidationIssue(
            code: 'state.empty_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'State variables cannot have empty IDs.',
          ),
        );

        continue;
      }

      if (!variableIds.add(variableId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'state.duplicate_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Duplicate state variable ID "$variableId".',
            elementId: variableId,
          ),
        );
      }

      if (!graph.containsElement(variable.owner)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'state.missing_owner',
            severity: StudioGraphValidationSeverity.error,
            message:
                'State variable "$variableId" is owned by '
                '"${variable.owner}", which does not exist in this graph.',
            elementId: variableId,
          ),
        );
      }

      if (variable.domain.isEmpty) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'state.empty_domain',
            severity: StudioGraphValidationSeverity.error,
            message:
                'State variable "$variableId" declares no allowed values.',
            elementId: variableId,
          ),
        );

        continue;
      }

      final duplicateValues = <String>{};

      for (final value in variable.domain) {
        if (!duplicateValues.add(value)) {
          issues.add(
            StudioGraphValidationIssue(
              code: 'state.duplicate_domain_value',
              severity: StudioGraphValidationSeverity.warning,
              message:
                  'State variable "$variableId" lists "$value" more than '
                  'once in its domain.',
              elementId: variableId,
            ),
          );
        }
      }

      if (!variable.allows(variable.initialValue)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'state.illegal_initial_value',
            severity: StudioGraphValidationSeverity.error,
            message:
                'State variable "$variableId" has initial value '
                '"${variable.initialValue}", which is outside its declared '
                'domain ${variable.domain}.',
            elementId: variableId,
          ),
        );
      }
    }
  }

  /// Checks event types, actions, behaviours, and their outcomes.
  ///
  /// This is also where conditions and effects finally get validated
  /// automatically. Until they had an owner there was nothing to walk; now
  /// that actions and behaviours carry them, every one is reachable from
  /// [validate] and the runtime evaluator can assume it is sound.
  void _validateDynamics(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    final eventTypeIds = <String>{};

    for (final StudioEventType eventType in graph.eventTypes) {
      final eventTypeId = eventType.id.trim();

      if (eventTypeId.isEmpty) {
        issues.add(
          const StudioGraphValidationIssue(
            code: 'event_type.empty_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Event types cannot have empty IDs.',
          ),
        );

        continue;
      }

      if (!eventTypeIds.add(eventTypeId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'event_type.duplicate_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Duplicate event type ID "$eventTypeId".',
            elementId: eventTypeId,
          ),
        );
      }
    }

    final actionIds = <String>{};

    for (final StudioActionDefinition action in graph.actionDefinitions) {
      final actionId = action.id.trim();

      if (actionId.isEmpty) {
        issues.add(
          const StudioGraphValidationIssue(
            code: 'action.empty_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Actions cannot have empty IDs.',
          ),
        );

        continue;
      }

      if (!actionIds.add(actionId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'action.duplicate_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Duplicate action ID "$actionId".',
            elementId: actionId,
          ),
        );
      }

      if (!graph.containsElement(action.initiator)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'action.missing_initiator',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Action "$actionId" is initiated by "${action.initiator}", '
                'which does not exist in this graph.',
            elementId: actionId,
          ),
        );
      }

      if (!graph.containsElement(action.target)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'action.missing_target',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Action "$actionId" targets "${action.target}", which does '
                'not exist in this graph.',
            elementId: actionId,
          ),
        );
      }

      final precondition = action.precondition;

      if (precondition != null) {
        issues.addAll(
          validateCondition(
            precondition,
            graph,
            ownerDescription: 'precondition of action "$actionId"',
          ),
        );
      }

      _validateOutcomes(
        outcomes: action.outcomes,
        otherwise: action.otherwise,
        graph: graph,
        eventTypeIds: eventTypeIds,
        ownerDescription: 'action "$actionId"',
        ownerId: actionId,
        issues: issues,
      );
    }

    final behaviorIds = <String>{};

    for (final StudioBehaviorDefinition behavior
        in graph.behaviorDefinitions) {
      final behaviorId = behavior.id.trim();

      if (behaviorId.isEmpty) {
        issues.add(
          const StudioGraphValidationIssue(
            code: 'behavior.empty_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Behaviours cannot have empty IDs.',
          ),
        );

        continue;
      }

      if (!behaviorIds.add(behaviorId)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'behavior.duplicate_id',
            severity: StudioGraphValidationSeverity.error,
            message: 'Duplicate behaviour ID "$behaviorId".',
            elementId: behaviorId,
          ),
        );
      }

      if (!graph.containsElement(behavior.owner)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'behavior.missing_owner',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Behaviour "$behaviorId" is owned by "${behavior.owner}", '
                'which does not exist in this graph.',
            elementId: behaviorId,
          ),
        );
      }

      if (!eventTypeIds.contains(behavior.trigger)) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'behavior.missing_trigger',
            severity: StudioGraphValidationSeverity.error,
            message:
                'Behaviour "$behaviorId" is triggered by event type '
                '"${behavior.trigger}", which is not declared.',
            elementId: behaviorId,
          ),
        );
      }

      final gate = behavior.condition;

      if (gate != null) {
        issues.addAll(
          validateCondition(
            gate,
            graph,
            ownerDescription: 'condition of behaviour "$behaviorId"',
          ),
        );
      }

      _validateOutcomes(
        outcomes: behavior.outcomes,
        otherwise: behavior.otherwise,
        graph: graph,
        eventTypeIds: eventTypeIds,
        ownerDescription: 'behaviour "$behaviorId"',
        ownerId: behaviorId,
        issues: issues,
      );
    }

    _validateTriggerCycles(graph, issues);
  }

  void _validateOutcomes({
    required List<StudioOutcome> outcomes,
    required StudioOutcome otherwise,
    required StudioSystemGraph graph,
    required Set<String> eventTypeIds,
    required String ownerDescription,
    required String ownerId,
    required List<StudioGraphValidationIssue> issues,
  }) {
    if (!otherwise.isOtherwise) {
      issues.add(
        StudioGraphValidationIssue(
          code: 'outcome.otherwise_has_condition',
          severity: StudioGraphValidationSeverity.error,
          message:
              'The fallback outcome of $ownerDescription carries a condition. '
              'A fallback must always apply, or outcome selection stops being '
              'total.',
          elementId: ownerId,
        ),
      );
    }

    final allOutcomes = <StudioOutcome>[...outcomes, otherwise];

    for (var index = 0; index < allOutcomes.length; index++) {
      final outcome = allOutcomes[index];
      final isFallback = index == allOutcomes.length - 1;
      final label = isFallback ? 'fallback outcome' : 'outcome $index';

      final condition = outcome.condition;

      if (condition != null) {
        issues.addAll(
          validateCondition(
            condition,
            graph,
            ownerDescription: '$label of $ownerDescription',
          ),
        );
      }

      for (final effect in outcome.effects) {
        issues.addAll(
          validateEffect(
            effect,
            graph,
            ownerDescription: '$label of $ownerDescription',
          ),
        );
      }

      for (final emitted in outcome.emits) {
        if (!eventTypeIds.contains(emitted)) {
          issues.add(
            StudioGraphValidationIssue(
              code: 'outcome.missing_event_type',
              severity: StudioGraphValidationSeverity.error,
              message:
                  'The $label of $ownerDescription emits event type '
                  '"$emitted", which is not declared.',
              elementId: ownerId,
            ),
          );
        }
      }
    }

    // A conditional outcome after an unconditional one can never be reached,
    // because selection stops at the first match.
    for (var index = 0; index < outcomes.length - 1; index++) {
      if (outcomes[index].condition == null) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'outcome.unreachable',
            severity: StudioGraphValidationSeverity.warning,
            message:
                'Outcome $index of $ownerDescription has no condition, so '
                'every later outcome is unreachable.',
            elementId: ownerId,
          ),
        );

        break;
      }
    }
  }

  /// Looks for behaviour chains that could feed themselves.
  ///
  /// The evaluator has runtime safeguards, but a loop that only ever stops
  /// because it hit a depth limit is a modelling problem, and it is much
  /// cheaper to see it in the model than to watch a trace truncate. This walks
  /// trigger-to-emit edges and reports any cycle it can reach.
  void _validateTriggerCycles(
    StudioSystemGraph graph,
    List<StudioGraphValidationIssue> issues,
  ) {
    // eventType -> event types reachable by one behaviour hop.
    final successors = <String, Set<String>>{};

    for (final behavior in graph.behaviorDefinitions) {
      final emitted = <String>{
        for (final outcome in [...behavior.outcomes, behavior.otherwise])
          ...outcome.emits,
      };

      successors.putIfAbsent(behavior.trigger, () => <String>{}).addAll(emitted);
    }

    final reported = <String>{};

    for (final start in successors.keys) {
      final visited = <String>{};
      final stack = <String>[start];

      while (stack.isNotEmpty) {
        final current = stack.removeLast();

        for (final next in successors[current] ?? const <String>{}) {
          if (next == start) {
            if (reported.add(start)) {
              issues.add(
                StudioGraphValidationIssue(
                  code: 'behavior.trigger_cycle',
                  severity: StudioGraphValidationSeverity.warning,
                  message:
                      'Event type "$start" can lead back to itself through '
                      'behaviour emissions. A run reaching this loop will '
                      'stop at the propagation limit rather than at '
                      'quiescence.',
                  elementId: start,
                ),
              );
            }

            break;
          }

          if (visited.add(next)) {
            stack.add(next);
          }
        }
      }
    }
  }

  /// Validates [condition] against the state variables declared by [graph].
  ///
  /// Conditions are not yet attached to anything, so this is not part of
  /// [validate]. It is the entry point a later phase uses when actions and
  /// behaviours begin carrying conditions, and it is what keeps the runtime
  /// evaluator free of defensive checks: an evaluated condition has already
  /// been proven to name real variables and legal values.
  ///
  /// [ownerDescription] identifies whatever carries the condition, so a
  /// message can say where the problem is.
  List<StudioGraphValidationIssue> validateCondition(
    StudioCondition condition,
    StudioSystemGraph graph, {
    String ownerDescription = 'condition',
  }) {
    final issues = <StudioGraphValidationIssue>[];

    for (final variableId in studioConditionVariableIds(condition)) {
      if (graph.stateVariableById(variableId) == null) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'condition.missing_variable',
            severity: StudioGraphValidationSeverity.error,
            message:
                'The $ownerDescription references state variable '
                '"$variableId", which is not declared.',
            elementId: variableId,
          ),
        );
      }
    }

    for (final comparison in studioConditionComparisons(condition)) {
      final variable = graph.stateVariableById(comparison.key);

      if (variable == null || variable.allows(comparison.value)) {
        continue;
      }

      issues.add(
        StudioGraphValidationIssue(
          code: 'condition.value_outside_domain',
          severity: StudioGraphValidationSeverity.error,
          message:
              'The $ownerDescription compares state variable '
              '"${comparison.key}" against "${comparison.value}", which is '
              'outside its declared domain ${variable.domain}.',
          elementId: comparison.key,
        ),
      );
    }

    return List<StudioGraphValidationIssue>.unmodifiable(issues);
  }

  /// Validates [effect] against the state variables declared by [graph].
  ///
  /// Not part of [validate] for the same reason as [validateCondition]:
  /// effects have no owner until a later phase introduces one.
  List<StudioGraphValidationIssue> validateEffect(
    StudioEffect effect,
    StudioSystemGraph graph, {
    String ownerDescription = 'effect',
  }) {
    final issues = <StudioGraphValidationIssue>[];

    for (final variableId in studioEffectVariableIds(effect)) {
      if (graph.stateVariableById(variableId) == null) {
        issues.add(
          StudioGraphValidationIssue(
            code: 'effect.missing_variable',
            severity: StudioGraphValidationSeverity.error,
            message:
                'The $ownerDescription assigns state variable "$variableId", '
                'which is not declared.',
            elementId: variableId,
          ),
        );
      }
    }

    for (final assignment in studioEffectAssignments(effect)) {
      final variable = graph.stateVariableById(assignment.key);

      if (variable == null || variable.allows(assignment.value)) {
        continue;
      }

      issues.add(
        StudioGraphValidationIssue(
          code: 'effect.value_outside_domain',
          severity: StudioGraphValidationSeverity.error,
          message:
              'The $ownerDescription assigns "${assignment.value}" to state '
              'variable "${assignment.key}", which is outside its declared '
              'domain ${variable.domain}.',
          elementId: assignment.key,
        ),
      );
    }

    return List<StudioGraphValidationIssue>.unmodifiable(issues);
  }
}

/// Result returned by StudioGraphValidator.
class StudioGraphValidationResult {
  const StudioGraphValidationResult({
    required this.graphSystemId,
    required this.issues,
  });

  final String graphSystemId;
  final List<StudioGraphValidationIssue> issues;

  bool get isValid => !hasErrors;

  bool get hasErrors => issues.any(
    (issue) => issue.severity == StudioGraphValidationSeverity.error,
  );

  bool get hasWarnings => issues.any(
    (issue) => issue.severity == StudioGraphValidationSeverity.warning,
  );

  List<StudioGraphValidationIssue> get errors {
    return List<StudioGraphValidationIssue>.unmodifiable(
      issues.where(
        (issue) => issue.severity == StudioGraphValidationSeverity.error,
      ),
    );
  }

  List<StudioGraphValidationIssue> get warnings {
    return List<StudioGraphValidationIssue>.unmodifiable(
      issues.where(
        (issue) => issue.severity == StudioGraphValidationSeverity.warning,
      ),
    );
  }

  /// Observations that are not defects, such as unknown facets.
  List<StudioGraphValidationIssue> get infos {
    return List<StudioGraphValidationIssue>.unmodifiable(
      issues.where(
        (issue) => issue.severity == StudioGraphValidationSeverity.info,
      ),
    );
  }

  /// Facets that have not yet been answered anywhere in this graph.
  List<StudioGraphValidationIssue> get openQuestions {
    return List<StudioGraphValidationIssue>.unmodifiable(
      issues.where((issue) => issue.code == 'facet.unknown'),
    );
  }

  String format() {
    if (issues.isEmpty) {
      return 'StudioSystemGraph "$graphSystemId" is valid.';
    }

    final lines = issues
        .map((issue) {
          final severity = issue.severity.name.toUpperCase();
          final element = issue.elementId == null
              ? ''
              : ' [${issue.elementId}]';

          return '- $severity ${issue.code}$element: ${issue.message}';
        })
        .join('\n');

    return 'StudioSystemGraph "$graphSystemId" validation failed:\n'
        '$lines';
  }
}

/// One graph validation finding.
class StudioGraphValidationIssue {
  const StudioGraphValidationIssue({
    required this.code,
    required this.severity,
    required this.message,
    this.elementId,
  });

  final String code;
  final StudioGraphValidationSeverity severity;
  final String message;
  final String? elementId;
}

enum StudioGraphValidationSeverity {
  /// An observation about the model that is not a defect.
  ///
  /// Unknown facets are reported at this severity. They describe what Systems
  /// Studio does not yet know, which is legitimate content rather than a
  /// problem to fix.
  info,

  warning,

  error,
}

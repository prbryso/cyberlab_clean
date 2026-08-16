import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/perspectives/actor/actor_perspective_view.dart';
import 'package:systems_studio/engine/perspectives/studio_perspective.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';

/// What a particular actor knows, observes, and can do.
///
/// There is one implementation, not one per actor. An Attacker view and an
/// Administrator view are the same derivation applied to different actors over
/// the same run; they differ because those actors received different
/// observations, not because anyone authored two perspectives. Authoring a
/// separate AttackerPerspective would make the difference cosmetic and would
/// have to be maintained in step with the model.
///
/// This file is intentionally free of Flutter dependencies.
class ActorPerspective extends StudioPerspective {
  const ActorPerspective();

  static const String perspectiveId = 'actor';

  @override
  String get id => perspectiveId;

  @override
  String get title => 'Actor';

  @override
  String get description =>
      'What this participant currently knows, can see, and could do.';

  @override
  StudioPerspectiveView view(StudioPerspectiveRequest request) {
    final selected = request.selectedElement;

    if (selected == null) {
      return const StudioPerspectiveUnsupported(
        perspectiveId: perspectiveId,
        reason: StudioPerspectiveUnsupportedReason.noSelection,
        message: 'Select an actor to see what they know.',
      );
    }

    if (selected.isRelationship) {
      return StudioPerspectiveUnsupported(
        perspectiveId: perspectiveId,
        reason: StudioPerspectiveUnsupportedReason.relationshipNotSupported,
        message:
            'A relationship is a connection, not a participant. Select one of '
            'its endpoints to see what that participant knows.',
        requestedElement: selected,
      );
    }

    final graph = request.session.graph;
    final node = graph.nodeById(selected.id);

    if (node == null) {
      return StudioPerspectiveUnsupported(
        perspectiveId: perspectiveId,
        reason: StudioPerspectiveUnsupportedReason.elementNotFound,
        message: 'That element is not part of this system.',
        requestedElement: selected,
      );
    }

    if (node.type != StudioGraphNodeType.actor) {
      return StudioPerspectiveUnsupported(
        perspectiveId: perspectiveId,
        reason: StudioPerspectiveUnsupportedReason.wrongElementKind,
        message:
            '"${node.label}" is not a participant. This perspective describes '
            'what an actor knows.',
        requestedElement: selected,
      );
    }

    final run = request.run;

    if (run == null) {
      return const StudioPerspectiveUnsupported(
        perspectiveId: perspectiveId,
        reason: StudioPerspectiveUnsupportedReason.runRequired,
        message:
            'Nothing has happened yet. What an actor knows depends on what '
            'has occurred.',
      );
    }

    return _buildView(
      actor: selected,
      graph: graph,
      run: run,
      label: node.label,
      description: node.description,
    );
  }

  ActorPerspectiveView _buildView({
    required StudioElementRef actor,
    required StudioSystemGraph graph,
    required SimulationRun run,
    required String label,
    required String description,
  }) {
    final node = graph.nodeById(actor.id)!;

    final goalsFacet = node.facets.goals;

    final observations = run.observationsFor(actor);

    // What the actor has actually learned about: the places its observations
    // came from, plus itself.
    final known = <StudioElementRef>{actor};

    for (final observation in observations) {
      // Only a full-fidelity observation tells you where something happened.
      // Second-hand awareness does not reveal its origin, so it cannot add to
      // what the actor knows about the system's shape.
      if (observation.fidelity == StudioObservationFidelity.full) {
        known.add(observation.event.source);
      }
    }

    // What the actor could learn about, given how the system is wired.
    final observable = <StudioElementRef>{actor};

    for (final candidate in graph.nodes) {
      if (candidate.id == actor.id) {
        continue;
      }

      if (run.observability.routeBetween(candidate.id, actor) != null) {
        observable.add(StudioElementRef.node(candidate.id));
      }
    }

    // Acting on something is a way of knowing about it.
    for (final action in graph.actionDefinitions) {
      if (action.initiator == actor) {
        observable.add(action.target);
      }
    }

    final observedEvents = observations
        .map((observation) => _observedEvent(observation, run, graph))
        .toList();

    final visibleState = <VisibleStateView>[];

    for (final variable in graph.stateVariables) {
      if (!known.contains(variable.owner)) {
        continue;
      }

      visibleState.add(
        VisibleStateView(
          variableId: variable.id,
          name: variable.name,
          owner: variable.owner,
          value: run.state.valueOf(variable),
        ),
      );
    }

    final performed = <String>[
      for (final entry in run.trace)
        if (entry.subject == actor) entry.definitionId,
    ];

    return ActorPerspectiveView(
      perspectiveId: perspectiveId,
      actor: actor,
      actorName: label,
      actorDescription: description,
      isRelevant: run.isRelevant(actor),
      goals: goalsFacet.valueOr(const []),
      goalsAreKnown: goalsFacet.isKnown,
      knownElements: _sorted(known),
      observableElements: _sorted(observable),
      observations: List<StudioObservation>.unmodifiable(observations),
      observedEvents: List<ObservedEventView>.unmodifiable(observedEvents),
      visibleState: List<VisibleStateView>.unmodifiable(visibleState),
      availableActions: run.availableActionsFor(actor),
      performedActionIds: List<String>.unmodifiable(performed),
    );
  }

  /// Shapes one occurrence to what this observer was in a position to know.
  ///
  /// The withholding happens here, once, rather than in every consumer. A
  /// renderer cannot accidentally show a source element that the observer
  /// never learned, because the view model does not carry one.
  ObservedEventView _observedEvent(
    StudioObservation observation,
    SimulationRun run,
    StudioSystemGraph graph,
  ) {
    final event = observation.event;
    final eventType = graph.eventTypeById(event.typeId);

    final name = eventType?.name ?? event.typeId;

    if (observation.fidelity == StudioObservationFidelity.existenceOnly) {
      return ObservedEventView(
        sequence: event.sequence,
        eventTypeId: event.typeId,
        eventTypeName: name,
        fidelity: observation.fidelity,
        basis: observation.basis,
      );
    }

    String? explanation;

    for (final entry in run.trace) {
      final emitted = entry.emittedEvents.any(
        (candidate) => candidate.sequence == event.sequence,
      );

      if (emitted) {
        explanation = entry.explanation.trim().isEmpty
            ? null
            : entry.explanation;
        break;
      }
    }

    return ObservedEventView(
      sequence: event.sequence,
      eventTypeId: event.typeId,
      eventTypeName: name,
      fidelity: observation.fidelity,
      basis: observation.basis,
      description: eventType?.description.trim().isEmpty ?? true
          ? null
          : eventType!.description,
      source: event.source,
      channelRelationshipIds: observation.channelRelationshipIds,
      explanation: explanation,
      payload: event.payload,
    );
  }

  static List<StudioElementRef> _sorted(Set<StudioElementRef> refs) {
    final list = refs.toList()
      ..sort((left, right) => left.id.compareTo(right.id));

    return List<StudioElementRef>.unmodifiable(list);
  }
}

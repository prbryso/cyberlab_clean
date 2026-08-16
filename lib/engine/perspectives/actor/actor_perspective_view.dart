import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_state_variable.dart';
import 'package:systems_studio/engine/perspectives/studio_perspective.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';

/// One occurrence as a particular actor received it.
///
/// This is where fidelity stops being a label and starts being a filter. The
/// same underlying event produces different objects for different observers,
/// and an observer's view simply does not carry what they were not in a
/// position to know.
///
/// At [StudioObservationFidelity.existenceOnly] the source element, the
/// description, the channel and the causal explanation are all absent — not
/// blanked out for display, but never put in the view model in the first
/// place. A renderer, a narrator, or an AI layer reading this object cannot
/// leak what it does not have.
class ObservedEventView {
  const ObservedEventView({
    required this.sequence,
    required this.eventTypeId,
    required this.eventTypeName,
    required this.fidelity,
    required this.basis,
    this.description,
    this.source,
    this.channelRelationshipIds = const [],
    this.explanation,
    this.payload = const {},
  });

  /// Position of the occurrence in the run.
  final int sequence;

  /// Which kind of occurrence. Available at every fidelity: knowing that
  /// *something of this kind* happened is the minimum awareness.
  final String eventTypeId;

  final String eventTypeName;

  final StudioObservationFidelity fidelity;

  final StudioObservationBasis basis;

  /// What the occurrence means. Full fidelity only.
  final String? description;

  /// Where it happened. Full fidelity only — knowing something occurred is
  /// not the same as knowing where.
  final StudioElementRef? source;

  /// The relationships the information travelled along. Full fidelity only.
  final List<String> channelRelationshipIds;

  /// Why it happened, taken from the causal trace. Full fidelity only.
  final String? explanation;

  /// Additional data. Full fidelity only.
  final Map<String, Object?> payload;

  bool get isFull => fidelity == StudioObservationFidelity.full;

  /// True when this view deliberately withholds detail.
  bool get isExistenceOnly =>
      fidelity == StudioObservationFidelity.existenceOnly;
}

/// A state value an actor can currently see.
class VisibleStateView {
  const VisibleStateView({
    required this.variableId,
    required this.name,
    required this.owner,
    required this.value,
  });

  final String variableId;
  final String name;
  final StudioElementRef owner;
  final String value;
}

/// What one actor currently knows, observes, and can do.
///
/// Derived entirely from the graph and the run. Nothing here is authored per
/// actor: an Attacker view and an Administrator view come from the same code
/// and differ because the two actors have received different observations.
/// That is what makes the perspectives semantic rather than cosmetic.
class ActorPerspectiveView extends StudioPerspectiveView {
  const ActorPerspectiveView({
    required super.perspectiveId,
    required this.actor,
    required this.actorName,
    required this.actorDescription,
    required this.isRelevant,
    this.goals = const [],
    this.goalsAreKnown = false,
    this.knownElements = const [],
    this.observableElements = const [],
    this.observations = const [],
    this.observedEvents = const [],
    this.visibleState = const [],
    this.availableActions = const [],
    this.performedActionIds = const [],
  });

  final StudioElementRef actor;

  final String actorName;

  final String actorDescription;

  /// Whether this actor is part of the exploration yet.
  ///
  /// An irrelevant actor still has a view — it is simply almost empty, which
  /// is itself the useful statement.
  final bool isRelevant;

  /// What this actor is trying to accomplish, from its declared Goals facet.
  final List<String> goals;

  /// False when the actor's Goals facet is unknown or not applicable, so a
  /// consumer can tell "no goals" from "goals not modelled".
  final bool goalsAreKnown;

  /// Elements this actor has actually learned something about, evidenced by
  /// observations it received.
  final List<StudioElementRef> knownElements;

  /// Elements this actor could learn about, given how the system is
  /// connected. The difference between this and [knownElements] is the space
  /// of what the actor might yet discover.
  final List<StudioElementRef> observableElements;

  /// Raw observations received, for consumers that need the full record.
  final List<StudioObservation> observations;

  /// Occurrences as this actor received them, shaped by fidelity.
  final List<ObservedEventView> observedEvents;

  /// State this actor can currently see.
  final List<VisibleStateView> visibleState;

  /// Actions this actor could take right now.
  final List<StudioActionDefinition> availableActions;

  /// Actions this actor has already taken during the run.
  final List<String> performedActionIds;

  bool get hasObserved => observedEvents.isNotEmpty;

  /// True when this actor knows something it was told rather than something it
  /// did — a useful distinction when explaining why an actor is involved.
  bool get knowsBySecondHand => observedEvents.any(
    (event) => event.basis != StudioObservationBasis.participation,
  );

  /// Event type IDs this actor has observed, in order.
  List<String> get observedEventTypeIds => List<String>.unmodifiable(
    observedEvents.map((event) => event.eventTypeId),
  );
}

/// Declared state variables paired with their current value, for derivation.
///
/// Internal helper kept alongside the view so the perspective and its view
/// speak the same shape.
typedef StateSnapshotEntry = ({StudioStateVariable variable, String value});

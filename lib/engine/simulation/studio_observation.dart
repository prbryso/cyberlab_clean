import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';

/// How much of an occurrence an observer receives.
///
/// Named levels rather than per-field visibility rules. Per-field rules are
/// more expressive and would make authoring intolerable at scale — every event
/// would need a visibility map for every possible observer. Levels say the
/// useful thing cheaply: the attacker knows what they tried, the administrator
/// knows only that something happened.
enum StudioObservationFidelity {
  /// The observer receives the occurrence and everything it carries.
  full,

  /// The observer can tell that something happened, but not the specifics.
  existenceOnly,
}

/// Why an observer could see an occurrence.
enum StudioObservationBasis {
  /// The observer took part in causing it.
  participation,

  /// Information reached the observer along information-bearing
  /// relationships.
  informationFlow,

  /// The observer was explicitly told, along a notification relationship.
  notification,
}

/// A runtime record that one observer perceived one occurrence.
///
/// The counterpart to the authored ObservationCapability facet: a capability
/// says what an element can sense in principle, an observation says what it
/// actually perceived, when, and through what.
///
/// Observations are what make different perspectives genuinely different
/// rather than cosmetically different. The same event produces different
/// observations for different observers, or none at all.
///
/// This file is intentionally free of Flutter dependencies.
class StudioObservation {
  const StudioObservation({
    required this.observer,
    required this.event,
    required this.basis,
    required this.fidelity,
    this.channelRelationshipIds = const [],
    this.distance = 0,
  });

  /// The element that perceived the occurrence.
  final StudioElementRef observer;

  /// What was perceived.
  final StudioEvent event;

  /// Why this observer could perceive it.
  final StudioObservationBasis basis;

  /// How much of it they received.
  final StudioObservationFidelity fidelity;

  /// Relationships the information travelled along, nearest the source first.
  ///
  /// Empty for participation. This is the audit trail for an observation: it
  /// answers "how did they come to know that?" with specific edges rather than
  /// an assertion.
  final List<String> channelRelationshipIds;

  /// Number of relationship hops from the source. Zero for participation.
  final int distance;

  @override
  String toString() {
    return 'StudioObservation($observer sees ${event.typeId} '
        'via ${basis.name}, ${fidelity.name})';
  }
}

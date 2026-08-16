/// A typed relationship between two elements in a system model.
///
/// Relationships allow Systems Studio to connect actors, assets, subsystems,
/// components, interfaces, incidents, failure modes, and external systems.
///
/// Examples:
///
/// - User authenticates through Identity Provider
/// - Credential Store protects Password Hashes
/// - MFA Service mitigates Credential Theft
/// - Phishing Incident affects User Accounts
/// - Network Interface crosses a Trust Boundary
class StudioRelationship {
  const StudioRelationship({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.type,
    required this.label,
    this.description = '',
    this.direction = StudioRelationshipDirection.forward,
    this.strength = StudioRelationshipStrength.normal,
    this.tags = const [],
    this.metadata = const {},
    this.carriedEventTypeIds,
  });

  /// Unique within the parent system.
  final String id;

  /// ID of the originating model element.
  final String sourceId;

  /// ID of the destination model element.
  final String targetId;

  /// Semantic meaning of the relationship.
  final StudioRelationshipType type;

  /// Short text displayed in diagrams or relationship lists.
  final String label;

  /// Longer explanation of the relationship.
  final String description;

  /// How the relationship should be interpreted directionally.
  final StudioRelationshipDirection direction;

  /// Relative importance or influence of the relationship.
  final StudioRelationshipStrength strength;

  /// Search and discovery terms.
  final List<String> tags;

  /// Optional extension data for subject-specific packages.
  ///
  /// The engine should not depend on particular metadata keys.
  final Map<String, Object?> metadata;

  /// Which event types this relationship can carry, when it is restricted.
  ///
  /// A connection being information-bearing says information *can* travel it;
  /// it does not say everything does. A command channel to an MFA service can
  /// carry a challenge without thereby carrying every failure the engine ever
  /// reports, and a notification edge can deliver an alert without delivering
  /// everything its source emits.
  ///
  /// - **null** — unrestricted. Whatever the relationship's information flow
  ///   permits, it carries. This is the default, so a system that says nothing
  ///   behaves exactly as it did before this existed.
  /// - **a list of IDs** — only those event types traverse it.
  /// - **empty** — the relationship carries no modelled event. Legitimate, and
  ///   indistinguishable from an oversight, so validation warns.
  ///
  /// A restriction only ever removes. It cannot make a relationship carry
  /// information its type and direction do not already allow, and it never
  /// downgrades an observation to [StudioObservationFidelity.existenceOnly] —
  /// an event that cannot travel is not observed vaguely, it is not observed.
  ///
  /// On a multi-hop route every relationship must carry the event: a chain is
  /// as permissive as its narrowest link.
  final List<String>? carriedEventTypeIds;

  /// True when this relationship carries [eventTypeId].
  ///
  /// Unrestricted relationships carry everything, which is what makes the
  /// absence of a declaration mean "no opinion" rather than "nothing".
  bool carries(String eventTypeId) {
    final carried = carriedEventTypeIds;

    return carried == null || carried.contains(eventTypeId);
  }

  /// Returns true when [elementId] is either endpoint.
  bool involves(String elementId) {
    return sourceId == elementId || targetId == elementId;
  }

  /// Returns the opposite endpoint from [elementId].
  ///
  /// Returns null if [elementId] is not part of this relationship.
  String? otherEndpoint(String elementId) {
    if (sourceId == elementId) {
      return targetId;
    }

    if (targetId == elementId) {
      return sourceId;
    }

    return null;
  }
}

enum StudioRelationshipType {
  contains,
  participatesIn,
  interactsWith,
  communicatesWith,
  sendsDataTo,
  sendsCommandTo,
  controls,
  monitors,

  /// Delivers a report to someone who was not otherwise watching.
  ///
  /// Distinct from [monitors]: monitoring is watching something, notifying is
  /// telling someone. Without a separate type, "the monitor watches the
  /// engine" and "the monitor tells the administrator" would be the same
  /// statement pointing in opposite directions.
  notifies,

  dependsOn,
  supports,
  protects,
  exposes,
  threatens,
  exploits,
  mitigates,
  detects,
  prevents,
  recovers,
  causes,
  contributesTo,
  propagatesTo,
  affects,
  produces,
  consumes,
  transforms,
  authenticates,
  authorizes,
  verifies,
  stores,
  crossesBoundary,
  relatedTo,
  custom,
}

enum StudioRelationshipDirection {
  /// Source points toward target.
  forward,

  /// Target points toward source.
  reverse,

  /// Both endpoints influence one another.
  bidirectional,

  /// Relationship has no directional meaning.
  undirected,
}

enum StudioRelationshipStrength { weak, normal, strong, critical }

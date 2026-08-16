/// Typed facet channel for Systems Studio graph elements.
///
/// PRODUCT_PRINCIPLES.md states that every node in a system can be understood
/// through five fundamental questions:
///
/// - Actions      — What can this element do?
/// - Goals        — What is this element trying to accomplish?
/// - Observations — What can it sense, watch, or infer?
/// - Events       — What conditions can it detect, generate, or report?
/// - Relationships — What does it depend on, affect, or communicate with?
///
/// Four of those five are *declared* properties of an element and live here.
///
/// Relationships are deliberately absent. A relationship is an edge between
/// two elements, not a value owned by one of them, so it cannot be declared or
/// set to "not applicable" by a single endpoint. Relationships are a *derived*
/// facet: they are computed from the graph through StudioGraphQuery and are
/// always present, though possibly empty.
///
/// This file is intentionally free of Flutter dependencies.
library;

/// Epistemic status of a declared facet.
///
/// This distinction comes directly from PRODUCT_PRINCIPLES.md:
///
/// > null means this concept does not apply to this node.
/// > unknown means it may apply, but we don't currently know the answer.
///
/// [StudioFacetStatus] is an authoring and explanation concept only. It
/// describes what Systems Studio knows about the real world. It must never be
/// used as an input to runtime evaluation logic; a future simulation evaluator
/// operates on simulation state, which is always fully determined.
enum StudioFacetStatus {
  /// The facet has been modelled and a value is available.
  known,

  /// The concept genuinely does not apply to this element.
  ///
  /// This is the "null" of PRODUCT_PRINCIPLES.md, expressed as a status rather
  /// than as an absent value so that it can be distinguished from [unknown].
  notApplicable,

  /// The concept may apply, but Systems Studio does not currently know the
  /// answer.
  ///
  /// Unknown facets are legitimate content. They mark places in a system model
  /// that are worth investigating.
  unknown,
}

/// A single declared facet and its epistemic status.
///
/// A facet is never simply an empty list. An empty list and "we do not know"
/// are different statements about a system, and Systems Studio keeps them
/// distinct.
class StudioFacet<T extends Object> {
  /// The facet has been modelled and carries [value].
  const StudioFacet.known(T value)
    : status = StudioFacetStatus.known,
      _value = value;

  /// The concept does not apply to this element.
  const StudioFacet.notApplicable()
    : status = StudioFacetStatus.notApplicable,
      _value = null;

  /// The concept may apply, but the answer is not currently modelled.
  const StudioFacet.unknown()
    : status = StudioFacetStatus.unknown,
      _value = null;

  final StudioFacetStatus status;

  final T? _value;

  /// The modelled value, or null when the facet is not [StudioFacetStatus.known].
  T? get value => _value;

  bool get isKnown => status == StudioFacetStatus.known;

  bool get isNotApplicable => status == StudioFacetStatus.notApplicable;

  bool get isUnknown => status == StudioFacetStatus.unknown;

  /// Returns the modelled value, or [fallback] when nothing is known.
  T valueOr(T fallback) => _value ?? fallback;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StudioFacet<T> &&
            other.status == status &&
            _facetValuesEqual(other._value, _value);
  }

  @override
  int get hashCode => Object.hash(status, _facetValueHash(_value));

  @override
  String toString() {
    return switch (status) {
      StudioFacetStatus.known => 'StudioFacet.known($_value)',
      StudioFacetStatus.notApplicable => 'StudioFacet.notApplicable()',
      StudioFacetStatus.unknown => 'StudioFacet.unknown()',
    };
  }
}

/// Identifies one of the four declared facets.
///
/// Provided so that presentation, export, and validation can enumerate facets
/// uniformly instead of hard-coding four separate cases each time.
enum StudioFacetKind {
  actions,
  goals,
  observationCapabilities,
  eventTypes;

  /// Short label for display.
  String get label {
    return switch (this) {
      StudioFacetKind.actions => 'Actions',
      StudioFacetKind.goals => 'Goals',
      StudioFacetKind.observationCapabilities => 'Observations',
      StudioFacetKind.eventTypes => 'Events',
    };
  }

  /// The question this facet answers, from PRODUCT_PRINCIPLES.md.
  String get question {
    return switch (this) {
      StudioFacetKind.actions => 'What can this element do?',
      StudioFacetKind.goals => 'What is this element trying to accomplish?',
      StudioFacetKind.observationCapabilities =>
        'What can it sense, watch, or infer?',
      StudioFacetKind.eventTypes =>
        'What conditions can it detect, generate, or report?',
    };
  }
}

/// The four declared facets of a graph element.
///
/// Every facet defaults to [StudioFacetStatus.unknown]. That default is
/// deliberate and honest: when a content package has not described what an
/// element observes, Systems Studio does not know what it observes. It should
/// not claim the element observes nothing.
///
/// A content package states status explicitly:
///
///     StudioNodeFacets(
///       actions: StudioFacet.known(['Validate credentials']),
///       goals: StudioFacet.notApplicable(),
///       observationCapabilities: StudioFacet.unknown(),
///     )
///
/// An empty list is never used to mean "nothing is known". Use
/// [StudioFacet.notApplicable] or [StudioFacet.unknown] instead.
class StudioNodeFacets {
  const StudioNodeFacets({
    this.actions = const StudioFacet<List<String>>.unknown(),
    this.goals = const StudioFacet<List<String>>.unknown(),
    this.observationCapabilities = const StudioFacet<List<String>>.unknown(),
    this.eventTypes = const StudioFacet<List<String>>.unknown(),
  });

  /// All four facets unknown.
  ///
  /// This is the correct starting point for any element whose behaviour has
  /// not yet been described.
  static const StudioNodeFacets unknown = StudioNodeFacets();

  /// What this element can do.
  final StudioFacet<List<String>> actions;

  /// What this element is trying to accomplish.
  final StudioFacet<List<String>> goals;

  /// What this element can sense, watch, or infer.
  ///
  /// This declares *capabilities*, not observations recorded at runtime.
  final StudioFacet<List<String>> observationCapabilities;

  /// What conditions this element can detect, generate, or report.
  ///
  /// This declares *event types*, not event occurrences.
  final StudioFacet<List<String>> eventTypes;

  /// Returns the facet identified by [kind].
  StudioFacet<List<String>> facetFor(StudioFacetKind kind) {
    return switch (kind) {
      StudioFacetKind.actions => actions,
      StudioFacetKind.goals => goals,
      StudioFacetKind.observationCapabilities => observationCapabilities,
      StudioFacetKind.eventTypes => eventTypes,
    };
  }

  /// All four facets in display order, paired with their kind.
  Iterable<MapEntry<StudioFacetKind, StudioFacet<List<String>>>> entries() {
    return StudioFacetKind.values.map(
      (kind) => MapEntry(kind, facetFor(kind)),
    );
  }

  /// True when at least one facet has been modelled.
  bool get hasAnyKnown =>
      actions.isKnown ||
      goals.isKnown ||
      observationCapabilities.isKnown ||
      eventTypes.isKnown;

  /// True when every facet is unknown.
  bool get isEntirelyUnknown =>
      actions.isUnknown &&
      goals.isUnknown &&
      observationCapabilities.isUnknown &&
      eventTypes.isUnknown;

  /// Facets that remain unknown.
  ///
  /// These are the open questions for this element — places in the system
  /// model worth investigating.
  Iterable<StudioFacetKind> unknownFacets() {
    return StudioFacetKind.values.where((kind) => facetFor(kind).isUnknown);
  }

  StudioNodeFacets copyWith({
    StudioFacet<List<String>>? actions,
    StudioFacet<List<String>>? goals,
    StudioFacet<List<String>>? observationCapabilities,
    StudioFacet<List<String>>? eventTypes,
  }) {
    return StudioNodeFacets(
      actions: actions ?? this.actions,
      goals: goals ?? this.goals,
      observationCapabilities:
          observationCapabilities ?? this.observationCapabilities,
      eventTypes: eventTypes ?? this.eventTypes,
    );
  }

  /// Every modelled facet value, for search indexing.
  Iterable<String> knownValues() sync* {
    for (final entry in entries()) {
      final value = entry.value.value;

      if (value != null) {
        yield* value;
      }
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StudioNodeFacets &&
            other.actions == actions &&
            other.goals == goals &&
            other.observationCapabilities == observationCapabilities &&
            other.eventTypes == eventTypes;
  }

  @override
  int get hashCode =>
      Object.hash(actions, goals, observationCapabilities, eventTypes);
}

bool _facetValuesEqual(Object? left, Object? right) {
  if (identical(left, right)) {
    return true;
  }

  if (left is List && right is List) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }

  return left == right;
}

int _facetValueHash(Object? value) {
  if (value is List) {
    return Object.hashAll(value);
  }

  return value.hashCode;
}

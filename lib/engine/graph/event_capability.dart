import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_event_type.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// What an element can do with events, derived from typed declarations.
///
/// The Events facet used to be prose an author wrote separately from the
/// `StudioEventType` declarations and the behaviours that emit and react to
/// them. Two sources of the same truth drift, and prose cannot be validated,
/// simulated, or reasoned about. Typed declarations are authoritative; this is
/// how the learner-facing view is obtained from them.
///
/// The three questions stay separate rather than collapsing into one list,
/// because they are genuinely different things to know about an element:
///
/// - **generates** — occurrences it causes;
/// - **detects** — occurrences it demonstrably reacts to;
/// - **reports** — occurrences it deliberately tells someone else about.
///
/// A monitor detects failures, generates alerts, and reports those alerts. An
/// engine generates failures and detects attempts but reports nothing. Flatten
/// those and the difference between watching, acting, and telling disappears.
///
/// This file is intentionally free of Flutter dependencies.
class StudioEventCapability {
  const StudioEventCapability({
    this.generates = const [],
    this.detects = const [],
    this.reports = const [],
  });

  static const StudioEventCapability none = StudioEventCapability();

  /// Event types this element causes to occur.
  final List<StudioEventType> generates;

  /// Event types this element reacts to.
  final List<StudioEventType> detects;

  /// Event types this element delivers to someone along a notification.
  ///
  /// A subset of [generates]: you can only report what you produce.
  final List<StudioEventType> reports;

  bool get isEmpty =>
      generates.isEmpty && detects.isEmpty && reports.isEmpty;

  bool get isNotEmpty => !isEmpty;
}

/// Derives event capability for every element of a graph.
///
/// Computed once per graph, like the observability index, because it depends
/// only on declarations and the graph is immutable.
class StudioEventCapabilityIndex {
  StudioEventCapabilityIndex._(this._byElement);

  final Map<StudioElementRef, StudioEventCapability> _byElement;

  factory StudioEventCapabilityIndex.forGraph(StudioSystemGraph graph) {
    final generates = <StudioElementRef, Set<String>>{};
    final detects = <StudioElementRef, Set<String>>{};
    final reports = <StudioElementRef, Set<String>>{};

    void add(
      Map<StudioElementRef, Set<String>> into,
      StudioElementRef element,
      String eventTypeId,
    ) {
      into.putIfAbsent(element, () => <String>{}).add(eventTypeId);
    }

    void add2(
      Map<StudioElementRef, Set<String>> into,
      StudioElementRef element,
      Set<String> eventTypeIds,
    ) {
      into.putIfAbsent(element, () => <String>{}).addAll(eventTypeIds);
    }

    // An action's occurrences are sourced at its target, so the target is what
    // generates them. The initiator chose to act; the target is where it
    // happened.
    for (final action in graph.actionDefinitions) {
      for (final outcome in [...action.outcomes, action.otherwise]) {
        for (final eventTypeId in outcome.emits) {
          add(generates, action.target, eventTypeId);
        }
      }
    }

    for (final behavior in graph.behaviorDefinitions) {
      add(detects, behavior.owner, behavior.trigger);

      for (final outcome in [...behavior.outcomes, behavior.otherwise]) {
        for (final eventTypeId in outcome.emits) {
          add(generates, behavior.owner, eventTypeId);
        }
      }
    }

    // Reporting is generating plus a deliberate channel to someone else.
    for (final relationship in graph.relationships) {
      if (relationship.type != StudioRelationshipType.notifies) {
        continue;
      }

      final reporter = StudioElementRef.node(relationship.sourceId);

      for (final eventTypeId in generates[reporter] ?? const <String>{}) {
        add(reports, reporter, eventTypeId);
      }
    }

    // A containing element does what its parts do. Rolling capability up the
    // hierarchy is why a subsystem or the system itself needs no separately
    // authored prose about events: what it can generate, detect and report is
    // exactly what its parts can.
    void rollUp(Map<StudioElementRef, Set<String>> source) {
      for (final entry in Map<StudioElementRef, Set<String>>.from(source).entries) {
        if (!entry.key.isNode) {
          continue;
        }

        var parentId = graph.nodeById(entry.key.id)?.parentId;

        final guard = <String>{entry.key.id};

        while (parentId != null && guard.add(parentId)) {
          add2(source, StudioElementRef.node(parentId), entry.value);

          parentId = graph.nodeById(parentId)?.parentId;
        }
      }
    }

    rollUp(generates);
    rollUp(detects);
    rollUp(reports);

    StudioEventType? resolve(String id) => graph.eventTypeById(id);

    List<StudioEventType> typesFor(
      Map<StudioElementRef, Set<String>> source,
      StudioElementRef element,
    ) {
      final ids = (source[element] ?? const <String>{}).toList()..sort();

      return List<StudioEventType>.unmodifiable(
        ids.map(resolve).whereType<StudioEventType>(),
      );
    }

    final elements = <StudioElementRef>{
      ...generates.keys,
      ...detects.keys,
      ...reports.keys,
    };

    return StudioEventCapabilityIndex._({
      for (final element in elements)
        element: StudioEventCapability(
          generates: typesFor(generates, element),
          detects: typesFor(detects, element),
          reports: typesFor(reports, element),
        ),
    });
  }

  /// Capability of [element]. Never null — an element with no typed event
  /// involvement simply has an empty capability.
  StudioEventCapability capabilityFor(StudioElementRef element) {
    return _byElement[element] ?? StudioEventCapability.none;
  }

  /// True when [element] has any typed event involvement at all.
  ///
  /// A display surface uses this to decide whether the derived view has
  /// anything to say, and falls back to authored prose when it does not.
  bool hasCapability(StudioElementRef element) {
    return _byElement.containsKey(element);
  }

  /// Every element with typed event involvement.
  Iterable<StudioElementRef> get elements => _byElement.keys;
}

import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';

/// Whether the architecture declares anything that carries a causal step.
enum StudioOverlayCarrier {
  /// One or more declared relationships carry this step, and can be
  /// highlighted in place on the architecture.
  declaredRelationship,

  /// Something happened between two elements that no declared relationship
  /// connects.
  ///
  /// This is shown rather than hidden. An action may name a target the
  /// architecture never said it could reach, and quietly drawing it as though
  /// a relationship existed would invent architecture that was never authored.
  undeclared,
}

/// One occurrence from the run, placed onto the architecture.
///
/// A step is the causal link plus the answer to "which part of the drawn
/// system carried this?". It adds no meaning of its own.
class StudioOverlayStep {
  const StudioOverlayStep({
    required this.sequence,
    required this.from,
    required this.to,
    required this.kind,
    required this.label,
    this.relationshipIds = const [],
    this.observers = const [],
    this.stateChanges = const [],
    this.eventTypeId,
  });

  /// Causal order within the run, zero-based, matching the causal record.
  final int sequence;

  /// What a learner is shown, counting from one.
  int get position => sequence + 1;

  final StudioElementRef from;
  final StudioElementRef to;

  final StudioCausalLinkKind kind;

  final String label;

  /// Declared relationships that carried this step, nearest the source first.
  final List<String> relationshipIds;

  /// Every element that observed the underlying occurrence.
  final List<StudioElementRef> observers;

  /// Runtime state changes this step caused.
  final List<StudioStateChange> stateChanges;

  final String? eventTypeId;

  StudioOverlayCarrier get carrier => relationshipIds.isEmpty
      ? StudioOverlayCarrier.undeclared
      : StudioOverlayCarrier.declaredRelationship;

  bool get isCarriedByArchitecture =>
      carrier == StudioOverlayCarrier.declaredRelationship;

  bool wasObservedBy(StudioElementRef observer) => observers.contains(observer);
}

/// What a run did to one state variable at one element, as a whole.
///
/// A variable can move several times during a run: the login interface goes
/// Idle, then Collecting credentials, then Access denied. Each of those
/// transitions is a separate occurrence and the causal record keeps every one
/// of them, with the step that caused it.
///
/// An element on the architecture map is not the place to re-tell that. The
/// map answers "what did this run do here?", which is a span — where the
/// element started and where it ended up. "Why did it move?" is a question
/// about occurrences, and the causal record answers it step by step. Summing
/// up here rather than listing keeps one question to one surface.
///
/// [changeCount] is carried so the summary can say it is a summary. A span
/// shown without it would read as a single transition.
///
/// **Not the same thing as StudioSituationDifference**, and the two must not
/// be merged. This is *history*: what the run did to a variable, spanning from
/// where the run first found it to where it left it, and it exists only for
/// variables the run actually touched. A difference is *the present*: how the
/// current value compares with where the situation began, which exists for a
/// variable a scenario set and nothing moved, and does not exist for a
/// variable that moved and came back. They answer "what happened here?" and
/// "what is true here?" respectively, and a node needs both.
class StudioOverlayStateSummary {
  const StudioOverlayStateSummary({
    required this.variableId,
    required this.owner,
    required this.initialValue,
    required this.currentValue,
    required this.changeCount,
  });

  final String variableId;

  final StudioElementRef owner;

  /// The value before the run's first change to this variable.
  final String initialValue;

  /// The value after the run's most recent change to it.
  final String currentValue;

  /// How many times it actually moved.
  final int changeCount;

  bool get changedMoreThanOnce => changeCount > 1;

  /// True when the run moved this variable and left it where it began.
  ///
  /// Worth distinguishing: the span alone would look like nothing happened,
  /// and something did.
  bool get returnedToStart => initialValue == currentValue;
}

/// The current run, expressed as something that can be drawn on top of the
/// architecture graph.
///
/// This is an **overlay**, not a replacement. It never edits the graph, never
/// adds elements to it, and never changes what a relationship means. It says
/// which existing elements took part, which existing relationships carried
/// what, and in what order — so the architecture can answer "what just
/// happened here?" without ceasing to answer "how is this built?".
///
/// The reveal sets exist because a causal chain routinely crosses hierarchy
/// levels. Requiring a learner to guess which subsystems to expand before the
/// chain becomes visible would hide the very thing they came to see.
///
/// This file is intentionally free of Flutter dependencies.
class SimulationGraphOverlay {
  const SimulationGraphOverlay({
    required this.steps,
    required this.involvedNodeIds,
    required this.revealNodeIds,
    required this.expandNodeIds,
    required this.firstSequenceByNodeId,
    required this.stateByNodeId,
  });

  static const SimulationGraphOverlay empty = SimulationGraphOverlay(
    steps: [],
    involvedNodeIds: {},
    revealNodeIds: {},
    expandNodeIds: {},
    firstSequenceByNodeId: {},
    stateByNodeId: {},
  );

  /// Occurrences in causal order.
  final List<StudioOverlayStep> steps;

  /// Elements that took part in the run.
  final Set<String> involvedNodeIds;

  /// Every node that must be present for the chain to be followable:
  /// the participants and the ancestors that contain them.
  final Set<String> revealNodeIds;

  /// Ancestors that must be expanded for the participants to be drawn.
  ///
  /// Participants themselves are absent — being shown does not require being
  /// opened, and force-opening a participant would expand parts of the system
  /// that had nothing to do with the run.
  final Set<String> expandNodeIds;

  /// When each participant first took part.
  final Map<String, int> firstSequenceByNodeId;

  /// What the run did to each participant's state, one entry per variable.
  ///
  /// Summarised rather than listed. A variable that moved several times has
  /// one entry here and every individual transition in the causal record.
  final Map<String, List<StudioOverlayStateSummary>> stateByNodeId;

  bool get isEmpty => steps.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool involves(String nodeId) => involvedNodeIds.contains(nodeId);

  int? firstSequenceFor(String nodeId) => firstSequenceByNodeId[nodeId];

  /// What the run did to [nodeId]'s state, one entry per variable.
  List<StudioOverlayStateSummary> stateFor(String nodeId) =>
      stateByNodeId[nodeId] ?? const [];

  /// Steps carried by [relationshipId], in causal order.
  List<StudioOverlayStep> stepsFor(String relationshipId) {
    return List<StudioOverlayStep>.unmodifiable(
      steps.where((step) => step.relationshipIds.contains(relationshipId)),
    );
  }

  /// Relationships that carried any part of the run.
  Set<String> get carryingRelationshipIds {
    return {
      for (final step in steps) ...step.relationshipIds,
    };
  }

  /// Steps that happened between elements no relationship connects.
  List<StudioOverlayStep> get undeclaredSteps {
    return List<StudioOverlayStep>.unmodifiable(
      steps.where((step) => !step.isCarriedByArchitecture),
    );
  }

  /// Steps [observer] actually perceived.
  ///
  /// Used to mark a selected actor's knowledge on top of the run. It never
  /// removes anything: the overlay shows what happened, and marking is a
  /// second layer over that, not a filter on it.
  List<StudioOverlayStep> stepsObservedBy(StudioElementRef observer) {
    return List<StudioOverlayStep>.unmodifiable(
      steps.where((step) => step.wasObservedBy(observer)),
    );
  }

  /// Adds whatever the run needs to a focused view of [graph], and nothing
  /// else.
  ///
  /// Focus is an architecture question — "show me around here" — and it keeps
  /// answering that. A run adds a second requirement: the chain has to be
  /// followable end to end, even where it leaves the neighbourhood the learner
  /// is standing in. So this is a union. Nothing the focus chose is dropped,
  /// and the graph itself is never modified.
  StudioSystemGraph revealWithin(
    StudioSystemGraph graph,
    StudioSystemGraph focused,
  ) {
    if (isEmpty) {
      return focused;
    }

    final nodeIds = <String>{
      for (final node in focused.nodes) node.id,
      ...revealNodeIds,
    };

    final keptRelationshipIds = <String>{
      for (final relationship in focused.relationships) relationship.id,
      ...carryingRelationshipIds,
    };

    return StudioSystemGraph(
      systemId: graph.systemId,
      nodes: List<StudioGraphNode>.unmodifiable([
        for (final node in graph.nodes)
          if (nodeIds.contains(node.id)) node,
      ]),
      relationships: List<StudioRelationship>.unmodifiable([
        for (final relationship in graph.relationships)
          if (nodeIds.contains(relationship.sourceId) &&
              nodeIds.contains(relationship.targetId) &&
              // Containment is what makes a revealed element readable as part
              // of something, so it travels with the elements it joins.
              (keptRelationshipIds.contains(relationship.id) ||
                  relationship.type == StudioRelationshipType.contains))
            relationship,
      ]),
      perspectiveDefinitions: graph.perspectiveDefinitions,
      stateVariables: graph.stateVariables,
      eventTypes: graph.eventTypes,
      actionDefinitions: graph.actionDefinitions,
      behaviorDefinitions: graph.behaviorDefinitions,
    );
  }

  /// Derives the overlay for [run].
  factory SimulationGraphOverlay.fromRun(SimulationRun run) {
    return SimulationGraphOverlay.fromCausalGraph(
      SimulationCausalGraph.fromRun(run),
      run,
    );
  }

  /// Derives the overlay from an already-computed causal record.
  ///
  /// The causal record is the source of truth for what happened and in what
  /// order. This adds only the mapping onto drawn architecture.
  factory SimulationGraphOverlay.fromCausalGraph(
    SimulationCausalGraph causal,
    SimulationRun run,
  ) {
    if (causal.isEmpty) {
      return SimulationGraphOverlay.empty;
    }

    final graph = run.graph;

    final steps = <StudioOverlayStep>[
      for (final link in causal.links)
        StudioOverlayStep(
          sequence: link.sequence,
          from: link.from,
          to: link.to,
          kind: link.kind,
          label: link.label,
          relationshipIds: _carriersFor(run, link),
          observers: link.observers,
          stateChanges: link.stateChanges,
          eventTypeId: link.eventTypeId,
        ),
    ];

    final involved = <String>{};
    final firstSequence = <String, int>{};

    void note(StudioElementRef element, int sequence) {
      if (!element.isNode) {
        return;
      }

      involved.add(element.id);
      firstSequence.putIfAbsent(element.id, () => sequence);
    }

    for (final step in steps) {
      note(step.from, step.sequence);
      note(step.to, step.sequence);
    }

    // Containing elements are revealed so a participant can be drawn at all,
    // but they did not take part and are not counted as participants.
    final reveal = <String>{...involved};
    final expand = <String>{};

    for (final nodeId in involved) {
      for (final ancestorId in _ancestorsOf(graph, nodeId)) {
        reveal.add(ancestorId);
        expand.add(ancestorId);
      }
    }

    final state = <String, List<StudioOverlayStateSummary>>{
      for (final node in causal.nodes)
        if (node.element.isNode && node.stateChanges.isNotEmpty)
          node.element.id: _summarise(node.stateChanges),
    };

    return SimulationGraphOverlay(
      steps: List<StudioOverlayStep>.unmodifiable(steps),
      involvedNodeIds: Set<String>.unmodifiable(involved),
      revealNodeIds: Set<String>.unmodifiable(reveal),
      expandNodeIds: Set<String>.unmodifiable(expand),
      firstSequenceByNodeId: Map<String, int>.unmodifiable(firstSequence),
      stateByNodeId: Map<String, List<StudioOverlayStateSummary>>.unmodifiable(
        state,
      ),
    );
  }

  /// Reduces a participant's transitions to one entry per variable.
  ///
  /// [changes] arrives oldest first, so the first entry for a variable holds
  /// where the run found it and the last holds where the run left it.
  /// Variables keep the order in which the run first touched them, which is
  /// the order the chain reached them in.
  static List<StudioOverlayStateSummary> _summarise(
    List<StudioStateChange> changes,
  ) {
    final byVariable = <String, List<StudioStateChange>>{};

    for (final change in changes) {
      byVariable.putIfAbsent(change.variableId, () => []).add(change);
    }

    return List<StudioOverlayStateSummary>.unmodifiable([
      for (final entry in byVariable.entries)
        StudioOverlayStateSummary(
          variableId: entry.key,
          owner: entry.value.first.owner,
          initialValue: entry.value.first.previousValue,
          currentValue: entry.value.last.newValue,
          changeCount: entry.value.length,
        ),
    ]);
  }

  /// Which declared relationships carried [link].
  ///
  /// Preference order matters. An observation already knows the exact edges
  /// information travelled along, and that record is better than anything
  /// inferred from the shape of the graph. Only when nothing recorded a route
  /// is the architecture searched for a relationship joining the two ends, and
  /// only then can the answer legitimately be "none".
  static List<String> _carriersFor(SimulationRun run, StudioCausalLink link) {
    if (link.channelRelationshipIds.isNotEmpty) {
      return List<String>.unmodifiable(link.channelRelationshipIds);
    }

    final eventSequence = link.eventSequence;

    if (eventSequence != null) {
      for (final observation in run.observations) {
        if (observation.event.sequence == eventSequence &&
            observation.observer == link.to &&
            observation.channelRelationshipIds.isNotEmpty) {
          return List<String>.unmodifiable(observation.channelRelationshipIds);
        }
      }
    }

    // A chosen action names its target directly and travels no route, so the
    // only question is whether the architecture connects the two at all.
    // Containment is excluded: being inside something is not a way of acting
    // on it.
    return List<String>.unmodifiable([
      for (final relationship in run.graph.relationships)
        if (relationship.type != StudioRelationshipType.contains &&
            relationship.involves(link.from.id) &&
            relationship.involves(link.to.id))
          relationship.id,
    ]);
  }

  /// Ancestor node IDs of [nodeId], nearest first.
  static List<String> _ancestorsOf(StudioSystemGraph graph, String nodeId) {
    final ancestors = <String>[];
    final seen = <String>{nodeId};

    var current = graph.nodeById(nodeId)?.parentId;

    while (current != null && seen.add(current)) {
      ancestors.add(current);
      current = graph.nodeById(current)?.parentId;
    }

    return ancestors;
  }
}

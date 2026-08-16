import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';

/// What kind of occurrence connects two elements.
enum StudioCausalLinkKind {
  /// An actor chose to do something.
  chosenAction,

  /// An element responded on its own because something happened.
  automaticBehavior,

  /// Information reached a participant.
  observation,
}

/// One element as it took part in what happened.
///
/// A causal node is not a new kind of thing. It refers to a real system
/// element by its [StudioElementRef], so selecting it in the causal view means
/// selecting the same element the rest of Systems Studio talks about. Nothing
/// here is a pseudo-element invented for the simulation.
class StudioCausalNode {
  const StudioCausalNode({
    required this.element,
    required this.label,
    required this.type,
    required this.firstSequence,
    this.becameInvolvedByObservation = false,
    this.hasActed = false,
    this.stateChanges = const [],
  });

  /// The real system element this node stands for.
  final StudioElementRef element;

  final String label;

  final StudioGraphNodeType type;

  /// Position of the earliest occurrence involving this element.
  final int firstSequence;

  /// True when this participant entered the run because something reached
  /// them, rather than because they were already present.
  ///
  /// Involvement is not action. A participant may become involved and do
  /// nothing at all.
  final bool becameInvolvedByObservation;

  /// True when this element chose an action during the run.
  final bool hasActed;

  /// Runtime state changes at this element, oldest first.
  ///
  /// Only values that actually changed during the run. Declared starting
  /// values are not changes and do not appear here.
  final List<StudioStateChange> stateChanges;

  bool get isActor => type == StudioGraphNodeType.actor;
}

/// One occurrence connecting two elements.
///
/// The node is the element; the link is the occurrence. Keeping them apart is
/// the difference between "this exists" and "this happened".
class StudioCausalLink {
  const StudioCausalLink({
    required this.sequence,
    required this.from,
    required this.to,
    required this.kind,
    required this.label,
    this.traceEntrySequence,
    this.eventSequence,
    this.eventTypeId,
    this.explanation,
    this.guidingQuestion,
    this.channelRelationshipIds = const [],
    this.stateChanges = const [],
    this.observers = const [],
  });

  /// Causal order within the run.
  final int sequence;

  final StudioElementRef from;
  final StudioElementRef to;

  final StudioCausalLinkKind kind;

  /// What to call this occurrence: the action's name, or the event's name.
  final String label;

  /// The trace entry this came from, so the detailed explanation can be found.
  final int? traceEntrySequence;

  /// The occurrence involved, when there was one.
  final int? eventSequence;
  final String? eventTypeId;

  final String? explanation;
  final String? guidingQuestion;

  /// For an observation, the relationships the information travelled along.
  final List<String> channelRelationshipIds;

  /// Runtime state changes caused by this occurrence.
  final List<StudioStateChange> stateChanges;

  /// Every element that observed the underlying occurrence.
  ///
  /// Used to show which parts of what happened a selected participant
  /// actually witnessed. It never restricts the graph — the causal record is
  /// system truth and stays complete.
  final List<StudioElementRef> observers;

  bool get isChosen => kind == StudioCausalLinkKind.chosenAction;
}

/// What happened during a run, in causal order.
///
/// Generated entirely from the run: its trace, the occurrences it produced,
/// and the observations those occurrences caused. No part of it is authored,
/// and there is no second description of the system to keep in step.
///
/// This answers a different question from the architecture graph. Architecture
/// says how a system is built; this says what took place in it and why. They
/// are deliberately separate views, because merging them would force one graph
/// to answer two questions and do neither well.
///
/// Everything needed to explain a chain is present from the moment it is
/// derived. Nothing has to be expanded to be discovered.
///
/// This file is intentionally free of Flutter dependencies.
class SimulationCausalGraph {
  const SimulationCausalGraph({required this.nodes, required this.links});

  static const SimulationCausalGraph empty = SimulationCausalGraph(
    nodes: [],
    links: [],
  );

  /// Elements that took part, ordered by when they first did.
  final List<StudioCausalNode> nodes;

  /// Occurrences connecting them, in causal order.
  final List<StudioCausalLink> links;

  bool get isEmpty => links.isEmpty;

  bool get isNotEmpty => !isEmpty;

  StudioCausalNode? nodeFor(StudioElementRef element) {
    for (final node in nodes) {
      if (node.element == element) {
        return node;
      }
    }

    return null;
  }

  /// Links whose occurrence [observer] actually perceived.
  List<StudioCausalLink> linksObservedBy(StudioElementRef observer) {
    return List<StudioCausalLink>.unmodifiable(
      links.where((link) => link.observers.contains(observer)),
    );
  }

  /// Derives the causal record of [run].
  ///
  /// Walks the trace in order. Each entry contributes the occurrence that
  /// produced it; each occurrence that reached a participant who was not part
  /// of causing it contributes an observation link.
  factory SimulationCausalGraph.fromRun(SimulationRun run) {
    final graph = run.graph;

    if (run.trace.isEmpty) {
      return SimulationCausalGraph.empty;
    }

    final links = <StudioCausalLink>[];

    var sequence = 0;

    String elementLabel(StudioElementRef ref) =>
        graph.labelForElement(ref) ?? ref.id;

    String eventLabel(String typeId) =>
        graph.eventTypeById(typeId)?.name ?? typeId;

    List<StudioElementRef> observersOf(int eventSequence) {
      return List<StudioElementRef>.unmodifiable(
        run.observations
            .where(
              (observation) => observation.event.sequence == eventSequence,
            )
            .map((observation) => observation.observer),
      );
    }

    for (final entry in run.trace) {
      final trigger = entry.triggeringEvent;

      if (entry.kind == StudioTraceCauseKind.action) {
        // An actor chose to act on something. The link runs from whoever
        // chose it to whatever they acted upon.
        links.add(
          StudioCausalLink(
            sequence: sequence++,
            from: entry.subject,
            to: entry.target ?? entry.subject,
            kind: StudioCausalLinkKind.chosenAction,
            label: entry.definitionName,
            traceEntrySequence: entry.sequence,
            explanation: _orNull(entry.explanation),
            guidingQuestion: _orNull(entry.guidingQuestion),
            stateChanges: entry.stateChanges,
          ),
        );
      } else if (trigger != null) {
        // An element responded to something that happened elsewhere. The link
        // runs from where that occurrence happened to whatever responded, and
        // is named after the occurrence rather than the response, because the
        // occurrence is what travelled between them.
        links.add(
          StudioCausalLink(
            sequence: sequence++,
            from: trigger.source,
            to: entry.subject,
            kind: StudioCausalLinkKind.automaticBehavior,
            label: eventLabel(trigger.typeId),
            traceEntrySequence: entry.sequence,
            eventSequence: trigger.sequence,
            eventTypeId: trigger.typeId,
            explanation: _orNull(entry.explanation),
            guidingQuestion: _orNull(entry.guidingQuestion),
            stateChanges: entry.stateChanges,
            observers: observersOf(trigger.sequence),
          ),
        );
      }

      // Occurrences this step produced may have reached participants who had
      // no hand in causing them. That is how someone becomes involved.
      for (final event in entry.emittedEvents) {
        for (final observation in run.observations) {
          if (observation.event.sequence != event.sequence) {
            continue;
          }

          if (observation.basis == StudioObservationBasis.participation) {
            // Taking part is not the same as being told, and the step that
            // caused the occurrence already appears above.
            continue;
          }

          final observer = observation.observer;

          if (!observer.isNode) {
            continue;
          }

          // A responding element already has its own link, named after this
          // same occurrence. Adding an observation link too would say the
          // same thing twice.
          final alreadyResponded = run.trace.any(
            (candidate) =>
                candidate.subject == observer &&
                candidate.triggeringEvent?.sequence == event.sequence,
          );

          if (alreadyResponded) {
            continue;
          }

          links.add(
            StudioCausalLink(
              sequence: sequence++,
              from: event.source,
              to: observer,
              kind: StudioCausalLinkKind.observation,
              label: eventLabel(event.typeId),
              traceEntrySequence: entry.sequence,
              eventSequence: event.sequence,
              eventTypeId: event.typeId,
              channelRelationshipIds: observation.channelRelationshipIds,
              observers: observersOf(event.sequence),
            ),
          );
        }
      }
    }

    return SimulationCausalGraph(
      nodes: _nodesFor(run, links, elementLabel),
      links: List<StudioCausalLink>.unmodifiable(links),
    );
  }

  static List<StudioCausalNode> _nodesFor(
    SimulationRun run,
    List<StudioCausalLink> links,
    String Function(StudioElementRef) label,
  ) {
    final firstSeen = <StudioElementRef, int>{};

    for (final link in links) {
      firstSeen.putIfAbsent(link.from, () => link.sequence);
      firstSeen.putIfAbsent(link.to, () => link.sequence);
    }

    final acted = <StudioElementRef>{
      for (final entry in run.trace)
        if (entry.kind == StudioTraceCauseKind.action) entry.subject,
    };

    final involvedByObservation = <StudioElementRef>{
      for (final link in links)
        if (link.kind == StudioCausalLinkKind.observation) link.to,
    };

    final changesByOwner = <StudioElementRef, List<StudioStateChange>>{};

    for (final entry in run.trace) {
      for (final change in entry.stateChanges) {
        changesByOwner.putIfAbsent(change.owner, () => []).add(change);
      }
    }

    final nodes = firstSeen.entries.map((entry) {
      final element = entry.key;
      final node = run.graph.nodeById(element.id);

      return StudioCausalNode(
        element: element,
        label: label(element),
        type: node?.type ?? StudioGraphNodeType.custom,
        firstSequence: entry.value,
        becameInvolvedByObservation: involvedByObservation.contains(element),
        hasActed: acted.contains(element),
        stateChanges: List<StudioStateChange>.unmodifiable(
          changesByOwner[element] ?? const [],
        ),
      );
    }).toList()..sort((left, right) {
      final byOrder = left.firstSequence.compareTo(right.firstSequence);

      return byOrder != 0 ? byOrder : left.label.compareTo(right.label);
    });

    return List<StudioCausalNode>.unmodifiable(nodes);
  }

  static String? _orNull(String value) =>
      value.trim().isEmpty ? null : value;
}

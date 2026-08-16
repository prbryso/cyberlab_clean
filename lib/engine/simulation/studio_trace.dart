import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_state_variable.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';

/// What kind of thing produced a trace entry.
enum StudioTraceCauseKind {
  /// An actor chose an action.
  action,

  /// An element responded to an occurrence.
  behavior,
}

/// Why a run stopped.
enum StudioTraceTermination {
  /// Nothing further was triggered. The normal ending.
  quiescence,

  /// The propagation depth limit was reached.
  depthLimit,

  /// The trace entry limit was reached.
  entryLimit,

  /// The action's precondition did not hold, so it never ran.
  preconditionNotMet,
}

/// One state value changing during a run.
///
/// Records both sides of the change, so an entry can say what a value was as
/// well as what it became. Without the previous value a trace can show that
/// something changed but not what changed about it.
class StudioStateChange {
  const StudioStateChange({
    required this.variableId,
    required this.owner,
    required this.previousValue,
    required this.newValue,
  });

  final String variableId;
  final StudioElementRef owner;
  final String previousValue;
  final String newValue;

  /// Key of the state slot this change affected.
  StudioStateKey get key =>
      StudioStateKey(owner: owner, variableId: variableId);

  @override
  String toString() => '$variableId: $previousValue -> $newValue';
}

/// One step in the causal chain of a run.
///
/// A trace entry exists to answer a single question: **why did this happen?**
/// Every field is there to support an answer.
///
/// - [triggeringEvent] says what caused this step. Null only for the action
///   the learner chose, which is where every chain begins.
/// - [outcomeIndex] and [usedOtherwise] say which result was selected and why
///   the others were not.
/// - [stateChanges] say what actually changed, on both sides.
/// - [emittedEvents] say what this step caused in turn, linking to the next
///   entries in the chain.
///
/// A trace entry is generated, never authored. It is not a SimulationStep: no
/// one wrote it in advance, it carries no narration script, and it says
/// nothing about what to show next.
class StudioTraceEntry {
  const StudioTraceEntry({
    required this.sequence,
    required this.depth,
    required this.kind,
    required this.definitionId,
    required this.definitionName,
    required this.subject,
    required this.outcomeIndex,
    required this.usedOtherwise,
    this.target,
    this.triggeringEvent,
    this.stateChanges = const [],
    this.emittedEvents = const [],
    this.explanation = '',
    this.guidingQuestion = '',
  });

  /// Position in the run, starting at zero.
  final int sequence;

  /// How far this step is from the chosen action.
  ///
  /// The action is depth zero; behaviours it triggers are depth one; and so on.
  final int depth;

  final StudioTraceCauseKind kind;

  /// ID of the action or behaviour definition that ran.
  final String definitionId;

  final String definitionName;

  /// The actor for an action, or the owning element for a behaviour.
  final StudioElementRef subject;

  /// What the action was taken against. Null for behaviours.
  final StudioElementRef? target;

  /// The occurrence that caused this step.
  ///
  /// Null for the chosen action, which is the root of the chain.
  final StudioEvent? triggeringEvent;

  /// Index of the selected outcome, or -1 when the fallback was used.
  final int outcomeIndex;

  /// True when no candidate outcome matched and the fallback ran.
  final bool usedOtherwise;

  final List<StudioStateChange> stateChanges;

  final List<StudioEvent> emittedEvents;

  final String explanation;

  final String guidingQuestion;

  @override
  String toString() {
    final cause = triggeringEvent == null
        ? 'chosen'
        : 'caused by ${triggeringEvent!.typeId}';

    return '#$sequence d$depth ${kind.name} $definitionId ($cause)';
  }
}

/// The generated causal record of one run.
///
/// A trace is produced by execution. Authors do not write it, and it contains
/// no sequencing instructions — no next step, next screen, or route. It is the
/// Flow of the conceptual model: the shape a run took, discovered rather than
/// scripted.
class StudioTrace {
  const StudioTrace({
    required this.entries,
    required this.termination,
    this.notes = const [],
  });

  /// Steps in the order they occurred.
  final List<StudioTraceEntry> entries;

  /// Why the run stopped.
  final StudioTraceTermination termination;

  /// Engine remarks, such as a safeguard having been reached.
  final List<String> notes;

  bool get isEmpty => entries.isEmpty;

  /// Every occurrence produced during the run, in order.
  List<StudioEvent> get allEvents {
    return List<StudioEvent>.unmodifiable([
      for (final entry in entries) ...entry.emittedEvents,
    ]);
  }

  /// Every state change made during the run, in order.
  List<StudioStateChange> get allStateChanges {
    return List<StudioStateChange>.unmodifiable([
      for (final entry in entries) ...entry.stateChanges,
    ]);
  }

  /// The entry that emitted [event], or null when nothing did.
  ///
  /// This is the direct answer to "why did this event happen?".
  StudioTraceEntry? entryThatEmitted(StudioEvent event) {
    for (final entry in entries) {
      for (final emitted in entry.emittedEvents) {
        if (emitted.sequence == event.sequence) {
          return entry;
        }
      }
    }

    return null;
  }

  /// The chain of steps leading to [entry], oldest first.
  ///
  /// Walks backwards from the entry through the event that triggered it, to
  /// the step that emitted that event, and so on to the chosen action. This is
  /// how a learner or an author asks "why did this happen?" and receives a
  /// complete answer rather than a single step.
  List<StudioTraceEntry> causalChainTo(StudioTraceEntry entry) {
    final chain = <StudioTraceEntry>[entry];

    var current = entry;

    while (current.triggeringEvent != null) {
      final cause = entryThatEmitted(current.triggeringEvent!);

      if (cause == null || chain.contains(cause)) {
        break;
      }

      chain.insert(0, cause);
      current = cause;
    }

    return List<StudioTraceEntry>.unmodifiable(chain);
  }
}

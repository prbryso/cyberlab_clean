import 'package:systems_studio/engine/models/studio_element_ref.dart';

/// A concrete occurrence during a run.
///
/// The runtime counterpart of StudioEventType. A type says authentication can
/// fail; an event says it did fail, here, at this point in this run.
///
/// [sequence] is unique within a run and gives every occurrence an identity.
/// That identity is what lets the evaluator guarantee a behaviour fires at
/// most once per triggering occurrence — without it, "the same event" would be
/// indistinguishable from "another event of the same type".
///
/// An event carries no notion of who can see it or how much of it they see.
/// Observation is Phase 6.
///
/// This file is intentionally free of Flutter dependencies.
class StudioEvent {
  const StudioEvent({
    required this.sequence,
    required this.typeId,
    required this.source,
    this.participants = const [],
    this.payload = const {},
  });

  /// Unique within a run, assigned in occurrence order.
  final int sequence;

  /// ID of the declared StudioEventType this occurrence belongs to.
  final String typeId;

  /// The element where this occurrence happened.
  ///
  /// For an event emitted by an action, this is the action's target — the
  /// place in the system where the effect landed. For an event emitted by a
  /// behaviour, it is the behaviour's owner.
  final StudioElementRef source;

  /// Elements that took direct part in causing this occurrence.
  ///
  /// For an action: the initiator and the target. For a behaviour: its owner.
  /// Participants observe what they were part of without needing a
  /// relationship to carry the information to them — you do not need to be
  /// told about something you did.
  final List<StudioElementRef> participants;

  /// Optional additional data.
  ///
  /// Unused by the current demonstration and carried only so that a later
  /// phase has somewhere to put observation payloads without reshaping this
  /// type.
  final Map<String, Object?> payload;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StudioEvent &&
            other.sequence == sequence &&
            other.typeId == typeId &&
            other.source == source;
  }

  @override
  int get hashCode => Object.hash(sequence, typeId, source);

  @override
  String toString() => 'StudioEvent(#$sequence $typeId at $source)';
}

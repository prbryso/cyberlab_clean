import 'studio_element_ref.dart';

/// An authored declaration that a class of occurrence can happen in a system.
///
/// This is a **declaration**, not an occurrence. A StudioEventType says
/// "authentication can fail"; a StudioEvent says "authentication failed, at
/// this point in this run, at this element". Keeping the two apart is why the
/// naming is explicit rather than both being called "event".
///
/// An event type is deliberately thin. It does not know who can observe it,
/// how much of it they see, or what it means — those are Phase 6 concerns.
///
/// Note the relationship to the Events *facet*: a facet is human-readable
/// prose describing what an element can detect, generate, or report, while
/// this is the machine-usable declaration that behaviours trigger on. They
/// overlap in intent and are not yet reconciled.
///
/// This file is intentionally free of Flutter dependencies.
class StudioEventType {
  const StudioEventType({
    required this.id,
    required this.name,
    this.description = '',
    this.declaredBy,
  });

  /// Unique within the system.
  final String id;

  /// Human-readable name, such as "Authentication failed".
  final String name;

  /// What this occurrence means when it happens.
  final String description;

  /// Optional element that is expected to originate this kind of event.
  ///
  /// Documentation only. The evaluator does not restrict which element may
  /// emit an event type — an event's actual source is recorded on the runtime
  /// occurrence.
  final StudioElementRef? declaredBy;

  @override
  String toString() => 'StudioEventType($id)';
}

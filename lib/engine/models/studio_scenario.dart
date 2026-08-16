import 'package:systems_studio/engine/models/studio_element_ref.dart';

/// A situation worth exploring in a system.
///
/// A scenario establishes a starting point and stops there. It says who is
/// already present and what is already true, and then hands over: what happens
/// next is decided by actors taking actions, exactly as it is without one.
///
/// **A scenario is not a script.** It has no steps, no ordering, no expected
/// outcome and no notion of success. That is deliberate and load-bearing: the
/// moment a scenario could say what ought to happen, exploring a system would
/// become following a lesson, and the same run could be judged right or wrong.
/// Systems Studio has no such judgement anywhere and this must not introduce
/// one.
///
/// State is expressed as **overrides**, not as a complete starting state. The
/// system's declared initial values remain its resting condition, and a
/// scenario names only what differs from it. So a scenario says "this account
/// is already locked" rather than restating every variable, authored content
/// stays in one place, and a system with no scenarios behaves exactly as it
/// always has.
///
/// This file is intentionally free of Flutter dependencies.
class StudioScenario {
  const StudioScenario({
    required this.id,
    required this.name,
    this.description = '',
    this.initialActors = const {},
    this.initialStateOverrides = const {},
  });

  /// Unique within the system.
  final String id;

  /// What this situation is called.
  final String name;

  /// What situation this establishes, and why it is worth exploring.
  final String description;

  /// Who is already part of the situation when it begins.
  ///
  /// Everyone else becomes relevant only by observing something, which is the
  /// existing and unchanged mechanism. Naming an actor here says they are
  /// already present — never that they will act.
  ///
  /// An empty set is meaningful: nobody is present, and nothing can happen
  /// until an occurrence reaches someone.
  final Set<StudioElementRef> initialActors;

  /// Values that differ from the system's declared starting values, keyed by
  /// state variable ID.
  ///
  /// Only differences. A variable absent here holds its declared initial
  /// value. Every value must belong to its variable's declared domain, which
  /// validation enforces.
  final Map<String, String> initialStateOverrides;

  /// The starting point every system has even when nothing is authored.
  ///
  /// Exists so that a run always has a scenario, and so that a system with no
  /// authored scenarios behaves precisely as it did before scenarios existed:
  /// declared initial values, and whoever the caller says is present.
  static const String implicitId = 'implicit.default';

  /// Builds the implicit scenario for a system with none authored.
  factory StudioScenario.implicit({
    Set<StudioElementRef> initialActors = const {},
  }) {
    return StudioScenario(
      id: implicitId,
      name: 'Explore freely',
      description:
          'The system as declared, with no particular situation established.',
      initialActors: initialActors,
    );
  }

  /// True when this is the fallback rather than something an author wrote.
  bool get isImplicit => id == implicitId;

  @override
  String toString() => 'StudioScenario($id)';
}

import 'studio_condition.dart';
import 'studio_effect.dart';

/// One possible result of an action or a behaviour.
///
/// An outcome pairs a condition with what happens when that condition holds:
/// state changes, and occurrences that follow.
///
/// Outcomes are selected by **ordered first match**. The first outcome whose
/// condition holds is the one that runs, and no other outcome runs. Every
/// action and behaviour must also supply an [StudioOutcome.otherwise] outcome,
/// which runs when no condition matched. That combination makes selection
/// total and deterministic: there is always exactly one result, and it is
/// always the same result for the same state.
///
/// There is deliberately no success or failure notion here. Whether an outcome
/// is good depends entirely on which actor you are — that is the point of the
/// perspective model, and building a verdict into the simulation primitive
/// would quietly turn exploration into assessment.
///
/// An outcome may carry authored meaning: an explanation of why this happened,
/// and a question worth considering. That is authored *meaning*, which is
/// wanted. It is not authored *sequence*, which is not: an outcome never says
/// what to show next, where to navigate, or which step follows.
///
/// This file is intentionally free of Flutter dependencies.
class StudioOutcome {
  /// A conditional outcome.
  const StudioOutcome({
    required StudioCondition this.condition,
    this.effects = const [],
    this.emits = const [],
    this.explanation = '',
    this.guidingQuestion = '',
  });

  /// The mandatory fallback outcome, used when no condition matched.
  ///
  /// Has no condition by construction, so it can never be skipped.
  const StudioOutcome.otherwise({
    this.effects = const [],
    this.emits = const [],
    this.explanation = '',
    this.guidingQuestion = '',
  }) : condition = null;

  /// When this outcome applies.
  ///
  /// Null only for the mandatory fallback outcome.
  final StudioCondition? condition;

  /// Changes this outcome makes to simulation state.
  final List<StudioEffect> effects;

  /// IDs of the event types this outcome causes to occur.
  final List<String> emits;

  /// Why this happened, in the author's words.
  ///
  /// Explanation, not navigation.
  final String explanation;

  /// A question worth considering at this point.
  final String guidingQuestion;

  /// True for the mandatory fallback outcome.
  bool get isOtherwise => condition == null;
}

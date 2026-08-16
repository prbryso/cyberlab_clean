/// Defines one major unit of instruction within an educational domain.
///
/// This model is intentionally independent of Flutter. It describes
/// educational content, not how that content is displayed.
class LearningModule {
  const LearningModule({
    required this.id,
    required this.domainId,
    required this.title,
    required this.description,
    required this.route,
    this.order = 0,
    this.estimatedMinutes,
    this.difficulty = LearningDifficulty.beginner,
    this.tags = const [],
    this.lessonIds = const [],
    this.systemIds = const [],
    this.simulationIds = const [],
  });

  /// Stable identifier.
  ///
  /// Example: `cybersecurity.password_security`
  final String id;

  /// ID of the educational domain that owns this module.
  ///
  /// Example: `cybersecurity`
  final String domainId;

  /// Learner-facing module title.
  final String title;

  /// Short learner-facing description.
  final String description;

  /// Route used by the current Flutter presentation layer.
  ///
  /// Route ownership may later move into a presentation adapter.
  final String route;

  /// Explicit display order.
  ///
  /// Registration order must not determine presentation order.
  final int order;

  /// Expected completion time, when known.
  final int? estimatedMinutes;

  /// Approximate learner difficulty.
  final LearningDifficulty difficulty;

  /// Search and classification metadata.
  final List<String> tags;

  /// Lessons belonging to the module.
  final List<String> lessonIds;

  /// System models associated with the module.
  final List<String> systemIds;

  /// Simulations associated with the module.
  final List<String> simulationIds;

  LearningModule copyWith({
    String? id,
    String? domainId,
    String? title,
    String? description,
    String? route,
    int? order,
    int? estimatedMinutes,
    LearningDifficulty? difficulty,
    List<String>? tags,
    List<String>? lessonIds,
    List<String>? systemIds,
    List<String>? simulationIds,
  }) {
    return LearningModule(
      id: id ?? this.id,
      domainId: domainId ?? this.domainId,
      title: title ?? this.title,
      description: description ?? this.description,
      route: route ?? this.route,
      order: order ?? this.order,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      lessonIds: lessonIds ?? this.lessonIds,
      systemIds: systemIds ?? this.systemIds,
      simulationIds: simulationIds ?? this.simulationIds,
    );
  }
}

enum LearningDifficulty { beginner, intermediate, advanced }

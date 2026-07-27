class LearningModule {
  final String title;
  final String goal;
  final String estimatedTime;
  final String difficulty;
  final String scenario;
  final String whyItMatters;
  final List<Lesson> lessons;

  const LearningModule({
    required this.title,
    required this.goal,
    required this.estimatedTime,
    required this.difficulty,
    required this.scenario,
    required this.whyItMatters,
    required this.lessons,
  });
}

class Lesson {
  final String title;
  final String route;
  final int minutes;

  const Lesson({
    required this.title,
    required this.route,
    required this.minutes,
  });
}

enum PerspectiveType { user, attacker, defender }

class Perspective {
  final PerspectiveType type;
  final String title;
  final String description;
  final List<String> steps;

  const Perspective({
    required this.type,
    required this.title,
    required this.description,
    required this.steps,
  });
}

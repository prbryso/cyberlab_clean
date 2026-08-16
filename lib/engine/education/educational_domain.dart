/// Defines a major field of study hosted by Systems Studio.
///
/// Examples:
/// - Cybersecurity
/// - Artificial Intelligence
/// - Electronics
/// - Control Systems
class EducationalDomain {
  const EducationalDomain({
    required this.id,
    required this.name,
    required this.description,
    this.moduleIds = const [],
    this.tags = const [],
  });

  /// Stable, permanent identifier.
  ///
  /// Example: `cybersecurity`
  final String id;

  /// Learner-facing domain name.
  final String name;

  /// Short explanation of the domain.
  final String description;

  /// IDs of the modules belonging to this domain.
  final List<String> moduleIds;

  /// Search and classification metadata.
  final List<String> tags;

  EducationalDomain copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? moduleIds,
    List<String>? tags,
  }) {
    return EducationalDomain(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      moduleIds: moduleIds ?? this.moduleIds,
      tags: tags ?? this.tags,
    );
  }
}

import 'package:flutter/material.dart';

/// Describes the graph-driven experience available for one system.
///
/// A StudioExperience does not contain the system's knowledge. The knowledge
/// remains in StudioSystemGraph. This model describes which reusable views
/// should be available for exploring that graph.
class StudioExperience {
  const StudioExperience({
    required this.systemId,
    this.views = StudioExperienceView.standardViews,
    this.defaultViewId = StudioExperienceView.overviewId,
  });

  /// Must match the corresponding StudioSystemDetail.systemId.
  final String systemId;

  /// Graph-driven views available for this system.
  final List<StudioExperienceView> views;

  /// ID of the view initially selected when the experience opens.
  final String defaultViewId;

  StudioExperienceView? viewById(String id) {
    for (final view in views) {
      if (view.id == id) {
        return view;
      }
    }

    return null;
  }

  StudioExperienceView get defaultView {
    return viewById(defaultViewId) ??
        (views.isNotEmpty ? views.first : StudioExperienceView.overview);
  }
}

/// Describes one reusable way of viewing a system graph.
///
/// These definitions are domain-independent. Cyber Lab, AI Lab, and future
/// libraries can use the same standard views and optionally add specialized
/// views later.
class StudioExperienceView {
  const StudioExperienceView({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.type,
  });

  static const String overviewId = 'overview';
  static const String architectureId = 'architecture';
  static const String exploreId = 'explore';
  static const String simulationId = 'simulation';

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final StudioExperienceViewType type;

  static const StudioExperienceView overview = StudioExperienceView(
    id: overviewId,
    label: 'Overview',
    description:
        'Understand the system purpose, structure, elements, and context.',
    icon: Icons.dashboard_outlined,
    type: StudioExperienceViewType.overview,
  );

  static const StudioExperienceView architecture = StudioExperienceView(
    id: architectureId,
    label: 'Architecture',
    description:
        'Visualize system structure, relationships, and focused context.',
    icon: Icons.account_tree_outlined,
    type: StudioExperienceViewType.architecture,
  );

  static const StudioExperienceView explore = StudioExperienceView(
    id: exploreId,
    label: 'Explore',
    description:
        'Follow relationships and investigate connected system elements.',
    icon: Icons.explore_outlined,
    type: StudioExperienceViewType.explore,
  );

  static const StudioExperienceView simulation = StudioExperienceView(
    id: simulationId,
    label: 'Simulate',
    description:
        'Change conditions and observe how system behavior and outcomes change.',
    icon: Icons.science_outlined,
    type: StudioExperienceViewType.simulation,
  );

  static const List<StudioExperienceView> standardViews = [
    overview,
    architecture,
    explore,
  ];

  static const List<StudioExperienceView> completeViews = [
    overview,
    architecture,
    explore,
    simulation,
  ];
}

enum StudioExperienceViewType {
  overview,
  architecture,
  explore,
  simulation,
  timeline,
  failures,
  dependencies,
  perspectives,
  custom,
}

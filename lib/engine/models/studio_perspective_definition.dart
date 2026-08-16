import 'package:flutter/material.dart';

/// A viewpoint used to examine goals, decisions, actions, and outcomes.
///
/// This type lives in its own file because it is referenced by both
/// [StudioSystemDetail] (which authors it) and [StudioSystemGraph] (which now
/// carries it through the build instead of discarding it). Keeping it separate
/// avoids an import cycle between the authoring model and the graph model.
///
/// It remains exported from `studio_system_detail.dart`, so existing content
/// packages continue to import it from there without change.
class StudioPerspectiveDefinition {
  const StudioPerspectiveDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.goals = const [],
    this.concerns = const [],
    this.decisions = const [],
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;

  final List<String> goals;
  final List<String> concerns;
  final List<String> decisions;
}

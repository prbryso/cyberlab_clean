import 'package:systems_studio/engine/models/system_model.dart';

/// Describes an executable simulation for a SystemModel.
///
/// The UI is responsible for rendering these steps.
/// This class only describes the behavior.
class SystemSimulation {
  const SystemSimulation({
    required this.id,
    required this.name,
    this.description,
    required this.steps,
  });

  final String id;
  final String name;
  final String? description;
  final List<SimulationStep> steps;

  bool get isEmpty => steps.isEmpty;

  int get stepCount => steps.length;
}

/// One step in a simulation.
///
/// A step typically highlights one node, displays narration,
/// and optionally highlights a connection.
class SimulationStep {
  const SimulationStep({
    required this.nodeId,
    required this.narration,
    this.title,
    this.fromNodeId,
    this.toNodeId,
    this.duration = const Duration(seconds: 2),
    this.level = SimulationLevel.normal,
    this.type = SimulationStepType.node,
  });

  /// Primary node involved in this step.
  final String nodeId;

  /// Short title displayed above the narration.
  final String? title;

  /// Explanation shown to the learner.
  final String narration;

  /// Optional connection that should be highlighted.
  final String? fromNodeId;

  final String? toNodeId;

  /// Suggested display time.
  final Duration duration;

  /// Importance of the event.
  final SimulationLevel level;

  /// How this step should be rendered.
  final SimulationStepType type;
}

enum SimulationStepType { node, connection, success, failure, information }

enum SimulationLevel { normal, warning, critical }

/// Associates a SystemModel with its simulation.
class SimulatedSystem {
  const SimulatedSystem({required this.model, required this.simulation});

  final SystemModel model;
  final SystemSimulation simulation;
}

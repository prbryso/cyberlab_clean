import 'package:systems_studio/engine/models/system_model.dart';

/// Identifies the perspective from which the learner views the system.
enum SystemPerspective { user, attacker, defender, administrator }

/// A SystemView describes how one actor interacts with a SystemModel.
///
/// The underlying system does not change. Only the actor,
/// inputs, outputs, and explanatory text change.
class SystemView {
  const SystemView({
    required this.id,
    required this.title,
    required this.perspective,
    required this.actor,
    required this.inputIds,
    required this.outputIds,
    this.description,
  });

  /// Unique identifier.
  final String id;

  /// Display title.
  final String title;

  /// User / Attacker / Defender / Administrator.
  final SystemPerspective perspective;

  /// External actor interacting with the system.
  final SystemEndpoint actor;

  /// IDs of the system inputs used in this view.
  final List<String> inputIds;

  /// IDs of the outputs produced in this view.
  final List<String> outputIds;

  /// Optional explanation shown to the learner.
  final String? description;
}

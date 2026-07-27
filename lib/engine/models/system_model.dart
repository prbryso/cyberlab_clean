enum SystemNodeType { process, component, decision, defense }

enum SystemEndpointType {
  user,
  attacker,
  defender,
  administrator,
  externalSystem,
  success,
  failure,
  neutral,
}

/// An input or output located outside the system boundary.
class SystemEndpoint {
  const SystemEndpoint({
    required this.id,
    required this.label,
    required this.type,
    this.description,
  });

  final String id;
  final String label;
  final SystemEndpointType type;
  final String? description;
}

/// A component located inside the system boundary.
///
/// In addition to its diagram properties, a node can contain optional
/// instructional content. This allows the interface to explain the node's
/// purpose, risks, defenses, and related lessons when it is selected.
class SystemNode {
  const SystemNode({
    required this.id,
    required this.label,
    required this.type,
    this.description,
    this.purpose,
    this.risks = const [],
    this.defenses = const [],
    this.relatedLessons = const [],
    this.references = const [],
    this.isShared = false,
  });

  final String id;
  final String label;
  final SystemNodeType type;

  /// A brief explanation of what this node represents.
  final String? description;

  /// The role this node performs within the system.
  final String? purpose;

  /// Threats, weaknesses, or failure modes associated with this node.
  final List<String> risks;

  /// Controls or practices that protect this node.
  final List<String> defenses;

  /// Application route names for lessons related to this node.
  final List<String> relatedLessons;

  /// Optional reference labels, document names, or web resources.
  final List<String> references;

  /// Shared nodes remain conceptually fixed when the user changes lenses.
  ///
  /// Example: the Authentication Server appears in the User,
  /// Attacker, and Defender views.
  final bool isShared;

  /// Whether this node contains content suitable for an information panel.
  bool get hasInstructionalContent {
    return description != null ||
        purpose != null ||
        risks.isNotEmpty ||
        defenses.isNotEmpty ||
        relatedLessons.isNotEmpty ||
        references.isNotEmpty;
  }
}

/// A connection between any two model elements.
///
/// The IDs may refer to an input, internal node, or output.
class SystemConnection {
  const SystemConnection({
    required this.fromId,
    required this.toId,
    this.label,
  });

  final String fromId;
  final String toId;
  final String? label;
}

/// The presentation-independent description of a system.
///
/// This class knows nothing about Flutter, layout, colors,
/// passwords, phishing, or cybersecurity.
class SystemModel {
  const SystemModel({
    required this.id,
    required this.name,
    required this.inputs,
    required this.nodes,
    required this.outputs,
    required this.connections,
    this.description,
  });

  final String id;
  final String name;
  final String? description;

  final List<SystemEndpoint> inputs;
  final List<SystemNode> nodes;
  final List<SystemEndpoint> outputs;
  final List<SystemConnection> connections;

  /// Returns true when an input, node, or output uses the supplied ID.
  bool containsElement(String id) {
    return inputs.any((element) => element.id == id) ||
        nodes.any((element) => element.id == id) ||
        outputs.any((element) => element.id == id);
  }

  SystemEndpoint? inputById(String id) {
    for (final input in inputs) {
      if (input.id == id) {
        return input;
      }
    }

    return null;
  }

  SystemNode? nodeById(String id) {
    for (final node in nodes) {
      if (node.id == id) {
        return node;
      }
    }

    return null;
  }

  SystemEndpoint? outputById(String id) {
    for (final output in outputs) {
      if (output.id == id) {
        return output;
      }
    }

    return null;
  }

  /// Returns all internal nodes that contain instructional content.
  List<SystemNode> get instructionalNodes {
    return nodes.where((node) => node.hasInstructionalContent).toList();
  }

  /// Useful during development to detect invalid model definitions.
  List<String> validate() {
    final errors = <String>[];
    final ids = <String>{};

    for (final input in inputs) {
      if (input.id.trim().isEmpty) {
        errors.add('Input has an empty ID.');
      }

      if (!ids.add(input.id)) {
        errors.add('Duplicate element ID: ${input.id}');
      }
    }

    for (final node in nodes) {
      if (node.id.trim().isEmpty) {
        errors.add('Node has an empty ID.');
      }

      if (!ids.add(node.id)) {
        errors.add('Duplicate element ID: ${node.id}');
      }
    }

    for (final output in outputs) {
      if (output.id.trim().isEmpty) {
        errors.add('Output has an empty ID.');
      }

      if (!ids.add(output.id)) {
        errors.add('Duplicate element ID: ${output.id}');
      }
    }

    for (final connection in connections) {
      if (!containsElement(connection.fromId)) {
        errors.add(
          'Connection references missing source: ${connection.fromId}',
        );
      }

      if (!containsElement(connection.toId)) {
        errors.add(
          'Connection references missing destination: ${connection.toId}',
        );
      }

      if (connection.fromId == connection.toId) {
        errors.add(
          'Connection cannot link an element to itself: '
          '${connection.fromId}',
        );
      }
    }

    return errors;
  }
}

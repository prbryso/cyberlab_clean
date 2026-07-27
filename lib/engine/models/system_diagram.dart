enum DiagramNodeType {
  user,
  attacker,
  defender,
  system,
  process,
  defense,
  success,
  danger,
}

class DiagramNode {
  final String id;
  final String label;
  final DiagramNodeType type;

  const DiagramNode({
    required this.id,
    required this.label,
    required this.type,
  });
}

class SystemDiagram {
  final String title;
  final String description;
  final List<DiagramNode> nodes;

  const SystemDiagram({
    required this.title,
    required this.description,
    required this.nodes,
  });
}

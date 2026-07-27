import 'package:flutter/material.dart';
import 'package:systems_studio/engine/models/system_diagram.dart';

class SystemDiagramWidget extends StatelessWidget {
  final SystemDiagram diagram;

  const SystemDiagramWidget({super.key, required this.diagram});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              diagram.title,
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              diagram.description,
              textAlign: TextAlign.center,
              style: text.bodyMedium,
            ),
            const SizedBox(height: 28),

            for (int i = 0; i < diagram.nodes.length; i++) ...[
              DiagramBlock(node: diagram.nodes[i]),
              if (i < diagram.nodes.length - 1) const DiagramArrow(),
            ],
          ],
        ),
      ),
    );
  }
}

class DiagramBlock extends StatelessWidget {
  final DiagramNode node;

  const DiagramBlock({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = _styleFor(node.type, color);

    return Container(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: style.border, width: 1.6),
      ),
      child: Text(
        node.label,
        textAlign: TextAlign.center,
        style: text.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: style.foreground,
        ),
      ),
    );
  }
}

class DiagramArrow extends StatelessWidget {
  const DiagramArrow({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Container(width: 2, height: 22, color: color.outline),
          Icon(Icons.arrow_drop_down, size: 34, color: color.outline),
        ],
      ),
    );
  }
}

class _NodeStyle {
  final Color background;
  final Color border;
  final Color foreground;

  const _NodeStyle({
    required this.background,
    required this.border,
    required this.foreground,
  });
}

_NodeStyle _styleFor(DiagramNodeType type, ColorScheme color) {
  switch (type) {
    case DiagramNodeType.user:
      return _NodeStyle(
        background: color.primaryContainer,
        border: color.primary,
        foreground: color.onPrimaryContainer,
      );

    case DiagramNodeType.attacker:
      return _NodeStyle(
        background: Colors.orange.shade100,
        border: Colors.deepOrange,
        foreground: Colors.deepOrange.shade900,
      );

    case DiagramNodeType.defender:
    case DiagramNodeType.defense:
    case DiagramNodeType.success:
      return _NodeStyle(
        background: Colors.green.shade100,
        border: Colors.green,
        foreground: Colors.green.shade900,
      );

    case DiagramNodeType.danger:
      return _NodeStyle(
        background: Colors.red.shade100,
        border: Colors.red,
        foreground: Colors.red.shade900,
      );

    case DiagramNodeType.system:
    case DiagramNodeType.process:
      return _NodeStyle(
        background: color.surfaceVariant,
        border: color.outline,
        foreground: color.onSurfaceVariant,
      );
  }
}

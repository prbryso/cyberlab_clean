import 'package:flutter/material.dart';
import 'package:systems_studio/engine/models/perspective.dart';

class PerspectiveCard extends StatelessWidget {
  final Perspective perspective;

  const PerspectiveCard({super.key, required this.perspective});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            perspective.title,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(perspective.description, style: text.bodyMedium),
          const SizedBox(height: 24),

          for (int i = 0; i < perspective.steps.length; i++) ...[
            _FlowStep(number: i + 1, text: perspective.steps[i]),
            if (i < perspective.steps.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 22, top: 6, bottom: 6),
                child: Icon(Icons.arrow_downward, size: 22),
              ),
          ],
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final int number;
  final String text;

  const _FlowStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.primary,
            foregroundColor: color.onPrimary,
            child: Text("$number", style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

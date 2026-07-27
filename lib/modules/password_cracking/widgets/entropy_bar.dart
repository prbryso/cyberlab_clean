import 'package:flutter/material.dart';

class EntropyBar extends StatelessWidget {
  final double score; // expected range: 0–100

  const EntropyBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Color transitions: red → orange → green
    final Color barColor = score < 30
        ? Colors.red
        : score < 60
        ? Colors.orange
        : Colors.green;

    return Container(
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: (score / 100).clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: barColor,
            ),
          ),
        ),
      ),
    );
  }
}

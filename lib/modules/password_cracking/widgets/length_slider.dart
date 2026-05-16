import 'dart:math';
import 'package:flutter/material.dart';
import 'entropy_bar.dart';

class LengthSlider extends StatelessWidget {
  final double length;
  final int charsetSize;
  final ValueChanged<double> onChanged;

  const LengthSlider({
    super.key,
    required this.length,
    required this.charsetSize,
    required this.onChanged,
  });

  // ---------------------------------------------------------
  // CRACK TIME ESTIMATE
  // ---------------------------------------------------------
  String get crackTime {
    if (charsetSize == 0) return "Instantly";

    final combos = pow(charsetSize, length.toInt());
    final seconds = combos / 1e10; // assume 10 billion guesses/sec

    if (seconds < 60) return "Seconds";
    if (seconds < 3600) return "Minutes";
    if (seconds < 86400) return "Hours";
    if (seconds < 31536000) return "Days";
    if (seconds < 3.15e9) return "Years";
    if (seconds < 3.15e11) return "Centuries";
    return "Longer than the universe";
  }

  // ---------------------------------------------------------
  // ENTROPY SCORE (0–100)
  // ---------------------------------------------------------
  double get entropyScore {
    if (charsetSize == 0) return 0;

    final bits = length * (log(charsetSize) / ln2);
    return (bits / 120).clamp(0, 1) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Adjust Password Length",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        Slider(
          min: 4,
          max: 24,
          divisions: 20,
          value: length,
          label: "${length.toInt()} characters",
          onChanged: onChanged,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Length: ${length.toInt()}",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "Crack time: $crackTime",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 8),

        EntropyBar(score: entropyScore),
      ],
    );
  }
}

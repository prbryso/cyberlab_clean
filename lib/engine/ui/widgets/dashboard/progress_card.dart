import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    const completedCourses = 1;
    const totalCourses = 12;
    const progress = completedCourses / totalCourses;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacing.md),
        color: color.surfaceVariant,
        border: Border.all(color: color.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Progress",
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: spacing.lg),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: color.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color.primary),
          ),
          SizedBox(height: spacing.sm),
          Text(
            "$completedCourses of $totalCourses modules completed",
            style: text.bodyMedium,
          ),
          SizedBox(height: spacing.lg),
          Text(
            "Next Module",
            style: text.labelLarge?.copyWith(
              color: color.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            "Prevent Account Takeovers",
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

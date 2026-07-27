import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacing.md),
        color: color.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Interactive Cybersecurity Awareness Training",
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color.onPrimaryContainer,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            "Teach the System.\nNot Just the Rule.",
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: color.onPrimaryContainer,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            "Understand how attackers think.\n"
            "Learn why attacks succeed.\n"
            "Recognize threats before they become incidents.",
            style: text.bodyLarge?.copyWith(color: color.onPrimaryContainer),
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: color.primary,
                ),
                onPressed: () => Navigator.pushNamed(context, "/password"),
                icon: const Icon(Icons.play_arrow),
                label: const Text("Begin Learning"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

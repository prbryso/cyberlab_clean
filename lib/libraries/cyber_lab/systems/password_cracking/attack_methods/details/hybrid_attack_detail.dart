import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class HybridAttackDetail extends StatelessWidget {
  const HybridAttackDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Hybrid Attacks")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hybrid Attacks",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "Hybrid attacks combine dictionary words with common patterns like numbers or symbols. "
              "Example: 'password' → 'password1' → 'Password1!'",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "Why It Works",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "Most people modify simple words with predictable patterns. "
              "Attackers know these patterns and automate them.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "How to Protect Yourself",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "• Avoid predictable substitutions\n"
              "• Use random passphrases instead of modified words\n"
              "• Use a password manager to generate strong passwords",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:systems_studio/theme/spacing.dart';

class BreachICloudDetail extends StatelessWidget {
  const BreachICloudDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("iCloud Celebrity Hack (2014)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The iCloud Celebrity Hack",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "In 2014, attackers gained access to dozens of celebrity iCloud accounts. "
              "This wasn’t a technical exploit — it was a human one.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "🔓 What Went Wrong",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "Attackers used weak security questions and reused passwords to break into accounts. "
              "Many answers were easily guessable from public information.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "⚡ Attack Method",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• Credential stuffing using leaked passwords\n"
              "• Guessing security questions using public info\n"
              "• Targeted social engineering",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "🧠 Lessons Learned",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• Security questions are often weaker than passwords\n"
              "• Password reuse is extremely dangerous\n"
              "• Attackers use personal info from social media",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

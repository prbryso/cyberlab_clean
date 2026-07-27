import 'package:flutter/material.dart';
import 'package:systems_studio/theme/spacing.dart';

class WeakPatternsDetail extends StatelessWidget {
  const WeakPatternsDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Patterns Attackers Exploit")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patterns Attackers Exploit",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "Attackers know the shortcuts people use when creating passwords. "
              "These predictable patterns make passwords easy to guess.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "Common Patterns",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "• Adding '1' or '!' at the end\n"
              "• Capitalizing the first letter only\n"
              "• Using keyboard patterns like 'qwerty'\n"
              "• Using birth years or names\n"
              "• Simple substitutions like 'a' → '@'",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

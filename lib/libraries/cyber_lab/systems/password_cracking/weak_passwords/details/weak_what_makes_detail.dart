import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class WeakWhatMakesDetail extends StatelessWidget {
  const WeakWhatMakesDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("What Makes a Password Weak?")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What Makes a Password Weak?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "A password is considered weak when it is short, predictable, reused, or based on common patterns. "
              "Attackers rely on these weaknesses to crack accounts quickly.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "Common Weaknesses",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "• Short passwords (under 10 characters)\n"
              "• Common words or phrases\n"
              "• Reused passwords across multiple sites\n"
              "• Predictable substitutions like 'P@ssw0rd'",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

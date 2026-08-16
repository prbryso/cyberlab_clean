import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class BreachAdobeDetail extends StatelessWidget {
  const BreachAdobeDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Adobe Breach (2013)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The Adobe Encryption Disaster",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "In 2013, Adobe exposed **153 million user accounts**. "
              "The shocking part wasn’t just the size — it was how the passwords were stored.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "🔓 What Went Wrong",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "Adobe stored passwords using **reversible encryption**, not hashing. "
              "That meant attackers didn’t need to crack anything — they could simply decrypt the data.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "⚡ Pattern-Based Cracking",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "Because passwords were encrypted in a predictable way, attackers could compare patterns. "
              "Millions of users followed the same structure:\n"
              "• password123\n"
              "• qwerty123\n"
              "• letmein1",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "🧠 Lessons Learned",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• Never store passwords with reversible encryption\n"
              "• Hashing + salting is mandatory\n"
              "• Users often follow predictable patterns attackers exploit",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

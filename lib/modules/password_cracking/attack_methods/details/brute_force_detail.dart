import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/spacing.dart';

class BruteForceDetail extends StatelessWidget {
  const BruteForceDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Brute Force Attacks"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Brute Force Attacks",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "A brute force attack tries every possible combination of characters. "
              "Short passwords fall quickly, but long passphrases become exponentially harder to crack.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "Why It Works",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "Computers can test billions of guesses per second. "
              "A 6‑character password may fall instantly, while a 14‑character passphrase may take centuries.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "How to Protect Yourself",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "• Use long passphrases (12+ characters)\n"
              "• Include randomness\n"
              "• Avoid predictable patterns",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

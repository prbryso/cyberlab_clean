import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class WeakLimitedTriesDetail extends StatelessWidget {
  const WeakLimitedTriesDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Limited Tries & Lockouts")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Limited Tries & Lockouts",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "Even if a password is weak, attackers can’t always brute‑force it freely. "
              "Most systems limit how many times you can guess before slowing you down or locking you out.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "🔒 Why Limited Tries Exist",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "Without guess limits, attackers could try billions of passwords per second. "
              "Lockouts force attackers to slow down to a crawl — or stop entirely.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "⏱️ Common Lockout Strategies",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• **Temporary lockout** after 5–10 failed attempts\n"
              "• **Increasing delays** (5 seconds → 30 seconds → minutes)\n"
              "• **Account freeze** until the user verifies identity\n"
              "• **IP rate limiting** to block automated attacks",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "🧠 Why This Matters",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "Limited tries don’t make weak passwords strong — but they prevent attackers from "
              "testing millions of guesses. This is why online brute‑forcing is much harder than offline cracking.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

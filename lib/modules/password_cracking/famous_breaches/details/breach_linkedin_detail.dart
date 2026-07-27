import 'package:flutter/material.dart';
import 'package:systems_studio/theme/spacing.dart';

class BreachLinkedInDetail extends StatelessWidget {
  const BreachLinkedInDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("LinkedIn Breach (2012)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The LinkedIn Password Leak",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "In 2012, attackers stole **117 million LinkedIn passwords**. "
              "The breach became a textbook example of how outdated hashing and weak passwords "
              "can collapse the security of an entire platform.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "🔓 What Went Wrong",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "LinkedIn stored passwords using **unsalted SHA‑1**, a hashing algorithm that was already "
              "considered insecure. Without a salt, attackers could use precomputed lookup tables and "
              "massive dictionary lists to crack passwords at incredible speed.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "⚡ How Attackers Cracked Them",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• Dictionary attacks using real leaked password lists\n"
              "• Hybrid attacks combining words + numbers\n"
              "• GPU rigs testing billions of guesses per second",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "📉 What They Found",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "The most common passwords were shockingly weak:\n"
              "• 123456\n"
              "• linkedin\n"
              "• password\n"
              "• qwerty\n"
              "• letmein",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "🧠 Lessons Learned",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• Never use outdated hashing algorithms\n"
              "• Always salt passwords\n"
              "• Users must avoid predictable passwords\n"
              "• Attackers rely heavily on real-world leaked lists",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

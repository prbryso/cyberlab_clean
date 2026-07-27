import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class WeakFixingDetail extends StatelessWidget {
  const WeakFixingDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("How to Fix Weak Passwords")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How to Fix Weak Passwords",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "Strengthening your passwords is simple once you understand the common weaknesses. "
              "These steps dramatically improve your security.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "Best Practices",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "• Use long passphrases (12–16+ characters)\n"
              "• Avoid predictable patterns\n"
              "• Use unique passwords for every site\n"
              "• Let a password manager generate strong passwords\n"
              "• Enable two-factor authentication",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

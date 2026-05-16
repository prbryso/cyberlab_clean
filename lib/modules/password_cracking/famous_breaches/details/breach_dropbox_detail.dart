import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/spacing.dart';

class BreachDropboxDetail extends StatelessWidget {
  const BreachDropboxDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Dropbox Breach (2016)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("The Dropbox Employee Password Leak",
                style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: spacing.md),

            Text(
              "In 2016, Dropbox confirmed that **68 million account credentials** were exposed. "
              "The root cause? A single employee reused a password.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text("🔓 What Went Wrong",
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: spacing.sm),

            Text(
              "An employee used the same password on Dropbox and LinkedIn. "
              "When LinkedIn was breached, attackers tried the same credentials on Dropbox — and it worked.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text("⚡ Attack Method",
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: spacing.sm),

            Text(
              "• Credential stuffing\n"
              "• Password reuse\n"
              "• Weak internal access controls",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text("🧠 Lessons Learned",
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: spacing.sm),

            Text(
              "• Never reuse passwords — especially for work\n"
              "• One breach can trigger another\n"
              "• Internal accounts must use strong authentication",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

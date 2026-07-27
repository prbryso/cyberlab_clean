import 'package:flutter/material.dart';
import 'package:systems_studio/theme/spacing.dart';

class BreachTwitterDetail extends StatelessWidget {
  const BreachTwitterDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Twitter Admin Panel Attack (2020)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The Twitter Admin Panel Takeover",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "In 2020, attackers gained access to Twitter’s internal admin tools and hijacked "
              "high-profile accounts including Obama, Musk, Apple, and more.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "🔓 What Went Wrong",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "Attackers socially engineered Twitter employees, convincing them to hand over internal credentials. "
              "Once inside, they had near-unlimited access.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "⚡ Attack Method",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• Social engineering\n"
              "• Credential theft\n"
              "• Privilege escalation inside admin tools",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "🧠 Lessons Learned",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• Humans are often the weakest link\n"
              "• Admin tools require strict access controls\n"
              "• Internal accounts must use strong MFA",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

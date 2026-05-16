import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/spacing.dart';

class WeakExamplesDetail extends StatelessWidget {
  const WeakExamplesDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Common Weak Password Examples")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Common Weak Password Examples",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "These passwords appear in real-world breach lists and are cracked instantly by attackers.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text("Examples", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: spacing.md),

            _passwordCloud(context),

            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

Widget _passwordCloud(BuildContext context) {
  final spacing = CyberLabSpacing.of(context);

  final passwords = [
    "123456",
    "password",
    "qwerty",
    "welcome1",
    "letmein",
    "iloveyou",
    "admin123",
  ];

  final colors = [
    Colors.red,
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  return Wrap(
    spacing: spacing.md,
    runSpacing: spacing.md,
    children: List.generate(passwords.length, (i) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: spacing.sm,
          horizontal: spacing.md,
        ),
        decoration: BoxDecoration(
          color: colors[i % colors.length].withOpacity(0.15),
          borderRadius: BorderRadius.circular(spacing.sm),
        ),
        child: Text(
          passwords[i],
          style: TextStyle(
            fontSize: 20 + (i * 2).toDouble(),
            fontWeight: FontWeight.w600,
            color: colors[i % colors.length],
          ),
        ),
      );
    }),
  );
}

import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/spacing.dart';

class DictionaryAttackDetail extends StatelessWidget {
  const DictionaryAttackDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dictionary Attacks"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dictionary Attacks",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            Text(
              "A dictionary attack uses massive lists of real leaked passwords from past breaches. "
              "If your password appears in these lists — even once — it can be cracked instantly.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "Why It Works",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "Most people reuse common passwords like '123456', 'qwerty', or simple patterns. "
              "Attackers simply try these known passwords first.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "How to Protect Yourself",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              "• Use long, unique passphrases\n"
              "• Avoid common words or patterns\n"
              "• Never reuse passwords across sites",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

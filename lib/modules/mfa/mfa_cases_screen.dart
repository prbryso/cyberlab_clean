import 'package:flutter/material.dart';

class MFACasesScreen extends StatelessWidget {
  const MFACasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("MFA Success Stories")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Real‑World MFA Success Stories",
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),

          Text(
            "Google’s 2017 Security Study",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            "Google found that hardware security keys blocked 100% of phishing attacks "
            "in their internal tests.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Text(
            "Microsoft Account Protection",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            "Microsoft reported that MFA blocks 99.9% of automated account attacks.",
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

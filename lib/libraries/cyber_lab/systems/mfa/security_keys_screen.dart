import 'package:flutter/material.dart';

class SecurityKeysScreen extends StatelessWidget {
  const SecurityKeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Hardware Security Keys")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Hardware Security Keys", style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),

          Text("What They Are", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Physical devices (like YubiKeys) that authenticate you by cryptographic challenge. "
            "They are the strongest form of MFA available.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Text("Why They’re So Strong", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "They cannot be phished, intercepted, or SIM‑swapped. "
            "They require physical possession.",
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

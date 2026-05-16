import 'package:flutter/material.dart';

class MFATypesScreen extends StatelessWidget {
  const MFATypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Types of MFA")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Types of MFA", style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),

          Text("Something You Know", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "This includes passwords, PINs, and security questions. "
            "It’s the weakest factor because it can be guessed or stolen.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Text("Something You Have", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "This includes phones, authenticator apps, SMS codes, and hardware keys. "
            "This is the most common second factor.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Text("Something You Are", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Biometrics like fingerprints, face scans, and voice recognition. "
            "Very strong, but not always available.",
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AuthenticatorAppsScreen extends StatelessWidget {
  const AuthenticatorAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Authenticator Apps")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Authenticator Apps", style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),

          Text("What They Are", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Authenticator apps generate time‑based one‑time codes (TOTPs). "
            "These codes change every 30 seconds and cannot be intercepted like SMS.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Text(
            "Why They’re Better Than SMS",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            "SMS can be hijacked through SIM‑swaps or number‑porting attacks. "
            "Authenticator apps avoid these weaknesses entirely.",
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

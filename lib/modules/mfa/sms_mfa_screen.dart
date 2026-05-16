import 'package:flutter/material.dart';

class SMSMFAScreen extends StatelessWidget {
  const SMSMFAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("SMS Codes (Weaknesses)")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("SMS MFA", style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),

          Text("How It Works", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "You receive a 6‑digit code by text message. "
            "It’s better than no MFA, but it has weaknesses.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Text("Weakness: SIM‑Swapping", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Attackers convince a phone carrier to move your number to their SIM card. "
            "They then receive your MFA codes.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Text("Weakness: Interception", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "SMS messages can be intercepted using outdated cellular protocols.",
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

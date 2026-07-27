import 'package:flutter/material.dart';

class CapstonePhase3Page extends StatelessWidget {
  const CapstonePhase3Page({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Phase 3: Escalation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phase 3: Escalation",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "The attacker escalated privileges using a misconfigured service and "
              "moved laterally across the network.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Questions to consider:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Which systems were hardened properly?"),
            _bullet("Which ones were not?"),
            _bullet("What logs show lateral movement?"),

            const SizedBox(height: 32),
            _next(context, "/capstone-phase4"),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Text("• "),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _next(BuildContext context, String route) => Center(
    child: ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: const Text("Continue to Phase 4"),
    ),
  );
}

import 'package:flutter/material.dart';

class CapstonePhase4Page extends StatelessWidget {
  const CapstonePhase4Page({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Phase 4: Containment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phase 4: Containment",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "You must now stop the attack without causing further damage. "
              "Shutting down the wrong system could disrupt operations.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Questions to consider:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Which systems must be isolated immediately?"),
            _bullet("Which logs confirm the attacker's location?"),
            _bullet("What is the safest containment strategy?"),

            const SizedBox(height: 32),
            _next(context, "/capstone-phase5"),
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
      child: const Text("Continue to Phase 5"),
    ),
  );
}

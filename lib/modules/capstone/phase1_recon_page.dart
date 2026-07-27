import 'package:flutter/material.dart';

class CapstonePhase1Page extends StatelessWidget {
  const CapstonePhase1Page({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Phase 1: Reconnaissance")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phase 1: Reconnaissance",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "Your SOC dashboard shows unusual login attempts from foreign IP "
              "addresses targeting accounts with weak passwords.\n\n"
              "You also see a suspicious email sent to several employees.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Questions to consider:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Is this a brute‑force attempt?"),
            _bullet("Is the phishing email part of the same campaign?"),
            _bullet("Which accounts are most at risk?"),

            const SizedBox(height: 32),
            _next(context, "/capstone-phase2"),
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
      child: const Text("Continue to Phase 2"),
    ),
  );
}

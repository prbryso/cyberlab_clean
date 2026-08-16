import 'package:flutter/material.dart';

class CapstonePhase2Page extends StatelessWidget {
  const CapstonePhase2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Phase 2: Breach")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phase 2: Breach",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "An attacker successfully logged in using a weak password. "
              "Moments later, logs show exploitation of an unpatched server.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Questions to consider:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Which vulnerability was exploited?"),
            _bullet("Was this a known CVE or a zero‑day?"),
            _bullet("How long has the attacker been inside?"),

            const SizedBox(height: 32),
            _next(context, "/capstone-phase3"),
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
      child: const Text("Continue to Phase 3"),
    ),
  );
}

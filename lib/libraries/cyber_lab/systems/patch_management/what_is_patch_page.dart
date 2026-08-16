import 'package:flutter/material.dart';

class WhatIsPatchPage extends StatelessWidget {
  const WhatIsPatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("What Is Patch Management?")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What Is Patch Management?",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "Patch Management is the process of updating software to fix "
              "vulnerabilities, improve stability, and add security features.\n\n"
              "When a vulnerability becomes public, attackers often weaponize it "
              "within hours. Patching quickly is the defender’s best chance to "
              "stay ahead.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Why it matters:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Fixes known vulnerabilities."),
            _bullet("Prevents exploitation of old flaws."),
            _bullet("Improves system stability and performance."),
            _bullet("Reduces attack surface."),
            _bullet("Protects against automated mass‑exploitation."),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/patch"),
                child: const Text("← Back to Patch Overview"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• "),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

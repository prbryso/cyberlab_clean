import 'package:flutter/material.dart';

class WhatIsHardeningPage extends StatelessWidget {
  const WhatIsHardeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("What Is System Hardening?")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What Is System Hardening?",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "System Hardening is the process of securing a system by reducing its "
              "attack surface. This means removing unnecessary software, closing "
              "unused ports, restricting permissions, and enforcing secure "
              "configurations.\n\n"
              "Hardening makes it harder for attackers to find a way in — even if "
              "vulnerabilities exist.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Key goals:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Reduce the number of vulnerabilities."),
            _bullet("Limit what attackers can do if they get in."),
            _bullet("Enforce secure defaults."),
            _bullet("Minimize unnecessary features and services."),
            _bullet("Strengthen system configurations."),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/hardening"),
                child: const Text("← Back to System Hardening Overview"),
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

import 'package:flutter/material.dart';

class ZeroDayDefensePage extends StatelessWidget {
  const ZeroDayDefensePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Defending Against Zero‑Days")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Defending Against Zero‑Days",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _bullet("Network segmentation — contain the blast radius."),
            _bullet("Least privilege — limit what attackers can do."),
            _bullet("Exploit mitigations — ASLR, DEP, sandboxing."),
            _bullet("Behavior‑based detection — catch unknown attacks."),
            _bullet("Rapid patching — fix the issue once disclosed."),
            _bullet("Defense‑in‑depth — multiple layers of protection."),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/zero-days"),
                child: const Text("← Back to Zero‑Days Overview"),
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

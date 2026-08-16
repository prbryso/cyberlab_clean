import 'package:flutter/material.dart';

class PatchBestPracticesPage extends StatelessWidget {
  const PatchBestPracticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Patch Best Practices")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patch Best Practices",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _bullet("Maintain an accurate asset inventory."),
            _bullet("Prioritize critical vulnerabilities (CVSS, KEV list)."),
            _bullet("Automate patch deployment where possible."),
            _bullet("Test patches in a staging environment."),
            _bullet("Use maintenance windows for production."),
            _bullet("Monitor for patch failures."),
            _bullet("Document patching policies and timelines."),

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

import 'package:flutter/material.dart';

class WhyPatchingFailsPage extends StatelessWidget {
  const WhyPatchingFailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Why Patching Fails")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Why Patching Fails",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _bullet("Legacy systems that cannot be updated."),
            _bullet("Fear of breaking production systems."),
            _bullet("Lack of inventory — unknown assets."),
            _bullet("Slow approval processes."),
            _bullet("Understaffed IT/security teams."),
            _bullet("Poor visibility into vulnerability severity."),
            _bullet("No automated patching tools."),

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

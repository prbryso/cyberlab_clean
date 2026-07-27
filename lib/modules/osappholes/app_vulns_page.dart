import 'package:flutter/material.dart';

class AppVulnsPage extends StatelessWidget {
  const AppVulnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Application Vulnerabilities")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Application-Level Weaknesses",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Applications introduce their own weaknesses. These are some of the "
              "most commonly exploited holes in modern cyber attacks.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            _bullet("Input validation failures"),
            _bullet("Authentication and authorization flaws"),
            _bullet("Insecure APIs"),
            _bullet("Outdated libraries or components"),
            _bullet("Misconfigurations and weak defaults"),
            _bullet("Hard-coded secrets"),
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
}

import 'package:flutter/material.dart';

class SecureCodingOverviewPage extends StatelessWidget {
  const SecureCodingOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Secure Coding")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Secure Coding: Preventing Vulnerabilities at the Source",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "Secure Coding is the practice of writing software in a way that "
              "prevents vulnerabilities from being introduced in the first place.\n\n"
              "Instead of relying on patches and hardening after deployment, "
              "secure coding stops bugs before they ever reach production.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 32),

            _topicCard(
              context,
              title: "What Is Secure Coding?",
              description:
                  "Learn why secure coding is the foundation of safe software.",
              route: "/secure-what",
            ),
            _topicCard(
              context,
              title: "Common Vulnerabilities",
              description: "SQL injection, buffer overflows, XSS, and more.",
              route: "/secure-vulns",
            ),
            _topicCard(
              context,
              title: "Secure Coding Practices",
              description:
                  "Input validation, sanitization, safe memory handling.",
              route: "/secure-practices",
            ),
            _topicCard(
              context,
              title: "Famous Coding Failures",
              description: "Real bugs that caused massive security incidents.",
              route: "/secure-failures",
            ),
            _topicCard(
              context,
              title: "Secure Coding Tools",
              description: "Static analysis, linters, dependency scanners.",
              route: "/secure-tools",
            ),
          ],
        ),
      ),
    );
  }

  Widget _topicCard(
    BuildContext context, {
    required String title,
    required String description,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

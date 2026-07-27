import 'package:flutter/material.dart';

class HardeningOverviewPage extends StatelessWidget {
  const HardeningOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("System Hardening")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "System Hardening: Reducing the Attack Surface",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "System Hardening is the process of reducing the number of ways an "
              "attacker can break into a system. Instead of waiting for patches, "
              "hardening proactively removes unnecessary features, services, and "
              "permissions.\n\n"
              "A hardened system has fewer vulnerabilities, fewer entry points, "
              "and fewer opportunities for attackers.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 32),

            _topicCard(
              context,
              title: "What Is System Hardening?",
              description: "Learn why hardening is essential for security.",
              route: "/hardening-what",
            ),
            _topicCard(
              context,
              title: "Understanding Attack Surface",
              description: "Every open port, service, and permission matters.",
              route: "/hardening-surface",
            ),
            _topicCard(
              context,
              title: "Hardening Methods",
              description:
                  "Accounts, services, network, OS, applications, and more.",
              route: "/hardening-methods",
            ),
            _topicCard(
              context,
              title: "Famous Hardening Failures",
              description: "Misconfigurations that led to major breaches.",
              route: "/hardening-failures",
            ),
            _topicCard(
              context,
              title: "Hardening Best Practices",
              description: "How defenders lock systems down effectively.",
              route: "/hardening-best",
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

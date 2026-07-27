import 'package:flutter/material.dart';

class ZeroDaysOverviewPage extends StatelessWidget {
  const ZeroDaysOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Zero‑Days")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Zero‑Days: The Unknown Threat",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "A zero‑day is a vulnerability that nobody knows about — not the "
              "vendor, not defenders, not the public. Only the attacker knows.\n\n"
              "Because there is no patch, no signature, and no warning, zero‑days "
              "are the most dangerous vulnerabilities in cybersecurity.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 32),

            _topicCard(
              context,
              title: "What Is a Zero‑Day?",
              description: "Learn what makes zero‑days unique and dangerous.",
              route: "/zero-what",
            ),
            _topicCard(
              context,
              title: "How Zero‑Days Are Discovered",
              description:
                  "Researchers, attackers, bug hunters, and nation‑states.",
              route: "/zero-discovery",
            ),
            _topicCard(
              context,
              title: "How Zero‑Days Are Detected",
              description:
                  "Behavioral analysis, anomalies, and threat intelligence.",
              route: "/zero-detection",
            ),
            _topicCard(
              context,
              title: "Famous Zero‑Days",
              description: "Stuxnet, Follina, Pegasus, and more.",
              route: "/zero-famous",
            ),
            _topicCard(
              context,
              title: "Defending Against Zero‑Days",
              description:
                  "Mitigations, segmentation, monitoring, and resilience.",
              route: "/zero-defense",
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

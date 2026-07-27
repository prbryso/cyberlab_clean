import 'package:flutter/material.dart';

class PatchOverviewPage extends StatelessWidget {
  const PatchOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Patch Management")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patch Management: Closing Known Holes",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "Once a vulnerability becomes known, the race begins. Attackers rush "
              "to weaponize it. Defenders rush to patch it.\n\n"
              "Patch Management is the process of identifying, prioritizing, "
              "testing, and deploying patches across systems before attackers "
              "can exploit them.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 32),

            _topicCard(
              context,
              title: "What Is Patch Management?",
              description: "Learn why patching is essential for security.",
              route: "/patch-what",
            ),
            _topicCard(
              context,
              title: "The Patch Cycle",
              description: "How patches move from discovery to deployment.",
              route: "/patch-cycle",
            ),
            _topicCard(
              context,
              title: "Why Patching Fails",
              description: "The real reasons organizations fall behind.",
              route: "/patch-fails",
            ),
            _topicCard(
              context,
              title: "Famous Patch Failures",
              description:
                  "Equifax, WannaCry, and other preventable disasters.",
              route: "/patch-famous",
            ),
            _topicCard(
              context,
              title: "Patch Best Practices",
              description: "How defenders stay ahead of attackers.",
              route: "/patch-best",
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

import 'package:flutter/material.dart';

class CapstoneOverviewPage extends StatelessWidget {
  const CapstoneOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Capstone: Incident Response Simulation"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Incident Response Simulation",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "This capstone challenge puts you in the role of a cybersecurity "
              "analyst responding to a real‑world style cyber incident.\n\n"
              "Across five phases, you will analyze clues, identify attack "
              "vectors, and make decisions that determine the outcome.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 32),

            _phaseCard(
              context,
              title: "Phase 1: Reconnaissance",
              description: "Spot early warning signs and suspicious activity.",
              route: "/capstone-phase1",
            ),
            _phaseCard(
              context,
              title: "Phase 2: Breach",
              description: "Analyze how the attacker got in.",
              route: "/capstone-phase2",
            ),
            _phaseCard(
              context,
              title: "Phase 3: Escalation",
              description: "Determine how the attacker moved deeper.",
              route: "/capstone-phase3",
            ),
            _phaseCard(
              context,
              title: "Phase 4: Containment",
              description: "Decide how to stop the attack safely.",
              route: "/capstone-phase4",
            ),
            _phaseCard(
              context,
              title: "Phase 5: Lessons Learned",
              description: "Review what went wrong and how to prevent it.",
              route: "/capstone-phase5",
            ),
          ],
        ),
      ),
    );
  }

  Widget _phaseCard(
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

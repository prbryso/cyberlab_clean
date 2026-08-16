import 'package:flutter/material.dart';

class AttackSurfacePage extends StatelessWidget {
  const AttackSurfacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Understanding Attack Surface")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Understanding Attack Surface",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "Your attack surface is every possible entry point an attacker could "
              "use to compromise your system. The larger the attack surface, the "
              "more opportunities attackers have.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Common attack surface areas:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Open ports and network services."),
            _bullet("User accounts and permissions."),
            _bullet("Installed software and applications."),
            _bullet("Default configurations."),
            _bullet("APIs and web interfaces."),
            _bullet("Cloud services and exposed storage buckets."),

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

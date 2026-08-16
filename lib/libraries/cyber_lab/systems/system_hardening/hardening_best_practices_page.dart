import 'package:flutter/material.dart';

class HardeningBestPracticesPage extends StatelessWidget {
  const HardeningBestPracticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Hardening Best Practices")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hardening Best Practices",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _bullet("Disable unnecessary services and ports."),
            _bullet("Use least privilege for all accounts."),
            _bullet("Apply secure configuration baselines (CIS Benchmarks)."),
            _bullet("Enable OS protections like ASLR and DEP."),
            _bullet("Segment networks to limit lateral movement."),
            _bullet("Enforce strong authentication and MFA."),
            _bullet("Regularly audit configurations and permissions."),

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

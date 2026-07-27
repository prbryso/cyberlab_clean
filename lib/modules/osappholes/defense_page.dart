import 'package:flutter/material.dart';

class DefensePage extends StatelessWidget {
  const DefensePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Defending Against Vulnerabilities")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Defense Strategies",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _bullet("Apply patches and updates quickly"),
            _bullet("Harden OS and application configurations"),
            _bullet("Use least-privilege access controls"),
            _bullet("Monitor for known exploited vulnerabilities"),
            _bullet("Use modern security controls (EDR, MFA, allow-listing)"),
            _bullet("Secure coding practices"),
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

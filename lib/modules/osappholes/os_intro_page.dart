import 'package:flutter/material.dart';

class OsIntroPage extends StatelessWidget {
  const OsIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("What Is a Vulnerability?")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Understanding Vulnerabilities",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "A vulnerability is a flaw, weakness, or misconfiguration that allows an "
              "attacker to cause unintended behavior. Think of it as a crack in a "
              "castle wall — defenders may not notice it, but attackers will.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text("Where Vulnerabilities Appear", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Operating systems"),
            _bullet("Applications"),
            _bullet("Drivers and firmware"),
            _bullet("Cloud services"),
            _bullet("Libraries and dependencies"),
            const SizedBox(height: 32),
            Text(
              "Attackers only need one weakness to gain a foothold. Understanding "
              "where these holes appear is the first step in defending systems.",
              style: text.bodyLarge,
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

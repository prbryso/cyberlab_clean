import 'package:flutter/material.dart';

class ZeroDayDiscoveryPage extends StatelessWidget {
  const ZeroDayDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("How Zero‑Days Are Discovered")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How Zero‑Days Are Discovered",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _section(
              text,
              "1. Security Researchers",
              "Researchers find bugs through fuzzing, code review, and testing.",
            ),

            _section(
              text,
              "2. Bug Bounty Hunters",
              "Independent hunters discover flaws and report them for rewards.",
            ),

            _section(
              text,
              "3. Attackers",
              "Cybercriminals and nation‑states actively search for unknown flaws.",
            ),

            _section(
              text,
              "4. Accidental Discovery",
              "Sometimes a crash or odd behavior reveals a deeper issue.",
            ),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/zero-days"),
                child: const Text("← Back to Zero‑Days Overview"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(TextTheme text, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(body, style: text.bodyLarge),
        ],
      ),
    );
  }
}

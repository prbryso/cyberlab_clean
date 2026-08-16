import 'package:flutter/material.dart';

class WhatIsZeroDayPage extends StatelessWidget {
  const WhatIsZeroDayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("What Is a Zero‑Day?")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What Is a Zero‑Day?",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "A zero‑day vulnerability is a flaw that is unknown to the vendor. "
              "Because no patch exists, attackers can exploit it freely.\n\n"
              "The term 'zero‑day' refers to the number of days defenders have had "
              "to fix the issue: zero.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Key characteristics:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Unknown to the vendor."),
            _bullet("No patch or fix available."),
            _bullet("Highly valuable to attackers."),
            _bullet("Often used by nation‑states or advanced groups."),
            _bullet("Can remain hidden for years."),

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

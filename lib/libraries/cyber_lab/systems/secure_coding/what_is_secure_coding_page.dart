import 'package:flutter/material.dart';

class WhatIsSecureCodingPage extends StatelessWidget {
  const WhatIsSecureCodingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("What Is Secure Coding?")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What Is Secure Coding?",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "Secure Coding is the discipline of writing software that avoids "
              "introducing vulnerabilities. It focuses on preventing bugs that "
              "attackers can exploit.\n\n"
              "Most vulnerabilities are not exotic — they come from simple coding "
              "mistakes that can be avoided with the right practices.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Goals of secure coding:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Prevent vulnerabilities before they exist."),
            _bullet("Reduce reliance on patches and emergency fixes."),
            _bullet("Improve software reliability and stability."),
            _bullet("Protect users and data from exploitation."),
            _bullet("Build security into the development lifecycle."),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/secure"),
                child: const Text("← Back to Secure Coding Overview"),
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

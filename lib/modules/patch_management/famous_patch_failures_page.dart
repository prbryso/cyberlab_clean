import 'package:flutter/material.dart';

class FamousPatchFailuresPage extends StatelessWidget {
  const FamousPatchFailuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Famous Patch Failures")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Famous Patch Failures",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _example(
              text,
              "Equifax (2017)",
              "A known Apache Struts vulnerability went unpatched, leading to "
                  "one of the largest data breaches in history.",
            ),

            _example(
              text,
              "WannaCry (2017)",
              "Microsoft released a patch for EternalBlue, but millions of "
                  "systems never installed it — enabling a global ransomware outbreak.",
            ),

            _example(
              text,
              "NotPetya (2017)",
              "Another EternalBlue‑based attack that crippled shipping and logistics companies.",
            ),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, "/patch"),
                child: const Text("← Back to Patch Overview"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _example(TextTheme text, String title, String body) {
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

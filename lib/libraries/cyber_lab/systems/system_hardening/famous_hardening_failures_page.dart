import 'package:flutter/material.dart';

class FamousHardeningFailuresPage extends StatelessWidget {
  const FamousHardeningFailuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Famous Hardening Failures")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Famous Hardening Failures",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _example(
              text,
              "Capital One (2019)",
              "A misconfigured AWS firewall allowed an attacker to access "
                  "sensitive customer data.",
            ),

            _example(
              text,
              "Microsoft Exchange (2021)",
              "Weak configurations and exposed services enabled mass exploitation.",
            ),

            _example(
              text,
              "MongoDB Exposures",
              "Thousands of databases left open to the internet with no password.",
            ),

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

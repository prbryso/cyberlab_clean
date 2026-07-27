import 'package:flutter/material.dart';

class SecurePracticesPage extends StatelessWidget {
  const SecurePracticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Secure Coding Practices")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Secure Coding Practices",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _practice(
              text,
              "Input Validation",
              "Never trust user input. Validate, sanitize, and encode it.",
            ),

            _practice(
              text,
              "Safe Memory Handling",
              "Avoid unsafe functions, check bounds, and use modern languages when possible.",
            ),

            _practice(
              text,
              "Dependency Management",
              "Keep libraries updated and avoid untrusted packages.",
            ),

            _practice(
              text,
              "Error Handling",
              "Avoid exposing stack traces or sensitive information.",
            ),

            _practice(
              text,
              "Secure Authentication",
              "Use strong password hashing, MFA, and secure session handling.",
            ),

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

  Widget _practice(TextTheme text, String title, String body) {
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

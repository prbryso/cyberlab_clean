import 'package:flutter/material.dart';

class FamousCodingFailuresPage extends StatelessWidget {
  const FamousCodingFailuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Famous Coding Failures")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Famous Coding Failures",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _example(
              text,
              "Heartbleed",
              "A simple bounds‑checking mistake in OpenSSL exposed private keys and passwords.",
            ),

            _example(
              text,
              "Cloudflare Parser Bug",
              "A memory handling bug caused private data to leak across the internet.",
            ),

            _example(
              text,
              "Apple goto fail;",
              "A duplicated line of code broke SSL certificate validation.",
            ),

            _example(
              text,
              "Log4Shell",
              "A logging library allowed remote code execution through string parsing.",
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

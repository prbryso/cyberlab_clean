import 'package:flutter/material.dart';

class CommonVulnerabilitiesPage extends StatelessWidget {
  const CommonVulnerabilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Common Vulnerabilities")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Common Vulnerabilities",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _vuln(
              text,
              "SQL Injection",
              "Occurs when user input is inserted into SQL queries without sanitization.",
            ),

            _vuln(
              text,
              "Cross‑Site Scripting (XSS)",
              "Happens when untrusted data is rendered into web pages.",
            ),

            _vuln(
              text,
              "Buffer Overflows",
              "Caused by writing more data than a buffer can hold.",
            ),

            _vuln(
              text,
              "Insecure Deserialization",
              "Allows attackers to manipulate serialized objects.",
            ),

            _vuln(
              text,
              "Broken Authentication",
              "Weak login systems, session handling, or password storage.",
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

  Widget _vuln(TextTheme text, String title, String body) {
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

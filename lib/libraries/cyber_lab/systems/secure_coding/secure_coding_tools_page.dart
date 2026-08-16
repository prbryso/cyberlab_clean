import 'package:flutter/material.dart';

class SecureCodingToolsPage extends StatelessWidget {
  const SecureCodingToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Secure Coding Tools")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Secure Coding Tools",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _tool(
              text,
              "Static Application Security Testing (SAST)",
              "Analyzes source code for vulnerabilities before runtime.",
            ),

            _tool(
              text,
              "Dynamic Application Security Testing (DAST)",
              "Tests running applications for exploitable flaws.",
            ),

            _tool(
              text,
              "Dependency Scanners",
              "Detect vulnerable libraries and outdated packages.",
            ),

            _tool(text, "Linters", "Enforce consistent, safe coding patterns."),

            _tool(
              text,
              "Secret Scanners",
              "Detect hard‑coded passwords, API keys, and tokens.",
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

  Widget _tool(TextTheme text, String title, String body) {
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

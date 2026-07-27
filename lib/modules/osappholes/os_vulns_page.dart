import 'package:flutter/material.dart';

class OsVulnsPage extends StatelessWidget {
  const OsVulnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Operating System Vulnerabilities")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "OS-Level Weaknesses",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Operating systems like Windows, macOS, Linux, Android, and iOS form "
              "the foundation of all computing. When the OS has a weakness, the "
              "entire system is at risk.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            _bullet("Unpatched or outdated OS versions"),
            _bullet("Kernel flaws and memory corruption"),
            _bullet("Privilege escalation weaknesses"),
            _bullet("Insecure default configurations"),
            _bullet("Unnecessary services left enabled"),
            _bullet("Driver vulnerabilities"),
            _bullet("Bootloader weaknesses"),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Text("• "),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

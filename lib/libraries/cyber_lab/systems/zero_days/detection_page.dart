import 'package:flutter/material.dart';

class ZeroDayDetectionPage extends StatelessWidget {
  const ZeroDayDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("How Zero‑Days Are Detected")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How Zero‑Days Are Detected",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _bullet("Behavioral analysis — detecting unusual activity."),
            _bullet("Crash logs — unexpected crashes can reveal exploitation."),
            _bullet(
              "Threat intelligence — reports from researchers and vendors.",
            ),
            _bullet(
              "Anomaly detection — spotting deviations from normal patterns.",
            ),
            _bullet(
              "Honeypots — traps that catch attackers using unknown exploits.",
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

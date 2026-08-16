import 'package:flutter/material.dart';

class FamousZeroDaysPage extends StatelessWidget {
  const FamousZeroDaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Famous Zero‑Days")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Famous Zero‑Days",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _example(
              text,
              "Stuxnet",
              "Used multiple zero‑days to sabotage Iranian nuclear centrifuges.",
            ),

            _example(
              text,
              "Follina",
              "A Microsoft Office zero‑day that required no macros and no clicks.",
            ),

            _example(
              text,
              "Pegasus",
              "NSO Group spyware used zero‑click iPhone zero‑days.",
            ),

            _example(
              text,
              "Heartbleed (initially)",
              "Before disclosure, attackers quietly exploited it to steal secrets.",
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

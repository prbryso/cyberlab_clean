import 'package:flutter/material.dart';

class CapstonePhase5Page extends StatelessWidget {
  const CapstonePhase5Page({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Phase 5: Lessons Learned")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phase 5: Lessons Learned",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              "The incident is contained. Now you must determine what went wrong "
              "and how to prevent it from happening again.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 24),
            Text("Key takeaways:", style: text.titleLarge),
            const SizedBox(height: 12),
            _bullet("Weak passwords enabled initial access."),
            _bullet("Phishing email was not reported."),
            _bullet("Unpatched server allowed exploitation."),
            _bullet("Hardening gaps enabled lateral movement."),
            _bullet("Lack of secure coding created the root vulnerability."),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/capstone',
                    (route) => route.isFirst,
                  );
                },
                child: const Text("Finish Capstone"),
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
      children: [
        const Text("• "),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

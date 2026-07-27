import 'package:flutter/material.dart';

class PatchCyclePage extends StatelessWidget {
  const PatchCyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("The Patch Cycle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The Patch Cycle",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _step(
              text,
              "1. Discovery",
              "A vulnerability becomes known to the vendor.",
            ),
            _step(
              text,
              "2. Patch Development",
              "Engineers create and test a fix.",
            ),
            _step(text, "3. Patch Release", "The vendor publishes the update."),
            _step(
              text,
              "4. Testing",
              "Organizations test the patch in their environment.",
            ),
            _step(
              text,
              "5. Deployment",
              "The patch is rolled out to all systems.",
            ),
            _step(
              text,
              "6. Verification",
              "Admins confirm the patch was applied successfully.",
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

  Widget _step(TextTheme text, String title, String body) {
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

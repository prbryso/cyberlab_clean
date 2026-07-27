import 'package:flutter/material.dart';
import 'package:systems_studio/theme/spacing.dart';

class WeakCaptchaDetail extends StatelessWidget {
  const WeakCaptchaDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("CAPTCHA & Bot Protection")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CAPTCHA & Bot Protection",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            // ------------------------------------------------------------
            // Definition
            // ------------------------------------------------------------
            Text("Definition", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: spacing.sm),
            Text(
              "CAPTCHA stands for 'Completely Automated Public Turing test to tell Computers and Humans Apart.' "
              "It’s a short challenge designed to distinguish real people from automated bots.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            // ------------------------------------------------------------
            // Visual Example
            // ------------------------------------------------------------
            Center(
              child: Image.asset(
                'assets/images/captcha.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: spacing.lg),

            // ------------------------------------------------------------
            // Description
            // ------------------------------------------------------------
            Text(
              "CAPTCHAs are challenges designed to tell humans and bots apart. "
              "They stop automated systems from blasting login pages with millions of password guesses.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            Text(
              "🤖 Why CAPTCHA Exists",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "Attackers use automated tools to try thousands of passwords per second. "
              "CAPTCHAs interrupt that automation by forcing a human to solve a puzzle.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "🧩 Common CAPTCHA Types",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• Image selection (\"click all the traffic lights\")\n"
              "• Distorted text recognition\n"
              "• Checkbox (“I’m not a robot”)\n"
              "• Behavioral analysis (mouse movement, timing)\n"
              "• Invisible CAPTCHA (background bot detection)",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "🧠 Why This Matters",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "CAPTCHAs don’t make passwords stronger — they make attacks harder. "
              "They protect login pages from automated brute‑force attempts and credential stuffing.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MFAOverviewScreen extends StatelessWidget {
  const MFAOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Multi‑Factor Authentication")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ------------------------------------------------------------
          // Title
          // ------------------------------------------------------------
          Text(
            "Multi‑Factor Authentication",
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),

          // ------------------------------------------------------------
          // What Is MFA?
          // ------------------------------------------------------------
          Text("What Is MFA?", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Multi‑Factor Authentication (MFA) adds an extra layer of security by "
            "requiring more than just a password. Even if someone steals your password, "
            "they still can’t get in without the second factor.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // ------------------------------------------------------------
          // Why It Matters
          // ------------------------------------------------------------
          Text("Why It Matters", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Most account breaches happen because passwords are weak or reused. "
            "MFA stops attackers by requiring something only you have — like a phone, "
            "a code, or a fingerprint.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // ------------------------------------------------------------
          // Coming Up Next
          // ------------------------------------------------------------
          Text("Coming Up Next", style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),

          NextTopicLink(
            title: "Types of MFA",
            onTap: () => Navigator.pushNamed(context, '/mfa_types'),
          ),
          NextTopicLink(
            title: "Authenticator Apps",
            onTap: () => Navigator.pushNamed(context, '/authenticator_apps'),
          ),
          NextTopicLink(
            title: "SMS Codes (and their weaknesses)",
            onTap: () => Navigator.pushNamed(context, '/sms_mfa'),
          ),
          NextTopicLink(
            title: "Hardware Security Keys",
            onTap: () => Navigator.pushNamed(context, '/security_keys'),
          ),
          NextTopicLink(
            title: "Real‑World MFA Success Stories",
            onTap: () => Navigator.pushNamed(context, '/mfa_cases'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class NextTopicLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const NextTopicLink({Key? key, required this.title, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(
              "> ",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

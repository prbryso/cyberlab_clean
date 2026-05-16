import 'package:flutter/material.dart';

class PasswordOverviewScreen extends StatelessWidget {
  const PasswordOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Password Overview")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ------------------------------------------------------------
          // What Are Passwords?
          // ------------------------------------------------------------
          Text("What Are Passwords?", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Passwords are the first line of defense for most accounts. "
            "They protect your identity, your data, and your online activity. "
            "A strong password makes it significantly harder for attackers to break in.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // ------------------------------------------------------------
          // Why Passwords Fail
          // ------------------------------------------------------------
          Text("Why Passwords Fail", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "Most password attacks succeed not because attackers are brilliant, "
            "but because passwords are predictable. Weak choices, reused passwords, "
            "and simple patterns make accounts easy targets.",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // ------------------------------------------------------------
          // Coming Up Next (Clickable Links)
          // ------------------------------------------------------------
          Text("Coming Up Next", style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),

          NextTopicLink(
            title: "Weak Passwords",
            onTap: () => Navigator.pushNamed(context, '/weak_passwords'),
          ),
          NextTopicLink(
            title: "Password Cracking",
            onTap: () => Navigator.pushNamed(context, '/password_cracking'),
          ),
          NextTopicLink(
            title: "Hashing & Salting",
            onTap: () => Navigator.pushNamed(context, '/hashing_salt'),
          ),
          NextTopicLink(
            title: "Real-World Password Breaches",
            onTap: () => Navigator.pushNamed(context, '/password_breaches'),
          ),
          NextTopicLink(
            title: "Password Managers",
            onTap: () => Navigator.pushNamed(context, '/password_managers'),
          ),
          NextTopicLink(
            title: "Multi-Factor Authentication",
            onTap: () => Navigator.pushNamed(context, '/mfa'),
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

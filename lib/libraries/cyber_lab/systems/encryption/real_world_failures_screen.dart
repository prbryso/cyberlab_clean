import 'package:flutter/material.dart';

class RealWorldFailuresScreen extends StatelessWidget {
  const RealWorldFailuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real‑World Encryption Failures')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'When Encryption Goes Wrong',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            Text(
              'Encryption is powerful — but only when used correctly. '
              'History is full of cases where companies used outdated algorithms, weak keys, or bad configurations, '
              'and attackers took full advantage.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              '1. Using Outdated Algorithms (MD5, SHA‑1, DES)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Some companies still use old algorithms that were broken years ago. '
              'MD5 and SHA‑1 can be cracked with modern hardware, and DES can be brute‑forced in hours. '
              'If a system relies on these, attackers can break the encryption outright.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              '2. Weak or Short Keys',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Even strong algorithms fail if the keys are too short. '
              'For example, RSA keys under 1024 bits can be cracked today. '
              'Attackers simply compute the private key and decrypt everything.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              '3. Hard‑Coded Keys in Apps',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Some developers accidentally ship their private keys inside apps or firmware. '
              'Once attackers extract the key, they can decrypt data, impersonate servers, or push fake updates.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              '4. Misconfigured HTTPS (No Certificate Validation)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'If an app doesn’t properly check certificates, attackers can perform man‑in‑the‑middle attacks. '
              'This lets them read passwords, messages, and private data — even though HTTPS appears to be “on.”',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              '5. Leaked Private Keys',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'If a private key is leaked, the entire system collapses. '
              'Attackers can decrypt traffic, impersonate servers, and sign malicious software. '
              'This has happened to major companies and certificate authorities.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              '6. No Encryption at All (The Silent Failure)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Sometimes the biggest failure is simply forgetting to turn encryption on. '
              'Databases, backups, and cloud storage buckets have been found storing sensitive data in plain text. '
              'Attackers don’t need to break encryption if there isn’t any.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'The Lesson',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Encryption is only as strong as the people who implement it. '
              'A single weak key, outdated algorithm, or misconfiguration can expose millions of users.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

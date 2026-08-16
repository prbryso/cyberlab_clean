import 'package:flutter/material.dart';

class HttpsScreen extends StatelessWidget {
  const HttpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How HTTPS Works')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'The Padlock That Protects the Internet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            Text(
              'Every time you see the little padlock in your browser, HTTPS is protecting your connection. '
              'It keeps attackers from spying on your passwords, messages, or personal information.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'The Problem HTTPS Solves',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'When you connect to a website, your data travels across many networks — Wi‑Fi routers, '
              'internet providers, and servers you don’t control. Without encryption, anyone along the path '
              'could read or modify your data.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'The TLS Handshake (The Magic Part)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'HTTPS uses a process called the TLS handshake to create a secure connection. '
              'Here’s what happens behind the scenes:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            Text(
              '1. **Your browser says hello**\n'
              '   It sends a list of encryption methods it supports.\n\n'
              '2. **The server sends its public key + certificate**\n'
              '   The certificate proves the server is who it claims to be.\n\n'
              '3. **Your browser verifies the certificate**\n'
              '   If it’s valid, the padlock appears.\n\n'
              '4. **Your browser creates a symmetric key**\n'
              '   This key will encrypt all data.\n\n'
              '5. **The symmetric key is encrypted with the server’s public key**\n'
              '   Only the server’s private key can unlock it.\n\n'
              '6. **Both sides switch to fast symmetric encryption**\n'
              '   Now the connection is secure.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'Why Use Both Types of Encryption?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Asymmetric encryption is used only for the handshake because it’s slow. '
              'Once the symmetric key is shared, the connection switches to symmetric mode, '
              'which is extremely fast and secure.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'What HTTPS Protects You From',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              '• Wi‑Fi snooping\n'
              '• Man‑in‑the‑middle attacks\n'
              '• Fake hotspots\n'
              '• Data tampering\n'
              '• Password theft\n\n'
              'Without HTTPS, logging into any site would be dangerous.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

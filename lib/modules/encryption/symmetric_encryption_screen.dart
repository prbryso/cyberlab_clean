import 'package:flutter/material.dart';

class SymmetricEncryptionScreen extends StatelessWidget {
  const SymmetricEncryptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symmetric Encryption')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'One Key for Everything',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            Text(
              'Symmetric encryption is the simplest form of encryption: '
              'the same key is used to lock (encrypt) and unlock (decrypt) the data. '
              'If you and I both have the same key, we can communicate securely.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'Why It’s Used Everywhere',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Symmetric encryption is extremely fast — much faster than public‑key encryption. '
              'Because of that, it’s used for almost all encrypted data you interact with every day:\n\n'
              '• Wi‑Fi networks (WPA2 / WPA3)\n'
              '• Encrypted hard drives\n'
              '• VPN tunnels\n'
              '• Messaging apps (after the initial key exchange)\n'
              '• HTTPS sessions (after the handshake)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'The Most Common Algorithm: AES',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'AES (Advanced Encryption Standard) is the world’s most widely used symmetric cipher. '
              'It comes in key sizes of 128, 192, and 256 bits. AES‑256 is considered extremely secure '
              'and is approved for top‑secret government data.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'The Big Weakness',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Symmetric encryption has one major challenge: key sharing. '
              'If both people need the same key, how do you safely send it to them without an attacker stealing it? '
              'This is known as the “key distribution problem.”',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'How We Solve It',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Modern systems solve the key distribution problem by using asymmetric encryption '
              'to exchange the symmetric key securely. Once both sides have the key, they switch to symmetric mode '
              'because it’s much faster.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

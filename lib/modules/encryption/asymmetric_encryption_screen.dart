import 'package:flutter/material.dart';

class AsymmetricEncryptionScreen extends StatelessWidget {
  const AsymmetricEncryptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Asymmetric Encryption')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Two Keys, One System',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            Text(
              'Asymmetric encryption uses a pair of keys: a public key and a private key. '
              'They are mathematically linked, but you cannot figure out the private key '
              'even if you know the public one.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'How It Works',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              '• The **public key** can be shared with anyone.\n'
              '• The **private key** must be kept secret.\n\n'
              'If someone encrypts a message with your public key, only your private key can decrypt it. '
              'This allows two people to communicate securely without ever sharing a secret key beforehand.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'Why It’s Powerful',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Asymmetric encryption solves the biggest problem in symmetric encryption: '
              'how to safely share the key. With public‑key systems, you don’t need to share a secret at all. '
              'Anyone can send you an encrypted message, and only you can open it.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'Common Algorithms',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              '• **RSA** — the classic algorithm, used for decades\n'
              '• **ECC (Elliptic Curve Cryptography)** — faster and more secure at smaller key sizes\n'
              '• **Diffie–Hellman** — used for secure key exchange\n\n'
              'Modern systems increasingly use ECC because it provides strong security with much smaller keys.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'Digital Signatures',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Asymmetric encryption also enables digital signatures. '
              'If you sign something with your private key, anyone can verify the signature using your public key. '
              'This proves the message came from you and wasn’t altered.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 20),

            Text(
              "A clearer look at digital signatures",
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              "Digital signatures are often confused with encryption, but they serve a "
              "different purpose. Instead of hiding the message, a digital signature proves "
              "who sent it and that it wasn’t changed.\n\n"
              "Here’s how it works:\n"
              "• The sender creates a hash (a fingerprint) of the message.\n"
              "• They encrypt that hash using their private key — this becomes the signature.\n"
              "• The receiver uses the sender’s public key to decrypt the signature.\n"
              "• If the decrypted hash matches the message’s hash, the message is authentic.\n\n"
              "This gives us two guarantees:\n"
              "1. Authenticity — only the sender’s private key could have created the signature.\n"
              "2. Integrity — if the message were altered, the hashes wouldn’t match.\n\n"
              "Digital signatures are used alongside encryption: encryption protects secrecy, "
              "while signatures protect trust.\n",
              style: theme.textTheme.bodyLarge,
            ),

            Text(
              "How does the receiver know how to hash the message?",
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              "The hashing algorithm used for digital signatures is not a secret. "
              "Both sides use the same public hashing standard (such as SHA‑256). "
              "The sender signs the hash of the message, and the receiver recomputes "
              "the hash using the same algorithm. If the two hashes match, the message "
              "is authentic and unchanged. The only secret in this process is the "
              "sender’s private key, which is used to create the signature.",
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            Text(
              'How Asymmetric Encryption Is Used in the Real World',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'Asymmetric encryption is rarely used by itself. It is powerful, but it is also '
              'slow and computationally expensive. Instead, real systems use it for very specific '
              'tasks where its strengths matter most:\n\n'
              '• Secure key exchange — used to safely share a symmetric key\n'
              '• Digital signatures — proving identity and message integrity\n'
              '• Authentication — verifying servers, users, and software\n\n'
              'Once a symmetric key is exchanged, almost all real‑world encryption switches to '
              'fast symmetric algorithms like AES. This hybrid approach is what powers HTTPS, '
              'VPNs, messaging apps, and nearly every secure system today.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            Text(
              'Where You See This Every Day',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              '• HTTPS websites\n'
              '• Secure messaging apps\n'
              '• Software updates\n'
              '• Cryptocurrency wallets\n'
              '• SSH logins\n\n'
              'Every time you see the padlock icon in your browser, asymmetric encryption is working behind the scenes.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

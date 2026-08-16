import 'package:flutter/material.dart';

class MathOverviewScreen extends StatelessWidget {
  const MathOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mathematical Overview of Encryption')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --------------------------------------------------
            // 1. The Goal of Encryption
            // --------------------------------------------------
            Text(
              '1. The Goal of Encryption',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Mathematically, encryption is a function that turns plaintext into ciphertext:\n\n'
              '  ciphertext = E_key(plaintext)\n\n'
              'Decryption is the inverse function:\n\n'
              '  plaintext = D_key(ciphertext)\n\n'
              'The goal is to design E and D so that they are easy to compute with the right key, '
              'but practically impossible to reverse without the key.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 2. Symmetric Encryption
            // --------------------------------------------------
            Text(
              '2. Symmetric Encryption (Math Synopsis)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Core idea: use a shared secret key to transform data so it looks random.\n\n'
              'Mathematical tools involved:\n'
              '• Substitution (replacing bytes with other bytes)\n'
              '• Permutation (shuffling positions)\n'
              '• Modular arithmetic (numbers wrap around)\n'
              '• Bitwise operations (like XOR)\n'
              '• Multiple rounds of these operations\n\n'
              'Ciphers like AES repeatedly apply substitution, permutation, and XOR with round keys. '
              'The math ensures that small changes in the input cause large, unpredictable changes in the output, '
              'and reversing the process without the key is computationally infeasible.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 3. Asymmetric Encryption
            // --------------------------------------------------
            Text(
              '3. Asymmetric Encryption (Math Synopsis)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Core idea: use math problems that are easy to compute in one direction, but extremely hard to reverse. '
              'These are called one-way functions.\n\n'
              'Examples of hard problems:\n'
              '• RSA: factoring a large number into its prime factors\n'
              '• ECC: solving the elliptic curve discrete logarithm problem\n\n'
              'The public key describes a mathematical function, and the private key is the secret needed to reverse it. '
              'In RSA, for example, encryption and decryption can be written as:\n\n'
              '  C = M^e mod n\n'
              '  M = C^d mod n\n\n'
              'Knowing e and n does not make it feasible to find d. That hardness is what provides security.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 4. Hashing
            // --------------------------------------------------
            Text(
              '4. Hashing (Math Synopsis)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Core idea: a hash function takes any input and produces a fixed-size output:\n\n'
              '  h = H(m)\n\n'
              'A good cryptographic hash function is:\n'
              '• One-way (you cannot recover m from h)\n'
              '• Collision-resistant (hard to find two different inputs with the same output)\n'
              '• Avalanche-prone (tiny changes in input cause large changes in output)\n\n'
              'Internally, hashes use bitwise operations, modular addition, and mixing/compression steps to '
              'spread input changes across the entire output.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 5. Digital Signatures
            // --------------------------------------------------
            Text(
              '5. Digital Signatures (Math Synopsis)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Core idea: use asymmetric math to sign a hash of the message.\n\n'
              'Steps:\n'
              '1. Compute the hash of the message:  h = H(m)\n'
              '2. Sign the hash with the private key:  s = Sign_priv(h)\n'
              '3. Verify using the public key:  Verify_pub(m, s)\n\n'
              'The math ensures that only the holder of the private key could have created the signature, '
              'and anyone with the public key can verify it. This provides authenticity and integrity.',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 6. Hybrid Encryption
            // --------------------------------------------------
            Text(
              '6. Hybrid Encryption (Math Synopsis)',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Real-world systems combine all of these pieces:\n\n'
              '1. Asymmetric encryption is used to protect or exchange a symmetric key.\n'
              '2. Symmetric encryption is used to encrypt all bulk data efficiently.\n'
              '3. Hashing and digital signatures are used to provide integrity and authenticity.\n\n'
              'This hybrid approach gives:\n'
              '• Speed (from symmetric encryption)\n'
              '• Secure key exchange (from asymmetric encryption)\n'
              '• Trust and tamper-detection (from hashes and signatures).',
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // 7. One-Sentence Summary
            // --------------------------------------------------
            Text(
              '7. One-Sentence Summary',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Symmetric encryption uses fast transformations with a shared key, asymmetric encryption relies on hard '
              'one-way math problems with public/private keys, hashing compresses data into irreversible fingerprints, '
              'digital signatures sign those fingerprints with private keys, and hybrid encryption combines all of them '
              'to secure real-world communication.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

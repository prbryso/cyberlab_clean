import 'package:flutter/material.dart';

class HashingVsEncryptionScreen extends StatelessWidget {
  const HashingVsEncryptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hashing vs Encryption')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Hashing Is NOT Encryption',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            Text(
              'People often confuse hashing with encryption, but they are completely different tools. '
              'Encryption is reversible. Hashing is not. That one difference changes everything.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'What Is Hashing?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Hashing takes any input — a password, a file, a message — and runs it through a mathematical function '
              'to produce a fixed‑length output called a hash. The key idea: you cannot turn a hash back into the original data.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            Text(
              'Examples of Hash Functions:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              '• SHA‑256\n'
              '• SHA‑1 (old and broken)\n'
              '• MD5 (very broken)\n'
              '• bcrypt / scrypt / Argon2 (designed for passwords)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'What Is Encryption?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Encryption transforms data into unreadable ciphertext, but it can always be reversed with the correct key. '
              'That’s the whole point — you want to get the original data back.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'Why Passwords Are Hashed, Not Encrypted',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'If a company encrypted your password, they would also need to store the key somewhere. '
              'If attackers stole that key, they could decrypt every password instantly.\n\n'
              'Hashing avoids this problem because there is no key and no way to reverse the hash.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'Salting: The Secret Ingredient',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'A salt is a random value added to your password before hashing. '
              'This prevents attackers from using precomputed lookup tables (rainbow tables) to crack hashes instantly.\n\n'
              'Every user gets a unique salt — even if two people use the same password, their hashes will be different.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Text(
              'Real‑World Example',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'If your password is "Puppy123", the hash might look like:\n\n'
              '  8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918\n\n'
              'There is no way to turn that back into "Puppy123". '
              'The only way to guess it is to try millions of passwords until one produces the same hash.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

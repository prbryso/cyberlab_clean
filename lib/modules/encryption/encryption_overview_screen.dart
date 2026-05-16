import 'package:flutter/material.dart';

class EncryptionOverviewScreen extends StatelessWidget {
  const EncryptionOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Encryption Overview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "What Is Encryption?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Encryption is the process of turning readable information (plaintext) "
              "into unreadable information (ciphertext). Only someone with the correct "
              "key can turn it back into something useful.",
            ),
            const SizedBox(height: 20),

            const Text(
              "Why It Matters",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Every time you send a message, log into a website, or connect to Wi-Fi, "
              "encryption protects your data from attackers.",
            ),
            const SizedBox(height: 30),

            const Text(
              "Coming Up Next",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _NextItem(
              title: "Asymmetric Encryption",
              route: "/encryption/asymmetric",
            ),
            _NextItem(
              title: "Symmetric Encryption",
              route: "/encryption/symmetric",
            ),
            _NextItem(title: "How HTTPS Works", route: "/encryption/https"),
            _NextItem(
              title: "Hashing vs Encryption",
              route: "/encryption/hashing",
            ),
            _NextItem(
              title: "Real-World Encryption Failures",
              route: "/encryption/failures",
            ),
            _NextItem(
              title: "Actul Failure Cases in Cryptography",
              route: "/encryption/cases",
            ),

            _NextItem(
              title: "Interactive Encryption Demo",
              route: "/encryption/demo",
            ),
            _NextItem(
              title: "An Overview of the Math Behind Encryption",
              route: "/encryption/math",
            ),
          ],
        ),
      ),
    );
  }
}

class _NextItem extends StatelessWidget {
  final String title;
  final String route;

  const _NextItem({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.arrow_forward_ios, size: 18),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

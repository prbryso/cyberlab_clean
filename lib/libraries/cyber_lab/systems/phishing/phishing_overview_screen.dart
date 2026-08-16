import 'package:flutter/material.dart';

class PhishingOverviewScreen extends StatelessWidget {
  const PhishingOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phishing Overview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "What Is Phishing?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Phishing is when an attacker pretends to be someone trustworthy — "
              "like a company, friend, or service — to trick you into clicking a link, "
              "opening an attachment, or giving away sensitive information.",
            ),
            const SizedBox(height: 20),

            const Text(
              "Why It Matters",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Phishing is the #1 way attackers steal passwords, money, and identities. "
              "Even careful people can fall for realistic scams, and schools, families, "
              "and businesses are frequent targets.",
            ),
            const SizedBox(height: 30),

            const Text(
              "Coming Up Next",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            const _NextItem(
              title: "More on Phishing",
              route: "/phishing/module",
            ),

            const _NextItem(
              title: "Phishing Examples",
              route: "/phishing/examples",
            ),
            const _NextItem(
              title: "Spot the Red Flags",
              route: "/phishing/spot",
            ),
            const _NextItem(
              title: "Email Header Analyzer",
              route: "/phishing/header",
            ),
            const _NextItem(
              title: "Malware Overview",
              route: "/phishing/malware",
            ),
            const _NextItem(title: "Phishing Quiz", route: "/phishing/quiz"),
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

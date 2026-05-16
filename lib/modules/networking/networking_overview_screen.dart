import 'package:flutter/material.dart';

class NetworkingOverviewScreen extends StatelessWidget {
  const NetworkingOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Networking Overview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "What Is Networking?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Networking is how devices communicate and share information. "
              "Phones, laptops, tablets, and servers all connect to form networks "
              "that allow data to move from one place to another.",
            ),
            const SizedBox(height: 20),

            const Text(
              "Why It Matters",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Every part of cybersecurity depends on networking. Understanding how "
              "devices communicate helps explain how attacks spread and how data "
              "is protected.",
            ),
            const SizedBox(height: 30),

            const Text(
              "Coming Up Next",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            const _NextItem(
              title: "How Devices Communicate",
              route: "/networking/communication",
            ),
            const _NextItem(
              title: "What Is an IP Address?",
              route: "/networking/ip",
            ),
            const _NextItem(
              title: "What Is a Router?",
              route: "/networking/router",
            ),
            const _NextItem(
              title: "Ports & Protocols",
              route: "/networking/ports",
            ),
            const _NextItem(
              title: "How the Internet Works",
              route: "/networking/internet",
            ),
            const _NextItem(
              title: "Home Network Safety",
              route: "/networking/safety",
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

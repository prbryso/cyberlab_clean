import 'package:flutter/material.dart';

class NetworkingInternetScreen extends StatelessWidget {
  const NetworkingInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("How the Internet Works")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "The Internet: A Giant Postal and Road System Combined",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "When you load a webpage, your device sends tiny packets — digital "
              "envelopes — across a massive global network. These packets travel "
              "through your router, your internet provider, regional networks, and "
              "undersea cables before reaching the destination server.",
            ),
            SizedBox(height: 20),

            Text(
              "DNS: Turning Names Into Addresses (The Internet’s GPS)",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "When you type a website name like amazon.com, your device doesn’t "
              "know where that is. DNS translates the name into an IP address — "
              "the real location of the server. Without DNS, you’d have to memorize "
              "IP addresses for every site you visit.",
            ),
            SizedBox(height: 20),

            Text(
              "Routing: How Packets Choose a Path Across the World",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Packets may travel through dozens of routers before reaching their "
              "destination. Each router chooses the fastest or least congested path. "
              "Packets can take different routes and arrive out of order, but your "
              "device reassembles them into the original message.",
            ),
            SizedBox(height: 20),

            Text(
              "HTTPS: Encryption That Protects You on the Move",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "HTTPS encrypts your data so attackers cannot read it, even if they "
              "intercept the packets. Without HTTPS, anyone on the same Wi‑Fi — "
              "like at a coffee shop — could see your passwords, messages, or "
              "personal information.\n\n"
              "Understanding how the internet moves data helps students see where "
              "attacks can happen — and how encryption defends against them.",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

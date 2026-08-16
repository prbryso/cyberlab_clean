import 'package:flutter/material.dart';

class NetworkingSafetyScreen extends StatelessWidget {
  const NetworkingSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Network Safety")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "Your Router: The Front Door to Your Digital Life",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "If your router is insecure, everything behind it is vulnerable. "
              "Attackers target outdated routers, default passwords, weak Wi‑Fi "
              "settings, and exposed admin panels. Securing your router protects "
              "every device in your home.",
            ),
            SizedBox(height: 20),

            Text(
              "Use Strong Wi‑Fi Security (WPA2 or WPA3 Only)",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "WPA3 is the strongest Wi‑Fi security. WPA2 is still acceptable. "
              "Never use WEP — it can be cracked in under a minute with free tools. "
              "A strong Wi‑Fi password plus modern security is critical.",
            ),
            SizedBox(height: 20),

            Text(
              "Update Your Router Like Any Other Device",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Routers need updates just like phones and laptops. Firmware updates "
              "fix vulnerabilities that attackers can exploit. Many home network "
              "breaches happen because the router was never updated.",
            ),
            SizedBox(height: 20),

            Text(
              "Use a Guest Network for Visitors and Smart Devices",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Guest networks isolate visitors and smart home devices from your main "
              "network. This prevents malware on one device from spreading to others. "
              "It’s one of the simplest and most effective ways to protect your home.",
            ),
            SizedBox(height: 20),

            Text(
              "Why IoT Devices Are High‑Risk and How to Contain Them",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Smart bulbs, cameras, doorbells, and other IoT devices often have weak "
              "security and rarely get updates. If one gets hacked, attackers may "
              "gain access to your entire network. Keeping them on a guest network "
              "helps contain the damage and protect your main devices.",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NetworkingRouterScreen extends StatelessWidget {
  const NetworkingRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("What Is a Router?")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "Routers: The Traffic Directors of Your Network",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "A router decides where packets go. It sits between your home devices "
              "and the internet, directing traffic so that each packet reaches the "
              "right destination without collisions or confusion.",
            ),
            SizedBox(height: 20),

            Text(
              "NAT: Many Devices, One Public IP Address",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Network Address Translation (NAT) lets many devices share a single "
              "public IP address. Your phone, laptop, and game console may all "
              "appear as one device to the outside world, thanks to your router.",
            ),
            SizedBox(height: 20),

            Text(
              "Routers as Security Devices, Not Just Wi‑Fi Boxes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Routers act as firewalls, blocking unwanted traffic from the internet. "
              "They can filter dangerous requests, close unused ports, and isolate "
              "devices. A poorly configured router, however, can expose your entire "
              "home network to attackers.",
            ),
            SizedBox(height: 20),

            Text(
              "Why Router Updates and Passwords Matter So Much",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Attackers often target routers with default passwords or outdated "
              "firmware. Updating your router and changing the admin password are "
              "two of the most important steps in home cybersecurity.\n\n"
              "When students understand routers, they understand the gateway between "
              "their home and the entire internet.",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

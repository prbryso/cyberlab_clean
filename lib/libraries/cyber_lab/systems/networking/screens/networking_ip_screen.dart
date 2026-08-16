import 'package:flutter/material.dart';

class NetworkingIPScreen extends StatelessWidget {
  const NetworkingIPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("What Is an IP Address?")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "IP Addresses: Your Device’s Home Address on the Network",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Every device on a network needs an address so data knows where to go. "
              "That address is called an IP address. Without it, your device would "
              "be invisible — it could send nothing and receive nothing.",
            ),
            SizedBox(height: 20),

            Text(
              "IPv4 vs IPv6: Old vs New Address Systems",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "IPv4 uses familiar numbers like 192.168.1.5. It was designed when the "
              "internet was small. Today, we have billions of devices, so IPv6 was "
              "created with much longer addresses to support almost unlimited devices.",
            ),
            SizedBox(height: 20),

            Text(
              "Public vs Private IPs: Inside vs Outside Your Home",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Private IPs are used inside your home network. Your router assigns them "
              "to your phone, laptop, TV, and other devices.\n\n"
              "Public IPs are used on the internet. Your internet provider gives your "
              "router a public IP so websites know where to send data back.",
            ),
            SizedBox(height: 20),

            Text(
              "Why IP Addresses Matter in Cybersecurity",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Attackers scan public IP addresses looking for vulnerable systems. "
              "Firewalls block suspicious IPs. VPNs hide your real IP to protect "
              "your privacy. IP addresses can even reveal your approximate location.\n\n"
              "Understanding IPs helps students see how devices are found, tracked, "
              "and sometimes attacked on the internet.",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

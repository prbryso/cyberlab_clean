import 'package:flutter/material.dart';

class NetworkingPortsScreen extends StatelessWidget {
  const NetworkingPortsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ports & Protocols")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "Ports: The Hidden Doors You Never See",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Every device has 65,535 ports — but you never see them. They’re "
              "invisible doors that software uses to communicate.",
            ),
            SizedBox(height: 20),

            Text(
              "Real‑World Examples of Ports",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "When you visit a website:\n"
              "• Your browser opens port 443\n"
              "• Your device says: “I want to talk HTTPS”\n"
              "• The server responds on the same port\n\n"
              "When you play a game:\n"
              "• The game might use port 3074\n"
              "• That’s how multiplayer traffic flows\n\n"
              "When you send email:\n"
              "• Your device uses port 25 or 587\n\n"
              "Each port is a dedicated lane for a specific type of traffic.",
            ),
            SizedBox(height: 20),

            Text(
              "Why Ports Matter in Cybersecurity",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Attackers don’t break in through the front door. They break in "
              "through open ports.\n\n"
              "They scan the internet looking for:\n"
              "• Ports running outdated software\n"
              "• Ports left open accidentally\n"
              "• Ports that reveal what system you’re running\n\n"
              "This is called port scanning, and it’s the first step in most attacks.",
            ),
            SizedBox(height: 20),

            Text(
              "Protocols: The Rules of the Road",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "A protocol is a language.\n"
              "• HTTP/HTTPS → websites\n"
              "• DNS → finding servers\n"
              "• FTP → file transfers\n"
              "• SMTP → email\n"
              "• SSH → secure remote access\n\n"
              "If ports are doors, protocols are the conversations happening behind them.",
            ),
            SizedBox(height: 20),

            Text(
              "• ports = doors\n"
              "• protocols = languages\n"
              "• scanning = checking which doors are unlocked\n\n",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

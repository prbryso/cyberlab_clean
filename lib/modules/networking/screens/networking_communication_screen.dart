import 'package:flutter/material.dart';

class NetworkingCommunicationScreen extends StatelessWidget {
  const NetworkingCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("How Devices Communicate")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "Packets: How Data Really Moves",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "When you send a message, stream a video, or load a webpage, your device "
              "breaks the data into tiny pieces called packets. Each packet contains "
              "part of the data plus information about where it’s going and how to "
              "reassemble it when it arrives.",
            ),
            SizedBox(height: 20),

            Text(
              "Sending & Receiving",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Packets travel across networks through routers and switches. They may "
              "take different paths and arrive at different times, but your device "
              "reassembles them into the original message.",
            ),
            SizedBox(height: 20),

            Text(
              "Why This Matters for Security",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Attackers can intercept or modify packets on unsecured networks. "
              "This is why HTTPS and encryption are essential — they protect packets "
              "from being read or changed.",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

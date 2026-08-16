import 'package:flutter/material.dart';

class DeepfakesScreen extends StatelessWidget {
  const DeepfakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deepfake Scams")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "What Are Deepfakes?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Deepfakes use AI to create realistic fake videos, audio, or images. "
              "Attackers use them to impersonate friends, family, or authority figures.",
            ),
            SizedBox(height: 20),

            Text(
              "Why They Are Dangerous",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Deepfakes can pressure people into sending money, sharing private "
              "information, or clicking harmful links. They are becoming harder to "
              "detect as technology improves.",
            ),
            SizedBox(height: 20),

            Text(
              "Common Examples",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "• Fake voicemail from a parent asking for money.\n"
              "• Fake video of a teacher requesting login info.\n"
              "• Fake audio message claiming to be a friend in trouble.",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

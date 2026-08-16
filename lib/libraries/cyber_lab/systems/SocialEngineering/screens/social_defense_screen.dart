import 'package:flutter/material.dart';

class SocialDefenseScreen extends StatelessWidget {
  const SocialDefenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Defending Against Social Engineering")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "How to Stay Safe",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "You can protect yourself from social engineering by slowing down, "
              "verifying identities, and questioning anything that feels urgent or unusual.",
            ),
            SizedBox(height: 20),

            Text(
              "Best Practices",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "• Verify requests through a second channel.\n"
              "• Never share passwords or codes.\n"
              "• Be cautious with unexpected links or attachments.\n"
              "• Don’t let strangers follow you into secure areas.\n"
              "• Question anything that feels rushed or emotional.",
            ),
            SizedBox(height: 20),

            Text(
              "Why This Matters",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Social engineering works because it targets human emotions. "
              "Awareness and healthy skepticism are your strongest defenses.",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

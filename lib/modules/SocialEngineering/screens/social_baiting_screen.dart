import 'package:flutter/material.dart';

class BaitingScreen extends StatelessWidget {
  const BaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baiting & Quid Pro Quo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "What Is Baiting?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Baiting uses curiosity or temptation to trick someone into taking an "
              "action. Attackers often offer something appealing — like free music, "
              "games, or storage — that actually contains malware.",
            ),
            SizedBox(height: 20),

            Text(
              "What Is Quid Pro Quo?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Quid Pro Quo attacks offer help or a service in exchange for access. "
              "For example, an attacker may pretend to be tech support and ask for "
              "a password to 'fix' a problem.",
            ),
            SizedBox(height: 20),

            Text(
              "Common Examples",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "• Free USB drive left in a parking lot.\n"
              "• Fake 'free download' websites.\n"
              "• “I can fix your computer — just give me your login.”",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

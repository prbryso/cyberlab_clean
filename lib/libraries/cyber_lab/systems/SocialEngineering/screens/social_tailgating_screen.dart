import 'package:flutter/material.dart';

class TailgatingScreen extends StatelessWidget {
  const TailgatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tailgating & Physical Access Attacks")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "What Is Tailgating?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Tailgating happens when an unauthorized person follows someone into a "
              "restricted area. Attackers rely on politeness — most people hold the "
              "door open without thinking.",
            ),
            SizedBox(height: 20),

            Text(
              "Physical Access Attacks",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Once inside, attackers may plug in malicious USB devices, steal "
              "equipment, or access unlocked computers.",
            ),
            SizedBox(height: 20),

            Text(
              "Common Examples",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "• Someone in a hoodie following a student into a locked lab.\n"
              "• An attacker pretending to be a delivery driver.\n"
              "• Someone asking to 'borrow a computer' for a moment.",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

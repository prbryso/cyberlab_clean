import 'package:flutter/material.dart';

class PretextingScreen extends StatelessWidget {
  const PretextingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pretexting & Impersonation")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "What Is Pretexting?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Pretexting is when an attacker creates a fake story or scenario to gain "
              "someone’s trust. They may pretend to be from tech support, a bank, or "
              "even a teacher or administrator.",
            ),
            SizedBox(height: 20),

            Text(
              "What Is Impersonation?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Impersonation is when an attacker pretends to be a real person with "
              "authority — like a principal, manager, or family member — to pressure "
              "someone into acting quickly.",
            ),
            SizedBox(height: 20),

            Text(
              "Common Examples",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "• “This is IT support — I need your password to fix your account.”\n"
              "• “Your child is in trouble — send money immediately.”\n"
              "• “I’m your boss — buy gift cards for a client.”",
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

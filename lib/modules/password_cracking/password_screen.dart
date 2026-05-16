import 'package:flutter/material.dart';
import 'package:cyber_lab/ui/layout/app_scaffold.dart';
import 'package:cyber_lab/ui/components/info_card.dart';
import 'package:cyber_lab/ui/components/button.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Password Cracking",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoCard(
            title: "How Password Cracking Works",
            body:
                "Attackers use automated tools to guess passwords using methods like brute force, dictionary attacks, and hybrid attacks. "
                "This module shows how long different passwords take to crack.",
            icon: Icons.lock_open,
          ),

          const SizedBox(height: 24),

          CyberButton(
            label: "Start Simulation",
            icon: Icons.play_arrow,
            onPressed: () {
              Navigator.pushNamed(context, "/password/sim");
            },
          ),
        ],
      ),
    );
  }
}
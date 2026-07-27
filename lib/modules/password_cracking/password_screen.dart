import 'package:flutter/material.dart';
import 'package:systems_studio/ui/layout/app_scaffold.dart';
import 'package:systems_studio/ui/components/info_card.dart';
import 'package:systems_studio/ui/components/button.dart';

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

import 'package:flutter/material.dart';
import 'package:systems_studio/engine/ui/layout/app_scaffold.dart';
import 'package:systems_studio/engine/ui/components/button.dart';
import 'package:systems_studio/modules/password_cracking/widgets/strength_meter.dart';
import 'package:systems_studio/modules/password_cracking/logic/password_analyzer.dart';

class PasswordSimulationScreen extends StatefulWidget {
  const PasswordSimulationScreen({super.key});

  @override
  State<PasswordSimulationScreen> createState() =>
      _PasswordSimulationScreenState();
}

class _PasswordSimulationScreenState extends State<PasswordSimulationScreen> {
  final TextEditingController _controller = TextEditingController();
  PasswordAnalysisResult? result;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Password Simulation",
      scrollable: false,
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: "Enter a password"),
            obscureText: true,
          ),

          const SizedBox(height: 24),

          CyberButton(
            label: "Analyze",
            onPressed: () {
              setState(() {
                result = PasswordAnalyzer.analyze(_controller.text);
              });
            },
          ),

          const SizedBox(height: 24),

          if (result != null) ...[
            StrengthMeter(strength: result!.strengthScore),
            const SizedBox(height: 16),
            Text("Estimated crack time: ${result!.crackTime}"),
            Text("Attack method: ${result!.likelyAttack}"),
          ],
        ],
      ),
    );
  }
}

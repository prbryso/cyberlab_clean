import 'package:flutter/material.dart';
import 'package:systems_studio/theme/spacing.dart';
import 'dart:math';

class PasswordCrackTimeScreen extends StatefulWidget {
  const PasswordCrackTimeScreen({super.key});

  @override
  State<PasswordCrackTimeScreen> createState() =>
      _PasswordCrackTimeScreenState();
}

class _PasswordCrackTimeScreenState extends State<PasswordCrackTimeScreen> {
  String password = "";
  String crackTime = "";
  Color strengthColor = Colors.grey;

  // Simple entropy-based estimator
  String estimateCrackTime(String pw) {
    if (pw.isEmpty) return "";

    int charsetSize = 0;

    if (pw.contains(RegExp(r'[a-z]'))) charsetSize += 26;
    if (pw.contains(RegExp(r'[A-Z]'))) charsetSize += 26;
    if (pw.contains(RegExp(r'[0-9]'))) charsetSize += 10;
    if (pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) charsetSize += 32;

    if (charsetSize == 0) charsetSize = 26;

    double combinations = pow(charsetSize, pw.length).toDouble();

    // Assume attacker can test 10 billion guesses per second
    double seconds = combinations / 10000000000;

    if (seconds < 1) return "Instantly";
    if (seconds < 60) return "${seconds.toStringAsFixed(1)} seconds";
    if (seconds < 3600) return "${(seconds / 60).toStringAsFixed(1)} minutes";
    if (seconds < 86400) return "${(seconds / 3600).toStringAsFixed(1)} hours";
    if (seconds < 31536000)
      return "${(seconds / 86400).toStringAsFixed(1)} days";

    return "${(seconds / 31536000).toStringAsFixed(1)} years";
  }

  Color getStrengthColor(String pw) {
    if (pw.isEmpty) return Colors.grey;

    if (pw.length < 6) return Colors.red;
    if (pw.length < 10) return Colors.orange;
    if (pw.length < 14) return Colors.yellow.shade700;

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Crack Time Estimator")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How Long Would Your Password Last?",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.md),

                Text(
                  "Type a password below to see how quickly an attacker could crack it "
                  "using modern hardware.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl),

                TextField(
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      password = value;
                      crackTime = estimateCrackTime(value);
                      strengthColor = getStrengthColor(value);
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Enter a password",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: spacing.lg),

                if (password.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(spacing.lg),
                    decoration: BoxDecoration(
                      color: strengthColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(spacing.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Estimated Crack Time:",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: spacing.sm),
                        Text(
                          crackTime,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: strengthColor),
                        ),
                        SizedBox(height: spacing.md),
                        Text(
                          "This estimate assumes an attacker can test 10 billion guesses per second — "
                          "a realistic speed using modern GPUs.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: spacing.xl * 1.5),

                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/password");
                    },
                    child: const Text("Next"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

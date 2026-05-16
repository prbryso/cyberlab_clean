import 'dart:math';
import 'package:flutter/material.dart';

class PasswordAnalyzer extends StatefulWidget {
  const PasswordAnalyzer({super.key});

  @override
  State<PasswordAnalyzer> createState() => _PasswordAnalyzerState();
}

class _PasswordAnalyzerState extends State<PasswordAnalyzer> {
  String password = "";

  // Detect charset size
  int get charsetSize {
    int size = 0;
    if (password.contains(RegExp(r'[a-z]'))) size += 26;
    if (password.contains(RegExp(r'[A-Z]'))) size += 26;
    if (password.contains(RegExp(r'[0-9]'))) size += 10;
    if (password.contains(RegExp(r'[!@#\$%^&*()_\-+=\[\]{};:"\\|,.<>/?]'))) {
      size += 33;
    }
    if (password.contains(" ")) size += 1;
    return size == 0 ? 1 : size;
  }

  double get entropyBits {
    if (password.isEmpty) return 0;
    return password.length * (log(charsetSize) / log(2));
  }

  String get crackTime {
    if (password.isEmpty) return "—";

    final guesses = pow(2, entropyBits);
    final seconds = guesses / 1e10;

    if (seconds < 0.001) return "< 0.001 seconds";
    if (seconds < 1) return "${seconds.toStringAsFixed(4)} seconds";
    if (seconds < 60) return "${seconds.toStringAsFixed(2)} seconds";
    if (seconds < 3600) return "${(seconds / 60).toStringAsFixed(2)} minutes";
    if (seconds < 86400) return "${(seconds / 3600).toStringAsFixed(2)} hours";
    if (seconds < 31536000) return "${(seconds / 86400).toStringAsFixed(2)} days";
    return "${(seconds / 31536000).toStringAsFixed(2)} years";
  }

  String get strengthLabel {
    if (password.contains(" ")) return "Passphrase";
    if (entropyBits < 30) return "Weak";
    if (entropyBits < 60) return "Medium";
    return "Strong";
  }

  String get explanation {
    if (password.isEmpty) return "Type a password to analyze it.";

    if (password.contains(" ")) {
      return "This looks like a passphrase. Passphrases are long and easier to remember.";
    }

    if (entropyBits < 30) {
      return "This password is weak. It’s short or uses a limited character set.";
    }

    if (entropyBits < 60) {
      return "This password is moderately strong, but could be improved with more length.";
    }

    return "This is a strong password. Long, complex, and hard to guess.";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Try‑It‑Yourself Password Analyzer",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          onChanged: (v) => setState(() => password = v),
          decoration: const InputDecoration(
            labelText: "Enter a password",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        if (password.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Strength: $strengthLabel",
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                Text("Entropy: ${entropyBits.toStringAsFixed(1)} bits",
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                Text("Estimated Crack Time: $crackTime",
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text(explanation, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
      ],
    );
  }
}

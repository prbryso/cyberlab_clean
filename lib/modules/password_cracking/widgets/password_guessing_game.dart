import 'dart:math';
import 'package:flutter/material.dart';

class PasswordGuessingGame extends StatefulWidget {
  const PasswordGuessingGame({super.key});

  @override
  State<PasswordGuessingGame> createState() => _PasswordGuessingGameState();
}

class _PasswordGuessingGameState extends State<PasswordGuessingGame> {
  final random = Random();

  String password = "";
  bool revealed = false;

  String guessCrackTime = "Seconds";
  String guessStrength = "Weak";

  final crackTimeOptions = [
    "Instant",
    "Seconds",
    "Minutes",
    "Hours",
    "Days",
    "Years",
    "Centuries",
    "Longer than the universe",
  ];

  final strengthOptions = ["Weak", "Medium", "Strong", "Passphrase"];

  @override
  void initState() {
    super.initState();
    generatePassword();
  }

  void generatePassword() {
    revealed = false;

    final type = random.nextInt(3);

    if (type == 0) {
      // Weak
      final weak = [
        "password",
        "dragon99",
        "sunshine",
        "qwerty123",
        "iloveyou",
      ];
      password = weak[random.nextInt(weak.length)];
    } else if (type == 1) {
      // Medium
      final medium = ["CoffeeBean42", "R3dH0use!", "BlueSky_77", "TigerClaw9"];
      password = medium[random.nextInt(medium.length)];
    } else {
      // Passphrase
      final words = [
        "silver",
        "garden",
        "rocket",
        "cloud",
        "forest",
        "river",
        "mountain",
        "shadow",
      ];
      final w1 = words[random.nextInt(words.length)];
      final w2 = words[random.nextInt(words.length)];
      final w3 = words[random.nextInt(words.length)];
      final w4 = words[random.nextInt(words.length)];
      password = "$w1 $w2 $w3 $w4";
    }

    setState(() {});
  }

  // Simple entropy estimate
  double get entropyBits {
    final length = password.length;

    int charset = 0;
    if (password.contains(RegExp(r'[a-z]'))) charset += 26;
    if (password.contains(RegExp(r'[A-Z]'))) charset += 26;
    if (password.contains(RegExp(r'[0-9]'))) charset += 10;
    if (password.contains(RegExp(r'[!@#\$%^&*()_\-+=\[\]{};:"\\|,.<>/?]'))) {
      charset += 33;
    }
    if (password.contains(" ")) charset += 1;

    if (charset == 0) return 0;

    return length * (log(charset) / log(2));
  }

  String get crackTime {
    final guesses = pow(2, entropyBits);
    final seconds = guesses / 1e10;

    if (seconds < 0.001) return "Instant";
    if (seconds < 1) return "Seconds";
    if (seconds < 60) return "Minutes";
    if (seconds < 3600) return "Hours";
    if (seconds < 86400) return "Days";
    if (seconds < 31536000) return "Years";
    if (seconds < 31536000 * 100) return "Centuries";
    return "Longer than the universe";
  }

  String get strengthCategory {
    if (password.contains(" ")) return "Passphrase";
    if (entropyBits < 30) return "Weak";
    if (entropyBits < 60) return "Medium";
    return "Strong";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password Guessing Mini‑Game",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            password,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: "monospace",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text("How long to crack?", style: theme.textTheme.bodyLarge),
        DropdownButton<String>(
          value: guessCrackTime,
          items: crackTimeOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => guessCrackTime = v ?? "Seconds"),
        ),

        const SizedBox(height: 12),

        Text("What type is this?", style: theme.textTheme.bodyLarge),
        DropdownButton<String>(
          value: guessStrength,
          items: strengthOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => guessStrength = v ?? "Weak"),
        ),

        const SizedBox(height: 20),

        FilledButton(
          onPressed: () => setState(() => revealed = true),
          child: const Text("Reveal"),
        ),

        const SizedBox(height: 20),

        if (revealed)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Actual Crack Time: $crackTime",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  "Actual Strength: $strengthCategory",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  "Entropy: ${entropyBits.toStringAsFixed(1)} bits",
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        FilledButton(
          onPressed: generatePassword,
          child: const Text("Next Password"),
        ),
      ],
    );
  }
}

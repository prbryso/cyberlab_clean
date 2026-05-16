import 'package:flutter/material.dart';
import 'dart:math';

class LockoutSimulator extends StatefulWidget {
  const LockoutSimulator({super.key});

  @override
  State<LockoutSimulator> createState() => _LockoutSimulatorState();
}

class _LockoutSimulatorState extends State<LockoutSimulator> {
  double attemptsBeforeLockout = 5;
  double cooldownSeconds = 10;
  double totalGuesses = 1000;

  String formatTime(double seconds) {
    if (seconds < 1) return "${seconds.toStringAsFixed(3)} seconds";
    if (seconds < 60) return "${seconds.toStringAsFixed(2)} seconds";
    if (seconds < 3600) return "${(seconds / 60).toStringAsFixed(2)} minutes";
    if (seconds < 86400) return "${(seconds / 3600).toStringAsFixed(2)} hours";
    if (seconds < 31536000) return "${(seconds / 86400).toStringAsFixed(2)} days";
    return "${(seconds / 31536000).toStringAsFixed(2)} years";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final attempts = attemptsBeforeLockout.round();
    final guesses = totalGuesses.round();
    final cooldown = cooldownSeconds;

    // How many full lockout cycles?
    final cycles = (guesses / attempts).ceil();

    // Total cooldown time
    final totalCooldown = max(0, (cycles - 1) * cooldown);

    // Assume 1 guess per second (realistic online rate limiting)
    final guessTime = guesses * 1.0;

    final totalTime = guessTime + totalCooldown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Lockout Simulator",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Text("Attempts before lockout: ${attempts.round()}",
            style: theme.textTheme.bodyLarge),
        Slider(
          value: attemptsBeforeLockout,
          min: 3,
          max: 10,
          divisions: 7,
          label: attemptsBeforeLockout.round().toString(),
          onChanged: (v) => setState(() => attemptsBeforeLockout = v),
        ),

        const SizedBox(height: 12),

        Text("Cooldown after lockout: ${cooldown.round()} seconds",
            style: theme.textTheme.bodyLarge),
        Slider(
          value: cooldownSeconds,
          min: 1,
          max: 60,
          divisions: 59,
          label: cooldownSeconds.round().toString(),
          onChanged: (v) => setState(() => cooldownSeconds = v),
        ),

        const SizedBox(height: 12),

        Text("Total guesses attacker wants to try: $guesses",
            style: theme.textTheme.bodyLarge),
        Slider(
          value: totalGuesses,
          min: 100,
          max: 1000000,
          divisions: 100,
          label: totalGuesses.round().toString(),
          onChanged: (v) => setState(() => totalGuesses = v),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Time Required:",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 8),
              Text(
                formatTime(totalTime),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: "monospace",
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "This shows why online brute‑force attacks are slow — "
                "systems add delays and lockouts that multiply attack time.",
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

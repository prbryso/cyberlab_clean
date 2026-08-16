import 'package:flutter/material.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/password_cracking/widgets/password_guessing_animation.dart';

class PasswordIntroScreen extends StatelessWidget {
  const PasswordIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Password Cracking",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  "How attackers break weak passwords — and how you can defend yourself.",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),

                // Body text
                Text(
                  "In this module, you’ll explore how attackers crack passwords, why some passwords fail instantly, and how to create strong passwords and passphrases that protect your accounts.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),

                // ⭐ Animated SVG password-guessing simulation
                const PasswordGuessingAnimation(),
                const SizedBox(height: 48),

                // Start button
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/password");
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text("Start Module"),
                    ),
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

import 'package:flutter/material.dart';

class CommonPasswordMistakes extends StatelessWidget {
  const CommonPasswordMistakes({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget mistake(String title, String description) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Common Password Mistakes",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        mistake(
          "Using Common Passwords",
          "Passwords like “password”, “123456”, and “qwerty” are guessed instantly.",
        ),

        mistake(
          "Short Passwords",
          "Anything under 10 characters is vulnerable to brute‑force attacks.",
        ),

        mistake(
          "Predictable Patterns",
          "Keyboard patterns (qwerty), repeated characters, and simple substitutions (P@ssw0rd) are easy to crack.",
        ),

        mistake(
          "Personal Information",
          "Birthdays, pet names, and favorite teams are easy for attackers to guess.",
        ),

        mistake(
          "Reusing Passwords",
          "If one site is breached, attackers try the same password everywhere.",
        ),

        mistake(
          "Relying Only on Complexity",
          "Adding symbols doesn’t help if the password is still short. Length matters more.",
        ),
      ],
    );
  }
}

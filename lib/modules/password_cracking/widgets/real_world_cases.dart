import 'package:flutter/material.dart';

class RealWorldCases extends StatelessWidget {
  const RealWorldCases({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget caseCard({
      required String title,
      required String description,
      required String lesson,
    }) {
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
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text("Lesson:", style: theme.textTheme.titleSmall),
            Text(lesson,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Real‑World Case Studies",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        caseCard(
          title: "The ‘password’ Password Breach",
          description:
              "A major company suffered a breach when an employee used the password “password”. "
              "Attackers guessed it instantly and gained access to internal systems.",
          lesson:
              "Never use common passwords — attackers try these first.",
        ),

        caseCard(
          title: "The 2012 LinkedIn Breach",
          description:
              "Millions of accounts were compromised because many users chose weak passwords like "
              "“123456” and “linkedin”. Attackers cracked them offline in seconds.",
          lesson:
              "Short, predictable passwords are trivial to crack once stolen.",
        ),

        caseCard(
          title: "Celebrity iCloud Hacks",
          description:
              "Attackers used targeted guessing and password‑reset tricks to break into celebrity accounts. "
              "Weak security questions and simple passwords made it possible.",
          lesson:
              "Use strong passwords and avoid predictable personal information.",
        ),

        caseCard(
          title: "The 2020 Twitter Admin Panel Attack",
          description:
              "Attackers gained access to internal tools by compromising an employee’s weak credentials. "
              "This allowed them to take over high‑profile accounts.",
          lesson:
              "One weak password can compromise an entire organization.",
        ),
      ],
    );
  }
}

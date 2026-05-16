import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/spacing.dart';

class PasswordManagerScreen extends StatelessWidget {
  const PasswordManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Managers"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The Smart Way to Stay Secure",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.md),

                Text(
                  "After learning how attackers crack passwords, how hashing works, and how quickly "
                  "weak passwords fall, there’s one tool that solves almost all of these problems: "
                  "a password manager.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl * 1.5),

                _ManagerCard(
                  icon: Icons.key,
                  title: "What Password Managers Do",
                  description:
                      "They store all your passwords securely in an encrypted vault. "
                      "You only need to remember one strong master password.",
                ),
                SizedBox(height: spacing.lg),

                _ManagerCard(
                  icon: Icons.password,
                  title: "Generate Strong Passwords",
                  description:
                      "Password managers create long, random passwords that are nearly impossible "
                      "for attackers to guess or brute-force.",
                ),
                SizedBox(height: spacing.lg),

                _ManagerCard(
                  icon: Icons.shield,
                  title: "Protect Against Reuse Attacks",
                  description:
                      "Because each password is unique, a breach on one site doesn’t put your other "
                      "accounts at risk.",
                ),
                SizedBox(height: spacing.lg),

                _ManagerCard(
                  icon: Icons.lock_clock,
                  title: "Auto-Fill & Convenience",
                  description:
                      "They automatically fill your passwords on websites and apps, making strong "
                      "security easier than weak security.",
                ),

                SizedBox(height: spacing.xl * 1.5),

                Text(
                  "Bottom Line",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  "Using a password manager is one of the simplest and most effective ways to protect "
                  "your online accounts. It eliminates weak passwords, prevents reuse, and keeps your "
                  "digital life secure.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                SizedBox(height: spacing.xl * 2),

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

class _ManagerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ManagerCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(spacing.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: spacing.xl),
          SizedBox(width: spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

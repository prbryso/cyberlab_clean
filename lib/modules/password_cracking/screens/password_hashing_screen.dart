import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/spacing.dart';

class PasswordHashingScreen extends StatelessWidget {
  const PasswordHashingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hashing"),
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
                  "How Passwords Are Stored",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.md),

                Text(
                  "Websites don’t store your actual password. Instead, they run it through a "
                  "mathematical process called hashing. A hash looks nothing like the original "
                  "password — and it can’t be reversed.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl * 1.5),

                _HashCard(
                  icon: Icons.lock,
                  title: "What Is Hashing?",
                  description:
                      "Hashing turns your password into a long, random-looking string of characters. "
                      "The same password always produces the same hash — but you can’t turn the hash "
                      "back into the password.",
                ),
                SizedBox(height: spacing.lg),

                _HashCard(
                  icon: Icons.shuffle,
                  title: "Why Hashing Protects You",
                  description:
                      "Even if attackers steal a database of hashes, they don’t get the actual passwords. "
                      "They must try to guess passwords and hash them until they find a match.",
                ),
                SizedBox(height: spacing.lg),

                _HashCard(
                  icon: Icons.scatter_plot,
                  title: "What Is a Salt?",
                  description:
                      "A salt is a random value added to your password before hashing. "
                      "It ensures that even if two people use the same password, their hashes are different.",
                ),
                SizedBox(height: spacing.lg),

                _HashCard(
                  icon: Icons.warning_amber,
                  title: "Why Weak Passwords Still Fail",
                  description:
                      "Attackers use fast computers and massive breach dictionaries to hash billions of guesses. "
                      "If your password is weak, they can still find a matching hash quickly.",
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

class _HashCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HashCard({
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

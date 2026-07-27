import 'package:flutter/material.dart';
import 'package:systems_studio/theme/spacing.dart';
import 'details/brute_force_detail.dart';
import 'details/credential_stuffing_detail.dart';
import 'details/hybrid_attack_detail.dart';
import 'details/dictionary_attack_detail.dart';

class PasswordAttackMethodsOverview extends StatelessWidget {
  const PasswordAttackMethodsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Attack Methods")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How Attackers Crack Passwords",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.md),

                Text(
                  "Attackers don’t guess passwords manually — they use automated tools "
                  "that can test millions or even billions of guesses per second. "
                  "Here are the most common attack methods used in real breaches.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl * 1.5),

                // Dictionary Attack
                _AttackCard(
                  icon: Icons.menu_book,
                  title: "Dictionary Attacks",
                  description:
                      "Attackers use massive lists of real leaked passwords from past breaches. "
                      "If your password appears in these lists — even once — it can be cracked instantly.",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DictionaryAttackDetail(),
                      ),
                    );
                  },
                ),

                SizedBox(height: spacing.lg),

                // Brute Force
                _AttackCard(
                  icon: Icons.memory,
                  title: "Brute Force",
                  description:
                      "This method tries every possible combination of characters. "
                      "Short passwords fall quickly, but longer passphrases become exponentially harder to crack.",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BruteForceDetail(),
                      ),
                    );
                  },
                ),

                SizedBox(height: spacing.lg),

                // Hybrid Attack
                _AttackCard(
                  icon: Icons.merge_type,
                  title: "Hybrid Attacks",
                  description:
                      "Attackers combine dictionary words with common patterns like numbers or symbols. "
                      "For example: 'password' → 'password1' → 'Password1!'",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HybridAttackDetail(),
                      ),
                    );
                  },
                ),

                SizedBox(height: spacing.lg),

                // Credential Stuffing
                _AttackCard(
                  icon: Icons.person_search,
                  title: "Credential Stuffing",
                  description:
                      "If attackers steal your password from one site, they try it on others. "
                      "Password reuse makes this attack extremely effective.",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CredentialStuffingDetail(),
                      ),
                    );
                  },
                ),

                SizedBox(height: spacing.xl * 1.5),

                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Back"),
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

class _AttackCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onMoreDetails;

  const _AttackCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onMoreDetails,
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
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: spacing.sm),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: spacing.md),

                TextButton(
                  onPressed: onMoreDetails,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red, // text color
                  ),
                  child: const Text(
                    "More details...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // bold
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

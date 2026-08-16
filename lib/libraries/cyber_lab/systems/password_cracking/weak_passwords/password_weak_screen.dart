import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

// DETAIL SCREENS
import 'details/weak_what_makes_detail.dart';
import 'details/weak_examples_detail.dart';
import 'details/weak_length_detail.dart';
import 'details/weak_patterns_detail.dart';
import 'details/weak_fixing_detail.dart';
import 'details/weak_limited_tries_detail.dart';
import 'details/weak_captcha_detail.dart';

class WeakPasswordsOverview extends StatelessWidget {
  const WeakPasswordsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Understanding Password Strength")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Understanding Password Strength",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.md),

                Text(
                  "Weak passwords are one of the most common causes of account breaches. "
                  "This module explores what makes passwords weak, how attackers exploit them, "
                  "and how to build strong, memorable alternatives.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl * 1.5),

                // 1 — What Makes a Password Weak?
                _OverviewCard(
                  icon: Icons.warning_amber_rounded,
                  title: "What Makes a Password Weak?",
                  description:
                      "Short, predictable, reused, or common passwords are extremely easy to crack.",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeakWhatMakesDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                // 2 — Common Weak Password Examples
                _OverviewCard(
                  icon: Icons.visibility_off,
                  title: "Common Weak Password Examples",
                  description:
                      "Real-world examples of passwords that attackers crack instantly.",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeakExamplesDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                // 3 — Why Length Matters
                _OverviewCard(
                  icon: Icons.straighten,
                  title: "Why Length Matters",
                  description:
                      "Password length is the #1 factor in resisting brute-force attacks.",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeakLengthDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                // 4 — Patterns Attackers Exploit
                _OverviewCard(
                  icon: Icons.grid_view,
                  title: "Patterns Attackers Exploit",
                  description:
                      "Attackers know the shortcuts people use — and automate them.",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeakPatternsDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                // 5 — How to Fix Weak Passwords
                _OverviewCard(
                  icon: Icons.build,
                  title: "How to Fix Weak Passwords",
                  description:
                      "Simple steps to turn weak passwords into strong, secure ones.",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeakFixingDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                // 6 — Limited Tries & Lockouts
                _OverviewCard(
                  icon: Icons.lock_clock,
                  title: "Limited Tries & Lockouts",
                  description:
                      "How systems slow down or block attackers from guessing passwords.",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeakLimitedTriesDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                // 7 — CAPTCHA & Bot Protection
                _OverviewCard(
                  icon: Icons.shield,
                  title: "CAPTCHA & Bot Protection",
                  description:
                      "How websites stop bots from blasting login pages with automated guesses.",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeakCaptchaDetail(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
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
                  onPressed: onTap,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text(
                    "More details",
                    style: TextStyle(fontWeight: FontWeight.bold),
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

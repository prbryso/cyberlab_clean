import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/spacing.dart';

import 'details/breach_linkedin_detail.dart';
import 'details/breach_adobe_detail.dart';
import 'details/breach_dropbox_detail.dart';
import 'details/breach_icloud_detail.dart';
import 'details/breach_twitter_detail.dart';

class FamousBreachesOverview extends StatelessWidget {
  const FamousBreachesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Famous Password Breaches")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Real-World Password Breaches",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: spacing.md),

                Text(
                  "These major breaches show how weak passwords, poor storage, and predictable patterns "
                  "lead to massive real-world compromises.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: spacing.xl * 1.5),

                _BreachCard(
                  icon: Icons.lock_open,
                  title: "LinkedIn (2012)",
                  description:
                      "117 million passwords leaked — many cracked instantly due to weak hashing.",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreachLinkedInDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                _BreachCard(
                  icon: Icons.security,
                  title: "Adobe (2013)",
                  description:
                      "153 million accounts exposed — encrypted, not hashed, with predictable patterns.",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreachAdobeDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                _BreachCard(
                  icon: Icons.cloud,
                  title: "iCloud Celebrity Hack (2014)",
                  description:
                      "Weak security questions + reused passwords enabled targeted account access.",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreachICloudDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                _BreachCard(
                  icon: Icons.storage,
                  title: "Dropbox (2016)",
                  description:
                      "Employee reused password from LinkedIn breach — led to internal compromise.",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreachDropboxDetail(),
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.lg),

                _BreachCard(
                  icon: Icons.admin_panel_settings,
                  title: "Twitter Admin Panel Attack (2020)",
                  description:
                      "Social engineering attack stole internal credentials — high-profile accounts hijacked.",
                  onMoreDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreachTwitterDetail(),
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

class _BreachCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onMoreDetails;

  const _BreachCard({
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
                Text(description,
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: spacing.md),
                TextButton(
                  onPressed: onMoreDetails,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
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

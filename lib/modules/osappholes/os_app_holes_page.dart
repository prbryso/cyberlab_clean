import 'package:flutter/material.dart';

class OsAppHolesOverviewPage extends StatelessWidget {
  const OsAppHolesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("OS & Application Holes")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Text(
              "OS & Application Vulnerabilities",
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ⭐ NEW SECTION: WHY ATTACKS WORK
            Text(
              "Why Attacks Work",
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Cyber attacks don’t succeed because attackers are brilliant. "
              "They succeed because systems are imperfect.\n\n"
              "Every device, every operating system, every application—no matter "
              "how modern or secure—contains weaknesses. Some are tiny mistakes "
              "in code. Some are misconfigurations. Some are outdated components "
              "that were never patched.\n\n"
              "Attackers don’t need to break the entire system. They only need "
              "one hole.\n\n"
              "This module explores those weaknesses—where they come from, how "
              "attackers exploit them, and how defenders can close the holes "
              "before they’re used.",
              style: text.bodyLarge,
            ),

            const SizedBox(height: 32),

            // INTRO TEXT
            Text(
              "Select a topic below to explore how vulnerabilities form and how "
              "attackers take advantage of them.",
              style: text.bodyLarge,
            ),
            const SizedBox(height: 32),

            // TOPIC CARDS
            _topicCard(
              context,
              title: "What Is a Vulnerability?",
              description:
                  "Learn what vulnerabilities are and where they appear.",
              route: "/osappholes/vul",
            ),

            _topicCard(
              context,
              title: "Operating System Vulnerabilities",
              description:
                  "Weaknesses in Windows, macOS, Linux, Android, and iOS.",
              route: "/osappholes/osv",
            ),

            _topicCard(
              context,
              title: "Application Vulnerabilities",
              description:
                  "Flaws in software, APIs, libraries, and components.",
              route: "/osappholes/appv",
            ),

            _topicCard(
              context,
              title: "How Attackers Exploit Holes",
              description:
                  "The full exploitation chain from scan to exfiltration.",
              route: "/osappholes/exploit",
            ),

            _topicCard(
              context,
              title: "Real-World Examples",
              description: "EternalBlue, Log4Shell, Dirty COW, and more.",
              route: "/osappholes/real",
            ),

            _topicCard(
              context,
              title: "Defense Strategies",
              description:
                  "Patching, hardening, least privilege, and monitoring.",
              route: "/osappholes/defense",
            ),
          ],
        ),
      ),
    );
  }

  Widget _topicCard(
    BuildContext context, {
    required String title,
    required String description,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

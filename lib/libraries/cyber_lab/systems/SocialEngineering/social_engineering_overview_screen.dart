import 'package:flutter/material.dart';

class SocialEngineeringOverviewScreen extends StatelessWidget {
  const SocialEngineeringOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Engineering Overview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "What Is Social Engineering?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Social engineering is when attackers manipulate people into giving up "
              "information, clicking harmful links, or granting access. Instead of "
              "breaking into systems, attackers trick humans — the weakest link in "
              "cybersecurity.",
            ),
            const SizedBox(height: 20),

            const Text(
              "Why It Matters",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Most cyberattacks begin with social engineering. Attackers use emotions "
              "like fear, urgency, curiosity, or trust to get people to act quickly "
              "without thinking. Even trained professionals can fall for these tactics.",
            ),
            const SizedBox(height: 20),

            const Text(
              "Common Social Engineering Tactics",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Pretexting — creating a fake story to gain trust.\n"
              "• Impersonation — pretending to be someone with authority.\n"
              "• Baiting — offering something tempting (free gift, download).\n"
              "• Tailgating — following someone into a secure area.\n"
              "• Quid Pro Quo — offering help in exchange for access.\n"
              "• Deepfake Scams — using AI‑generated voices or videos.",
            ),
            const SizedBox(height: 30),

            const Text(
              "Coming Up Next",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            const _NextItem(
              title: "Pretexting & Impersonation",
              route: "/social/pretexting",
            ),
            const _NextItem(
              title: "Baiting & Quid Pro Quo Attacks",
              route: "/social/baiting",
            ),
            const _NextItem(
              title: "Tailgating & Physical Access Attacks",
              route: "/social/tailgating",
            ),
            const _NextItem(
              title: "Deepfake Scams",
              route: "/social/deepfakes",
            ),
            const _NextItem(
              title: "How to Defend Against Social Engineering",
              route: "/social/defense",
            ),
          ],
        ),
      ),
    );
  }
}

class _NextItem extends StatelessWidget {
  final String title;
  final String route;

  const _NextItem({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.arrow_forward_ios, size: 18),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

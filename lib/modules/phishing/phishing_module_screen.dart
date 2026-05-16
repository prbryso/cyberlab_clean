import 'package:flutter/material.dart';

class PhishingModuleScreen extends StatelessWidget {
  const PhishingModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Phishing Detective')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: '1. How Attackers Trick You',
            children: [
              _Bullet('Spoofed senders (fake or compromised accounts)'),
              _Bullet('Urgency (“Act now!” “Your account will close!”)'),
              _Bullet('Emotion (“special moment,” “important notice”)'),
              _Bullet('Attachments that install malware'),
              _Bullet('Fake login pages that steal passwords'),
              _Bullet('Mass‑BCC emails to hide victims from each other'),
              const SizedBox(height: 12),
              const Text(
                'Phishing works because it feels personal — even when it isn’t.',
              ),
            ],
          ),

          _SectionCard(
            title: '2. Red Flags to Watch For',
            children: [
              _Bullet('Vague or emotional subject lines'),
              _Bullet('Unexpected attachments'),
              _Bullet('“Verify your account” or “Reset your password”'),
              _Bullet('Poor grammar or unusual tone'),
              _Bullet('Strange links or mismatched URLs'),
              _Bullet('Being BCC’d instead of listed in To:'),
              _Bullet('A familiar name… but an unfamiliar message'),
              const SizedBox(height: 12),
              const Text('If something feels “off,” it probably is.'),
            ],
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────────────────────
//   HELPER WIDGETS (must be OUTSIDE the class)
// ─────────────────────────────────────────────────────────────
//

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _Subheading extends StatelessWidget {
  final String text;

  const _Subheading(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValue(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _AnswerLines extends StatelessWidget {
  final int count;

  const _AnswerLines({this.count = 2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: 1,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _QuizItem extends StatelessWidget {
  final String question;
  final String answer;

  const _QuizItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text('Answer: $answer'),
        ],
      ),
    );
  }
}

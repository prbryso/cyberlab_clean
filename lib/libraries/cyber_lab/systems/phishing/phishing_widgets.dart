import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionCard({required this.title, required this.children});

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

class Bullet extends StatelessWidget {
  final String text;

  const Bullet(this.text);

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

class KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const KeyValue(this.label, this.value);

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

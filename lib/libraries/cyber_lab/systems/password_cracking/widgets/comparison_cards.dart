import 'package:flutter/material.dart';

class ComparisonCards extends StatelessWidget {
  const ComparisonCards({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Short vs Long Passwords",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _PasswordCard(
                    title: "Short & Complex",
                    password: "P@5sW!",
                    details: [
                      "6 characters",
                      "Mixed symbols, numbers, uppercase",
                      "Still vulnerable to brute‑force",
                      "Cracked in seconds",
                    ],
                    color: Colors.red.shade400,
                  ),
                ),

                SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),

                Expanded(
                  child: _PasswordCard(
                    title: "Long Passphrase",
                    password: "correct horse battery staple",
                    details: [
                      "28 characters",
                      "Easy to remember",
                      "Massive search space",
                      "Effectively uncrackable",
                    ],
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PasswordCard extends StatelessWidget {
  final String title;
  final String password;
  final List<String> details;
  final Color color;

  const _PasswordCard({
    required this.title,
    required this.password,
    required this.details,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          // Password example
          Text(
            password,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: "monospace",
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Bullet points
          ...details.map(
            (d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• ", style: theme.textTheme.bodyMedium),
                  Expanded(child: Text(d, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

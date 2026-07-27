import 'dart:math';
import 'package:flutter/material.dart';

class PassphraseGenerator extends StatefulWidget {
  const PassphraseGenerator({super.key});

  @override
  State<PassphraseGenerator> createState() => _PassphraseGeneratorState();
}

class _PassphraseGeneratorState extends State<PassphraseGenerator> {
  final random = Random();
  String passphrase = "";

  // A small curated list — you can expand this later
  final List<String> words = const [
    "sunset",
    "river",
    "bicycle",
    "cloud",
    "forest",
    "coffee",
    "bridge",
    "silver",
    "mountain",
    "pencil",
    "orange",
    "galaxy",
    "whisper",
    "candle",
    "window",
    "garden",
    "rocket",
    "feather",
    "shadow",
    "planet",
  ];

  int wordCount = 4;
  String separator = " ";

  void generate() {
    final selected = List.generate(
      wordCount,
      (_) => words[random.nextInt(words.length)],
    );

    setState(() {
      passphrase = selected.join(separator);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Passphrase Generator",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Text("Words:", style: theme.textTheme.bodyMedium),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: wordCount,
              items: [3, 4, 5, 6]
                  .map((n) => DropdownMenuItem(value: n, child: Text("$n")))
                  .toList(),
              onChanged: (v) => setState(() => wordCount = v ?? 4),
            ),
            const SizedBox(width: 24),
            Text("Separator:", style: theme.textTheme.bodyMedium),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: separator,
              items: [
                " ",
                "-",
                "_",
                ".",
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => separator = v ?? " "),
            ),
          ],
        ),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: generate,
          child: const Text("Generate Passphrase"),
        ),

        const SizedBox(height: 16),

        if (passphrase.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              passphrase,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: "monospace",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

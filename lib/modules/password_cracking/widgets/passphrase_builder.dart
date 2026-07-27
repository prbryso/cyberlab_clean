import 'dart:math';
import 'package:flutter/material.dart';

class PassphraseBuilder extends StatefulWidget {
  const PassphraseBuilder({super.key});

  @override
  State<PassphraseBuilder> createState() => _PassphraseBuilderState();
}

class _PassphraseBuilderState extends State<PassphraseBuilder> {
  final random = Random();

  // Small demo list — entropy uses realistic Diceware size
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

  List<String> selectedWords = ["", "", "", ""];
  String separator = " ";

  // Use realistic Diceware wordlist size for entropy
  static const int wordListSize = 7776;

  double get entropyBits {
    final count = selectedWords.where((w) => w.isNotEmpty).length;
    if (count == 0) return 0;

    return count * (log(wordListSize) / log(2));
  }

  String get crackTime {
    if (entropyBits == 0) return "—";

    final guesses = pow(2, entropyBits);
    final seconds = guesses / 1e10; // 10 billion guesses/sec

    if (seconds < 0.001) return "< 0.001 seconds";
    if (seconds < 1) return "${seconds.toStringAsFixed(4)} seconds";
    if (seconds < 60) return "${seconds.toStringAsFixed(2)} seconds";
    if (seconds < 3600) return "${(seconds / 60).toStringAsFixed(2)} minutes";
    if (seconds < 86400) return "${(seconds / 3600).toStringAsFixed(2)} hours";
    if (seconds < 31536000)
      return "${(seconds / 86400).toStringAsFixed(2)} days";

    return "${(seconds / 31536000).toStringAsFixed(2)} years";
  }

  void randomizeWord(int index) {
    setState(() {
      selectedWords[index] = words[random.nextInt(words.length)];
    });
  }

  String get finalPassphrase {
    return selectedWords.where((w) => w.isNotEmpty).join(separator);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Passphrase Builder",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Column(
          children: List.generate(selectedWords.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(
                          0.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedWords[i].isEmpty ? "(empty)" : selectedWords[i],
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: "monospace",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => randomizeWord(i),
                    child: const Text("Random"),
                  ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
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

        const SizedBox(height: 20),

        if (finalPassphrase.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              finalPassphrase,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: "monospace",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        const SizedBox(height: 20),

        if (finalPassphrase.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Estimated Entropy: ${entropyBits.toStringAsFixed(1)} bits",
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 6),
              Text(
                "Estimated Crack Time: $crackTime",
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
      ],
    );
  }
}

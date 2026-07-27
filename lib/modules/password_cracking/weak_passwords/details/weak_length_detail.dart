import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';
import '../../widgets/passphrase_generator.dart'; // ← Add your generator import

class WeakLengthDetail extends StatelessWidget {
  const WeakLengthDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Why Length Matters")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Text(
              "Why Length Matters",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: spacing.md),

            // INTRO
            Text(
              "Password length is the single most important factor in resisting brute‑force attacks. "
              "Every extra character multiplies the number of possible combinations — not linearly, "
              "but **exponentially**. This is why short passwords fall instantly, while long ones "
              "can survive for centuries.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            SizedBox(height: spacing.xl),

            // SECTION: TABLE TITLE
            Text(
              "Crack Time by Length",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "Below is a simplified look at how password length affects the total number of "
              "possible combinations — and how long a modern attacker would need to brute‑force it.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            // TABLE
            _buildCrackTimeTable(context),

            SizedBox(height: spacing.xl * 1.5),

            // PASSPHRASES SECTION
            Text(
              "Passphrases: Length Made Easy",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "A passphrase is a long password made from multiple words. Passphrases are one of the "
              "easiest ways to create extremely strong passwords because they combine high length "
              "with natural memorability.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            Text(
              "Examples of strong passphrases:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),

            _buildPassphraseExamples(context),

            SizedBox(height: spacing.lg),

            Text(
              "Why passphrases work:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: spacing.sm),

            Text(
              "• They are long — usually 20–30+ characters\n"
              "• They create massive search spaces for attackers\n"
              "• They are easier to remember than complex symbols\n"
              "• They avoid predictable patterns like names or dates\n"
              "• They work beautifully with password managers",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.xl * 1.5),

            // ⭐ NEW SECTION: PASSPHRASE GENERATOR
            Text(
              "Try It Yourself: Passphrase Generator",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: spacing.md),

            Text(
              "Generate a strong, memorable passphrase instantly. Adjust the number of words or "
              "separator to see how length affects strength.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            SizedBox(height: spacing.lg),

            const PassphraseGenerator(), // ← Your generator widget

            SizedBox(height: spacing.xl),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // CRACK TIME TABLE
  // -------------------------
  Widget _buildCrackTimeTable(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    final rows = [
      ["6 characters", "a–z", "308 million", "< 1 second"],
      ["8 characters", "a–z + A–Z + 0–9", "218 trillion", "minutes"],
      ["10 characters", "full charset", "839 quadrillion", "days"],
      ["12 characters", "full charset", "3 sextillion", "centuries"],
      ["16 characters", "full charset", "7.9e28", "longer than the universe"],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(spacing.md),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.4),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        children: [
          // HEADER ROW
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
            ),
            children: [
              _tableHeader(context, "Length"),
              _tableHeader(context, "Characters"),
              _tableHeader(context, "Combinations"),
              _tableHeader(context, "Crack Time"),
            ],
          ),

          // DATA ROWS
          for (final row in rows)
            TableRow(
              children: [
                _tableCell(context, row[0]),
                _tableCell(context, row[1]),
                _tableCell(context, row[2]),
                _tableCell(context, row[3]),
              ],
            ),
        ],
      ),
    );
  }

  Widget _tableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _tableCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  // -------------------------
  // PASSPHRASE EXAMPLES
  // -------------------------
  Widget _buildPassphraseExamples(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    final examples = [
      "correct horse battery staple",
      "sunset river bicycle cloud",
      "the horse jumped the fence",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: examples.map((p) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.25),
              borderRadius: BorderRadius.circular(spacing.sm),
            ),
            child: Text(
              p,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        );
      }).toList(),
    );
  }
}

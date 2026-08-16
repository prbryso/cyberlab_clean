import 'package:flutter/material.dart';

class CharsetToggle extends StatelessWidget {
  final bool useLower;
  final bool useUpper;
  final bool useNumbers;
  final bool useSymbols;

  /// Callback returns updated values in order:
  /// (lowercase, uppercase, numbers, symbols)
  final void Function(bool, bool, bool, bool) onChanged;

  const CharsetToggle({
    super.key,
    required this.useLower,
    required this.useUpper,
    required this.useNumbers,
    required this.useSymbols,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Character Sets Used",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            // LOWERCASE
            FilterChip(
              label: const Text("Lowercase (a–z)"),
              selected: useLower,
              onSelected: (v) => onChanged(v, useUpper, useNumbers, useSymbols),
            ),

            // UPPERCASE
            FilterChip(
              label: const Text("Uppercase (A–Z)"),
              selected: useUpper,
              onSelected: (v) => onChanged(useLower, v, useNumbers, useSymbols),
            ),

            // NUMBERS
            FilterChip(
              label: const Text("Numbers (0–9)"),
              selected: useNumbers,
              onSelected: (v) => onChanged(useLower, useUpper, v, useSymbols),
            ),

            // SYMBOLS
            FilterChip(
              label: const Text("Symbols (! @ # …)"),
              selected: useSymbols,
              onSelected: (v) => onChanged(useLower, useUpper, useNumbers, v),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          "Current charset size: ${_charsetSize()} characters",
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  int _charsetSize() {
    int size = 0;
    if (useLower) size += 26;
    if (useUpper) size += 26;
    if (useNumbers) size += 10;
    if (useSymbols) size += 33; // printable symbols
    return size;
  }
}

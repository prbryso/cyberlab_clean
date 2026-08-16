import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

import 'length_slider.dart';
import 'charset_toggle.dart';
import 'comparison_cards.dart';

class PasswordStrengthLab extends StatefulWidget {
  const PasswordStrengthLab({super.key});

  @override
  State<PasswordStrengthLab> createState() => _PasswordStrengthLabState();
}

class _PasswordStrengthLabState extends State<PasswordStrengthLab> {
  double length = 10;

  bool useLower = true;
  bool useUpper = true;
  bool useNumbers = true;
  bool useSymbols = true;

  int get charsetSize {
    int size = 0;
    if (useLower) size += 26;
    if (useUpper) size += 26;
    if (useNumbers) size += 10;
    if (useSymbols) size += 33; // common printable symbols
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------
        // LENGTH SLIDER + ENTROPY BAR
        // ---------------------------------------------------------
        LengthSlider(
          length: length,
          charsetSize: charsetSize,
          onChanged: (v) => setState(() => length = v),
        ),

        SizedBox(height: spacing.lg),

        // ---------------------------------------------------------
        // CHARSET TOGGLES
        // ---------------------------------------------------------
        CharsetToggle(
          useLower: useLower,
          useUpper: useUpper,
          useNumbers: useNumbers,
          useSymbols: useSymbols,
          onChanged: (l, u, n, s) {
            setState(() {
              useLower = l;
              useUpper = u;
              useNumbers = n;
              useSymbols = s;
            });
          },
        ),

        SizedBox(height: spacing.lg),

        // ---------------------------------------------------------
        // SIDE-BY-SIDE COMPARISON CARDS
        // ---------------------------------------------------------
        const ComparisonCards(),
      ],
    );
  }
}

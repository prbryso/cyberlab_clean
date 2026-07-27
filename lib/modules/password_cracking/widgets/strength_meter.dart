import 'package:flutter/material.dart';
import 'package:systems_studio/theme/colors.dart';

class StrengthMeter extends StatelessWidget {
  final int strength; // 0–100

  const StrengthMeter({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    Color barColor;

    if (strength < 30) {
      barColor = AppColors.danger;
    } else if (strength < 60) {
      barColor = AppColors.warning;
    } else if (strength < 80) {
      barColor = AppColors.cyberBlue;
    } else {
      barColor = AppColors.success;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Strength: $strength/100"),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strength / 100,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

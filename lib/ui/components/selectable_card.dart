import 'package:flutter/material.dart';

import 'package:systems_studio/theme/colors.dart';
import 'package:systems_studio/theme/spacing.dart';
import 'package:systems_studio/theme/typography.dart';
import 'package:systems_studio/ui/components/app_card.dart';

class SelectableCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SelectableCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(spacing.md),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

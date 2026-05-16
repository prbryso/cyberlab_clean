import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/colors.dart';
import 'package:cyber_lab/theme/typography.dart';
import 'package:cyber_lab/theme/spacing.dart';
import 'app_card.dart';

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
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.md),
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
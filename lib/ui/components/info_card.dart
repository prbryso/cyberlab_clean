import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/colors.dart';
import 'package:cyber_lab/theme/typography.dart';
import 'package:cyber_lab/theme/spacing.dart';
import 'app_card.dart';
import 'package:cyber_lab/ui/theme/app_spacing.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData? icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.body,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, color: AppColors.cyberBlue, size: 28),
          if (icon != null) const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
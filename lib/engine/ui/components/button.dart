import 'package:flutter/material.dart';
import 'package:systems_studio/engine/theme/colors.dart';
import 'package:systems_studio/engine/theme/typography.dart';
import 'package:systems_studio/engine/theme/spacing.dart';
import 'package:systems_studio/engine/ui/theme/app_spacing.dart';

enum ButtonType { primary, secondary, ghost, danger }

class CyberButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool fullWidth;
  final IconData? icon;

  const CyberButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.fullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;

    // Colors based on type
    Color background;
    Color foreground;
    Color border;

    switch (type) {
      case ButtonType.primary:
        background = isDisabled
            ? AppColors.primary.withOpacity(0.4)
            : AppColors.primary;
        foreground = Colors.white;
        border = Colors.transparent;
        break;

      case ButtonType.secondary:
        background = isDisabled ? AppColors.surfaceAlt : AppColors.surface;
        foreground = AppColors.textPrimary;
        border = AppColors.border;
        break;

      case ButtonType.ghost:
        background = Colors.transparent;
        foreground = isDisabled ? AppColors.textMuted : AppColors.textPrimary;
        border = Colors.transparent;
        break;

      case ButtonType.danger:
        background = isDisabled
            ? AppColors.danger.withOpacity(0.4)
            : AppColors.danger;
        foreground = Colors.white;
        border = Colors.transparent;
        break;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border, width: 1.5),
          ),
          textStyle: AppTypography.bodyBold,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

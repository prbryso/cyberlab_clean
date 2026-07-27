import 'package:flutter/material.dart';

import 'package:systems_studio/engine/theme/spacing.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final color = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(spacing.md),
        border: Border.all(color: color.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.primaryContainer,
                    borderRadius: BorderRadius.circular(spacing.sm),
                  ),
                  child: Icon(icon, size: 21, color: color.onPrimaryContainer),
                ),
                SizedBox(width: spacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: spacing.xs),
                      Text(
                        subtitle!,
                        style: text.bodyMedium?.copyWith(
                          color: color.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[SizedBox(width: spacing.sm), trailing!],
            ],
          ),
          SizedBox(height: spacing.sm),
          Container(
            width: 48,
            height: 3,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          SizedBox(height: spacing.md),
          child,
        ],
      ),
    );
  }
}

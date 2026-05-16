import 'package:flutter/material.dart';

/// Global spacing scale for Cyber Lab.
/// Provides consistent padding, margins, and sizing across the app.
class CyberLabSpacing {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  const CyberLabSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  /// Access spacing from the widget tree.
  static CyberLabSpacing of(BuildContext context) {
    return const CyberLabSpacing(
      xs: 4,
      sm: 8,
      md: 12,
      lg: 20,
      xl: 32,
    );
  }
}
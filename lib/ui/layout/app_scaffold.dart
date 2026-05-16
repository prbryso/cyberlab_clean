import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/colors.dart';
import 'package:cyber_lab/theme/spacing.dart';
import 'package:cyber_lab/ui/theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool scrollable;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigation;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.scrollable = true,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: child,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
            )
          : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigation,
      body: SafeArea(
        child: scrollable
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: content,
              )
            : content,
      ),
    );
  }
}
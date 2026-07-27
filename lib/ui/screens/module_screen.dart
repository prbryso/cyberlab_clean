import 'package:flutter/material.dart';

import 'package:systems_studio/data/systems/authentication_systems.dart';
import 'package:systems_studio/engine/models/module.dart';
import 'package:systems_studio/engine/models/perspective.dart';
import 'package:systems_studio/engine/models/system_model.dart';
import 'package:systems_studio/theme/spacing.dart';
import 'package:systems_studio/ui/widgets/common/section_card.dart';
import 'package:systems_studio/ui/widgets/diagrams/system_model_widget.dart';
import 'package:systems_studio/ui/widgets/module/module_roadmap.dart';
import 'package:systems_studio/ui/widgets/perspective/perspective_selector.dart';

class ModuleScreen extends StatefulWidget {
  final LearningModule module;

  const ModuleScreen({super.key, required this.module});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  PerspectiveType selectedPerspective = PerspectiveType.user;

  SystemModel get selectedAuthenticationModel {
    switch (selectedPerspective) {
      case PerspectiveType.user:
        return userAuthenticationSystem;

      case PerspectiveType.attacker:
        return attackerAuthenticationSystem;

      case PerspectiveType.defender:
        return defenderAuthenticationSystem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final color = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      body: ListView(
        padding: EdgeInsets.all(spacing.md),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ModuleHero(module: widget.module),
                  SizedBox(height: spacing.lg),
                  SectionCard(
                    title: 'Scenario',
                    icon: Icons.menu_book_outlined,
                    child: Text(
                      widget.module.scenario,
                      style: text.bodyLarge?.copyWith(
                        height: 1.5,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  SectionCard(
                    title: 'Why This Matters',
                    icon: Icons.psychology_outlined,
                    child: Text(
                      widget.module.whyItMatters,
                      style: text.bodyLarge?.copyWith(
                        height: 1.5,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  SectionCard(
                    title: 'System View',
                    icon: Icons.account_tree_outlined,
                    subtitle:
                        'Explore how the same authentication system behaves '
                        'from different perspectives.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select the User, Attacker, or Defender view to '
                          'understand each role’s goals, actions, and outcomes.',
                          style: text.bodyMedium?.copyWith(
                            height: 1.45,
                            color: color.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: spacing.md),
                        PerspectiveSelector(
                          selected: selectedPerspective,
                          onChanged: (value) {
                            setState(() {
                              selectedPerspective = value;
                            });
                          },
                        ),
                        SizedBox(height: spacing.lg),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final slideAnimation = Tween<Offset>(
                              begin: const Offset(0, 0.025),
                              end: Offset.zero,
                            ).animate(animation);

                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: slideAnimation,
                                child: child,
                              ),
                            );
                          },
                          child: SystemModelWidget(
                            key: ValueKey(selectedAuthenticationModel.id),
                            model: selectedAuthenticationModel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  SectionCard(
                    title: 'Module Roadmap',
                    icon: Icons.route_outlined,
                    subtitle:
                        'Follow the lessons below to complete this learning '
                        'module.',
                    child: ModuleRoadmap(module: widget.module),
                  ),
                  SizedBox(height: spacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleHero extends StatelessWidget {
  final LearningModule module;

  const _ModuleHero({required this.module});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final color = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(spacing.md),
        border: Border.all(color: color.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(spacing.md),
            ),
            child: Icon(
              Icons.lock_person_outlined,
              size: 30,
              color: color.onPrimary,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: text.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  module.goal,
                  style: text.titleMedium?.copyWith(
                    height: 1.4,
                    color: color.onPrimaryContainer.withValues(alpha: 0.88),
                  ),
                ),
                SizedBox(height: spacing.md),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    _HeroBadge(
                      icon: Icons.schedule_outlined,
                      label: module.estimatedTime,
                    ),
                    _HeroBadge(
                      icon: Icons.school_outlined,
                      label: module.difficulty,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final color = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color.primary),
          SizedBox(width: spacing.xs),
          Text(
            label,
            style: text.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

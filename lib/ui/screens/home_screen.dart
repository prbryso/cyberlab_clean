import 'package:flutter/material.dart';

import 'package:systems_studio/engine/core/responsive/responsive_layout.dart';
import 'package:systems_studio/theme/spacing.dart';
import 'package:systems_studio/ui/widgets/dashboard/dashboard_header.dart';
import 'package:systems_studio/ui/widgets/dashboard/progress_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler.scale(1).clamp(1.0, 1.2);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        appBar: AppBar(title: const Text('iSecurity')),
        body: ListView(
          padding: EdgeInsets.all(spacing.md),
          children: [
            _DashboardSection(spacing: spacing),
            SizedBox(height: spacing.lg),
            _LearningPathHeading(spacing: spacing),
            SizedBox(height: spacing.sm),
            _ModuleGrid(spacing: spacing),
          ],
        ),
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final CyberLabSpacing spacing;

  const _DashboardSection({required this.spacing});

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isSmall(context)) {
      return Column(
        children: [
          const DashboardHeader(),
          SizedBox(height: spacing.md),
          const ProgressCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 3, child: DashboardHeader()),
        SizedBox(width: spacing.md),
        const Expanded(flex: 1, child: ProgressCard()),
      ],
    );
  }
}

class _LearningPathHeading extends StatelessWidget {
  final CyberLabSpacing spacing;

  const _LearningPathHeading({required this.spacing});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (ResponsiveLayout.isSmall(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Path',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Start anywhere or follow the recommended sequence. '
            'Use the Begin Learning button to get started.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Learning Path',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text:
                '        Start anywhere or follow the recommended sequence. '
                'Use the Begin Learning button to get started.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  final CyberLabSpacing spacing;

  const _ModuleGrid({required this.spacing});

  @override
  Widget build(BuildContext context) {
    final columns = _columnCount(context);
    final cardHeight = _cardHeight(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _modules.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing.sm,
        mainAxisSpacing: spacing.sm,
        mainAxisExtent: cardHeight,
      ),
      itemBuilder: (context, index) {
        final module = _modules[index];

        return ModuleCard(
          title: module.title,
          description: module.description,
          icon: module.icon,
          route: module.route,
        );
      },
    );
  }

  int _columnCount(BuildContext context) {
    if (ResponsiveLayout.isLarge(context)) {
      return 3;
    }

    if (ResponsiveLayout.isMedium(context)) {
      return 2;
    }

    return 1;
  }

  double _cardHeight(BuildContext context) {
    if (ResponsiveLayout.isSmall(context)) {
      return 132;
    }

    return 142;
  }
}

class ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const ModuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(spacing.md),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(spacing.md),
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: spacing.lg * 1.1, color: colorScheme.primary),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xs),
                    Flexible(
                      child: Text(
                        description,
                        style: textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleDefinition {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const _ModuleDefinition({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}

const List<_ModuleDefinition> _modules = [
  _ModuleDefinition(
    title: 'Prevent Account Takeovers',
    description:
        'Learn how attackers break weak passwords and reuse stolen credentials.',
    icon: Icons.lock,
    route: '/password',
  ),
  _ModuleDefinition(
    title: 'Protect Data with Encryption',
    description: 'Understand how encryption protects private information.',
    icon: Icons.key,
    route: '/encryption',
  ),
  _ModuleDefinition(
    title: 'Spot Phishing Attacks',
    description:
        'Recognize fake emails, malicious links, and credential theft attempts.',
    icon: Icons.mark_email_read,
    route: '/phishing',
  ),
  _ModuleDefinition(
    title: 'Defeat Social Engineering',
    description:
        'Learn how attackers manipulate people to bypass technical defenses.',
    icon: Icons.psychology,
    route: '/social',
  ),
  _ModuleDefinition(
    title: 'Understand Networks',
    description:
        'See how systems communicate and where attackers look for weakness.',
    icon: Icons.hub,
    route: '/networking',
  ),
  _ModuleDefinition(
    title: 'OS and Application Holes',
    description: 'Learn how software and operating system flaws are exploited.',
    icon: Icons.warning_amber,
    route: '/osappholes',
  ),
  _ModuleDefinition(
    title: 'Exploits',
    description: 'See how attackers turn vulnerabilities into real attacks.',
    icon: Icons.bolt,
    route: '/exploits',
  ),
  _ModuleDefinition(
    title: 'Zero-Days',
    description: 'Learn why unknown vulnerabilities are especially dangerous.',
    icon: Icons.bug_report,
    route: '/zero-days',
  ),
  _ModuleDefinition(
    title: 'Patch Management',
    description: 'Fix vulnerabilities before attackers exploit them.',
    icon: Icons.system_update_alt,
    route: '/patch',
  ),
  _ModuleDefinition(
    title: 'System Hardening',
    description: 'Reduce attack surface and lock systems down.',
    icon: Icons.shield,
    route: '/hardening',
  ),
  _ModuleDefinition(
    title: 'Secure Coding',
    description: 'Prevent vulnerabilities before software is released.',
    icon: Icons.code,
    route: '/secure',
  ),
  _ModuleDefinition(
    title: 'Capstone Challenge',
    description: 'Complete a full incident response simulation.',
    icon: Icons.flag,
    route: '/capstone',
  ),
];

import 'package:flutter/material.dart';

import 'package:systems_studio/engine/core/responsive/responsive_layout.dart';
import 'package:systems_studio/engine/models/studio_library.dart';
import 'package:systems_studio/engine/models/studio_system.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, required this.library});

  final StudioLibrary library;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final dashboard = library.dashboard;

    final featuredSystem = _systemById(
      library.systems,
      dashboard.featuredSystemId,
    );

    return Scaffold(
      appBar: AppBar(title: Text(library.name)),
      body: ListView(
        padding: EdgeInsets.all(spacing.md),
        children: [
          _LibraryHero(library: library, spacing: spacing),
          SizedBox(height: spacing.lg),
          if (featuredSystem != null) ...[
            _FeaturedSystemCard(system: featuredSystem, spacing: spacing),
            SizedBox(height: spacing.lg),
          ],
          _DashboardRow(library: library, spacing: spacing),
          SizedBox(height: spacing.lg),
          _SectionTitle(
            title: 'Explore Systems',
            subtitle:
                'Choose any system to explore its concepts, perspectives, '
                'diagrams, lessons, and simulations.',
          ),
          SizedBox(height: spacing.sm),
          _SystemGrid(systems: library.systems, spacing: spacing),
        ],
      ),
    );
  }

  StudioSystem? _systemById(List<StudioSystem> systems, String id) {
    for (final system in systems) {
      if (system.id == id) {
        return system;
      }
    }

    return null;
  }
}

class _LibraryHero extends StatelessWidget {
  const _LibraryHero({required this.library, required this.spacing});

  final StudioLibrary library;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = library.dashboard;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(spacing.md),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(spacing.md),
            ),
            child: Icon(library.icon, size: 32, color: colorScheme.onPrimary),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  library.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  dashboard.heroTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  dashboard.heroSubtitle,
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.md),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    _HeroBadge(
                      icon: Icons.account_tree_outlined,
                      label: '${library.systems.length} systems',
                    ),
                    const _HeroBadge(
                      icon: Icons.explore_outlined,
                      label: 'Open exploration',
                    ),
                    _HeroBadge(
                      icon: Icons.info_outline,
                      label: 'Version ${library.version}',
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
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: colorScheme.primary),
          SizedBox(width: spacing.xs),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSystemCard extends StatelessWidget {
  const _FeaturedSystemCard({required this.system, required this.spacing});

  final StudioSystem system;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(spacing.md),
              ),
              child: Icon(system.icon, size: 30, color: colorScheme.primary),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured System',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    system.title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    system.description,
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.md),
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, system.entryRoute);
              },
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Explore'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardRow extends StatelessWidget {
  const _DashboardRow({required this.library, required this.spacing});

  final StudioLibrary library;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isSmall(context)) {
      return Column(
        children: [
          _SuggestedPathsCard(library: library, spacing: spacing),
          SizedBox(height: spacing.md),
          _FeaturedSimulationCard(library: library, spacing: spacing),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SuggestedPathsCard(library: library, spacing: spacing),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: _FeaturedSimulationCard(library: library, spacing: spacing),
        ),
      ],
    );
  }
}

class _SuggestedPathsCard extends StatelessWidget {
  const _SuggestedPathsCard({required this.library, required this.spacing});

  final StudioLibrary library;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    final dashboard = library.dashboard;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route_outlined, color: colorScheme.primary),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    'Suggested Explorations',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Use these optional paths to explore related systems.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.md),
            _PathRow(
              libraryId: library.id,
              pathId: 'beginner',
              label: 'Foundations',
              count: dashboard.beginnerPath.length,
              icon: Icons.flag_outlined,
            ),
            SizedBox(height: spacing.sm),
            _PathRow(
              libraryId: library.id,
              pathId: 'intermediate',
              label: 'Systems and Threats',
              count: dashboard.intermediatePath.length,
              icon: Icons.account_tree_outlined,
            ),
            SizedBox(height: spacing.sm),
            _PathRow(
              libraryId: library.id,
              pathId: 'advanced',
              label: 'Defense and Application',
              count: dashboard.advancedPath.length,
              icon: Icons.shield_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.libraryId,
    required this.pathId,
    required this.label,
    required this.count,
    required this.icon,
  });

  final String libraryId;
  final String pathId;
  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(spacing.sm),
        onTap: () {
          Navigator.pushNamed(context, '/library/$libraryId/path/$pathId');
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xs,
            vertical: spacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: colorScheme.primary),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$count systems',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: spacing.xs),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedSimulationCard extends StatelessWidget {
  const _FeaturedSimulationCard({required this.library, required this.spacing});

  final StudioLibrary library;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    final dashboard = library.dashboard;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science_outlined, color: colorScheme.primary),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    'Featured Simulation',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Text(
              'Password Cracking',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Explore how password length, complexity, attack methods, and '
              'defensive controls affect cracking time.',
              style: textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.md),
            Row(
              children: [
                Icon(
                  Icons.memory_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    dashboard.featuredSimulationId,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SystemGrid extends StatelessWidget {
  const _SystemGrid({required this.systems, required this.spacing});

  final List<StudioSystem> systems;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: systems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columnCount(context),
        crossAxisSpacing: spacing.sm,
        mainAxisSpacing: spacing.sm,
        mainAxisExtent: _cardHeight(context),
      ),
      itemBuilder: (context, index) {
        return _SystemCard(system: systems[index]);
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
    return ResponsiveLayout.isSmall(context) ? 138 : 146;
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.system});

  final StudioSystem system;

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
          Navigator.pushNamed(context, system.entryRoute);
        },
        child: Ink(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(spacing.md),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                system.icon,
                size: spacing.lg * 1.1,
                color: colorScheme.primary,
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      system.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xs),
                    Flexible(
                      child: Text(
                        system.description,
                        style: textTheme.bodyMedium?.copyWith(height: 1.35),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.xs),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

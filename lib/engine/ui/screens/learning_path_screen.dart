import 'package:flutter/material.dart';

import 'package:systems_studio/engine/core/responsive/responsive_layout.dart';
import 'package:systems_studio/engine/models/studio_library.dart';
import 'package:systems_studio/engine/models/studio_system.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({
    super.key,
    required this.library,
    required this.pathName,
    required this.systemIds,
  });

  final StudioLibrary library;
  final String pathName;
  final List<String> systemIds;

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final systems = _resolveSystems();

    return Scaffold(
      appBar: AppBar(title: Text('$pathName Path')),
      body: ListView(
        padding: EdgeInsets.all(spacing.md),
        children: [
          _PathHeader(
            library: library,
            pathName: pathName,
            systemCount: systems.length,
            spacing: spacing,
          ),
          SizedBox(height: spacing.lg),
          Text(
            'Learning Sequence',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Complete these systems in the recommended order.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.md),
          if (systems.isEmpty)
            const _EmptyPathMessage()
          else
            _PathSystemList(systems: systems, spacing: spacing),
        ],
      ),
    );
  }

  List<StudioSystem> _resolveSystems() {
    final systemsById = {
      for (final system in library.systems) system.id: system,
    };

    return [
      for (final id in systemIds)
        if (systemsById[id] != null) systemsById[id]!,
    ];
  }
}

class _PathHeader extends StatelessWidget {
  const _PathHeader({
    required this.library,
    required this.pathName,
    required this.systemCount,
    required this.spacing,
  });

  final StudioLibrary library;
  final String pathName;
  final int systemCount;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(spacing.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _pathIcon(pathName),
            size: 48,
            color: colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  library.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  '$pathName Learning Path',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  _pathDescription(pathName),
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  '$systemCount learning systems',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _pathIcon(String name) {
    switch (name.toLowerCase()) {
      case 'beginner':
        return Icons.flag_outlined;

      case 'intermediate':
        return Icons.route;

      case 'advanced':
        return Icons.workspace_premium_outlined;

      default:
        return Icons.school_outlined;
    }
  }

  String _pathDescription(String name) {
    switch (name.toLowerCase()) {
      case 'beginner':
        return 'Build the foundational knowledge needed to recognize common '
            'threats and understand essential protections.';

      case 'intermediate':
        return 'Explore how systems communicate, where vulnerabilities arise, '
            'and how attackers turn weaknesses into attacks.';

      case 'advanced':
        return 'Apply defensive engineering practices and integrate what you '
            'have learned in increasingly complex scenarios.';

      default:
        return 'Follow the recommended sequence of learning systems.';
    }
  }
}

class _PathSystemList extends StatelessWidget {
  const _PathSystemList({required this.systems, required this.spacing});

  final List<StudioSystem> systems;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isLarge(context)) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: systems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: spacing.md,
          mainAxisSpacing: spacing.md,
          mainAxisExtent: 160,
        ),
        itemBuilder: (context, index) {
          return _PathSystemCard(
            system: systems[index],
            sequenceNumber: index + 1,
          );
        },
      );
    }

    return Column(
      children: [
        for (var index = 0; index < systems.length; index++) ...[
          _PathSystemCard(system: systems[index], sequenceNumber: index + 1),
          if (index < systems.length - 1) SizedBox(height: spacing.md),
        ],
      ],
    );
  }
}

class _PathSystemCard extends StatelessWidget {
  const _PathSystemCard({required this.system, required this.sequenceNumber});

  final StudioSystem system;
  final int sequenceNumber;

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
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Text(
                  '$sequenceNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: spacing.md),
              Icon(system.icon, color: colorScheme.primary),
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
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      system.description,
                      style: textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPathMessage extends StatelessWidget {
  const _EmptyPathMessage();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No systems are currently assigned to this learning path.',
          ),
        ),
      ),
    );
  }
}

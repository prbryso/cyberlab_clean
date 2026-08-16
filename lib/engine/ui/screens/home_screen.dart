import 'package:flutter/material.dart';

import 'package:systems_studio/engine/core/responsive/responsive_layout.dart';
import 'package:systems_studio/engine/models/studio_library.dart';
import 'package:systems_studio/engine/services/studio_library_registry.dart';
import 'package:systems_studio/engine/theme/spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CyberLabSpacing.of(context);
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler.scale(1).clamp(1.0, 1.2);
    final libraries = StudioLibraryRegistry.instance.libraries;

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Systems Studio')),
        body: ListView(
          padding: EdgeInsets.all(spacing.md),
          children: [
            _StudioHeader(spacing: spacing),
            SizedBox(height: spacing.lg),
            Text(
              'Learning Libraries',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing.xs),
            Text(
              'Select a library to explore its systems, lessons, '
              'diagrams, and simulations.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: spacing.md),
            if (libraries.isEmpty)
              const _EmptyLibraryMessage()
            else
              _LibraryGrid(libraries: libraries, spacing: spacing),
          ],
        ),
      ),
    );
  }
}

class _StudioHeader extends StatelessWidget {
  const _StudioHeader({required this.spacing});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Complex Systems',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Teach the System.\nNot Just the Rule.',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Choose a learning library and explore how its systems work.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryGrid extends StatelessWidget {
  const _LibraryGrid({required this.libraries, required this.spacing});

  final List<StudioLibrary> libraries;
  final CyberLabSpacing spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: libraries.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columnCount(context),
        crossAxisSpacing: spacing.sm,
        mainAxisSpacing: spacing.sm,
        mainAxisExtent: 190,
      ),
      itemBuilder: (context, index) {
        return _LibraryCard(library: libraries[index]);
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
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.library});

  final StudioLibrary library;

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
          Navigator.pushNamed(context, '/library/${library.id}');
        },
        child: Ink(
          padding: EdgeInsets.all(spacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(spacing.md),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(library.icon, size: 42, color: colorScheme.primary),
              SizedBox(height: spacing.md),
              Text(
                library.name,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: spacing.xs),
              Expanded(
                child: Text(
                  library.description,
                  style: textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${library.systems.length} systems',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLibraryMessage extends StatelessWidget {
  const _EmptyLibraryMessage();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No learning libraries are installed.')),
      ),
    );
  }
}

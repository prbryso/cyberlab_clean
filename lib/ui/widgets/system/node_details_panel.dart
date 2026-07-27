import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/system_model.dart';

class NodeDetailsPanel extends StatelessWidget {
  const NodeDetailsPanel({super.key, required this.node});

  final SystemNode? node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (node == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.touch_app_outlined, size: 48, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'Select a System Component',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Click any component in the system diagram to learn its purpose, '
              'risks, defenses, and related lessons.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              node!.label,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Chip(label: Text(node!.type.name.toUpperCase())),

            const SizedBox(height: 22),

            if (node!.description != null)
              _Section(title: 'Description', child: Text(node!.description!)),

            if (node!.purpose != null)
              _Section(title: 'Purpose', child: Text(node!.purpose!)),

            if (node!.risks.isNotEmpty)
              _BulletSection(
                title: 'Risks',
                items: node!.risks,
                icon: Icons.warning_amber_rounded,
              ),

            if (node!.defenses.isNotEmpty)
              _BulletSection(
                title: 'Defenses',
                items: node!.defenses,
                icon: Icons.shield_outlined,
              ),

            if (node!.relatedLessons.isNotEmpty)
              _BulletSection(
                title: 'Related Lessons',
                items: node!.relatedLessons,
                icon: Icons.menu_book_outlined,
              ),

            if (node!.references.isNotEmpty)
              _BulletSection(
                title: 'References',
                items: node!.references,
                icon: Icons.link,
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.title,
    required this.items,
    required this.icon,
  });

  final String title;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

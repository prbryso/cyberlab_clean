import 'package:flutter/material.dart';
import 'package:systems_studio/engine/models/module.dart';

class ModuleRoadmap extends StatelessWidget {
  final LearningModule module;

  const ModuleRoadmap({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Column(
      children: [
        for (int i = 0; i < module.lessons.length; i++)
          _RoadmapTile(
            lesson: module.lessons[i],
            isLast: i == module.lessons.length - 1,
          ),
      ],
    );
  }
}

class _RoadmapTile extends StatelessWidget {
  final Lesson lesson;
  final bool isLast;

  const _RoadmapTile({required this.lesson, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pushNamed(context, lesson.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: color.primaryContainer,
                    child: Icon(
                      Icons.play_arrow,
                      size: 18,
                      color: color.onPrimaryContainer,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 42,
                      color: color.outlineVariant,
                    ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: color.primary),
                        const SizedBox(width: 6),
                        Text(
                          "${lesson.minutes} minutes",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            Icon(Icons.chevron_right, color: color.outline),
          ],
        ),
      ),
    );
  }
}

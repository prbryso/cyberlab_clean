import 'package:flutter/material.dart';
import 'package:systems_studio/engine/models/system_simulation.dart';
import 'package:systems_studio/engine/controllers/simulation_controller.dart';

class SimulationPanel extends StatelessWidget {
  const SimulationPanel({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final simulation = controller.simulation;
        final step = controller.currentStep;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.play_circle_outline, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      simulation?.name ?? 'Simulation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    controller.hasSimulation
                        ? 'Step ${controller.hasStarted ? controller.currentStepIndex + 1 : 0}'
                              ' of ${simulation!.stepCount}'
                        : '',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              LinearProgressIndicator(
                value: controller.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(6),
              ),

              const SizedBox(height: 24),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: controller.hasSimulation
                        ? controller.start
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run'),
                  ),

                  OutlinedButton.icon(
                    onPressed: controller.hasStarted
                        ? controller.previous
                        : null,
                    icon: const Icon(Icons.skip_previous),
                    label: const Text('Previous'),
                  ),

                  OutlinedButton.icon(
                    onPressed: controller.hasStarted ? controller.next : null,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next'),
                  ),

                  TextButton.icon(
                    onPressed: controller.hasStarted ? controller.reset : null,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              if (step == null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Press Run to begin the simulation.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title ?? 'Simulation Step',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Chip(
                      avatar: Icon(switch (step.level) {
                        SimulationLevel.normal => Icons.info_outline,
                        SimulationLevel.warning => Icons.warning_amber_rounded,
                        SimulationLevel.critical => Icons.gpp_bad,
                      }, size: 18),
                      label: Text(step.level.name.toUpperCase()),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      step.narration,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/simulation/causal_graph.dart';
import 'package:systems_studio/engine/simulation/studio_trace.dart';

/// What happened during the run, as a causal chain through the system.
///
/// This is not the architecture graph and does not try to be. Architecture
/// answers how a system is built; this answers what took place in it. Because
/// it is generated from the run, everything needed to follow a chain is here
/// from the moment it appears — there is no hierarchy to expand and nothing to
/// go looking for.
///
/// It shows **system truth**: the complete chain, regardless of who knew what.
/// When a participant is selected, the occurrences that participant actually
/// witnessed are marked. Nothing is hidden — a learner needs to be able to see
/// both what happened and how little of it someone knew.
class CausalGraphView extends StatelessWidget {
  const CausalGraphView({
    super.key,
    required this.causalGraph,
    this.selectedActor,
    this.selectedElement,
    this.onElementSelected,
    this.emptyMessage = 'Nothing has happened yet. Choose an action to begin.',
  });

  final SimulationCausalGraph causalGraph;

  /// When set, occurrences this participant observed are marked.
  final StudioElementRef? selectedActor;

  final StudioElementRef? selectedElement;

  final ValueChanged<StudioElementRef>? onElementSelected;

  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (causalGraph.isEmpty) {
      return Padding(
        key: const Key('causal-graph-empty'),
        padding: const EdgeInsets.all(24),
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      key: const Key('causal-graph'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final link in causalGraph.links)
          _CausalStep(
            link: link,
            causalGraph: causalGraph,
            selectedActor: selectedActor,
            selectedElement: selectedElement,
            onElementSelected: onElementSelected,
          ),
      ],
    );
  }
}

class _CausalStep extends StatelessWidget {
  const _CausalStep({
    required this.link,
    required this.causalGraph,
    required this.selectedActor,
    required this.selectedElement,
    required this.onElementSelected,
  });

  final StudioCausalLink link;
  final SimulationCausalGraph causalGraph;
  final StudioElementRef? selectedActor;
  final StudioElementRef? selectedElement;
  final ValueChanged<StudioElementRef>? onElementSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actor = selectedActor;

    final witnessed = actor != null && link.observers.contains(actor);

    final target = causalGraph.nodeFor(link.to);

    return Padding(
      key: Key('causal-step-${link.sequence}'),
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ElementChip(
            element: link.from,
            causalGraph: causalGraph,
            selectedElement: selectedElement,
            onElementSelected: onElementSelected,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 18, top: 2, bottom: 2),
            // The rail marks the height of the step it belongs to. It is a
            // border rather than a sibling of fixed height, so it matches
            // however many lines the content wraps onto — and one fewer row
            // of children is one fewer thing that can fail to fit.
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // What happened, and what kind of happening it was.
                  //
                  // A set of things about one step rather than a fixed
                  // line of them: in a sidebar the name alone can want
                  // the whole width, and the badges should drop beneath
                  // it instead of squeezing it. A Row would have to
                  // choose which of them to crush.
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // The icon belongs to the name, so they travel as
                      // one item and wrap together.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              _iconFor(link.kind),
                              size: 14,
                              color: _colorFor(link.kind, colorScheme),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              link.label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _colorFor(link.kind, colorScheme),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _KindTag(kind: link.kind),
                      if (witnessed) const _WitnessTag(),
                    ],
                  ),

                  // Why this happened, in the author's words.
                  //
                  // Distinct from the question below it in both role and
                  // appearance: this is a statement about what took place,
                  // and it is the only thing on the step that answers "why
                  // this outcome and not the other one". Shown only where an
                  // author wrote it.
                  if (link.explanation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        link.explanation!,
                        key: Key('causal-explanation-${link.sequence}'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                        ),
                      ),
                    ),

                  // The question an author left open at this step.
                  //
                  // Set apart from the facts above it, because it is not one:
                  // it is an invitation to look, and it stays a question. It
                  // names nothing to do next and appears only where an author
                  // wrote one — none is ever invented to fill a gap.
                  if (link.guidingQuestion != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.help_outline,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              link.guidingQuestion!,
                              key: Key('causal-question-${link.sequence}'),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (link.channelRelationshipIds.isNotEmpty)
                    Text(
                      'via ${link.channelRelationshipIds.join(", ")}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                  // Only values that actually changed during the run.
                  //
                  // This surface is the history, so every transition is
                  // listed. One step can move the same variable twice —
                  // an outcome applies its effects in order — so the
                  // position within the step is part of what identifies a
                  // transition, alongside the step's own sequence. Without
                  // it, two moves of one variable in one step would claim
                  // the same identity.
                  for (final (index, change)
                      in link.stateChanges.indexed)
                    Text(
                      '${change.variableId.split(".").last}: '
                      '${change.previousValue} → ${change.newValue}',
                      key: Key(
                        'causal-change-${link.sequence}-$index-'
                        '${change.variableId}',
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: Icon(
                  Icons.arrow_downward,
                  size: 16,
                  color: colorScheme.outline,
                ),
              ),
              Expanded(
                child: _ElementChip(
                  element: link.to,
                  causalGraph: causalGraph,
                  selectedElement: selectedElement,
                  onElementSelected: onElementSelected,
                  showInvolvement: true,
                ),
              ),
            ],
          ),

          // Becoming involved is an actor concept. A component that an
          // occurrence reached has not "become involved and not acted" — it
          // simply received something. Saying otherwise would put actor
          // language on a part of the system, and would contradict the
          // element chip above, which already shows involvement for actors
          // only.
          if (target != null &&
              target.isActor &&
              target.becameInvolvedByObservation &&
              !target.hasActed)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 2),
              child: Text(
                'Became involved. Has not acted.',
                key: Key('causal-involved-${target.element.id}'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  static IconData _iconFor(StudioCausalLinkKind kind) {
    return switch (kind) {
      StudioCausalLinkKind.chosenAction => Icons.touch_app_outlined,
      StudioCausalLinkKind.automaticBehavior => Icons.settings_suggest_outlined,
      StudioCausalLinkKind.observation => Icons.campaign_outlined,
    };
  }

  static Color _colorFor(StudioCausalLinkKind kind, ColorScheme scheme) {
    return switch (kind) {
      StudioCausalLinkKind.chosenAction => scheme.primary,
      StudioCausalLinkKind.automaticBehavior => scheme.tertiary,
      StudioCausalLinkKind.observation => scheme.secondary,
    };
  }
}

/// Says whether an occurrence was chosen by someone or happened on its own.
class _KindTag extends StatelessWidget {
  const _KindTag({required this.kind});

  final StudioCausalLinkKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = switch (kind) {
      StudioCausalLinkKind.chosenAction => 'chosen',
      StudioCausalLinkKind.automaticBehavior => 'automatic',
      StudioCausalLinkKind.observation => 'reached them',
    };

    return Container(
      key: Key('causal-kind-${kind.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Marks an occurrence the selected participant actually witnessed.
class _WitnessTag extends StatelessWidget {
  const _WitnessTag();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('causal-witnessed'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'they saw this',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A real system element, selectable by its own identity.
class _ElementChip extends StatelessWidget {
  const _ElementChip({
    required this.element,
    required this.causalGraph,
    required this.selectedElement,
    required this.onElementSelected,
    this.showInvolvement = false,
  });

  final StudioElementRef element;
  final SimulationCausalGraph causalGraph;
  final StudioElementRef? selectedElement;
  final ValueChanged<StudioElementRef>? onElementSelected;
  final bool showInvolvement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final node = causalGraph.nodeFor(element);
    final label = node?.label ?? element.id;

    final isSelected = selectedElement == element;

    final involved =
        showInvolvement && (node?.becameInvolvedByObservation ?? false);

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('causal-element-${element.id}'),
          borderRadius: BorderRadius.circular(8),
          onTap: onElementSelected == null
              ? null
              : () => onElementSelected!(element),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ),
            // Sized to its label where there is room, and wrapping the label
            // where there is not. The icons keep their space either way, so
            // a narrow column costs the name a second line rather than
            // costing it characters.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (node?.isActor ?? false) ...[
                  Icon(
                    involved
                        ? Icons.notifications_active_outlined
                        : Icons.person_outline,
                    size: 14,
                    color: involved
                        ? colorScheme.tertiary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (node != null && node.stateChanges.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.toggle_on_outlined,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience for showing changes at one element, used by detail surfaces.
List<StudioStateChange> causalChangesFor(
  SimulationCausalGraph causalGraph,
  StudioElementRef element,
) {
  return causalGraph.nodeFor(element)?.stateChanges ?? const [];
}

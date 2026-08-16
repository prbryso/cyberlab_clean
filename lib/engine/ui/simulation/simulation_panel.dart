import 'package:flutter/material.dart';

import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/perspectives/actor/actor_perspective.dart';
import 'package:systems_studio/engine/perspectives/actor/actor_perspective_view.dart';
import 'package:systems_studio/engine/perspectives/studio_perspective.dart';
import 'package:systems_studio/engine/ui/simulation/studio_simulation_controller.dart';
import 'package:systems_studio/engine/ui/widgets/perspective/actor_perspective_renderer.dart';
import 'package:systems_studio/engine/simulation/studio_situation_snapshot.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/action_list_sheet.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/causal_graph_view.dart';
import 'package:systems_studio/engine/ui/widgets/simulation/trace_view.dart';

/// The learner-facing surface for exploring a running system.
///
/// Holds no simulation logic of its own. Every decision — which actions are
/// available, what an actor knows, what happened and why — comes from the
/// controller and the perspective. This widget selects, displays, and forwards
/// choices.
class SimulationPanel extends StatefulWidget {
  const SimulationPanel({
    super.key,
    required this.controller,
    required this.session,
    this.selectedElement,
    this.onElementSelected,
  });

  final StudioSimulationController controller;

  /// The validated graph and query helper for the system being explored.
  final StudioGraphSession session;

  /// Selection shared with the rest of the screen, when there is one.
  final StudioElementRef? selectedElement;

  final ValueChanged<StudioElementRef>? onElementSelected;

  @override
  State<SimulationPanel> createState() => _SimulationPanelState();
}

class _SimulationPanelState extends State<SimulationPanel> {
  static const ActorPerspective _perspective = ActorPerspective();

  /// The situation the learner chose, or null while they are choosing.
  ///
  /// A run always has a scenario, so this is not the run's state — it is
  /// whether the learner has said which situation they came to explore. A
  /// system offering none skips the question entirely.
  StudioScenario? _chosenScenario;

  StudioElementRef? _localSelection;

  List<StudioScenario> get _scenarios => _graph.scenarios;

  /// True when this panel opened onto an exploration already under way.
  ///
  /// Such a run started somewhere before this panel existed, so there is no
  /// choice outstanding. Without this, resetting that run would empty it,
  /// make it look unstarted, and throw the learner into the chooser — losing
  /// the exploration to a question nobody asked.
  bool _openedMidRun = false;

  @override
  void initState() {
    super.initState();

    _openedMidRun = !widget.controller.isAtStart;
  }

  /// True while the learner still has a situation to choose.
  ///
  /// Emptiness alone never asks the question: a reset run is empty, and reset
  /// must stay inside its situation.
  bool get _isChoosingScenario =>
      _scenarios.isNotEmpty &&
      _chosenScenario == null &&
      !_openedMidRun &&
      widget.controller.isAtStart;

  /// Begins exploring [scenario], from the beginning.
  ///
  /// Always a restart, so returning to a situation is a fresh exploration
  /// rather than a resumption of whatever was left behind in it. Nothing is
  /// performed here: choosing where to start is not the same as acting.
  void _chooseScenario(StudioScenario scenario) {
    widget.controller.restart(scenario: scenario);

    setState(() {
      _chosenScenario = scenario;
      _localSelection = null;
    });
  }

  /// Returns to the question of which situation to explore.
  ///
  /// Leaving a situation ends the exploration of it. The run goes back to the
  /// start so the chooser is answering a real question rather than hovering
  /// over a run still holding someone else's history.
  void _changeScenario() {
    widget.controller.restart();

    setState(() {
      _chosenScenario = null;
      _localSelection = null;

      // Asking for the chooser is asking the question, so whatever this panel
      // opened onto no longer suppresses it.
      _openedMidRun = false;
    });
  }

  StudioElementRef? get _selection =>
      widget.selectedElement ?? _localSelection;

  /// True when the current selection is one nobody chose.
  ///
  /// A system explorer arrives focused on the system itself, so that — and
  /// nothing selected at all — is what this panel inherits rather than what a
  /// learner asked about. Any other element is a question about that element
  /// and must be answered as one.
  bool get _isInheritedSelection {
    final selection = _selection;

    return selection == null ||
        (selection.isNode && selection.id == _graph.systemId);
  }

  StudioSystemGraph get _graph => widget.controller.graph;

  List<StudioGraphNode> get _actors =>
      _graph.nodes.where((node) => node.type == StudioGraphNodeType.actor)
          .toList()
        ..sort((left, right) => left.label.compareTo(right.label));

  void _select(StudioElementRef ref) {
    final callback = widget.onElementSelected;

    if (callback != null) {
      callback(ref);
    }

    setState(() {
      _localSelection = ref;
    });
  }

  Future<void> _openActions(ActorPerspectiveView view) async {
    final chosen = await ActionListSheet.show(
      context,
      actorName: view.actorName,
      actions: view.availableActions,
      graph: _graph,
      isRelevant: view.isRelevant,
    );

    if (chosen == null || !mounted) {
      return;
    }

    _perform(chosen);
  }

  void _perform(StudioActionDefinition action) {
    // The controller owns the run. This widget only forwards the choice, and
    // the AnimatedBuilder below rebuilds everything from the new run state.
    widget.controller.perform(action);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (_isChoosingScenario) {
          return _ScenarioChooser(
            scenarios: _scenarios,
            onChosen: _chooseScenario,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;

            final perspective = _buildPerspectiveArea();
            final trace = _buildTraceArea();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_chosenScenario != null)
                  _ScenarioBar(
                    scenario: _chosenScenario!,
                    graph: _graph,
                    onChange: _changeScenario,
                  ),
                _RunHeader(controller: widget.controller),
                const Divider(height: 1),
                _ActorStrip(
                  actors: _actors,
                  controller: widget.controller,
                  selected: _selection,
                  onSelected: _select,
                  initialActors: widget.controller.scenario.initialActors,
                ),
                const Divider(height: 1),
                Expanded(
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 3, child: perspective),
                            const VerticalDivider(width: 1),
                            Expanded(flex: 2, child: trace),
                          ],
                        )
                      : ListView(
                          children: [
                            SizedBox(height: 420, child: perspective),
                            const Divider(height: 1),
                            trace,
                          ],
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPerspectiveArea() {
    final result = _perspective.view(
      StudioPerspectiveRequest(
        session: widget.session,
        selectedElement: _selection,
        run: widget.controller.run,
      ),
    );

    // A perspective that declines says so. It never describes something else,
    // so selecting a relationship cannot quietly become selecting a node.
    if (result is StudioPerspectiveUnsupported) {
      final scenario = _chosenScenario;

      // Entering a situation and being met by a refusal about whatever the
      // screen happened to be showing is the wrong first thing to read, so
      // the situation is described instead.
      //
      // Only for the selection nobody made. Choosing a component, or a
      // relationship, is a question about that element, and answering it with
      // a description of the situation would quietly change the subject —
      // exactly what the perspective contract exists to prevent. Those keep
      // the typed refusal that says what cannot be shown and why.
      if (scenario != null && _isInheritedSelection) {
        return _SituationEntry(scenario: scenario, graph: _graph);
      }

      return PerspectiveUnsupportedView(view: result);
    }

    final view = result as ActorPerspectiveView;

    return ActorPerspectiveRenderer(
      view: view,
      graph: _graph,
      onOpenActions: () => _openActions(view),
      onElementSelected: _select,
    );
  }

  /// The causal view and the detailed record, in one scrolling column.
  ///
  /// They answer different questions and are deliberately both present. The
  /// graph is for following what happened through the system; the record is
  /// for reading why each step happened. Neither replaces the other, and
  /// neither is the architecture graph, which answers how the system is built.
  Widget _buildTraceArea() {
    // One derivation for this build. The causal record and the overlay that
    // places it come from the same snapshot, so they cannot disagree.
    final situation = StudioSituationSnapshot.of(
      widget.controller.graph,
      widget.controller.run,
    );

    final causalGraph = situation.causal;

    // Marking what a participant witnessed only makes sense for a participant.
    final selection = _selection;

    final selectedActor =
        selection != null &&
            selection.isNode &&
            _graph.nodeById(selection.id)?.type == StudioGraphNodeType.actor
        ? selection
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeading(
            icon: Icons.account_tree_outlined,
            title: 'What happened',
            subtitle: selectedActor == null
                ? 'The causal chain this run produced, through the system.'
                : 'The whole chain. Marked where '
                      '${_graph.labelForElement(selectedActor) ?? "they"} '
                      'witnessed it.',
          ),
          const SizedBox(height: 12),
          // What is true now, against where this situation began. Absent when
          // nothing differs — there is no such thing as a change of nothing,
          // and saying "no changes" would be noise at the exact moment the
          // screen is already saying nothing has happened.
          if (situation.hasDifferences) ...[
            _SinceThisStarted(situation: situation, graph: _graph),
            const SizedBox(height: 16),
          ],
          CausalGraphView(
            causalGraph: causalGraph,
            selectedActor: selectedActor,
            selectedElement: _selection,
            onElementSelected: _select,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          _SectionHeading(
            icon: Icons.timeline_outlined,
            title: 'Details',
            subtitle:
                'Generated by running the system, not written in advance.',
          ),
          const SizedBox(height: 12),
          TraceView(entries: widget.controller.trace, graph: _graph),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Which situation the learner wants to explore.
///
/// Shown before the actor controls, because being asked to act without being
/// told what is going on is a worse question than it looks. A scenario says
/// what is going on and nothing more — no ordering, no expected outcome — so
/// this is a choice of starting point, not of storyline.
class _ScenarioChooser extends StatelessWidget {
  const _ScenarioChooser({required this.scenarios, required this.onChosen});

  final List<StudioScenario> scenarios;
  final ValueChanged<StudioScenario> onChosen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      key: const Key('scenario-chooser'),
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Choose a scenario',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A scenario sets up the situation. What happens after that is '
          'decided by whoever acts.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        for (final scenario in scenarios)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: Key('scenario-option-${scenario.id}'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChosen(scenario),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and chevron share a line, and the name may wrap
                      // rather than push the chevron off a narrow panel.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              scenario.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      if (scenario.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          scenario.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Says which situation is being explored, and offers a way out of it.
///
/// Deliberately modest: the situation is context for everything below it, not
/// the subject of the screen.
/// What a situation established before anyone acted.
///
/// The scenario's authored overrides, and only those — read out with the
/// element and variable names the rest of Systems Studio uses rather than the
/// IDs the model stores. Nothing is inferred, summarised or added.
///
/// These are **starting facts, not changes**. A learner needs them because
/// they are the difference between two situations of the same system, and
/// they can never appear under "Since this started": that compares now
/// against where the situation began, and these *are* where it began.
class _StartingFacts extends StatelessWidget {
  const _StartingFacts({required this.scenario, required this.graph});

  final StudioScenario scenario;
  final StudioSystemGraph graph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final overrides = scenario.initialStateOverrides;

    // A situation that establishes nothing has nothing to say here. An empty
    // heading would imply otherwise.
    if (overrides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      key: const Key('starting-facts'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This situation starts with',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        for (final entry in overrides.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _describe(entry.key, entry.value),
              key: Key('starting-fact-${entry.key}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  /// "Credential Store · Integrity: Compromised".
  ///
  /// Falls back to the raw ID only when the graph does not declare the
  /// variable, which validation already reports as an error — better to show
  /// something truthful than to hide the inconsistency.
  String _describe(String variableId, String value) {
    final variable = graph.stateVariableById(variableId);

    if (variable == null) {
      return '$variableId: $value';
    }

    final owner = graph.labelForElement(variable.owner) ?? variable.owner.id;

    return '$owner · ${variable.name}: $value';
  }
}

/// What situation this is, for someone who has just entered it.
///
/// Shown in place of the perspective's refusal when no participant is
/// selected. It describes and invites; it does not choose. Naming a
/// participant here would be recommending one, and which viewpoint is worth
/// taking is the learner's question to answer.
class _SituationEntry extends StatelessWidget {
  const _SituationEntry({required this.scenario, required this.graph});

  final StudioScenario scenario;
  final StudioSystemGraph graph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      key: const Key('situation-entry'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scenario.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (scenario.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              scenario.description,
              key: const Key('situation-entry-description'),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
          if (scenario.initialStateOverrides.isNotEmpty) ...[
            const SizedBox(height: 16),
            _StartingFacts(scenario: scenario, graph: graph),
          ],
          const SizedBox(height: 20),
          Text(
            'Select a participant above to see what they can observe and '
            'what they can do.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nothing happens until someone acts.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Says which situation is being explored, and offers a way out of it.
///
/// Deliberately modest: the situation is context for everything below it, not
/// the subject of the screen. Its detail is available on request rather than
/// permanently occupying a panel the learner came here to act in.
class _ScenarioBar extends StatefulWidget {
  const _ScenarioBar({
    required this.scenario,
    required this.graph,
    required this.onChange,
  });

  final StudioScenario scenario;
  final StudioSystemGraph graph;
  final VoidCallback onChange;

  @override
  State<_ScenarioBar> createState() => _ScenarioBarState();
}

class _ScenarioBarState extends State<_ScenarioBar> {
  /// Collapsed by default. What situation this is stays visible; the detail
  /// of it is one tap away rather than permanently occupying the panel a
  /// learner came here to act in.
  bool _expanded = false;

  StudioScenario get scenario => widget.scenario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasDetail =
        scenario.description.isNotEmpty ||
        scenario.initialStateOverrides.isNotEmpty;

    return Container(
      key: const Key('scenario-bar'),
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and controls as a set, so a long name takes another line
          // rather than crushing the way back out.
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      scenario.name,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (hasDetail)
                    TextButton.icon(
                      key: const Key('scenario-detail-toggle'),
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      icon: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                      label: Text(_expanded ? 'Hide details' : 'Details'),
                    ),
                  TextButton.icon(
                    key: const Key('change-scenario'),
                    onPressed: widget.onChange,
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Change scenario'),
                  ),
                ],
              ),
            ],
          ),

          // What the learner chose, still recoverable once they have moved on
          // to acting. Collapsed by default so it costs nothing until asked
          // for.
          if (hasDetail && _expanded) ...[
            const SizedBox(height: 10),
            if (scenario.description.isNotEmpty)
              Text(
                scenario.description,
                key: const Key('scenario-bar-description'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            if (scenario.initialStateOverrides.isNotEmpty) ...[
              const SizedBox(height: 12),
              _StartingFacts(scenario: scenario, graph: widget.graph),
            ],
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

/// How the present differs from where this situation began.
///
/// Endpoints, not history: each line compares now against the scenario's
/// starting value. A variable that moved and came back is not listed, and one
/// the scenario set but nothing touched is not listed either. What happened in
/// between is the causal record's business, immediately below.
class _SinceThisStarted extends StatelessWidget {
  const _SinceThisStarted({required this.situation, required this.graph});

  final StudioSituationSnapshot situation;
  final StudioSystemGraph graph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const Key('since-this-started'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Since this started',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final difference in situation.differences)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${graph.labelForElement(difference.owner) ?? difference.owner.id}'
                ' · ${difference.variableId.split(".").last}: '
                '${difference.startedAs} → ${difference.isNow}',
                key: Key('difference-${difference.variableId}'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RunHeader extends StatelessWidget {
  const _RunHeader({required this.controller});

  final StudioSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              controller.isAtStart
                  ? 'Nothing has happened yet.'
                  : '${controller.trace.length} steps · '
                        '${controller.relevantActors.length} participants '
                        'involved',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton.icon(
            key: const Key('reset-run'),
            onPressed: controller.isAtStart ? null : controller.reset,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Every actor in the system, with whether it has become involved.
///
/// All actors are listed, including ones the model has not drawn in yet.
/// Hiding them would make involvement look like an authoring choice rather
/// than something that happens because information reached someone.
class _ActorStrip extends StatelessWidget {
  const _ActorStrip({
    required this.actors,
    required this.controller,
    required this.selected,
    required this.onSelected,
    required this.initialActors,
  });

  final List<StudioGraphNode> actors;
  final StudioSimulationController controller;
  final StudioElementRef? selected;
  final ValueChanged<StudioElementRef> onSelected;

  /// Who the situation placed here, as distinct from who has since become
  /// involved. Being present from the outset is an authored fact about the
  /// situation; becoming involved is something that happened during the run.
  final Set<StudioElementRef> initialActors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          for (final actor in actors) ...[
            Builder(
              builder: (context) {
                final ref = StudioElementRef.node(actor.id);
                final relevant = controller.isRelevant(ref);
                final isSelected = selected == ref;

                // Said in words. Colour alone cannot be read by everyone, and
                // does not say what it means to anyone on first encounter.
                //
                // No status is phrased as a prospect. An actor who is not
                // involved may simply never be: relevance arrives because
                // something reached them, and nothing guarantees anything
                // will.
                final String status;

                if (initialActors.contains(ref)) {
                  status = 'Present at start';
                } else if (relevant) {
                  status = 'Involved';
                } else {
                  status = 'Not currently involved';
                }

                // Only worth saying for someone who could act on it.
                final actionCount = relevant
                    ? controller.availableActionsFor(ref).length
                    : 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    key: Key('actor-chip-${actor.id}'),
                    selected: isSelected,
                    onSelected: (_) => onSelected(ref),
                    avatar: Icon(
                      relevant
                          ? Icons.notifications_active_outlined
                          : Icons.person_outline,
                      size: 16,
                      color: relevant
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(actor.label),
                        Text(
                          actionCount == 0
                              ? status
                              : '$status · $actionCount available',
                          key: Key('actor-status-${actor.id}'),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

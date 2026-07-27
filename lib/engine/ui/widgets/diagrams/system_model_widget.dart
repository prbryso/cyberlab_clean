import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/system_model.dart';
import 'package:systems_studio/engine/ui/widgets/system/node_details_panel.dart';

class SystemModelWidget extends StatefulWidget {
  const SystemModelWidget({super.key, required this.model});

  final SystemModel model;

  @override
  State<SystemModelWidget> createState() => _SystemModelWidgetState();
}

class _SystemModelWidgetState extends State<SystemModelWidget> {
  SystemNode? _selectedNode;

  @override
  void didUpdateWidget(covariant SystemModelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.model.id == widget.model.id) {
      return;
    }

    final selectedNodeId = _selectedNode?.id;

    if (selectedNodeId == null) {
      return;
    }

    SystemNode? matchingNode;

    for (final node in widget.model.nodes) {
      if (node.id == selectedNodeId) {
        matchingNode = node;
        break;
      }
    }

    _selectedNode = matchingNode;
  }

  void _selectNode(SystemNode node) {
    setState(() {
      if (_selectedNode?.id == node.id) {
        _selectedNode = null;
      } else {
        _selectedNode = node;
      }
    });
  }

  void _clearSelection() {
    if (_selectedNode == null) {
      return;
    }

    setState(() {
      _selectedNode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final validationErrors = widget.model.validate();

    assert(
      validationErrors.isEmpty,
      'Invalid SystemModel:\n${validationErrors.join('\n')}',
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DiagramHeader(model: widget.model),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final useSidePanel = constraints.maxWidth >= 980;

                if (useSidePanel) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DiagramSurface(
                          model: widget.model,
                          selectedNode: _selectedNode,
                          onNodeSelected: _selectNode,
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 360,
                        child: _DetailsArea(
                          selectedNode: _selectedNode,
                          onClose: _clearSelection,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DiagramSurface(
                      model: widget.model,
                      selectedNode: _selectedNode,
                      onNodeSelected: _selectNode,
                    ),
                    const SizedBox(height: 20),
                    _DetailsArea(
                      selectedNode: _selectedNode,
                      onClose: _clearSelection,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagramSurface extends StatelessWidget {
  const _DiagramSurface({
    required this.model,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  final SystemModel model;
  final SystemNode? selectedNode;
  final ValueChanged<SystemNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < model.inputs.length; index++) ...[
            _EndpointWidget(
              endpoint: model.inputs[index],
              endpointRole: 'INPUT',
            ),
            const _FlowArrow(),
          ],
          _SystemBoundary(
            model: model,
            selectedNode: selectedNode,
            onNodeSelected: onNodeSelected,
          ),
          if (model.outputs.isNotEmpty) const _FlowArrow(),
          for (var index = 0; index < model.outputs.length; index++) ...[
            _EndpointWidget(
              endpoint: model.outputs[index],
              endpointRole: 'OUTPUT',
            ),
            if (index < model.outputs.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _DetailsArea extends StatelessWidget {
  const _DetailsArea({required this.selectedNode, required this.onClose});

  final SystemNode? selectedNode;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        NodeDetailsPanel(node: selectedNode),
        if (selectedNode != null)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              tooltip: 'Close component details',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerHigh,
                foregroundColor: colors.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _DiagramHeader extends StatelessWidget {
  const _DiagramHeader({required this.model});

  final SystemModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Text(
          model.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        if (model.description != null &&
            model.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              model.description!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SystemBoundary extends StatelessWidget {
  const _SystemBoundary({
    required this.model,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  final SystemModel model;
  final SystemNode? selectedNode;
  final ValueChanged<SystemNode> onNodeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.12),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.75),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'SYSTEM BOUNDARY',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < model.nodes.length; index++) ...[
            _NodeWidget(
              node: model.nodes[index],
              isSelected: selectedNode?.id == model.nodes[index].id,
              onTap: () => onNodeSelected(model.nodes[index]),
            ),
            if (index < model.nodes.length - 1) const _FlowArrow(compact: true),
          ],
        ],
      ),
    );
  }
}

class _EndpointWidget extends StatelessWidget {
  const _EndpointWidget({required this.endpoint, required this.endpointRole});

  final SystemEndpoint endpoint;
  final String endpointRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = _endpointStyle(endpoint.type, colors);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: style.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: style.iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _endpointIcon(endpoint.type),
                size: 22,
                color: style.foreground,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    endpointRole,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: style.foreground.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    endpoint.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: style.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _endpointIcon(SystemEndpointType type) {
    return switch (type) {
      SystemEndpointType.user => Icons.person_outline,
      SystemEndpointType.attacker => Icons.gpp_bad_outlined,
      SystemEndpointType.defender => Icons.shield_outlined,
      SystemEndpointType.administrator => Icons.admin_panel_settings_outlined,
      SystemEndpointType.externalSystem => Icons.cloud_outlined,
      SystemEndpointType.success => Icons.check_circle_outline,
      SystemEndpointType.failure => Icons.error_outline,
      SystemEndpointType.neutral => Icons.output_outlined,
    };
  }
}

class _NodeWidget extends StatelessWidget {
  const _NodeWidget({
    required this.node,
    required this.isSelected,
    required this.onTap,
  });

  final SystemNode node;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = _nodeStyle(node.type, colors);

    final selectedBorderColor = colors.primary;
    final normalBorderColor = style.border;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${node.label}. Select to view details.',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 360),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color.alphaBlend(
                        colors.primary.withValues(alpha: 0.08),
                        style.background,
                      )
                    : style.background,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isSelected ? selectedBorderColor : normalBorderColor,
                  width: isSelected
                      ? 2.2
                      : node.isShared
                      ? 1.7
                      : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(
                      alpha: isSelected ? 0.12 : 0.06,
                    ),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: style.iconBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _nodeIcon(node.type),
                      size: 22,
                      color: style.foreground,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: style.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (node.isShared) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Shared system component',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: style.foreground.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                        if (node.hasInstructionalContent) ...[
                          const SizedBox(height: 5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                size: 14,
                                color: style.foreground.withValues(alpha: 0.70),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  isSelected
                                      ? 'Details selected'
                                      : 'Select for details',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: style.foreground.withValues(
                                      alpha: 0.70,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected
                        ? Icons.chevron_right_rounded
                        : Icons.info_outline_rounded,
                    size: 20,
                    color: style.foreground.withValues(alpha: 0.70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _nodeIcon(SystemNodeType type) {
    return switch (type) {
      SystemNodeType.process => Icons.arrow_forward_rounded,
      SystemNodeType.component => Icons.dns_outlined,
      SystemNodeType.decision => Icons.call_split_outlined,
      SystemNodeType.defense => Icons.shield_outlined,
    };
  }
}

class _FlowArrow extends StatelessWidget {
  const _FlowArrow({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 5 : 7),
      child: Column(
        children: [
          Container(
            width: 2,
            height: compact ? 10 : 14,
            decoration: BoxDecoration(
              color: colors.outline.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: compact ? 22 : 26,
            color: colors.outline,
          ),
        ],
      ),
    );
  }
}

class _VisualStyle {
  const _VisualStyle({
    required this.background,
    required this.border,
    required this.foreground,
    required this.iconBackground,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final Color iconBackground;
}

_VisualStyle _endpointStyle(SystemEndpointType type, ColorScheme colors) {
  return switch (type) {
    SystemEndpointType.attacker => _VisualStyle(
      background: Colors.orange.shade50,
      border: Colors.orange.shade300,
      foreground: Colors.deepOrange.shade900,
      iconBackground: Colors.orange.shade100,
    ),
    SystemEndpointType.defender ||
    SystemEndpointType.administrator => _VisualStyle(
      background: Colors.green.shade50,
      border: Colors.green.shade300,
      foreground: Colors.green.shade900,
      iconBackground: Colors.green.shade100,
    ),
    SystemEndpointType.success => _VisualStyle(
      background: Colors.green.shade50,
      border: Colors.green.shade300,
      foreground: Colors.green.shade900,
      iconBackground: Colors.green.shade100,
    ),
    SystemEndpointType.failure => _VisualStyle(
      background: Colors.red.shade50,
      border: Colors.red.shade300,
      foreground: Colors.red.shade900,
      iconBackground: Colors.red.shade100,
    ),
    SystemEndpointType.user ||
    SystemEndpointType.externalSystem ||
    SystemEndpointType.neutral => _VisualStyle(
      background: colors.surfaceContainerLow,
      border: colors.outlineVariant,
      foreground: colors.onSurface,
      iconBackground: colors.primaryContainer,
    ),
  };
}

_VisualStyle _nodeStyle(SystemNodeType type, ColorScheme colors) {
  return switch (type) {
    SystemNodeType.process => _VisualStyle(
      background: colors.surface,
      border: colors.outlineVariant,
      foreground: colors.onSurface,
      iconBackground: colors.surfaceContainerHighest,
    ),
    SystemNodeType.component => _VisualStyle(
      background: colors.primaryContainer,
      border: colors.primary.withValues(alpha: 0.65),
      foreground: colors.onPrimaryContainer,
      iconBackground: colors.primary.withValues(alpha: 0.14),
    ),
    SystemNodeType.decision => _VisualStyle(
      background: colors.tertiaryContainer,
      border: colors.tertiary.withValues(alpha: 0.65),
      foreground: colors.onTertiaryContainer,
      iconBackground: colors.tertiary.withValues(alpha: 0.14),
    ),
    SystemNodeType.defense => _VisualStyle(
      background: colors.secondaryContainer,
      border: colors.secondary.withValues(alpha: 0.65),
      foreground: colors.onSecondaryContainer,
      iconBackground: colors.secondary.withValues(alpha: 0.14),
    ),
  };
}

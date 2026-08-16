import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/ui/workspace/workspace_controller.dart';

/// Primary control surface for the System Workspace.
///
/// The toolbar manages workspace navigation, search, visibility controls,
/// neighbor highlighting, and canvas commands.
class WorkspaceToolbar extends StatefulWidget {
  const WorkspaceToolbar({
    super.key,
    required this.controller,
    required this.onFitToView,
    this.onCenterSelected,
    this.onSearchResultSelected,
  });

  final WorkspaceController controller;

  /// Requests that the graph canvas fit the visible graph into the viewport.
  final VoidCallback onFitToView;

  /// Requests that the graph canvas center the currently selected node.
  final VoidCallback? onCenterSelected;

  /// Invoked after the user selects a search result.
  final ValueChanged<String>? onSearchResultSelected;

  @override
  State<WorkspaceToolbar> createState() => _WorkspaceToolbarState();
}

class _WorkspaceToolbarState extends State<WorkspaceToolbar> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  OverlayEntry? _searchOverlay;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.controller.state.searchQuery,
    );

    _searchFocusNode = FocusNode();

    widget.controller.addListener(_handleControllerChanged);
    _searchFocusNode.addListener(_handleSearchFocusChanged);
  }

  @override
  void didUpdateWidget(covariant WorkspaceToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);

    _searchController.text = widget.controller.state.searchQuery;
    _removeSearchOverlay();
  }

  @override
  void dispose() {
    _removeSearchOverlay();

    widget.controller.removeListener(_handleControllerChanged);
    _searchFocusNode.removeListener(_handleSearchFocusChanged);

    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    final query = widget.controller.state.searchQuery;

    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    setState(() {});

    if (_searchFocusNode.hasFocus && query.trim().isNotEmpty) {
      _showSearchOverlay();
    } else {
      _removeSearchOverlay();
    }
  }

  void _handleSearchFocusChanged() {
    if (_searchFocusNode.hasFocus &&
        widget.controller.state.searchQuery.trim().isNotEmpty) {
      _showSearchOverlay();
    } else {
      _removeSearchOverlay();
    }
  }

  void _handleSearchChanged(String query) {
    widget.controller.setSearchQuery(query);

    if (query.trim().isEmpty) {
      _removeSearchOverlay();
      return;
    }

    _showSearchOverlay();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.controller.clearSearch();
    _removeSearchOverlay();
    _searchFocusNode.requestFocus();
  }

  void _showSearchOverlay() {
    _removeSearchOverlay();

    final overlay = Overlay.maybeOf(context);

    if (overlay == null) {
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) {
      return;
    }

    final toolbarOrigin = renderBox.localToGlobal(Offset.zero);
    final results = widget.controller.searchResults();

    _searchOverlay = OverlayEntry(
      builder: (overlayContext) {
        final screenWidth = MediaQuery.sizeOf(overlayContext).width;
        final left = toolbarOrigin.dx + 12;
        final availableWidth = screenWidth - left - 12;
        final width = availableWidth.clamp(280.0, 480.0);

        return Positioned(
          left: left,
          top: toolbarOrigin.dy + renderBox.size.height - 4,
          width: width,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: results.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No matching system elements.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: results.length,
                      separatorBuilder: (context, index) {
                        return const Divider(height: 1);
                      },
                      itemBuilder: (context, index) {
                        final node = results[index];

                        return ListTile(
                          leading: Icon(_iconForNodeType(node.type)),
                          title: Text(node.label),
                          subtitle: Text(
                            node.description.trim().isEmpty
                                ? _displayNodeType(node.type)
                                : node.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            widget.controller.focusOnNode(node);
                            widget.onSearchResultSelected?.call(node.id);

                            _searchController.clear();
                            widget.controller.clearSearch();
                            _removeSearchOverlay();
                            _searchFocusNode.unfocus();
                          },
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );

    final searchOverlay = _searchOverlay;

    if (searchOverlay != null) {
      overlay.insert(searchOverlay);
    }
  }

  void _removeSearchOverlay() {
    _searchOverlay?.remove();
    _searchOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedNode = widget.controller.selectedNode;
    final selectedRelationship = widget.controller.selectedRelationship;
    final colorScheme = Theme.of(context).colorScheme;

    final hasSelection = selectedNode != null || selectedRelationship != null;

    final selectionLabel =
        selectedNode?.label ??
        selectedRelationship?.label ??
        'No element selected';

    final selectionTypeLabel = selectedNode != null
        ? _displayNodeType(selectedNode.type)
        : selectedRelationship != null
        ? 'Relationship · ${selectedRelationship.type.name}'
        : '';

    return Material(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _handleSearchChanged,
                    onClear: _clearSearch,
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _ToolbarActions(
                      controller: widget.controller,
                      onFitToView: widget.onFitToView,
                      onCenterSelected: widget.onCenterSelected,
                    ),
                  ),
                  if (hasSelection) ...[
                    const SizedBox(height: 8),
                    _SelectionIndicator(
                      label: selectionLabel,
                      typeLabel: selectionTypeLabel,
                    ),
                  ],
                ],
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 380,
                  child: _SearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _handleSearchChanged,
                    onClear: _clearSearch,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SelectionIndicator(
                    label: selectionLabel,
                    typeLabel: selectionTypeLabel,
                  ),
                ),
                const SizedBox(width: 12),
                _ToolbarActions(
                  controller: widget.controller,
                  onFitToView: widget.onFitToView,
                  onCenterSelected: widget.onCenterSelected,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search system elements…',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(Icons.close),
              ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.label, required this.typeLabel});

  final String label;
  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.my_location_outlined, size: 19, color: colorScheme.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (typeLabel.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            typeLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ToolbarActions extends StatelessWidget {
  const _ToolbarActions({
    required this.controller,
    required this.onFitToView,
    required this.onCenterSelected,
  });

  final WorkspaceController controller;
  final VoidCallback onFitToView;
  final VoidCallback? onCenterSelected;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Back to previous focus',
          onPressed: state.canGoBack ? controller.goBack : null,
          icon: const Icon(Icons.arrow_back),
        ),
        IconButton(
          tooltip: 'Return to system root',
          onPressed: state.isFocusedAtRoot ? null : controller.reset,
          icon: const Icon(Icons.home_outlined),
        ),
        IconButton(
          tooltip: 'Fit graph to view',
          onPressed: onFitToView,
          icon: const Icon(Icons.fit_screen_outlined),
        ),
        if (onCenterSelected != null)
          IconButton(
            tooltip: 'Center selected element',
            onPressed: onCenterSelected,
            icon: const Icon(Icons.center_focus_strong_outlined),
          ),
        const SizedBox(width: 4),
        _ToggleButton(
          tooltip: 'Show structure panel',
          selected: state.showStructurePanel,
          icon: Icons.account_tree_outlined,
          onPressed: controller.toggleStructurePanel,
        ),
        _ToggleButton(
          tooltip: 'Show details panel',
          selected: state.showDetailsPanel,
          icon: Icons.info_outline,
          onPressed: controller.toggleDetailsPanel,
        ),
        _ToggleButton(
          tooltip: 'Highlight connected elements',
          selected: state.highlightNeighbors,
          icon: Icons.hub_outlined,
          onPressed: controller.toggleNeighborHighlighting,
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.tooltip,
    required this.selected,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final bool selected;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      isSelected: selected,
      onPressed: onPressed,
      icon: Icon(icon),
      selectedIcon: Icon(icon, color: colorScheme.primary),
    );
  }
}

String _displayNodeType(StudioGraphNodeType type) {
  return switch (type) {
    StudioGraphNodeType.system => 'System',
    StudioGraphNodeType.subsystem => 'Subsystem',
    StudioGraphNodeType.component => 'Component',
    StudioGraphNodeType.actor => 'Actor',
    StudioGraphNodeType.asset => 'Asset',
    StudioGraphNodeType.interface => 'Interface',
    StudioGraphNodeType.boundary => 'Boundary',
    StudioGraphNodeType.input => 'Input',
    StudioGraphNodeType.output => 'Output',
    StudioGraphNodeType.failureMode => 'Failure Mode',
    StudioGraphNodeType.control => 'Control',
    StudioGraphNodeType.simulation => 'Simulation',
    StudioGraphNodeType.incident => 'Incident',
    StudioGraphNodeType.reference => 'Reference',
    StudioGraphNodeType.externalSystem => 'External System',
    StudioGraphNodeType.process => 'Process',
    StudioGraphNodeType.state => 'State',
    StudioGraphNodeType.custom => 'Custom',
  };
}

IconData _iconForNodeType(StudioGraphNodeType type) {
  return switch (type) {
    StudioGraphNodeType.system => Icons.account_tree_outlined,
    StudioGraphNodeType.subsystem => Icons.hub_outlined,
    StudioGraphNodeType.component => Icons.widgets_outlined,
    StudioGraphNodeType.actor => Icons.person_outline,
    StudioGraphNodeType.asset => Icons.inventory_2_outlined,
    StudioGraphNodeType.interface => Icons.compare_arrows_outlined,
    StudioGraphNodeType.boundary => Icons.border_outer_outlined,
    StudioGraphNodeType.input => Icons.input_outlined,
    StudioGraphNodeType.output => Icons.output_outlined,
    StudioGraphNodeType.failureMode => Icons.warning_amber_outlined,
    StudioGraphNodeType.control => Icons.shield_outlined,
    StudioGraphNodeType.simulation => Icons.science_outlined,
    StudioGraphNodeType.incident => Icons.crisis_alert_outlined,
    StudioGraphNodeType.reference => Icons.menu_book_outlined,
    StudioGraphNodeType.externalSystem => Icons.cloud_outlined,
    StudioGraphNodeType.process => Icons.settings_outlined,
    StudioGraphNodeType.state => Icons.change_circle_outlined,
    StudioGraphNodeType.custom => Icons.extension_outlined,
  };
}

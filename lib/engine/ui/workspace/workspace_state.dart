import 'package:flutter/foundation.dart';

import 'package:systems_studio/engine/models/studio_element_ref.dart';

/// Immutable interaction state for the System Workspace.
///
/// The graph owns system knowledge.
/// Perspectives own interpretation.
/// WorkspaceState owns only the user's current interaction context.
///
/// Selection and focus address graph *elements*, so the user can select and
/// inspect a relationship as well as a node.
@immutable
class WorkspaceState {
  const WorkspaceState({
    required this.rootNodeId,
    required this.selectedElement,
    required this.focusElement,
    this.focusHistory = const [],
    this.searchQuery = '',
    this.showStructurePanel = true,
    this.showDetailsPanel = true,
    this.highlightNeighbors = true,
  });

  /// Root node of the complete system graph.
  ///
  /// The root of a system graph is always a node, so this stays a node ID.
  final String rootNodeId;

  /// Element currently selected by the user.
  final StudioElementRef selectedElement;

  /// Element currently at the center of the workspace focus.
  final StudioElementRef focusElement;

  /// Previous focus elements, oldest first.
  final List<StudioElementRef> focusHistory;

  /// Current node-search text.
  final String searchQuery;

  /// Whether the hierarchy panel is visible.
  final bool showStructurePanel;

  /// Whether the selected-node details panel is visible.
  final bool showDetailsPanel;

  /// Whether directly connected nodes should be emphasized.
  final bool highlightNeighbors;

  bool get canGoBack => focusHistory.isNotEmpty;

  /// Node reference for the graph root.
  StudioElementRef get rootElement => StudioElementRef.node(rootNodeId);

  bool get isFocusedAtRoot => focusElement == rootElement;

  bool get hasSearchQuery => searchQuery.trim().isNotEmpty;

  WorkspaceState copyWith({
    String? rootNodeId,
    StudioElementRef? selectedElement,
    StudioElementRef? focusElement,
    List<StudioElementRef>? focusHistory,
    String? searchQuery,
    bool? showStructurePanel,
    bool? showDetailsPanel,
    bool? highlightNeighbors,
  }) {
    return WorkspaceState(
      rootNodeId: rootNodeId ?? this.rootNodeId,
      selectedElement: selectedElement ?? this.selectedElement,
      focusElement: focusElement ?? this.focusElement,
      focusHistory: List<StudioElementRef>.unmodifiable(
        focusHistory ?? this.focusHistory,
      ),
      searchQuery: searchQuery ?? this.searchQuery,
      showStructurePanel: showStructurePanel ?? this.showStructurePanel,
      showDetailsPanel: showDetailsPanel ?? this.showDetailsPanel,
      highlightNeighbors: highlightNeighbors ?? this.highlightNeighbors,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WorkspaceState &&
            other.rootNodeId == rootNodeId &&
            other.selectedElement == selectedElement &&
            other.focusElement == focusElement &&
            listEquals(other.focusHistory, focusHistory) &&
            other.searchQuery == searchQuery &&
            other.showStructurePanel == showStructurePanel &&
            other.showDetailsPanel == showDetailsPanel &&
            other.highlightNeighbors == highlightNeighbors;
  }

  @override
  int get hashCode {
    return Object.hash(
      rootNodeId,
      selectedElement,
      focusElement,
      Object.hashAll(focusHistory),
      searchQuery,
      showStructurePanel,
      showDetailsPanel,
      highlightNeighbors,
    );
  }
}

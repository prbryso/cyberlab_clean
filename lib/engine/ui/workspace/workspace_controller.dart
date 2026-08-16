import 'package:flutter/foundation.dart';

import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/ui/workspace/workspace_state.dart';

/// Controls user interaction within the System Workspace.
///
/// This controller does not modify the system graph. It manages selection,
/// focus history, search text, and workspace panel visibility.
///
/// Selection and focus address graph elements, so either a node or a
/// relationship can be selected, focused, and inspected. The node-oriented
/// members are retained for callers that only ever deal in nodes.
class WorkspaceController extends ChangeNotifier {
  WorkspaceController({
    required StudioSystemGraph graph,
    StudioElementRef? initialSelectedElement,
    StudioElementRef? initialFocusElement,
  }) : _graph = graph,
       _state = WorkspaceState(
         rootNodeId: graph.systemId,
         selectedElement:
             _validatedElement(graph, initialSelectedElement) ??
             StudioElementRef.node(graph.systemId),
         focusElement:
             _validatedElement(graph, initialFocusElement) ??
             StudioElementRef.node(graph.systemId),
       );

  StudioSystemGraph _graph;
  WorkspaceState _state;

  StudioSystemGraph get graph => _graph;

  WorkspaceState get state => _state;

  /// The element the user has selected, whatever its kind.
  StudioElementRef get selectedElement => _state.selectedElement;

  /// The element at the centre of the workspace focus.
  StudioElementRef get focusElement => _state.focusElement;

  /// The selected node, or null when a relationship is selected.
  StudioGraphNode? get selectedNode {
    final element = _state.selectedElement;

    return element.isNode ? _graph.nodeById(element.id) : null;
  }

  /// The selected relationship, or null when a node is selected.
  StudioRelationship? get selectedRelationship {
    final element = _state.selectedElement;

    return element.isRelationship ? _graph.relationshipById(element.id) : null;
  }

  /// The focused node, or null when a relationship is focused.
  StudioGraphNode? get focusNode {
    final element = _state.focusElement;

    return element.isNode ? _graph.nodeById(element.id) : null;
  }

  /// The focused relationship, or null when a node is focused.
  StudioRelationship? get focusRelationship {
    final element = _state.focusElement;

    return element.isRelationship ? _graph.relationshipById(element.id) : null;
  }

  /// Display label for the current selection, or null when it does not
  /// resolve against the current graph.
  String? get selectedElementLabel {
    return _graph.labelForElement(_state.selectedElement);
  }

  bool get canGoBack => _state.canGoBack;

  /// Replaces the graph while preserving valid workspace state when possible.
  void updateGraph(StudioSystemGraph graph, {bool resetFocus = false}) {
    _graph = graph;

    final rootElement = StudioElementRef.node(graph.systemId);

    if (resetFocus) {
      _state = WorkspaceState(
        rootNodeId: graph.systemId,
        selectedElement: rootElement,
        focusElement: rootElement,
        showStructurePanel: _state.showStructurePanel,
        showDetailsPanel: _state.showDetailsPanel,
        highlightNeighbors: _state.highlightNeighbors,
      );

      notifyListeners();
      return;
    }

    final selectedElement = graph.containsElement(_state.selectedElement)
        ? _state.selectedElement
        : rootElement;

    final focusElement = graph.containsElement(_state.focusElement)
        ? _state.focusElement
        : rootElement;

    final validHistory = _state.focusHistory
        .where(graph.containsElement)
        .toList();

    _state = _state.copyWith(
      rootNodeId: graph.systemId,
      selectedElement: selectedElement,
      focusElement: focusElement,
      focusHistory: validHistory,
    );

    notifyListeners();
  }

  /// Selects an element without changing workspace focus.
  void selectElement(StudioElementRef element) {
    if (!_graph.containsElement(element) ||
        element == _state.selectedElement) {
      return;
    }

    _state = _state.copyWith(selectedElement: element);

    notifyListeners();
  }

  /// Selects a node without changing workspace focus.
  void selectNode(String nodeId) {
    selectElement(StudioElementRef.node(nodeId));
  }

  /// Selects a relationship without changing workspace focus.
  void selectRelationship(String relationshipId) {
    selectElement(StudioElementRef.relationship(relationshipId));
  }

  /// Selects and focuses an element.
  void focusOnElement(StudioElementRef element) {
    if (!_graph.containsElement(element)) {
      return;
    }

    if (element == _state.focusElement) {
      selectElement(element);
      return;
    }

    final history = <StudioElementRef>[
      ..._state.focusHistory,
      _state.focusElement,
    ];

    _state = _state.copyWith(
      selectedElement: element,
      focusElement: element,
      focusHistory: history,
      searchQuery: '',
    );

    notifyListeners();
  }

  /// Selects and focuses a node by ID.
  void focusNodeById(String nodeId) {
    focusOnElement(StudioElementRef.node(nodeId));
  }

  /// Selects and focuses [node].
  void focusOnNode(StudioGraphNode node) {
    focusOnElement(StudioElementRef.node(node.id));
  }

  /// Selects and focuses [relationship].
  void focusOnRelationship(StudioRelationship relationship) {
    focusOnElement(StudioElementRef.relationship(relationship.id));
  }

  /// Returns to the previous focus.
  void goBack() {
    if (_state.focusHistory.isEmpty) {
      return;
    }

    final history = [..._state.focusHistory];
    final previousFocus = history.removeLast();

    if (!_graph.containsElement(previousFocus)) {
      _state = _state.copyWith(focusHistory: history);

      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      selectedElement: previousFocus,
      focusElement: previousFocus,
      focusHistory: history,
      searchQuery: '',
    );

    notifyListeners();
  }

  /// Returns selection and focus to the system root.
  void reset() {
    final rootElement = StudioElementRef.node(_graph.systemId);

    _state = _state.copyWith(
      selectedElement: rootElement,
      focusElement: rootElement,
      focusHistory: const [],
      searchQuery: '',
    );

    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (query == _state.searchQuery) {
      return;
    }

    _state = _state.copyWith(searchQuery: query);

    notifyListeners();
  }

  void clearSearch() {
    if (_state.searchQuery.isEmpty) {
      return;
    }

    _state = _state.copyWith(searchQuery: '');

    notifyListeners();
  }

  void toggleStructurePanel() {
    _state = _state.copyWith(showStructurePanel: !_state.showStructurePanel);

    notifyListeners();
  }

  void toggleDetailsPanel() {
    _state = _state.copyWith(showDetailsPanel: !_state.showDetailsPanel);

    notifyListeners();
  }

  void toggleNeighborHighlighting() {
    _state = _state.copyWith(highlightNeighbors: !_state.highlightNeighbors);

    notifyListeners();
  }

  /// Returns searchable nodes matching the current query.
  ///
  /// Search remains node-oriented in this phase.
  List<StudioGraphNode> searchResults({int maximumResults = 20}) {
    final query = _state.searchQuery.trim().toLowerCase();

    if (query.isEmpty || maximumResults <= 0) {
      return const [];
    }

    final matches =
        _graph.nodes.where((node) {
          if (node.id.toLowerCase().contains(query) ||
              node.label.toLowerCase().contains(query) ||
              node.description.toLowerCase().contains(query)) {
            return true;
          }

          if (node.tags.any((tag) => tag.toLowerCase().contains(query))) {
            return true;
          }

          if (node.semanticSearchValues().any(
            (value) => value.toLowerCase().contains(query),
          )) {
            return true;
          }

          final stateVariables = _graph.stateVariablesFor(
            StudioElementRef.node(node.id),
          );

          if (stateVariables.any(
            (variable) =>
                variable.name.toLowerCase().contains(query) ||
                variable.domain.any(
                  (value) => value.toLowerCase().contains(query),
                ),
          )) {
            return true;
          }

          return _metadataContains(node.metadata, query);
        }).toList()..sort((left, right) {
          final leftStarts = left.label.toLowerCase().startsWith(query);
          final rightStarts = right.label.toLowerCase().startsWith(query);

          if (leftStarts != rightStarts) {
            return leftStarts ? -1 : 1;
          }

          return left.label.toLowerCase().compareTo(right.label.toLowerCase());
        });

    return List<StudioGraphNode>.unmodifiable(matches.take(maximumResults));
  }

  static StudioElementRef? _validatedElement(
    StudioSystemGraph graph,
    StudioElementRef? element,
  ) {
    if (element == null || !graph.containsElement(element)) {
      return null;
    }

    return element;
  }

  bool _metadataContains(Map<String, Object?> metadata, String query) {
    for (final entry in metadata.entries) {
      if (entry.key.toLowerCase().contains(query) ||
          _valueContains(entry.value, query)) {
        return true;
      }
    }

    return false;
  }

  bool _valueContains(Object? value, String query) {
    if (value == null) {
      return false;
    }

    if (value is String || value is num || value is bool || value is Enum) {
      return value.toString().toLowerCase().contains(query);
    }

    if (value is Iterable) {
      return value.any((item) => _valueContains(item, query));
    }

    if (value is Map) {
      return value.entries.any(
        (entry) =>
            entry.key.toString().toLowerCase().contains(query) ||
            _valueContains(entry.value, query),
      );
    }

    return value.toString().toLowerCase().contains(query);
  }
}

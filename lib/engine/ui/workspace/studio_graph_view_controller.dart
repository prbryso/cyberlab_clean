import 'package:flutter/foundation.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// Owns all UI state associated with displaying a system graph.
///
/// This class never modifies the underlying graph.
/// It only controls how the graph is presented.
///
/// Current responsibilities:
/// • Expanded / collapsed nodes
///
/// Future responsibilities:
/// • Selected node
/// • Zoom
/// • Pan
/// • Filters
/// • Search results
/// • Highlighted paths
/// • Animation state
class StudioGraphViewController extends ChangeNotifier {
  final Set<String> _expandedNodes = {};

  List<StudioGraphNode> visibleNodes(StudioSystemGraph graph) {
    final visible = <StudioGraphNode>[];

    final root = graph.nodeById(graph.systemId);

    if (root == null) {
      return visible;
    }

    void visit(StudioGraphNode node) {
      visible.add(node);

      if (!isExpanded(node.id)) {
        return;
      }

      final children =
          graph.nodes
              .where((candidate) => candidate.parentId == node.id)
              .toList()
            ..sort((a, b) => a.label.compareTo(b.label));

      for (final child in children) {
        visit(child);
      }
    }

    visit(root);

    return visible;
  }

  bool isExpanded(String nodeId) {
    return _expandedNodes.contains(nodeId);
  }

  void expand(String nodeId) {
    if (_expandedNodes.add(nodeId)) {
      notifyListeners();
    }
  }

  void collapse(String nodeId) {
    if (_expandedNodes.remove(nodeId)) {
      notifyListeners();
    }
  }

  void toggle(String nodeId) {
    if (isExpanded(nodeId)) {
      collapse(nodeId);
    } else {
      expand(nodeId);
    }
  }

  void expandAll(Iterable<String> nodeIds) {
    bool changed = false;

    for (final id in nodeIds) {
      changed |= _expandedNodes.add(id);
    }

    if (changed) {
      notifyListeners();
    }
  }

  void collapseAll() {
    if (_expandedNodes.isEmpty) return;

    _expandedNodes.clear();
    notifyListeners();
  }

  Set<String> get expandedNodes => Set.unmodifiable(_expandedNodes);
}

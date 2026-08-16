import 'package:systems_studio/engine/graph/graph_builder.dart';
import 'package:systems_studio/engine/graph/graph_query.dart';
import 'package:systems_studio/engine/graph/graph_validator.dart';
import 'package:systems_studio/engine/models/studio_system_detail.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// Main entry point for building, validating, and querying system graphs.
///
/// UI widgets, analysis tools, and future exporters should depend on this
/// façade rather than constructing graph-engine components directly.
class StudioGraphEngine {
  const StudioGraphEngine({
    this.builder = const StudioGraphBuilder(),
    this.validator = const StudioGraphValidator(),
  });

  final StudioGraphBuilder builder;
  final StudioGraphValidator validator;

  /// Builds a graph from [detail] and validates it.
  StudioSystemGraph build(StudioSystemDetail detail) {
    final graph = builder.build(detail);
    validator.validateOrThrow(graph);
    return graph;
  }

  /// Validates an existing graph without rebuilding it.
  StudioGraphValidationResult validate(StudioSystemGraph graph) {
    return validator.validate(graph);
  }

  /// Validates [graph] and throws when errors are present.
  void validateOrThrow(StudioSystemGraph graph) {
    validator.validateOrThrow(graph);
  }

  /// Creates a read-only query helper for [graph].
  StudioGraphQuery query(StudioSystemGraph graph) {
    return StudioGraphQuery(graph);
  }

  /// Builds and returns both the graph and query helper.
  StudioGraphSession open(StudioSystemDetail detail) {
    final graph = build(detail);

    return StudioGraphSession(graph: graph, query: StudioGraphQuery(graph));
  }
}

/// Ready-to-use graph context for one system.
///
/// A screen or analysis tool can keep one session rather than rebuilding the
/// graph and query helper separately.
class StudioGraphSession {
  const StudioGraphSession({required this.graph, required this.query});

  final StudioSystemGraph graph;
  final StudioGraphQuery query;
}

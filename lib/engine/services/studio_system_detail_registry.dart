import 'package:systems_studio/engine/models/studio_system_detail.dart';

/// Central registry for rich, exploration-oriented system content.
///
/// StudioLibraryRegistry remains responsible for installed libraries and their
/// lightweight StudioSystem catalog entries.
///
/// StudioSystemDetailRegistry stores the deeper system information used by the
/// future SystemExplorerScreen:
///
/// - purpose
/// - actors
/// - assets
/// - boundaries
/// - inputs and outputs
/// - perspectives
/// - failure modes
/// - simulations
/// - incidents
/// - references
class StudioSystemDetailRegistry {
  StudioSystemDetailRegistry._();

  static final StudioSystemDetailRegistry instance =
      StudioSystemDetailRegistry._();

  final Map<String, StudioSystemDetail> _detailsBySystemId = {};

  /// All registered system details.
  ///
  /// A new unmodifiable list is returned so callers cannot modify the
  /// registry's internal state.
  List<StudioSystemDetail> get details {
    return List<StudioSystemDetail>.unmodifiable(_detailsBySystemId.values);
  }

  /// Number of registered system-detail records.
  int get length => _detailsBySystemId.length;

  /// True when no system details have been registered.
  bool get isEmpty => _detailsBySystemId.isEmpty;

  /// Registers one system-detail record.
  ///
  /// System IDs must be unique. Registering a different detail record with an
  /// existing system ID throws a StateError because silently replacing system
  /// content could hide a library configuration problem.
  void register(StudioSystemDetail detail) {
    final systemId = detail.systemId.trim();

    if (systemId.isEmpty) {
      throw ArgumentError.value(
        detail.systemId,
        'detail.systemId',
        'System ID cannot be empty.',
      );
    }

    final existing = _detailsBySystemId[systemId];

    if (existing != null) {
      if (identical(existing, detail)) {
        return;
      }

      throw StateError(
        'A StudioSystemDetail is already registered for system '
        '"$systemId".',
      );
    }

    _detailsBySystemId[systemId] = detail;
  }

  /// Registers several system-detail records.
  ///
  /// Each record is validated using [register].
  void registerAll(Iterable<StudioSystemDetail> details) {
    for (final detail in details) {
      register(detail);
    }
  }

  /// Returns the detail record for [systemId], or null when that system has
  /// not yet been migrated to the rich exploration model.
  StudioSystemDetail? detailBySystemId(String systemId) {
    return _detailsBySystemId[systemId];
  }

  /// Whether rich detail exists for [systemId].
  bool contains(String systemId) {
    return _detailsBySystemId.containsKey(systemId);
  }

  /// Returns all registered detail records containing [tag].
  ///
  /// Matching is case-insensitive.
  List<StudioSystemDetail> detailsByTag(String tag) {
    final normalizedTag = tag.trim().toLowerCase();

    if (normalizedTag.isEmpty) {
      return const [];
    }

    return List<StudioSystemDetail>.unmodifiable(
      _detailsBySystemId.values.where(
        (detail) => detail.tags.any(
          (detailTag) => detailTag.toLowerCase() == normalizedTag,
        ),
      ),
    );
  }

  /// Searches system summaries, purposes, tags, actors, assets, incidents,
  /// simulations, and references.
  ///
  /// This provides a basic local discovery mechanism. A larger search service
  /// can later index the same model without changing library content.
  List<StudioSystemDetail> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return details;
    }

    final matches = _detailsBySystemId.values.where(
      (detail) => _matchesQuery(detail, normalizedQuery),
    );

    return List<StudioSystemDetail>.unmodifiable(matches);
  }

  bool _matchesQuery(StudioSystemDetail detail, String query) {
    final searchableValues = <String>[
      detail.systemId,
      detail.summary,
      detail.purpose,
      ...detail.guidingQuestions,
      ...detail.boundaries,
      ...detail.inputs,
      ...detail.outputs,
      ...detail.tags,
      ...detail.facets.knownValues(),
      ...detail.actors.expand(
        (actor) => [
          actor.name,
          actor.description,
          ...actor.facets.knownValues(),
        ],
      ),
      ...detail.assets.expand(
        (asset) => [
          asset.name,
          asset.description,
          ...asset.protectionGoals,
          ...asset.facets.knownValues(),
        ],
      ),
      ...detail.subsystems.expand(
        (subsystem) => subsystem
            .flatten()
            .expand(
              (node) => [
                ...node.facets.knownValues(),
                ...node.components.expand(
                  (component) => component.facets.knownValues(),
                ),
              ],
            ),
      ),
      ...detail.failureModes.expand(
        (failure) => [
          failure.title,
          failure.description,
          ...failure.causes,
          ...failure.effects,
          ...failure.controls,
        ],
      ),
      ...detail.perspectives.expand(
        (perspective) => [
          perspective.name,
          perspective.description,
          ...perspective.goals,
          ...perspective.concerns,
          ...perspective.decisions,
        ],
      ),
      ...detail.simulations.expand(
        (simulation) => [
          simulation.title,
          simulation.description,
          ...simulation.explorationQuestions,
          ...simulation.tags,
        ],
      ),
      ...detail.incidents.expand(
        (incident) => [
          incident.title,
          incident.summary,
          ...incident.systemEffects,
          ...incident.lessons,
        ],
      ),
      ...detail.references.expand(
        (reference) => [
          reference.title,
          reference.source,
          reference.description,
        ],
      ),
    ];

    return searchableValues.any((value) => value.toLowerCase().contains(query));
  }

  /// Removes all registered details.
  ///
  /// Intended primarily for development resets and framework-level testing.
  void clear() {
    _detailsBySystemId.clear();
  }
}

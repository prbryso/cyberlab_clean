import 'package:systems_studio/engine/perspectives/studio_perspective.dart';

/// Central catalog of graph-driven perspectives available to System Studio.
///
/// The engine can register universal perspectives such as Overview,
/// Architecture, and Explore. Individual libraries may later contribute
/// additional perspectives such as Attack Chain, Token Flow, or Timeline.
///
/// Perspective IDs must be unique.
class PerspectiveCatalog {
  PerspectiveCatalog._();

  static final PerspectiveCatalog instance = PerspectiveCatalog._();

  final Map<String, StudioPerspective> _perspectives =
      <String, StudioPerspective>{};

  /// Returns all registered perspectives in registration order.
  List<StudioPerspective> get perspectives =>
      List<StudioPerspective>.unmodifiable(_perspectives.values);

  /// Returns the perspective registered with [id], or null when none exists.
  StudioPerspective? perspectiveById(String id) {
    return _perspectives[id];
  }

  /// Returns true when a perspective with [id] has been registered.
  bool contains(String id) {
    return _perspectives.containsKey(id);
  }

  /// Registers one perspective.
  ///
  /// Registering a second perspective with the same ID is treated as an
  /// architectural error because StudioExperience resolves perspectives by
  /// stable identifier.
  void register(StudioPerspective perspective) {
    if (_perspectives.containsKey(perspective.id)) {
      throw StateError(
        'A StudioPerspective with ID "${perspective.id}" is already '
        'registered.',
      );
    }

    _perspectives[perspective.id] = perspective;
  }

  /// Registers several perspectives in order.
  void registerAll(Iterable<StudioPerspective> perspectives) {
    for (final perspective in perspectives) {
      register(perspective);
    }
  }

  /// Resolves the supplied perspective IDs.
  ///
  /// IDs are returned in the same order in which they appear in
  /// [perspectiveIds]. Unknown IDs are omitted by default.
  ///
  /// Set [throwOnMissing] to true when missing registrations should be treated
  /// as configuration errors.
  List<StudioPerspective> resolve(
    Iterable<String> perspectiveIds, {
    bool throwOnMissing = false,
  }) {
    final resolved = <StudioPerspective>[];

    for (final id in perspectiveIds) {
      final perspective = _perspectives[id];

      if (perspective == null) {
        if (throwOnMissing) {
          throw StateError('No StudioPerspective with ID "$id" is registered.');
        }

        continue;
      }

      resolved.add(perspective);
    }

    return List<StudioPerspective>.unmodifiable(resolved);
  }

  /// Removes all registered perspectives.
  ///
  /// This is primarily useful during application reconfiguration or isolated
  /// development. Normal application startup should register perspectives
  /// once.
  void clear() {
    _perspectives.clear();
  }
}

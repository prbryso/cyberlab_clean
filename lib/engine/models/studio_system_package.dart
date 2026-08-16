import 'package:systems_studio/engine/models/studio_library.dart';
import 'package:systems_studio/engine/models/studio_system_detail.dart';
import 'package:systems_studio/engine/services/studio_library_registry.dart';
import 'package:systems_studio/engine/services/studio_system_detail_registry.dart';

/// Installable content package for Systems Studio.
///
/// A package can be created inside this project or supplied by a future
/// third-party library. Installing the package registers:
///
/// - one StudioLibrary;
/// - the library's lightweight StudioSystem catalog entries;
/// - the library's routes;
/// - rich StudioSystemDetail records.
///
/// The Systems Studio engine does not need to know what subject the package
/// represents.
abstract class StudioSystemPackage {
  const StudioSystemPackage();

  /// Unique identifier for this installable package.
  ///
  /// Example:
  ///
  ///     cyber_lab
  ///     water_systems
  ///     flight_systems
  String get id;

  /// Human-readable package name.
  String get name;

  /// Package version.
  String get version;

  /// Library supplied by this package.
  StudioLibrary get library;

  /// Rich system descriptions supplied by this package.
  ///
  /// A package may initially return an empty list and add system details
  /// incrementally.
  List<StudioSystemDetail> get systemDetails;

  /// Installs this package into Systems Studio.
  ///
  /// Safe to call repeatedly. Existing libraries are ignored by the library
  /// registry, and already-registered system details are not registered again.
  void install() {
    _validate();

    StudioLibraryRegistry.instance.register(library);

    final detailRegistry = StudioSystemDetailRegistry.instance;

    for (final detail in systemDetails) {
      if (!detailRegistry.contains(detail.systemId)) {
        detailRegistry.register(detail);
      }
    }
  }

  /// Validates the package before registration.
  ///
  /// This catches common third-party configuration problems early, such as:
  ///
  /// - blank package IDs;
  /// - a package/library ID mismatch;
  /// - duplicate system IDs;
  /// - duplicate routes;
  /// - detail records that do not correspond to systems in the library.
  void _validate() {
    final normalizedPackageId = id.trim();

    if (normalizedPackageId.isEmpty) {
      throw StateError('StudioSystemPackage.id cannot be empty.');
    }

    if (name.trim().isEmpty) {
      throw StateError(
        'StudioSystemPackage "$normalizedPackageId" must have a name.',
      );
    }

    if (version.trim().isEmpty) {
      throw StateError(
        'StudioSystemPackage "$normalizedPackageId" must have a version.',
      );
    }

    if (library.id.trim().isEmpty) {
      throw StateError(
        'The library supplied by package "$normalizedPackageId" '
        'must have an ID.',
      );
    }

    if (library.id != normalizedPackageId) {
      throw StateError(
        'Package ID "$normalizedPackageId" does not match '
        'library ID "${library.id}".',
      );
    }

    final systemIds = <String>{};

    for (final system in library.systems) {
      final systemId = system.id.trim();

      if (systemId.isEmpty) {
        throw StateError(
          'Package "$normalizedPackageId" contains a system '
          'with an empty ID.',
        );
      }

      if (!systemIds.add(systemId)) {
        throw StateError(
          'Package "$normalizedPackageId" contains duplicate '
          'system ID "$systemId".',
        );
      }

      if (system.entryRoute.trim().isEmpty) {
        throw StateError('System "$systemId" must define an entry route.');
      }
    }

    final routePaths = <String>{};

    for (final route in library.routes) {
      final path = route.path.trim();

      if (path.isEmpty) {
        throw StateError(
          'Package "$normalizedPackageId" contains a route '
          'with an empty path.',
        );
      }

      if (!path.startsWith('/')) {
        throw StateError(
          'Route "$path" in package "$normalizedPackageId" '
          'must begin with "/".',
        );
      }

      if (!routePaths.add(path)) {
        throw StateError(
          'Package "$normalizedPackageId" contains duplicate '
          'route "$path".',
        );
      }
    }

    final detailIds = <String>{};

    for (final detail in systemDetails) {
      final systemId = detail.systemId.trim();

      if (systemId.isEmpty) {
        throw StateError(
          'Package "$normalizedPackageId" contains a system detail '
          'with an empty system ID.',
        );
      }

      if (!detailIds.add(systemId)) {
        throw StateError(
          'Package "$normalizedPackageId" contains duplicate '
          'detail records for system "$systemId".',
        );
      }

      if (!systemIds.contains(systemId)) {
        throw StateError(
          'System detail "$systemId" does not correspond to a '
          'StudioSystem supplied by package "$normalizedPackageId".',
        );
      }
    }

    for (final system in library.systems) {
      if (!routePaths.contains(system.entryRoute)) {
        throw StateError(
          'System "${system.id}" uses entry route '
          '"${system.entryRoute}", but that route is not registered '
          'by package "$normalizedPackageId".',
        );
      }
    }
  }
}

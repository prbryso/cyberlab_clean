import 'package:systems_studio/engine/models/studio_library.dart';
import 'package:systems_studio/engine/models/studio_route.dart';

class StudioLibraryRegistry {
  StudioLibraryRegistry._();

  static final StudioLibraryRegistry instance = StudioLibraryRegistry._();

  final List<StudioLibrary> _libraries = [];

  List<StudioLibrary> get libraries => List.unmodifiable(_libraries);

  void register(StudioLibrary library) {
    final existingLibrary = libraryById(library.id);

    if (existingLibrary != null) {
      return;
    }

    for (final route in library.routes) {
      final existingRoute = routeByPath(route.path);

      if (existingRoute != null) {
        throw StateError(
          'Cannot register library "${library.id}". '
          'Route "${route.path}" is already registered.',
        );
      }
    }

    _libraries.add(library);
  }

  StudioLibrary? libraryById(String id) {
    for (final library in _libraries) {
      if (library.id == id) {
        return library;
      }
    }

    return null;
  }

  StudioRoute? routeByPath(String path) {
    for (final library in _libraries) {
      for (final route in library.routes) {
        if (route.path == path) {
          return route;
        }
      }
    }

    return null;
  }

  bool containsLibrary(String id) {
    return libraryById(id) != null;
  }

  bool containsRoute(String path) {
    return routeByPath(path) != null;
  }

  /// Intended for automated tests.
  void clear() {
    _libraries.clear();
  }
}

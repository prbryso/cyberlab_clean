import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/models/studio_system.dart';
import 'package:systems_studio/libraries/cyber_lab/cyber_lab_library.dart';
import 'package:systems_studio/libraries/cyber_lab/cyber_lab_routes.dart';

/// Where the library's tiles actually take a learner.
///
/// `StudioSystem.entryRoute` is the only thing the library UI reads when a
/// tile is tapped (`library_screen.dart`, `learning_path_screen.dart`). A
/// system can be fully migrated and still be unreachable if this says
/// otherwise, which is a failure no model test would catch.
void main() {
  final library = CyberLabLibrary.instance;

  StudioSystem systemById(String id) =>
      library.systems.firstWhere((system) => system.id == id);

  final routePaths = cyberLabRoutes.map((route) => route.path).toSet();

  test('the migrated systems open the Systems Studio shell', () {
    expect(
      systemById('cybersecurity.phishing').entryRoute,
      '/phishing/explorer',
    );
    expect(
      systemById('cybersecurity.password_security').entryRoute,
      '/password/explorer',
    );
  });

  test('every entry route is actually registered', () {
    for (final system in library.systems) {
      expect(
        routePaths,
        contains(system.entryRoute),
        reason: '${system.id} points at a route that does not exist',
      );
    }
  });

  test('the legacy phishing entry point still resolves', () {
    // Migration is additive. Nothing that worked before stops working.
    expect(routePaths, contains('/phishing'));
    expect(
      routePaths.where((path) => path.startsWith('/phishing')).length,
      greaterThan(1),
    );
  });
}

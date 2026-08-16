import 'package:flutter/material.dart';

import 'package:systems_studio/engine/services/studio_library_registry.dart';
import 'package:systems_studio/engine/ui/screens/home_screen.dart';
import 'package:systems_studio/engine/ui/screens/learning_path_screen.dart';
import 'package:systems_studio/engine/ui/screens/library_screen.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';

    if (routeName == '/') {
      return MaterialPageRoute(
        builder: (_) => const HomeScreen(),
        settings: settings,
      );
    }

    final learningPathRoute = _buildLearningPathRoute(routeName, settings);

    if (learningPathRoute != null) {
      return learningPathRoute;
    }

    final libraryRoute = _buildLibraryRoute(routeName, settings);

    if (libraryRoute != null) {
      return libraryRoute;
    }

    final registeredRoute = StudioLibraryRegistry.instance.routeByPath(
      routeName,
    );

    if (registeredRoute != null) {
      return MaterialPageRoute(
        builder: registeredRoute.builder,
        settings: settings,
      );
    }

    return MaterialPageRoute(
      builder: (_) => const _NotFoundScreen(),
      settings: settings,
    );
  }

  static Route<dynamic>? _buildLibraryRoute(
    String routeName,
    RouteSettings settings,
  ) {
    const libraryPrefix = '/library/';

    if (!routeName.startsWith(libraryPrefix)) {
      return null;
    }

    final remainder = routeName.substring(libraryPrefix.length);

    if (remainder.isEmpty || remainder.contains('/')) {
      return null;
    }

    final library = StudioLibraryRegistry.instance.libraryById(remainder);

    if (library == null) {
      return null;
    }

    return MaterialPageRoute(
      builder: (_) => LibraryScreen(library: library),
      settings: settings,
    );
  }

  static Route<dynamic>? _buildLearningPathRoute(
    String routeName,
    RouteSettings settings,
  ) {
    final segments = routeName
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (segments.length != 4) {
      return null;
    }

    if (segments[0] != 'library' || segments[2] != 'path') {
      return null;
    }

    final libraryId = segments[1];
    final pathId = segments[3];

    final library = StudioLibraryRegistry.instance.libraryById(libraryId);

    if (library == null) {
      return null;
    }

    final pathDefinition = switch (pathId) {
      'beginner' => (
        name: 'Beginner',
        systemIds: library.dashboard.beginnerPath,
      ),
      'intermediate' => (
        name: 'Intermediate',
        systemIds: library.dashboard.intermediatePath,
      ),
      'advanced' => (
        name: 'Advanced',
        systemIds: library.dashboard.advancedPath,
      ),
      _ => null,
    };

    if (pathDefinition == null) {
      return null;
    }

    return MaterialPageRoute(
      builder: (_) => LearningPathScreen(
        library: library,
        pathName: pathDefinition.name,
        systemIds: pathDefinition.systemIds,
      ),
      settings: settings,
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('404 — Page Not Found')));
  }
}

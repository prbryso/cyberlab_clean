import 'studio_route.dart';
import 'studio_system.dart';

abstract interface class StudioLibrary {
  String get id;

  String get name;

  String get description;

  String get version;

  List<StudioSystem> get systems;

  List<StudioRoute> get routes;
}

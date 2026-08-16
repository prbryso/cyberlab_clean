import 'package:flutter/material.dart';

import 'library_dashboard.dart';
import 'studio_route.dart';
import 'studio_system.dart';

abstract interface class StudioLibrary {
  String get id;

  String get name;

  String get description;

  String get version;

  IconData get icon;

  LibraryDashboard get dashboard;

  List<StudioSystem> get systems;

  List<StudioRoute> get routes;
}

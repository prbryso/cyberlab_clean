import 'package:flutter/material.dart';

typedef StudioPageBuilder = Widget Function(BuildContext context);

class StudioRoute {
  final String path;
  final StudioPageBuilder builder;

  const StudioRoute({required this.path, required this.builder});
}

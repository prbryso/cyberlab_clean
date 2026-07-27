import 'package:flutter/material.dart';

abstract interface class StudioSystem {
  String get id;

  String get title;

  String get description;

  IconData get icon;

  String get entryRoute;
}

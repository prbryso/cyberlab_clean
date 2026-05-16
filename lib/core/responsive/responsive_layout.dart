import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveLayout {
  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.small;

  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.small &&
      MediaQuery.of(context).size.width < Breakpoints.medium;

  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.medium;
}
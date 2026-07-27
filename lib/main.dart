import 'package:flutter/material.dart';
import 'package:systems_studio/theme/theme.dart';
import 'package:systems_studio/engine/core/routing/app_router.dart';

void main() {
  runApp(CyberLabApp());
}

class CyberLabApp extends StatelessWidget {
  CyberLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Lab',
      theme: CyberLabTheme.light,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

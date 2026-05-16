import 'package:flutter/material.dart';
import 'package:cyber_lab/theme/theme.dart';
import 'package:cyber_lab/core/routing/app_router.dart';


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


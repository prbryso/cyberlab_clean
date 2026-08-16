import 'package:flutter/material.dart';

import 'package:systems_studio/engine/core/routing/app_router.dart';
import 'package:systems_studio/engine/theme/theme.dart';
import 'package:systems_studio/libraries/cyber_lab/cyber_lab_package.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Install all Systems Studio content packages here.
  const CyberLabPackage().install();

  runApp(const SystemsStudioApp());
}

class SystemsStudioApp extends StatelessWidget {
  const SystemsStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Systems Studio',
      debugShowCheckedModeBanner: false,
      theme: CyberLabTheme.light,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

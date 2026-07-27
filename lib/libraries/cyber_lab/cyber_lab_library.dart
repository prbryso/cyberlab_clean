import 'package:systems_studio/engine/models/studio_library.dart';
import 'package:systems_studio/engine/models/studio_route.dart';
import 'package:systems_studio/engine/models/studio_system.dart';

class CyberLabLibrary implements StudioLibrary {
  const CyberLabLibrary();

  @override
  String get id => 'cyber_lab';

  @override
  String get name => 'Cyber Lab';

  @override
  String get description =>
      'Interactive cybersecurity education using systems thinking.';

  @override
  String get version => '1.0.0';

  @override
  List<StudioSystem> get systems => const [];

  @override
  List<StudioRoute> get routes => const [];
}

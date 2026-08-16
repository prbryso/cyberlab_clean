import 'package:systems_studio/engine/education/educational_registry.dart';
import 'package:systems_studio/engine/models/studio_library.dart';
import 'package:systems_studio/engine/models/studio_system_detail.dart';
import 'package:systems_studio/engine/models/studio_system_package.dart';
import 'systems/authentication/password_security_detail.dart';
import 'systems/phishing/phishing_detail.dart';

import 'cyber_lab_library.dart';

/// Installable Cyber Lab content package.
///
/// Cyber Lab currently uses both:
///
/// - the Systems Studio library and system architecture;
/// - the older EducationalRegistry for its existing learning modules.
///
/// As systems are migrated to StudioSystemDetail, their detail records can be
/// added to [systemDetails] without requiring changes to the engine.
class CyberLabPackage extends StudioSystemPackage {
  const CyberLabPackage();

  @override
  String get id => 'cyber_lab';

  @override
  String get name => 'Cyber Lab';

  @override
  String get version => '1.0.0';

  @override
  StudioLibrary get library => CyberLabLibrary.instance;

  @override
  // Not a const list: the details it holds are not constants, because an
  // authored scenario names its actors by reference.
  List<StudioSystemDetail> get systemDetails => [
    passwordSecurityDetail,
    phishingDetail,
  ];

  @override
  void install() {
    // Preserve the existing educational module registration while Cyber Lab
    // is gradually migrated to the richer system-detail architecture.
    CyberLabLibrary.register(EducationalRegistry.instance);

    // Register the library, routes, systems, and rich system details.
    super.install();
  }
}

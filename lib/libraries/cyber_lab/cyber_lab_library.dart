import 'package:flutter/material.dart';
import 'package:systems_studio/engine/education/educational_registry.dart';
import 'package:systems_studio/engine/education/learning_module.dart';
import 'package:systems_studio/engine/models/library_dashboard.dart';
import 'package:systems_studio/engine/models/studio_library.dart';
import 'package:systems_studio/engine/models/studio_route.dart';
import 'package:systems_studio/engine/models/studio_system.dart';

import 'cyber_lab_routes.dart';
import 'cyber_security_domain.dart';

/// Cyber Lab is the first installed Systems Studio library.
///
/// It supplies:
///
/// - Library metadata
/// - Dashboard configuration
/// - Cybersecurity systems
/// - Cyber Lab routes
/// - Educational domain and module registration
class CyberLabLibrary implements StudioLibrary {
  CyberLabLibrary._();

  static final CyberLabLibrary instance = CyberLabLibrary._();

  /// Registers Cyber Lab educational content.
  ///
  /// Safe to call multiple times.
  static void register(EducationalRegistry registry) {
    if (!registry.containsDomain(cyberSecurityDomain.id)) {
      registry.registerDomain(cyberSecurityDomain);
    }

    for (final module in cyberSecurityModules) {
      if (!registry.containsModule(module.id)) {
        registry.registerModule(module);
      }
    }
  }

  @override
  String get id => 'cyber_lab';

  @override
  String get name => 'Cyber Lab';

  @override
  String get description =>
      'Explore cybersecurity systems through interactive lessons, '
      'diagrams, and simulations.';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.security;

  @override
  LibraryDashboard get dashboard => const LibraryDashboard(
    heroTitle: 'Understand cybersecurity through systems thinking.',
    heroSubtitle:
        'Learn how attackers think, why attacks succeed, and how resilient systems are built.',
    featuredSystemId: 'cybersecurity.password_security',
    featuredSimulationId: 'password_cracking',
    beginnerPath: [
      'cybersecurity.password_security',
      'cybersecurity.encryption',
      'cybersecurity.phishing',
      'cybersecurity.social_engineering',
    ],
    intermediatePath: [
      'cybersecurity.networking',
      'cybersecurity.os_application_holes',
      'cybersecurity.exploits',
      'cybersecurity.zero_days',
    ],
    advancedPath: [
      'cybersecurity.patch_management',
      'cybersecurity.system_hardening',
      'cybersecurity.secure_coding',
      'cybersecurity.capstone',
    ],
  );

  @override
  List<StudioSystem> get systems {
    return List<StudioSystem>.unmodifiable(
      cyberSecurityModules.map(_CyberLabSystem.new),
    );
  }

  @override
  List<StudioRoute> get routes {
    return List<StudioRoute>.unmodifiable(cyberLabRoutes);
  }
}

class _CyberLabSystem implements StudioSystem {
  const _CyberLabSystem(this.module);

  final LearningModule module;

  @override
  String get id => module.id;

  @override
  String get title => module.title;

  @override
  String get description => module.description;

  @override
  String get entryRoute {
    // Systems that have been migrated to the Systems Studio shell open there.
    // Everything else still opens its original module route, which continues
    // to work unchanged — migration is additive, and the legacy screens are
    // reachable exactly as before.
    return switch (module.id) {
      'cybersecurity.password_security' => '/password/explorer',
      'cybersecurity.phishing' => '/phishing/explorer',
      _ => module.route,
    };
  }

  @override
  IconData get icon => _iconForModule(module.id);
}

IconData _iconForModule(String id) {
  return switch (id) {
    'cybersecurity.password_security' => Icons.lock,
    'cybersecurity.encryption' => Icons.key,
    'cybersecurity.phishing' => Icons.mark_email_read,
    'cybersecurity.social_engineering' => Icons.psychology,
    'cybersecurity.networking' => Icons.hub,
    'cybersecurity.os_application_holes' => Icons.warning_amber,
    'cybersecurity.exploits' => Icons.bolt,
    'cybersecurity.zero_days' => Icons.bug_report,
    'cybersecurity.patch_management' => Icons.system_update_alt,
    'cybersecurity.system_hardening' => Icons.shield,
    'cybersecurity.secure_coding' => Icons.code,
    'cybersecurity.capstone' => Icons.flag,
    _ => Icons.school,
  };
}

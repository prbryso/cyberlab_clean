import 'package:systems_studio/data/modules/password_module.dart';
import 'package:systems_studio/engine/models/studio_route.dart';
import 'package:systems_studio/engine/ui/screens/module_screen.dart';

// Password Security
import 'package:systems_studio/libraries/cyber_lab/systems/password_cracking/attack_methods/attack_methods_overview.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/password_cracking/famous_breaches/famous_breaches_overview.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/password_cracking/screens/password_hashing_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/password_cracking/screens/password_intro_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/password_cracking/screens/password_manager_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/password_cracking/weak_passwords/password_weak_screen.dart';

// Multi-Factor Authentication
import 'package:systems_studio/libraries/cyber_lab/systems/mfa/authenticator_apps_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/mfa/mfa_cases_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/mfa/mfa_overview_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/mfa/mfa_types_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/mfa/security_keys_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/mfa/sms_mfa_screen.dart';

// Encryption
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/asymmetric_encryption_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/encryption_demo_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/encryption_overview_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/hashing_vs_encryption_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/https_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/math_overview_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/real_world_crypto_failures_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/real_world_failures_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/encryption/symmetric_encryption_screen.dart';

// Phishing and Malware
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/phishing_menu_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/phishing_module_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/phishing_overview_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/example_delivery_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/example_invitation_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/example_invoice_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/example_password_reset_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/examples_gallery_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/header_analyzer_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/malware_overview_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/malware_protection_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/malware_ransomware_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/malware_spyware_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/malware_trojans_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/phishing_quiz_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/phishing/screens/spot_red_flags_screen.dart';

// Social Engineering
import 'package:systems_studio/libraries/cyber_lab/systems/SocialEngineering/screens/social_baiting_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/SocialEngineering/screens/social_deepfakes_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/SocialEngineering/screens/social_defense_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/SocialEngineering/screens/social_pretexting_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/SocialEngineering/screens/social_tailgating_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/SocialEngineering/social_engineering_overview_screen.dart';

// Networking
import 'package:systems_studio/libraries/cyber_lab/systems/networking/networking_overview_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/networking/screens/networking_communication_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/networking/screens/networking_internet_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/networking/screens/networking_ip_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/networking/screens/networking_ports_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/networking/screens/networking_router_screen.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/networking/screens/networking_safety_screen.dart';

// OS and Application Holes
import 'package:systems_studio/libraries/cyber_lab/systems/osappholes/app_vulns_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/osappholes/defense_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/osappholes/exploit_chain_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/osappholes/os_app_holes_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/osappholes/os_intro_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/osappholes/os_vulns_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/osappholes/real_examples_page.dart';

// Exploits
import 'package:systems_studio/libraries/cyber_lab/systems/exploits/exploit_defense_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/exploits/exploit_lifecycle_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/exploits/exploit_types_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/exploits/exploits_overview_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/exploits/famous_exploits_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/exploits/what_is_exploit_page.dart';

// Zero-Days
import 'package:systems_studio/libraries/cyber_lab/systems/zero_days/detection_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/zero_days/discovery_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/zero_days/famous_zero_days_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/zero_days/what_is_zero_day_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/zero_days/zero_day_defense_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/zero_days/zero_days_overview_page.dart';

// Patch Management
import 'package:systems_studio/libraries/cyber_lab/systems/patch_management/famous_patch_failures_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/patch_management/patch_best_practices_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/patch_management/patch_cycle_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/patch_management/patch_overview_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/patch_management/what_is_patch_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/patch_management/why_patching_fails_page.dart';

// System Hardening
import 'package:systems_studio/libraries/cyber_lab/systems/system_hardening/attack_surface_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/system_hardening/famous_hardening_failures_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/system_hardening/hardening_best_practices_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/system_hardening/hardening_methods_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/system_hardening/hardening_overview_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/system_hardening/what_is_hardening_page.dart';

// Secure Coding
import 'package:systems_studio/libraries/cyber_lab/systems/secure_coding/common_vulnerabilities_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/secure_coding/famous_coding_failures_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/secure_coding/secure_coding_overview_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/secure_coding/secure_coding_tools_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/secure_coding/secure_practices_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/secure_coding/what_is_secure_coding_page.dart';

// Capstone
import 'package:systems_studio/libraries/cyber_lab/systems/capstone/capstone_overview_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/capstone/phase1_recon_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/capstone/phase2_breach_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/capstone/phase3_escalation_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/capstone/phase4_containment_page.dart';
import 'package:systems_studio/libraries/cyber_lab/systems/capstone/phase5_lessons_page.dart';
import 'package:systems_studio/engine/ui/screens/system_graph_inspector_screen.dart';
import 'package:systems_studio/engine/ui/screens/system_explorer_screen.dart';

final List<StudioRoute> cyberLabRoutes = [
  // The generic Systems Studio shell, one entry per system that has a model.
  // Legacy routes below continue to resolve; the two coexist while areas
  // migrate.
  StudioRoute(
    path: '/phishing/explorer',
    builder: (_) => const SystemExplorerScreen(
      systemId: 'cybersecurity.phishing',
      title: 'Recognise a Deceptive Message',
    ),
  ),

  StudioRoute(
    path: '/password/explorer',
    builder: (_) => const SystemExplorerScreen(
      systemId: 'cybersecurity.password_security',
      title: 'Prevent Account Takeovers',
    ),
  ),

  StudioRoute(
    path: '/password/system-map',
    builder: (_) => const SystemGraphInspectorScreen(
      systemId: 'cybersecurity.password_security',
      title: 'Prevent Account Takeovers',
    ),
  ),

  // Password Security
  StudioRoute(
    path: '/password',
    builder: (_) => const ModuleScreen(module: passwordModule),
  ),
  StudioRoute(
    path: '/password/intro',
    builder: (_) => const PasswordIntroScreen(),
  ),
  StudioRoute(
    path: '/weak_passwords',
    builder: (_) => const WeakPasswordsOverview(),
  ),
  StudioRoute(
    path: '/password_cracking',
    builder: (_) => const PasswordAttackMethodsOverview(),
  ),
  StudioRoute(
    path: '/hashing_salt',
    builder: (_) => const PasswordHashingScreen(),
  ),
  StudioRoute(
    path: '/password_breaches',
    builder: (_) => const FamousBreachesOverview(),
  ),
  StudioRoute(
    path: '/password_managers',
    builder: (_) => const PasswordManagerScreen(),
  ),

  // MFA
  StudioRoute(path: '/mfa', builder: (_) => const MFAOverviewScreen()),
  StudioRoute(path: '/mfa_types', builder: (_) => const MFATypesScreen()),
  StudioRoute(
    path: '/authenticator_apps',
    builder: (_) => const AuthenticatorAppsScreen(),
  ),
  StudioRoute(path: '/sms_mfa', builder: (_) => const SMSMFAScreen()),
  StudioRoute(
    path: '/security_keys',
    builder: (_) => const SecurityKeysScreen(),
  ),
  StudioRoute(path: '/mfa_cases', builder: (_) => const MFACasesScreen()),

  // Encryption
  StudioRoute(path: '/encryption', builder: (_) => EncryptionOverviewScreen()),
  StudioRoute(
    path: '/encryption/symmetric',
    builder: (_) => SymmetricEncryptionScreen(),
  ),
  StudioRoute(
    path: '/encryption/asymmetric',
    builder: (_) => AsymmetricEncryptionScreen(),
  ),
  StudioRoute(path: '/encryption/https', builder: (_) => HttpsScreen()),
  StudioRoute(
    path: '/encryption/hashing',
    builder: (_) => HashingVsEncryptionScreen(),
  ),
  StudioRoute(
    path: '/encryption/failures',
    builder: (_) => RealWorldFailuresScreen(),
  ),
  StudioRoute(path: '/encryption/demo', builder: (_) => EncryptionDemoScreen()),
  StudioRoute(path: '/encryption/math', builder: (_) => MathOverviewScreen()),
  StudioRoute(
    path: '/encryption/cases',
    builder: (_) => RealWorldCryptoFailuresScreen(),
  ),

  // Phishing
  StudioRoute(
    path: '/phishing',
    builder: (_) => const PhishingOverviewScreen(),
  ),
  StudioRoute(
    path: '/phishing/menu',
    builder: (_) => const PhishingMenuScreen(),
  ),
  StudioRoute(
    path: '/phishing/module',
    builder: (_) => const PhishingModuleScreen(),
  ),
  StudioRoute(
    path: '/phishing/examples',
    builder: (_) => const PhishingExamplesScreen(),
  ),
  StudioRoute(
    path: '/phishing/examples/invitation',
    builder: (_) => const ExampleInvitationScreen(),
  ),
  StudioRoute(
    path: '/phishing/examples/invoice',
    builder: (_) => const ExampleInvoiceScreen(),
  ),
  StudioRoute(
    path: '/phishing/examples/password_reset',
    builder: (_) => const ExamplePasswordResetScreen(),
  ),
  StudioRoute(
    path: '/phishing/examples/delivery',
    builder: (_) => const ExampleDeliveryScreen(),
  ),
  StudioRoute(
    path: '/phishing/spot',
    builder: (_) => const SpotRedFlagsScreen(),
  ),
  StudioRoute(
    path: '/phishing/header',
    builder: (_) => const HeaderAnalyzerScreen(),
  ),
  StudioRoute(
    path: '/phishing/quiz',
    builder: (_) => const PhishingQuizScreen(),
  ),

  // Malware
  StudioRoute(
    path: '/phishing/malware',
    builder: (_) => const MalwareOverviewScreen(),
  ),
  StudioRoute(
    path: '/malware/ransomware',
    builder: (_) => const RansomwareScreen(),
  ),
  StudioRoute(path: '/malware/spyware', builder: (_) => const SpywareScreen()),
  StudioRoute(path: '/malware/trojans', builder: (_) => const TrojansScreen()),
  StudioRoute(
    path: '/malware/protection',
    builder: (_) => const MalwareProtectionScreen(),
  ),

  // Social Engineering
  StudioRoute(
    path: '/social',
    builder: (_) => const SocialEngineeringOverviewScreen(),
  ),
  StudioRoute(
    path: '/social/tailgating',
    builder: (_) => const TailgatingScreen(),
  ),
  StudioRoute(
    path: '/social/pretexting',
    builder: (_) => const PretextingScreen(),
  ),
  StudioRoute(
    path: '/social/defense',
    builder: (_) => const SocialDefenseScreen(),
  ),
  StudioRoute(
    path: '/social/deepfakes',
    builder: (_) => const DeepfakesScreen(),
  ),
  StudioRoute(path: '/social/baiting', builder: (_) => const BaitingScreen()),

  // Networking
  StudioRoute(
    path: '/networking',
    builder: (_) => const NetworkingOverviewScreen(),
  ),
  StudioRoute(
    path: '/networking/communication',
    builder: (_) => const NetworkingCommunicationScreen(),
  ),
  StudioRoute(
    path: '/networking/internet',
    builder: (_) => const NetworkingInternetScreen(),
  ),
  StudioRoute(
    path: '/networking/ip',
    builder: (_) => const NetworkingIPScreen(),
  ),
  StudioRoute(
    path: '/networking/ports',
    builder: (_) => const NetworkingPortsScreen(),
  ),
  StudioRoute(
    path: '/networking/router',
    builder: (_) => const NetworkingRouterScreen(),
  ),
  StudioRoute(
    path: '/networking/safety',
    builder: (_) => const NetworkingSafetyScreen(),
  ),

  // OS and Application Holes
  StudioRoute(
    path: '/osappholes',
    builder: (_) => const OsAppHolesOverviewPage(),
  ),
  StudioRoute(path: '/osappholes/vul', builder: (_) => const OsIntroPage()),
  StudioRoute(path: '/osappholes/osv', builder: (_) => const OsVulnsPage()),
  StudioRoute(path: '/osappholes/appv', builder: (_) => const AppVulnsPage()),
  StudioRoute(
    path: '/osappholes/real',
    builder: (_) => const RealExamplesPage(),
  ),
  StudioRoute(path: '/osappholes/defense', builder: (_) => const DefensePage()),
  StudioRoute(
    path: '/osappholes/exploit',
    builder: (_) => const ExploitChainPage(),
  ),

  // Exploits
  StudioRoute(path: '/exploits', builder: (_) => const ExploitsOverviewPage()),
  StudioRoute(
    path: '/exploits-what',
    builder: (_) => const WhatIsExploitPage(),
  ),
  StudioRoute(
    path: '/exploits-lifecycle',
    builder: (_) => const ExploitLifecyclePage(),
  ),
  StudioRoute(
    path: '/exploits-types',
    builder: (_) => const ExploitTypesPage(),
  ),
  StudioRoute(
    path: '/exploits-famous',
    builder: (_) => const FamousExploitsPage(),
  ),
  StudioRoute(
    path: '/exploits-defense',
    builder: (_) => const ExploitDefensePage(),
  ),

  // Zero-Days
  StudioRoute(path: '/zero-days', builder: (_) => const ZeroDaysOverviewPage()),
  StudioRoute(path: '/zero-what', builder: (_) => const WhatIsZeroDayPage()),
  StudioRoute(
    path: '/zero-discovery',
    builder: (_) => const ZeroDayDiscoveryPage(),
  ),
  StudioRoute(
    path: '/zero-detection',
    builder: (_) => const ZeroDayDetectionPage(),
  ),
  StudioRoute(path: '/zero-famous', builder: (_) => const FamousZeroDaysPage()),
  StudioRoute(
    path: '/zero-defense',
    builder: (_) => const ZeroDayDefensePage(),
  ),

  // Patch Management
  StudioRoute(path: '/patch', builder: (_) => const PatchOverviewPage()),
  StudioRoute(path: '/patch-what', builder: (_) => const WhatIsPatchPage()),
  StudioRoute(path: '/patch-cycle', builder: (_) => const PatchCyclePage()),
  StudioRoute(
    path: '/patch-fails',
    builder: (_) => const WhyPatchingFailsPage(),
  ),
  StudioRoute(
    path: '/patch-famous',
    builder: (_) => const FamousPatchFailuresPage(),
  ),
  StudioRoute(
    path: '/patch-best',
    builder: (_) => const PatchBestPracticesPage(),
  ),

  // System Hardening
  StudioRoute(
    path: '/hardening',
    builder: (_) => const HardeningOverviewPage(),
  ),
  StudioRoute(
    path: '/hardening-what',
    builder: (_) => const WhatIsHardeningPage(),
  ),
  StudioRoute(
    path: '/hardening-surface',
    builder: (_) => const AttackSurfacePage(),
  ),
  StudioRoute(
    path: '/hardening-methods',
    builder: (_) => const HardeningMethodsPage(),
  ),
  StudioRoute(
    path: '/hardening-failures',
    builder: (_) => const FamousHardeningFailuresPage(),
  ),
  StudioRoute(
    path: '/hardening-best',
    builder: (_) => const HardeningBestPracticesPage(),
  ),

  // Secure Coding
  StudioRoute(
    path: '/secure',
    builder: (_) => const SecureCodingOverviewPage(),
  ),
  StudioRoute(
    path: '/secure-what',
    builder: (_) => const WhatIsSecureCodingPage(),
  ),
  StudioRoute(
    path: '/secure-vulns',
    builder: (_) => const CommonVulnerabilitiesPage(),
  ),
  StudioRoute(
    path: '/secure-practices',
    builder: (_) => const SecurePracticesPage(),
  ),
  StudioRoute(
    path: '/secure-failures',
    builder: (_) => const FamousCodingFailuresPage(),
  ),
  StudioRoute(
    path: '/secure-tools',
    builder: (_) => const SecureCodingToolsPage(),
  ),

  // Capstone
  StudioRoute(path: '/capstone', builder: (_) => const CapstoneOverviewPage()),
  StudioRoute(
    path: '/capstone-phase1',
    builder: (_) => const CapstonePhase1Page(),
  ),
  StudioRoute(
    path: '/capstone-phase2',
    builder: (_) => const CapstonePhase2Page(),
  ),
  StudioRoute(
    path: '/capstone-phase3',
    builder: (_) => const CapstonePhase3Page(),
  ),
  StudioRoute(
    path: '/capstone-phase4',
    builder: (_) => const CapstonePhase4Page(),
  ),
  StudioRoute(
    path: '/capstone-phase5',
    builder: (_) => const CapstonePhase5Page(),
  ),
];

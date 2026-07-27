import 'package:flutter/material.dart';
import 'package:systems_studio/engine/ui/screens/home_screen.dart';

// Password Cracking module
import 'package:systems_studio/modules/password_cracking/screens/password_intro_screen.dart';
import 'package:systems_studio/modules/password_cracking/famous_breaches/famous_breaches_overview.dart';
import 'package:systems_studio/modules/password_cracking/weak_passwords/password_weak_screen.dart';
import 'package:systems_studio/modules/password_cracking/screens/password_hashing_screen.dart';
import 'package:systems_studio/modules/password_cracking/screens/password_crack_time_screen.dart';
import 'package:systems_studio/modules/password_cracking/screens/password_manager_screen.dart';
import 'package:systems_studio/modules/password_cracking/password_overview_screen.dart';
import 'package:systems_studio/modules/password_cracking/weak_passwords/details/password_weak_screen_old.dart';
import 'package:systems_studio/modules/mfa/mfa_overview_screen.dart';
import 'package:systems_studio/modules/mfa/mfa_types_screen.dart';
import 'package:systems_studio/modules/mfa/authenticator_apps_screen.dart';
import 'package:systems_studio/modules/mfa/sms_mfa_screen.dart';
import 'package:systems_studio/modules/mfa/security_keys_screen.dart';
import 'package:systems_studio/modules/mfa/mfa_cases_screen.dart';

// NEW: Attack Methods Overview (correct file)
import 'package:systems_studio/modules/password_cracking/attack_methods/attack_methods_overview.dart';

// NEW encryption module importscode .
import 'package:systems_studio/modules/encryption/encryption_overview_screen.dart';
import 'package:systems_studio/modules/encryption/symmetric_encryption_screen.dart';
import 'package:systems_studio/modules/encryption/asymmetric_encryption_screen.dart';
import 'package:systems_studio/modules/encryption/https_screen.dart';
import 'package:systems_studio/modules/encryption/hashing_vs_encryption_screen.dart';
import 'package:systems_studio/modules/encryption/real_world_failures_screen.dart';
import 'package:systems_studio/modules/encryption/encryption_demo_screen.dart';
import 'package:systems_studio/modules/encryption/math_overview_screen.dart';
import 'package:systems_studio/modules/encryption/real_world_crypto_failures_screen.dart';

//Phishing modules
import 'package:systems_studio/modules/phishing/phishing_module_screen.dart';
import 'package:systems_studio/modules/phishing/phishing_menu_screen.dart';
import 'package:systems_studio/modules/phishing/screens/example_delivery_screen.dart';
import 'package:systems_studio/modules/phishing/screens/example_invitation_screen.dart';
import 'package:systems_studio/modules/phishing/screens/example_invoice_screen.dart';
import 'package:systems_studio/modules/phishing/screens/example_password_reset_screen.dart';
import 'package:systems_studio/modules/phishing/screens/examples_gallery_screen.dart';
import 'package:systems_studio/modules/phishing/screens/header_analyzer_screen.dart';
import 'package:systems_studio/modules/phishing/screens/phishing_quiz_screen.dart';
import 'package:systems_studio/modules/phishing/screens/spot_red_flags_screen.dart';
import 'package:systems_studio/modules/phishing/phishing_overview_screen.dart';
import 'package:systems_studio/modules/phishing/screens/malware_overview_screen.dart';
import 'package:systems_studio/modules/phishing/screens/malware_ransomware_screen.dart';
import 'package:systems_studio/modules/phishing/screens/malware_spyware_screen.dart';
import 'package:systems_studio/modules/phishing/screens/malware_trojans_screen.dart';
import 'package:systems_studio/modules/phishing/screens/malware_protection_screen.dart';

//Social Engineering Modules
import 'package:systems_studio/modules/SocialEngineering/social_engineering_overview_screen.dart';
import 'package:systems_studio/modules/SocialEngineering/screens/social_tailgating_screen.dart';
import 'package:systems_studio/modules/SocialEngineering/screens/social_pretexting_screen.dart';
import 'package:systems_studio/modules/SocialEngineering/screens/social_defense_screen.dart';
import 'package:systems_studio/modules/SocialEngineering/screens/social_deepfakes_screen.dart';
import 'package:systems_studio/modules/SocialEngineering/screens/social_baiting_screen.dart';

//Networking Modules
import 'package:systems_studio/modules/networking/networking_overview_screen.dart';
import 'package:systems_studio/modules/networking/screens/networking_communication_screen.dart';
import 'package:systems_studio/modules/networking/screens/networking_internet_screen.dart';
import 'package:systems_studio/modules/networking/screens/networking_ip_screen.dart';
import 'package:systems_studio/modules/networking/screens/networking_ports_screen.dart';
import 'package:systems_studio/modules/networking/screens/networking_router_screen.dart';
import 'package:systems_studio/modules/networking/screens/networking_safety_screen.dart';

//OS Application Holes Modulesimport
import 'package:systems_studio/modules/osappholes/os_app_holes_page.dart';
import 'package:systems_studio/modules/osappholes/os_intro_page.dart';
import 'package:systems_studio/modules/osappholes/app_vulns_page.dart';
import 'package:systems_studio/modules/osappholes/defense_page.dart';
import 'package:systems_studio/modules/osappholes/exploit_chain_page.dart';
import 'package:systems_studio/modules/osappholes/os_vulns_page.dart';
import 'package:systems_studio/modules/osappholes/real_examples_page.dart';

import 'package:systems_studio/modules/exploits/exploits_overview_page.dart';
import 'package:systems_studio/modules/exploits/what_is_exploit_page.dart';
import 'package:systems_studio/modules/exploits/exploit_lifecycle_page.dart';
import 'package:systems_studio/modules/exploits/exploit_types_page.dart';
import 'package:systems_studio/modules/exploits/famous_exploits_page.dart';
import 'package:systems_studio/modules/exploits/exploit_defense_page.dart';

import 'package:systems_studio/modules/zero_days/zero_days_overview_page.dart';
import 'package:systems_studio/modules/zero_days/what_is_zero_day_page.dart';
import 'package:systems_studio/modules/zero_days/discovery_page.dart';
import 'package:systems_studio/modules/zero_days/detection_page.dart';
import 'package:systems_studio/modules/zero_days/famous_zero_days_page.dart';
import 'package:systems_studio/modules/zero_days/zero_day_defense_page.dart';

import 'package:systems_studio/modules/patch_management/patch_overview_page.dart';
import 'package:systems_studio/modules/patch_management/what_is_patch_page.dart';
import 'package:systems_studio/modules/patch_management/patch_cycle_page.dart';
import 'package:systems_studio/modules/patch_management/why_patching_fails_page.dart';
import 'package:systems_studio/modules/patch_management/famous_patch_failures_page.dart';
import 'package:systems_studio/modules/patch_management/patch_best_practices_page.dart';

import 'package:systems_studio/modules/system_hardening/hardening_overview_page.dart';
import 'package:systems_studio/modules/system_hardening/what_is_hardening_page.dart';
import 'package:systems_studio/modules/system_hardening/attack_surface_page.dart';
import 'package:systems_studio/modules/system_hardening/hardening_methods_page.dart';
import 'package:systems_studio/modules/system_hardening/famous_hardening_failures_page.dart';
import 'package:systems_studio/modules/system_hardening/hardening_best_practices_page.dart';

import 'package:systems_studio/modules/secure_coding/secure_coding_overview_page.dart';
import 'package:systems_studio/modules/secure_coding/what_is_secure_coding_page.dart';
import 'package:systems_studio/modules/secure_coding/common_vulnerabilities_page.dart';
import 'package:systems_studio/modules/secure_coding/secure_practices_page.dart';
import 'package:systems_studio/modules/secure_coding/famous_coding_failures_page.dart';
import 'package:systems_studio/modules/secure_coding/secure_coding_tools_page.dart';

import 'package:systems_studio/modules/capstone/capstone_overview_page.dart';
import 'package:systems_studio/modules/capstone/phase1_recon_page.dart';
import 'package:systems_studio/modules/capstone/phase2_breach_page.dart';
import 'package:systems_studio/modules/capstone/phase3_escalation_page.dart';
import 'package:systems_studio/modules/capstone/phase4_containment_page.dart';
import 'package:systems_studio/modules/capstone/phase5_lessons_page.dart';

import 'package:systems_studio/engine/ui/screens/module_screen.dart';
import 'package:systems_studio/data/modules/password_module.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case '/password':
        return MaterialPageRoute(
          builder: (_) => const ModuleScreen(module: passwordModule),
        );
      case '/password/intro':
        return MaterialPageRoute(builder: (_) => const PasswordIntroScreen());

      case '/weak_passwords':
        return MaterialPageRoute(builder: (_) => const WeakPasswordsOverview());

      case '/password_cracking':
        return MaterialPageRoute(
          builder: (_) => const PasswordAttackMethodsOverview(),
        );

      case '/hashing_salt':
        return MaterialPageRoute(builder: (_) => const PasswordHashingScreen());

      case '/password_breaches':
        return MaterialPageRoute(
          builder: (_) => const FamousBreachesOverview(),
        );

      case '/password_managers':
        return MaterialPageRoute(builder: (_) => const PasswordManagerScreen());

      case '/mfa':
        return MaterialPageRoute(builder: (_) => const MFAOverviewScreen());

      case '/mfa_types':
        return MaterialPageRoute(builder: (_) => const MFATypesScreen());

      case '/authenticator_apps':
        return MaterialPageRoute(
          builder: (_) => const AuthenticatorAppsScreen(),
        );

      case '/sms_mfa':
        return MaterialPageRoute(builder: (_) => const SMSMFAScreen());

      case '/security_keys':
        return MaterialPageRoute(builder: (_) => const SecurityKeysScreen());

      case '/mfa_cases':
        return MaterialPageRoute(builder: (_) => const MFACasesScreen());

      // NEW encryption routes
      case '/encryption':
        return MaterialPageRoute(builder: (_) => EncryptionOverviewScreen());

      case '/encryption/symmetric':
        return MaterialPageRoute(builder: (_) => SymmetricEncryptionScreen());

      case '/encryption/asymmetric':
        return MaterialPageRoute(builder: (_) => AsymmetricEncryptionScreen());

      case '/encryption/https':
        return MaterialPageRoute(builder: (_) => HttpsScreen());

      case '/encryption/hashing':
        return MaterialPageRoute(builder: (_) => HashingVsEncryptionScreen());

      case '/encryption/failures':
        return MaterialPageRoute(builder: (_) => RealWorldFailuresScreen());

      case '/encryption/demo':
        return MaterialPageRoute(builder: (_) => EncryptionDemoScreen());

      case '/encryption/math':
        return MaterialPageRoute(builder: (_) => MathOverviewScreen());

      case '/encryption/cases':
        return MaterialPageRoute(
          builder: (_) => RealWorldCryptoFailuresScreen(),
        );

      case '/phishing':
        return MaterialPageRoute(
          builder: (_) => const PhishingOverviewScreen(),
        );

      case '/phishing/menu':
        return MaterialPageRoute(builder: (_) => const PhishingMenuScreen());

      case '/phishing/module':
        return MaterialPageRoute(builder: (_) => const PhishingModuleScreen());

      case '/phishing/examples':
        return MaterialPageRoute(
          builder: (_) => const PhishingExamplesScreen(),
        );

      case '/phishing/examples/invitation':
        return MaterialPageRoute(
          builder: (_) => const ExampleInvitationScreen(),
        );

      case '/phishing/examples/invoice':
        return MaterialPageRoute(builder: (_) => const ExampleInvoiceScreen());

      case '/phishing/examples/password_reset':
        return MaterialPageRoute(
          builder: (_) => const ExamplePasswordResetScreen(),
        );

      case '/phishing/examples/delivery':
        return MaterialPageRoute(builder: (_) => const ExampleDeliveryScreen());

      case '/phishing/spot':
        return MaterialPageRoute(builder: (_) => const SpotRedFlagsScreen());

      case '/phishing/header':
        return MaterialPageRoute(builder: (_) => const HeaderAnalyzerScreen());

      case '/phishing/quiz':
        return MaterialPageRoute(builder: (_) => const PhishingQuizScreen());

      case '/phishing/malware':
        return MaterialPageRoute(builder: (_) => const MalwareOverviewScreen());

      case '/malware/ransomware':
        return MaterialPageRoute(builder: (_) => const RansomwareScreen());

      case '/malware/spyware':
        return MaterialPageRoute(builder: (_) => const SpywareScreen());

      case '/malware/trojans':
        return MaterialPageRoute(builder: (_) => const TrojansScreen());

      case '/malware/protection':
        return MaterialPageRoute(
          builder: (_) => const MalwareProtectionScreen(),
        );

      case '/social':
        return MaterialPageRoute(
          builder: (_) => const SocialEngineeringOverviewScreen(),
        );

      case '/social/tailgating':
        return MaterialPageRoute(builder: (_) => const TailgatingScreen());

      case '/social/pretexting':
        return MaterialPageRoute(builder: (_) => const PretextingScreen());

      case '/social/defense':
        return MaterialPageRoute(builder: (_) => const SocialDefenseScreen());

      case '/social/deepfakes':
        return MaterialPageRoute(builder: (_) => const DeepfakesScreen());

      case '/social/baiting':
        return MaterialPageRoute(builder: (_) => const BaitingScreen());

      case '/networking':
        return MaterialPageRoute(
          builder: (_) => const NetworkingOverviewScreen(),
        );

      case '/networking/communication':
        return MaterialPageRoute(
          builder: (_) => const NetworkingCommunicationScreen(),
        );

      case '/networking/internet':
        return MaterialPageRoute(
          builder: (_) => const NetworkingInternetScreen(),
        );

      case '/networking/ip':
        return MaterialPageRoute(builder: (_) => const NetworkingIPScreen());

      case '/networking/ports':
        return MaterialPageRoute(builder: (_) => const NetworkingPortsScreen());

      case '/networking/router':
        return MaterialPageRoute(
          builder: (_) => const NetworkingRouterScreen(),
        );

      case '/networking/safety':
        return MaterialPageRoute(
          builder: (_) => const NetworkingSafetyScreen(),
        );

      case '/osappholes':
        return MaterialPageRoute(
          builder: (_) => const OsAppHolesOverviewPage(),
        );

      case '/osappholes/vul':
        return MaterialPageRoute(builder: (_) => const OsIntroPage());

      case '/osappholes/osv':
        return MaterialPageRoute(builder: (_) => const OsVulnsPage());

      case '/osappholes/appv':
        return MaterialPageRoute(builder: (_) => const AppVulnsPage());

      case '/osappholes/real':
        return MaterialPageRoute(builder: (_) => const RealExamplesPage());

      case '/osappholes/defense':
        return MaterialPageRoute(builder: (_) => const DefensePage());

      case '/osappholes/exploit':
        return MaterialPageRoute(builder: (_) => const ExploitChainPage());

      case '/exploits':
        return MaterialPageRoute(builder: (_) => const ExploitsOverviewPage());
      case '/exploits-what':
        return MaterialPageRoute(builder: (_) => const WhatIsExploitPage());
      case '/exploits-lifecycle':
        return MaterialPageRoute(builder: (_) => const ExploitLifecyclePage());
      case '/exploits-types':
        return MaterialPageRoute(builder: (_) => const ExploitTypesPage());
      case '/exploits-famous':
        return MaterialPageRoute(builder: (_) => const FamousExploitsPage());
      case '/exploits-defense':
        return MaterialPageRoute(builder: (_) => const ExploitDefensePage());
      case '/zero-days':
        return MaterialPageRoute(builder: (_) => const ZeroDaysOverviewPage());
      case '/zero-what':
        return MaterialPageRoute(builder: (_) => const WhatIsZeroDayPage());
      case '/zero-discovery':
        return MaterialPageRoute(builder: (_) => const ZeroDayDiscoveryPage());
      case '/zero-detection':
        return MaterialPageRoute(builder: (_) => const ZeroDayDetectionPage());
      case '/zero-famous':
        return MaterialPageRoute(builder: (_) => const FamousZeroDaysPage());
      case '/zero-defense':
        return MaterialPageRoute(builder: (_) => const ZeroDayDefensePage());

      case '/patch':
        return MaterialPageRoute(builder: (_) => const PatchOverviewPage());
      case '/patch-what':
        return MaterialPageRoute(builder: (_) => const WhatIsPatchPage());
      case '/patch-cycle':
        return MaterialPageRoute(builder: (_) => const PatchCyclePage());
      case '/patch-fails':
        return MaterialPageRoute(builder: (_) => const WhyPatchingFailsPage());
      case '/patch-famous':
        return MaterialPageRoute(
          builder: (_) => const FamousPatchFailuresPage(),
        );
      case '/patch-best':
        return MaterialPageRoute(
          builder: (_) => const PatchBestPracticesPage(),
        );

      case '/hardening':
        return MaterialPageRoute(builder: (_) => const HardeningOverviewPage());
      case '/hardening-what':
        return MaterialPageRoute(builder: (_) => const WhatIsHardeningPage());
      case '/hardening-surface':
        return MaterialPageRoute(builder: (_) => const AttackSurfacePage());
      case '/hardening-methods':
        return MaterialPageRoute(builder: (_) => const HardeningMethodsPage());
      case '/hardening-failures':
        return MaterialPageRoute(
          builder: (_) => const FamousHardeningFailuresPage(),
        );
      case '/hardening-best':
        return MaterialPageRoute(
          builder: (_) => const HardeningBestPracticesPage(),
        );

      case '/secure':
        return MaterialPageRoute(
          builder: (_) => const SecureCodingOverviewPage(),
        );
      case '/secure-what':
        return MaterialPageRoute(
          builder: (_) => const WhatIsSecureCodingPage(),
        );
      case '/secure-vulns':
        return MaterialPageRoute(
          builder: (_) => const CommonVulnerabilitiesPage(),
        );
      case '/secure-practices':
        return MaterialPageRoute(builder: (_) => const SecurePracticesPage());
      case '/secure-failures':
        return MaterialPageRoute(
          builder: (_) => const FamousCodingFailuresPage(),
        );
      case '/secure-tools':
        return MaterialPageRoute(builder: (_) => const SecureCodingToolsPage());

      case '/capstone':
        return MaterialPageRoute(builder: (_) => const CapstoneOverviewPage());
      case '/capstone-phase1':
        return MaterialPageRoute(builder: (_) => const CapstonePhase1Page());
      case '/capstone-phase2':
        return MaterialPageRoute(builder: (_) => const CapstonePhase2Page());
      case '/capstone-phase3':
        return MaterialPageRoute(builder: (_) => const CapstonePhase3Page());
      case '/capstone-phase4':
        return MaterialPageRoute(builder: (_) => const CapstonePhase4Page());
      case '/capstone-phase5':
        return MaterialPageRoute(builder: (_) => const CapstonePhase5Page());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("404 — Page Not Found"))),
        );
    }
  }
}

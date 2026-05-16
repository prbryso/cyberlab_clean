import 'package:flutter/material.dart';
import 'package:cyber_lab/ui/screens/home_screen.dart';

// Password Cracking module
import 'package:cyber_lab/modules/password_cracking/screens/password_intro_screen.dart';
import 'package:cyber_lab/modules/password_cracking/famous_breaches/famous_breaches_overview.dart';
import 'package:cyber_lab/modules/password_cracking/weak_passwords/password_weak_screen.dart';
import 'package:cyber_lab/modules/password_cracking/screens/password_hashing_screen.dart';
import 'package:cyber_lab/modules/password_cracking/screens/password_crack_time_screen.dart';
import 'package:cyber_lab/modules/password_cracking/screens/password_manager_screen.dart';
import 'package:cyber_lab/modules/password_cracking/password_overview_screen.dart';
import 'package:cyber_lab/modules/password_cracking/weak_passwords/details/password_weak_screen_old.dart';
import 'package:cyber_lab/modules/mfa/mfa_overview_screen.dart';
import 'package:cyber_lab/modules/mfa/mfa_types_screen.dart';
import 'package:cyber_lab/modules/mfa/authenticator_apps_screen.dart';
import 'package:cyber_lab/modules/mfa/sms_mfa_screen.dart';
import 'package:cyber_lab/modules/mfa/security_keys_screen.dart';
import 'package:cyber_lab/modules/mfa/mfa_cases_screen.dart';

// NEW: Attack Methods Overview (correct file)
import 'package:cyber_lab/modules/password_cracking/attack_methods/attack_methods_overview.dart';

// NEW encryption module importscode .
import 'package:cyber_lab/modules/encryption/encryption_overview_screen.dart';
import 'package:cyber_lab/modules/encryption/symmetric_encryption_screen.dart';
import 'package:cyber_lab/modules/encryption/asymmetric_encryption_screen.dart';
import 'package:cyber_lab/modules/encryption/https_screen.dart';
import 'package:cyber_lab/modules/encryption/hashing_vs_encryption_screen.dart';
import 'package:cyber_lab/modules/encryption/real_world_failures_screen.dart';
import 'package:cyber_lab/modules/encryption/encryption_demo_screen.dart';
import 'package:cyber_lab/modules/encryption/math_overview_screen.dart';
import 'package:cyber_lab/modules/encryption/real_world_crypto_failures_screen.dart';

//Phishing modules
import 'package:cyber_lab/modules/phishing/phishing_module_screen.dart';
import 'package:cyber_lab/modules/phishing/phishing_menu_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/example_delivery_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/example_invitation_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/example_invoice_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/example_password_reset_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/examples_gallery_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/header_analyzer_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/phishing_quiz_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/spot_red_flags_screen.dart';
import 'package:cyber_lab/modules/phishing/phishing_overview_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/malware_overview_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/malware_ransomware_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/malware_spyware_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/malware_trojans_screen.dart';
import 'package:cyber_lab/modules/phishing/screens/malware_protection_screen.dart';

//Social Engineering Modules
import 'package:cyber_lab/modules/SocialEngineering/social_engineering_overview_screen.dart';
import 'package:cyber_lab/modules/SocialEngineering/screens/social_tailgating_screen.dart';
import 'package:cyber_lab/modules/SocialEngineering/screens/social_pretexting_screen.dart';
import 'package:cyber_lab/modules/SocialEngineering/screens/social_defense_screen.dart';
import 'package:cyber_lab/modules/SocialEngineering/screens/social_deepfakes_screen.dart';
import 'package:cyber_lab/modules/SocialEngineering/screens/social_baiting_screen.dart';

//Networking Modules
import 'package:cyber_lab/modules/networking/networking_overview_screen.dart';
import 'package:cyber_lab/modules/networking/screens/networking_communication_screen.dart';
import 'package:cyber_lab/modules/networking/screens/networking_internet_screen.dart';
import 'package:cyber_lab/modules/networking/screens/networking_ip_screen.dart';
import 'package:cyber_lab/modules/networking/screens/networking_ports_screen.dart';
import 'package:cyber_lab/modules/networking/screens/networking_router_screen.dart';
import 'package:cyber_lab/modules/networking/screens/networking_safety_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/password':
        return MaterialPageRoute(
          builder: (_) => const PasswordOverviewScreen(),
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

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("404 — Page Not Found"))),
        );
    }
  }
}

import 'package:systems_studio/engine/models/module.dart';

const passwordModule = LearningModule(
  title: "Prevent Account Takeovers",
  goal:
      "Understand why passwords fail and how attackers use stolen credentials.",
  estimatedTime: "20 minutes",
  difficulty: "Beginner",
  scenario:
      "An attacker has downloaded a database containing millions of stolen usernames and passwords. You are the attacker. Which accounts would you try first, and why?",
  whyItMatters:
      "Password attacks are one of the most common ways accounts are compromised. Understanding credential theft, password reuse, and credential stuffing helps you recognize why strong passwords and multi-factor authentication matter.",
  lessons: [
    Lesson(title: "Introduction", route: "/password/intro", minutes: 5),
    Lesson(title: "Weak Passwords", route: "/weak_passwords", minutes: 8),
    Lesson(
      title: "Password Cracking",
      route: "/password_cracking",
      minutes: 10,
    ),
    Lesson(title: "Hashing & Salt", route: "/hashing_salt", minutes: 8),
    Lesson(title: "Famous Breaches", route: "/password_breaches", minutes: 8),
    Lesson(title: "Password Managers", route: "/password_managers", minutes: 6),
    Lesson(title: "Multi-Factor Authentication", route: "/mfa", minutes: 10),
    Lesson(title: "MFA Types", route: "/mfa_types", minutes: 6),
    Lesson(
      title: "Authenticator Apps",
      route: "/authenticator_apps",
      minutes: 6,
    ),
    Lesson(title: "SMS MFA", route: "/sms_mfa", minutes: 6),
    Lesson(title: "Security Keys", route: "/security_keys", minutes: 6),
    Lesson(title: "MFA Case Studies", route: "/mfa_cases", minutes: 8),
  ],
);

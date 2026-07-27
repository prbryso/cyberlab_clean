import 'package:systems_studio/engine/models/perspective.dart';

const passwordPerspectives = [
  Perspective(
    type: PerspectiveType.user,
    title: "User Perspective",
    description: "What normally happens when a user signs in.",
    steps: [
      "User enters username and password",
      "Authentication server checks the credentials",
      "If they match, access is granted",
    ],
  ),
  Perspective(
    type: PerspectiveType.attacker,
    title: "Attacker Perspective",
    description: "How stolen passwords can be reused against real accounts.",
    steps: [
      "Attacker obtains stolen credentials",
      "Automated tools try those credentials on many sites",
      "Password reuse creates successful logins",
      "The account is taken over",
    ],
  ),
  Perspective(
    type: PerspectiveType.defender,
    title: "Defender Perspective",
    description: "How defenses change the attack outcome.",
    steps: [
      "Use unique passwords for every account",
      "Store them in a password manager",
      "Require multi-factor authentication",
      "Credential stuffing is blocked",
    ],
  ),
];

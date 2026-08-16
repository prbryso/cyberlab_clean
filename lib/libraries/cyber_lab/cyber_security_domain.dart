import 'package:systems_studio/engine/education/educational_domain.dart';
import 'package:systems_studio/engine/education/learning_module.dart';

const String cyberSecurityDomainId = 'cybersecurity';

const cyberSecurityDomain = EducationalDomain(
  id: cyberSecurityDomainId,
  name: 'Cybersecurity',
  description:
      'Understand how digital systems are attacked, defended, and secured.',
  moduleIds: [
    'cybersecurity.password_security',
    'cybersecurity.encryption',
    'cybersecurity.phishing',
    'cybersecurity.social_engineering',
    'cybersecurity.networking',
    'cybersecurity.os_application_holes',
    'cybersecurity.exploits',
    'cybersecurity.zero_days',
    'cybersecurity.patch_management',
    'cybersecurity.system_hardening',
    'cybersecurity.secure_coding',
    'cybersecurity.capstone',
  ],
  tags: ['cybersecurity', 'security', 'digital safety'],
);

const passwordSecurityModule = LearningModule(
  id: 'cybersecurity.password_security',
  domainId: cyberSecurityDomainId,
  title: 'Prevent Account Takeovers',
  description:
      'Learn how attackers break weak passwords and reuse stolen credentials.',
  route: '/password',
  order: 1,
  estimatedMinutes: 20,
  difficulty: LearningDifficulty.beginner,
  tags: ['passwords', 'authentication', 'account security'],
);

const encryptionModule = LearningModule(
  id: 'cybersecurity.encryption',
  domainId: cyberSecurityDomainId,
  title: 'Protect Data with Encryption',
  description: 'Understand how encryption protects private information.',
  route: '/encryption',
  order: 2,
  estimatedMinutes: 25,
  difficulty: LearningDifficulty.beginner,
  tags: ['encryption', 'cryptography', 'data protection'],
);

const phishingModule = LearningModule(
  id: 'cybersecurity.phishing',
  domainId: cyberSecurityDomainId,
  title: 'Spot Phishing Attacks',
  description:
      'Recognize fake emails, malicious links, and credential theft attempts.',
  route: '/phishing',
  order: 3,
  estimatedMinutes: 20,
  difficulty: LearningDifficulty.beginner,
  tags: ['phishing', 'email security', 'credential theft'],
);

const socialEngineeringModule = LearningModule(
  id: 'cybersecurity.social_engineering',
  domainId: cyberSecurityDomainId,
  title: 'Defeat Social Engineering',
  description:
      'Learn how attackers manipulate people to bypass technical defenses.',
  route: '/social',
  order: 4,
  estimatedMinutes: 20,
  difficulty: LearningDifficulty.beginner,
  tags: ['social engineering', 'human behavior', 'manipulation'],
);

const networkingModule = LearningModule(
  id: 'cybersecurity.networking',
  domainId: cyberSecurityDomainId,
  title: 'Understand Networks',
  description:
      'See how systems communicate and where attackers look for weakness.',
  route: '/networking',
  order: 5,
  estimatedMinutes: 30,
  difficulty: LearningDifficulty.intermediate,
  tags: ['networking', 'communications', 'network security'],
);

const osApplicationHolesModule = LearningModule(
  id: 'cybersecurity.os_application_holes',
  domainId: cyberSecurityDomainId,
  title: 'OS and Application Holes',
  description: 'Learn how software and operating system flaws are exploited.',
  route: '/osappholes',
  order: 6,
  estimatedMinutes: 25,
  difficulty: LearningDifficulty.intermediate,
  tags: ['operating systems', 'applications', 'vulnerabilities'],
);

const exploitsModule = LearningModule(
  id: 'cybersecurity.exploits',
  domainId: cyberSecurityDomainId,
  title: 'Exploits',
  description: 'See how attackers turn vulnerabilities into real attacks.',
  route: '/exploits',
  order: 7,
  estimatedMinutes: 25,
  difficulty: LearningDifficulty.intermediate,
  tags: ['exploits', 'attacks', 'vulnerabilities'],
);

const zeroDaysModule = LearningModule(
  id: 'cybersecurity.zero_days',
  domainId: cyberSecurityDomainId,
  title: 'Zero-Days',
  description: 'Learn why unknown vulnerabilities are especially dangerous.',
  route: '/zero-days',
  order: 8,
  estimatedMinutes: 20,
  difficulty: LearningDifficulty.intermediate,
  tags: ['zero-day', 'unknown vulnerabilities', 'threats'],
);

const patchManagementModule = LearningModule(
  id: 'cybersecurity.patch_management',
  domainId: cyberSecurityDomainId,
  title: 'Patch Management',
  description: 'Fix vulnerabilities before attackers exploit them.',
  route: '/patch',
  order: 9,
  estimatedMinutes: 20,
  difficulty: LearningDifficulty.intermediate,
  tags: ['patching', 'updates', 'vulnerability management'],
);

const systemHardeningModule = LearningModule(
  id: 'cybersecurity.system_hardening',
  domainId: cyberSecurityDomainId,
  title: 'System Hardening',
  description: 'Reduce attack surface and lock systems down.',
  route: '/hardening',
  order: 10,
  estimatedMinutes: 25,
  difficulty: LearningDifficulty.intermediate,
  tags: ['hardening', 'attack surface', 'configuration'],
);

const secureCodingModule = LearningModule(
  id: 'cybersecurity.secure_coding',
  domainId: cyberSecurityDomainId,
  title: 'Secure Coding',
  description: 'Prevent vulnerabilities before software is released.',
  route: '/secure',
  order: 11,
  estimatedMinutes: 30,
  difficulty: LearningDifficulty.intermediate,
  tags: ['secure coding', 'software development', 'application security'],
);

const capstoneModule = LearningModule(
  id: 'cybersecurity.capstone',
  domainId: cyberSecurityDomainId,
  title: 'Capstone Challenge',
  description: 'Complete a full incident response simulation.',
  route: '/capstone',
  order: 12,
  estimatedMinutes: 45,
  difficulty: LearningDifficulty.advanced,
  tags: ['capstone', 'incident response', 'simulation'],
);

const List<LearningModule> cyberSecurityModules = [
  passwordSecurityModule,
  encryptionModule,
  phishingModule,
  socialEngineeringModule,
  networkingModule,
  osApplicationHolesModule,
  exploitsModule,
  zeroDaysModule,
  patchManagementModule,
  systemHardeningModule,
  secureCodingModule,
  capstoneModule,
];

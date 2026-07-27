import 'package:systems_studio/engine/models/system_model.dart';

const userAuthenticationSystem = SystemModel(
  id: 'authentication_user_view',
  name: 'Authentication System',
  description: 'A legitimate user requests access to a protected account.',
  inputs: [
    SystemEndpoint(
      id: 'user',
      label: 'User',
      type: SystemEndpointType.user,
      description: 'The person requesting access.',
    ),
  ],
  nodes: [
    SystemNode(
      id: 'enter_password',
      label: 'Enter Password',
      type: SystemNodeType.process,
      description:
          'The user enters a password or passphrase to prove identity.',
      purpose:
          'Collect credentials that will be verified by the authentication system.',
      risks: ['Weak passwords', 'Reused passwords', 'Shoulder surfing'],
      defenses: ['Strong passphrases', 'Password managers', 'Password masking'],
      relatedLessons: ['/weak-passwords', '/password-managers'],
    ),
    SystemNode(
      id: 'authentication_server',
      label: 'Authentication Server',
      type: SystemNodeType.component,
      isShared: true,
      description:
          'Central service responsible for validating user credentials.',
      purpose: 'Authenticate users and enforce organizational access policies.',
      risks: [
        'Credential stuffing',
        'Brute-force attacks',
        'Denial of service',
      ],
      defenses: [
        'Rate limiting',
        'Account lockout',
        'Password hashing',
        'Multi-factor authentication',
      ],
      relatedLessons: ['/password-cracking', '/hashing', '/mfa'],
    ),
  ],
  outputs: [
    SystemEndpoint(
      id: 'access_granted',
      label: 'Access Granted',
      type: SystemEndpointType.success,
    ),
  ],
  connections: [
    SystemConnection(fromId: 'user', toId: 'enter_password'),
    SystemConnection(fromId: 'enter_password', toId: 'authentication_server'),
    SystemConnection(fromId: 'authentication_server', toId: 'access_granted'),
  ],
);

const attackerAuthenticationSystem = SystemModel(
  id: 'authentication_attacker_view',
  name: 'Authentication System',
  description: 'An attacker attempts to misuse the same authentication system.',
  inputs: [
    SystemEndpoint(
      id: 'attacker',
      label: 'Attacker',
      type: SystemEndpointType.attacker,
      description: 'A person attempting unauthorized access.',
    ),
  ],
  nodes: [
    SystemNode(
      id: 'credential_stuffing',
      label: 'Credential Stuffing',
      type: SystemNodeType.process,
      description:
          'Automated testing of large collections of stolen usernames and passwords.',
      purpose: 'Exploit password reuse across multiple online services.',
      risks: ['Large-scale account compromise', 'Undetected automated attacks'],
      defenses: ['Rate limiting', 'MFA', 'Password breach detection'],
      relatedLessons: ['/password-breaches', '/mfa'],
    ),
    SystemNode(
      id: 'authentication_server',
      label: 'Authentication Server',
      type: SystemNodeType.component,
      isShared: true,
      description:
          'Receives login requests and determines whether access is allowed.',
      purpose:
          'Evaluate credentials against organizational authentication policy.',
      risks: [
        'Credential stuffing',
        'Brute-force attacks',
        'Service disruption',
      ],
      defenses: ['Account lockout', 'Rate limiting', 'Monitoring'],
      relatedLessons: ['/password-cracking', '/hashing', '/mfa'],
    ),
  ],
  outputs: [
    SystemEndpoint(
      id: 'account_takeover',
      label: 'Account Takeover',
      type: SystemEndpointType.failure,
    ),
  ],
  connections: [
    SystemConnection(fromId: 'attacker', toId: 'credential_stuffing'),
    SystemConnection(
      fromId: 'credential_stuffing',
      toId: 'authentication_server',
    ),
    SystemConnection(fromId: 'authentication_server', toId: 'account_takeover'),
  ],
);

const defenderAuthenticationSystem = SystemModel(
  id: 'authentication_defender_view',
  name: 'Authentication System',
  description: 'Defenses alter how the authentication system responds.',
  inputs: [
    SystemEndpoint(id: 'user', label: 'User', type: SystemEndpointType.user),
  ],
  nodes: [
    SystemNode(
      id: 'password_manager',
      label: 'Password Manager',
      type: SystemNodeType.defense,
      description:
          'Generates and stores strong, unique passwords for every account.',
      purpose: 'Reduce password reuse and eliminate weak passwords.',
      defenses: ['Strong random passwords', 'Secure storage'],
      relatedLessons: ['/password-managers'],
    ),
    SystemNode(
      id: 'authentication_server',
      label: 'Authentication Server',
      type: SystemNodeType.component,
      isShared: true,
      description: 'Processes credentials and applies authentication policy.',
      purpose: 'Provide secure access while resisting attacks.',
      risks: ['Credential attacks', 'Configuration errors'],
      defenses: ['Password hashing', 'Monitoring', 'Rate limiting', 'MFA'],
      relatedLessons: ['/hashing', '/mfa'],
    ),
    SystemNode(
      id: 'mfa',
      label: 'Multi-Factor Authentication',
      type: SystemNodeType.defense,
      description:
          'Requires an additional verification factor before access is granted.',
      purpose: 'Prevent account compromise even when a password is stolen.',
      defenses: ['Authenticator apps', 'Security keys', 'Biometrics'],
      relatedLessons: ['/mfa', '/security-keys'],
    ),
  ],
  outputs: [
    SystemEndpoint(
      id: 'access_granted',
      label: 'Access Granted',
      type: SystemEndpointType.success,
    ),
  ],
  connections: [
    SystemConnection(fromId: 'user', toId: 'password_manager'),
    SystemConnection(fromId: 'password_manager', toId: 'authentication_server'),
    SystemConnection(fromId: 'authentication_server', toId: 'mfa'),
    SystemConnection(fromId: 'mfa', toId: 'access_granted'),
  ],
);

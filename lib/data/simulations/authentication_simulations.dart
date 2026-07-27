import 'package:systems_studio/engine/models/system_simulation.dart';

const userAuthenticationSimulation = SystemSimulation(
  id: 'authentication_user_simulation',
  name: 'User Authentication',
  description: 'A legitimate user successfully authenticates to the system.',
  steps: [
    SimulationStep(
      title: 'Enter Password',
      nodeId: 'enter_password',
      narration:
          'The user enters their password to begin the authentication process.',
    ),
    SimulationStep(
      title: 'Credentials Sent',
      nodeId: 'authentication_server',
      fromNodeId: 'enter_password',
      toNodeId: 'authentication_server',
      type: SimulationStepType.connection,
      narration:
          'The credentials are securely transmitted to the authentication server.',
    ),
    SimulationStep(
      title: 'Verify Credentials',
      nodeId: 'authentication_server',
      narration:
          'The authentication server compares the submitted credentials against the stored account information.',
    ),
    SimulationStep(
      title: 'Access Granted',
      nodeId: 'authentication_server',
      type: SimulationStepType.success,
      narration: 'The credentials are valid and the user is granted access.',
    ),
  ],
);

const attackerAuthenticationSimulation = SystemSimulation(
  id: 'authentication_attacker_simulation',
  name: 'Credential Stuffing Attack',
  description:
      'An attacker attempts to compromise an account using previously stolen passwords.',
  steps: [
    SimulationStep(
      title: 'Credential Stuffing',
      nodeId: 'credential_stuffing',
      narration:
          'The attacker automatically submits thousands of stolen username and password combinations.',
      level: SimulationLevel.warning,
    ),
    SimulationStep(
      title: 'Authentication Requests',
      nodeId: 'authentication_server',
      fromNodeId: 'credential_stuffing',
      toNodeId: 'authentication_server',
      type: SimulationStepType.connection,
      narration:
          'Each credential pair is sent to the authentication server for validation.',
      level: SimulationLevel.warning,
    ),
    SimulationStep(
      title: 'Password Match',
      nodeId: 'authentication_server',
      narration: 'One of the stolen passwords matches the user account.',
      level: SimulationLevel.critical,
    ),
    SimulationStep(
      title: 'Account Takeover',
      nodeId: 'authentication_server',
      type: SimulationStepType.failure,
      narration:
          'The attacker successfully gains unauthorized access to the account.',
      level: SimulationLevel.critical,
    ),
  ],
);

const defenderAuthenticationSimulation = SystemSimulation(
  id: 'authentication_defender_simulation',
  name: 'Defended Authentication',
  description:
      'Security controls interrupt the attack before the account is compromised.',
  steps: [
    SimulationStep(
      title: 'Strong Password',
      nodeId: 'password_manager',
      narration:
          'The password manager creates and stores a strong, unique password.',
    ),
    SimulationStep(
      title: 'Authentication',
      nodeId: 'authentication_server',
      fromNodeId: 'password_manager',
      toNodeId: 'authentication_server',
      type: SimulationStepType.connection,
      narration:
          'The authentication server validates the submitted credentials.',
    ),
    SimulationStep(
      title: 'Multi-Factor Authentication',
      nodeId: 'mfa',
      narration:
          'A second authentication factor is required before access is granted.',
    ),
    SimulationStep(
      title: 'Attack Blocked',
      nodeId: 'mfa',
      type: SimulationStepType.success,
      narration:
          'Even if a password is stolen, the attacker cannot complete authentication without the second factor.',
    ),
  ],
);

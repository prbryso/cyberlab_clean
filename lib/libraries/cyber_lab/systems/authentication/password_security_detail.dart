import 'package:flutter/material.dart';

import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_behavior_definition.dart';
import 'package:systems_studio/engine/models/studio_condition.dart';
import 'package:systems_studio/engine/models/studio_effect.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_event_type.dart';
import 'package:systems_studio/engine/models/studio_outcome.dart';
import 'package:systems_studio/engine/models/studio_facets.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_scenario.dart';
import 'package:systems_studio/engine/models/studio_state_variable.dart';
import 'package:systems_studio/engine/models/studio_subsystem.dart';
import 'package:systems_studio/engine/models/studio_system_detail.dart';

/// Not const: the authored scenario names its initial actors as a Set of
/// [StudioElementRef], which defines its own equality and so cannot be an
/// element of a const Set. The detail is built once at startup and never
/// mutated, so nothing depends on its constness.
final passwordSecurityDetail = StudioSystemDetail(
  systemId: 'cybersecurity.password_security',
  summary:
      'Explore how users, credentials, identity services, attackers, and defensive controls interact to protect accounts.',
  purpose:
      'Verify identity while limiting unauthorized access, credential theft, account takeover, and recovery abuse.',
  // Events are not restated in prose anywhere below. Typed StudioEventType
  // declarations and the behaviours that emit and react to them are
  // authoritative; the learner-facing view is derived from them, rolled up
  // through the hierarchy. Prose alongside would be a second source of the
  // same truth, in different words, that nothing could validate.
  facets: StudioNodeFacets(
    actions: StudioFacet.known([
      'Accept an identity claim',
      'Evaluate authentication evidence',
      'Grant or deny access',
      'Challenge with an additional factor',
      'Lock an account',
      'Restore access through recovery',
    ]),
    goals: StudioFacet.known([
      'Admit the legitimate account holder',
      'Refuse everyone else',
      'Stay available to the people who depend on it',
    ]),
    observationCapabilities: StudioFacet.known([
      'Authentication attempts and their outcomes',
      'Device and network context of an attempt',
      'Rate and distribution of failures',
    ]),
  ),
  guidingQuestions: [
    'What does the authentication system actually trust?',
    'Where do credentials travel and where are they stored?',
    'How can an attacker bypass or misuse normal authentication flows?',
    'Which controls prevent, detect, or limit account takeover?',
    'What happens when the user loses access to a trusted factor?',
  ],
  actors: [
    StudioActor(
      id: 'user',
      name: 'User',
      description:
          'The person attempting to access an account or protected service.',
      icon: Icons.person_outline,
      facets: StudioNodeFacets(
        goals: StudioFacet.known([
          'Access the correct account',
          'Use convenient authentication',
          'Recover access when credentials are lost',
        ]),
        actions: StudioFacet.known([
          'Enter credentials',
          'Approve or reject MFA requests',
          'Use account recovery',
          'Change passwords',
        ]),
        observationCapabilities: StudioFacet.known([
          'Whether a login attempt succeeded or failed',
          'Unexpected MFA prompts they did not initiate',
          'Notification that a password was changed',
        ]),
        // A user notices things but does not report structured events into
        // the system. Whether user-reported suspicion should be modelled as
        // an event type is an open question.
        eventTypes: StudioFacet.unknown(),
      ),
    ),
    StudioActor(
      id: 'attacker',
      name: 'Attacker',
      description:
          'A person or automated system attempting to gain unauthorized access.',
      icon: Icons.warning_amber_outlined,
      facets: StudioNodeFacets(
        goals: StudioFacet.known([
          'Steal or guess credentials',
          'Bypass MFA',
          'Take control of an account',
          'Avoid detection',
        ]),
        actions: StudioFacet.known([
          'Perform phishing',
          'Try credential stuffing',
          'Guess passwords',
          'Abuse recovery workflows',
        ]),
        observationCapabilities: StudioFacet.known([
          'Whether an individual attempt succeeded or failed',
          'Whether an account appears locked',
          'Whether an additional factor was demanded',
        ]),
        // The attacker causes events but does not publish them. Modelling the
        // traces an attacker leaves is a separate question from what they
        // deliberately report.
        eventTypes: StudioFacet.notApplicable(),
      ),
    ),
    StudioActor(
      id: 'administrator',
      name: 'Administrator',
      description:
          'The person or team responsible for configuring and monitoring authentication controls.',
      icon: Icons.admin_panel_settings_outlined,
      facets: StudioNodeFacets(
        goals: StudioFacet.known([
          'Reduce unauthorized access',
          'Maintain account availability',
          'Detect suspicious activity',
        ]),
        actions: StudioFacet.known([
          'Set authentication policy',
          'Review alerts',
          'Reset accounts',
          'Configure MFA and lockout controls',
        ]),
        observationCapabilities: StudioFacet.known([
          'Security alerts raised by monitoring',
          'Authentication logs and failure patterns',
          'Lockout and recovery activity',
        ]),
        eventTypes: StudioFacet.known([
          'Policy changed',
          'Account manually reset',
          'Account manually locked',
        ]),
      ),
    ),
  ],
  assets: [
    StudioAsset(
      id: 'user_account',
      name: 'User Account',
      description:
          'The identity, access rights, and services associated with a user.',
      icon: Icons.account_circle_outlined,
      protectionGoals: ['Confidentiality', 'Integrity', 'Availability'],
      // An account is acted upon; it does not act, and it pursues nothing of
      // its own. Its states are worth watching, but it watches nothing.
      facets: StudioNodeFacets(
        actions: StudioFacet.notApplicable(),
        goals: StudioFacet.notApplicable(),
        observationCapabilities: StudioFacet.notApplicable(),
        eventTypes: StudioFacet.known([
          'Account taken over',
          'Account locked out of legitimate use',
        ]),
      ),
    ),
    StudioAsset(
      id: 'credentials',
      name: 'Credentials',
      description:
          'Passwords, passkeys, tokens, codes, and other proof of identity.',
      icon: Icons.key_outlined,
      protectionGoals: ['Confidentiality', 'Integrity'],
      facets: StudioNodeFacets(
        actions: StudioFacet.notApplicable(),
        goals: StudioFacet.notApplicable(),
        observationCapabilities: StudioFacet.notApplicable(),
        // Whether a credential should be treated as something that can be
        // "known compromised" — and by whom — is genuinely open.
        eventTypes: StudioFacet.unknown(),
      ),
    ),
    StudioAsset(
      id: 'authentication_records',
      name: 'Authentication Records',
      description:
          'Logs, alerts, recovery records, and evidence of authentication activity.',
      icon: Icons.receipt_long_outlined,
      protectionGoals: ['Integrity', 'Availability'],
      facets: StudioNodeFacets(
        actions: StudioFacet.notApplicable(),
        goals: StudioFacet.notApplicable(),
        observationCapabilities: StudioFacet.notApplicable(),
        eventTypes: StudioFacet.known([
          'Record tampered with',
          'Record unavailable when needed',
        ]),
      ),
    ),
  ],
  boundaries: [
    'User-controlled device',
    'Identity service boundary',
    'Credential storage boundary',
    'External network',
    'Account recovery process',
  ],
  inputs: [
    'Username or account identifier',
    'Password, passkey, or authentication factor',
    'Device and network context',
    'Recovery request',
    'Authentication policy',
  ],
  outputs: [
    'Access granted',
    'Access denied',
    'MFA challenge',
    'Account lockout',
    'Security alert',
    'Recovery action',
  ],
  subsystems: [
    StudioSubsystem(
      id: 'credential_entry',
      name: 'Credential Entry',
      description:
          'Collects authentication information from the user or device.',
      icon: Icons.login_outlined,
      purpose:
          'Gather identity claims and authentication factors for evaluation.',
      facets: StudioNodeFacets(
        actions: StudioFacet.known([
          'Collect an identity claim',
          'Collect an authentication factor',
          'Transmit an authentication request',
        ]),
        goals: StudioFacet.known([
          'Capture what the user offers without altering it',
          'Reveal nothing extra to an onlooker',
        ]),
        observationCapabilities: StudioFacet.known([
          'Whether input was submitted',
          'Which device and interface was used',
        ]),
      ),
      components: [
        StudioComponent(
          id: 'login_interface',
          name: 'Login Interface',
          description:
              'The application or web page where authentication begins.',
          icon: Icons.web_outlined,
          componentType: StudioComponentType.software,
          responsibilities: [
            'Collect account identifier',
            'Collect authentication factors',
            'Display authentication results',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Accept typed or stored credentials',
              'Submit an authentication request',
              'Show the result of an attempt',
            ]),
            // The login page serves the identity service's goal; it holds no
            // goal of its own.
            goals: StudioFacet.notApplicable(),
            observationCapabilities: StudioFacet.known([
              'What the user submitted',
              'The response returned to the user',
            ]),
          ),
        ),
        StudioComponent(
          id: 'user_device',
          name: 'User Device',
          description:
              'The computer, phone, or other endpoint used to authenticate.',
          icon: Icons.devices_outlined,
          componentType: StudioComponentType.hardware,
          responsibilities: [
            'Present the login interface',
            'Store device credentials or passkeys',
            'Exchange authentication data',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Hold a stored credential or passkey',
              'Prove possession of a factor',
            ]),
            goals: StudioFacet.notApplicable(),
            // A device can in principle observe a great deal. What this model
            // should credit it with observing is not yet decided.
            observationCapabilities: StudioFacet.unknown(),
            eventTypes: StudioFacet.unknown(),
          ),
        ),
      ],
    ),
    StudioSubsystem(
      id: 'identity_service',
      name: 'Identity Service',
      description:
          'Evaluates authentication evidence and decides whether access should be granted.',
      icon: Icons.verified_user_outlined,
      purpose: 'Verify identity claims and apply authentication policy.',
      facets: StudioNodeFacets(
        actions: StudioFacet.known([
          'Verify an authentication factor',
          'Apply authentication policy',
          'Issue or refuse access',
          'Demand an additional factor',
        ]),
        goals: StudioFacet.known([
          'Decide correctly on every attempt',
          'Fail closed rather than open',
        ]),
        observationCapabilities: StudioFacet.known([
          'Credential validity',
          'Attempt frequency per account',
          'Whether an additional factor was satisfied',
        ]),
      ),
      components: [
        StudioComponent(
          id: 'authentication_engine',
          name: 'Authentication Engine',
          description:
              'Processes credentials, factors, policy, and risk signals.',
          icon: Icons.settings_suggest_outlined,
          componentType: StudioComponentType.service,
          responsibilities: [
            'Validate credentials',
            'Apply lockout policy',
            'Request MFA',
            'Return an authentication decision',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Compare a submitted credential against stored proof',
              'Count consecutive failures',
              'Demand an additional factor',
              'Grant, deny, or lock',
            ]),
            goals: StudioFacet.known([
              'Admit only the account holder',
              'Refuse without leaking why',
            ]),
            observationCapabilities: StudioFacet.known([
              'Credential validity',
              'Consecutive failure count per account',
              'Origin and timing of each attempt',
            ]),
          ),
        ),
        StudioComponent(
          id: 'credential_store',
          name: 'Credential Store',
          description:
              'Stores password hashes, public keys, recovery data, and related records.',
          icon: Icons.storage_outlined,
          componentType: StudioComponentType.database,
          responsibilities: [
            'Store credential verifiers',
            'Protect authentication secrets',
            'Support credential changes',
          ],
          // Mirrors the Credential Store row in PRODUCT_PRINCIPLES.md:
          // Actions defined, Goals maybe, Observations none, Events defined.
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Return a stored verifier',
              'Accept a replacement verifier',
            ]),
            // Whether a passive store should be credited with a goal of its
            // own, or only inherit the identity service's, is unresolved.
            goals: StudioFacet.unknown(),
            observationCapabilities: StudioFacet.notApplicable(),
            eventTypes: StudioFacet.known([
              'Store contents exposed',
              'Verifier changed',
            ]),
          ),
        ),
        StudioComponent(
          id: 'mfa_service',
          name: 'MFA Service',
          description:
              'Provides additional authentication challenges beyond the primary credential.',
          icon: Icons.phonelink_lock_outlined,
          componentType: StudioComponentType.service,
          responsibilities: [
            'Generate or validate second factors',
            'Send authentication prompts',
            'Record MFA results',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Issue a challenge',
              'Validate a response',
              'Send a prompt to a registered device',
            ]),
            goals: StudioFacet.known([
              'Confirm possession of a second factor',
            ]),
            observationCapabilities: StudioFacet.known([
              'Whether a challenge was answered',
              'How long the response took',
            ]),
            eventTypes: StudioFacet.known([
              'Challenge approved',
              'Challenge denied',
              'Challenge ignored',
            ]),
          ),
        ),
      ],
    ),
    StudioSubsystem(
      id: 'monitoring_and_recovery',
      name: 'Monitoring and Recovery',
      description:
          'Detects suspicious behavior and helps legitimate users regain access.',
      icon: Icons.health_and_safety_outlined,
      purpose:
          'Detect misuse, support investigation, and restore access safely.',
      facets: StudioNodeFacets(
        actions: StudioFacet.known([
          'Raise an alert',
          'Record authentication activity',
          'Restore access to a verified user',
        ]),
        goals: StudioFacet.known([
          'Notice misuse before damage spreads',
          'Return legitimate users to their accounts',
        ]),
        observationCapabilities: StudioFacet.known([
          'Authentication outcomes across accounts',
          'Unusual timing, volume, or origin',
          'Recovery requests',
        ]),
      ),
      components: [
        StudioComponent(
          id: 'security_monitoring',
          name: 'Security Monitoring',
          description:
              'Collects authentication events and identifies suspicious patterns.',
          icon: Icons.monitor_heart_outlined,
          componentType: StudioComponentType.service,
          responsibilities: [
            'Record authentication events',
            'Detect repeated failures',
            'Identify unusual devices or locations',
            'Generate alerts',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Record an authentication event',
              'Correlate events across accounts',
              'Raise an alert',
            ]),
            goals: StudioFacet.known([
              'Notice misuse that individual attempts do not reveal',
            ]),
            observationCapabilities: StudioFacet.known([
              'Every authentication outcome reaching it',
              'Repeated failures against one account',
              'One credential tried across many accounts',
              'Logins from unusual devices or locations',
            ]),
          ),
        ),
        StudioComponent(
          id: 'account_recovery',
          name: 'Account Recovery',
          description:
              'Restores access when a legitimate user loses credentials or factors.',
          icon: Icons.restore_outlined,
          componentType: StudioComponentType.procedure,
          responsibilities: [
            'Verify recovery requests',
            'Reset authentication factors',
            'Prevent recovery abuse',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Verify a recovery claim',
              'Reset an authentication factor',
              'Refuse a recovery request',
            ]),
            goals: StudioFacet.known([
              'Return access to the real account holder',
              'Give nothing to anyone else',
            ]),
            observationCapabilities: StudioFacet.known([
              'Evidence supplied with a recovery request',
              'How often recovery is attempted for one account',
            ]),
            eventTypes: StudioFacet.known([
              'Recovery completed',
              'Recovery refused',
            ]),
          ),
        ),
      ],
    ),
  ],
  stateVariables: [
    StudioStateVariable(
      id: 'authentication_engine.mode',
      name: 'Mode',
      owner: StudioElementRef.node('authentication_engine'),
      description:
          'What the engine is currently doing about authentication requests.',
      domain: ['Ready', 'Evaluating', 'Challenging', 'Locked', 'Degraded'],
      initialValue: 'Ready',
    ),
    StudioStateVariable(
      id: 'credential_store.integrity',
      name: 'Integrity',
      owner: StudioElementRef.node('credential_store'),
      description:
          'Whether stored verifiers can still be trusted and reached.',
      domain: ['Available', 'Unavailable', 'Compromised', 'Read-only'],
      initialValue: 'Available',
    ),
    StudioStateVariable(
      id: 'user_account.access',
      name: 'Access',
      owner: StudioElementRef.node('user_account'),
      description: 'Who can currently reach the account.',
      domain: ['Active', 'Locked', 'Compromised', 'Recovering'],
      initialValue: 'Active',
    ),
    StudioStateVariable(
      id: 'login_interface.stage',
      name: 'Stage',
      owner: StudioElementRef.node('login_interface'),
      description: 'Where the login exchange has reached.',
      domain: [
        'Idle',
        'Collecting credentials',
        'Waiting for response',
        'Access granted',
        'Access denied',
      ],
      initialValue: 'Idle',
    ),
    StudioStateVariable(
      id: 'user_device.trust',
      name: 'Trust',
      owner: StudioElementRef.node('user_device'),
      description: 'How much the system is willing to believe this device.',
      domain: ['Trusted', 'Untrusted', 'Compromised', 'Offline'],
      // A device starts unproven. Trust is earned during a run, not assumed.
      initialValue: 'Untrusted',
    ),
    StudioStateVariable(
      id: 'security_monitoring.signal',
      name: 'Signal',
      owner: StudioElementRef.node('security_monitoring'),
      description:
          'How loudly monitoring is currently reporting authentication '
          'behaviour.',
      // Symbolic rather than a count: the condition language compares values,
      // it does not do arithmetic, and a systems learner cares about the
      // change in posture rather than the exact number of failures.
      domain: ['Quiet', 'Elevated', 'Alerting'],
      initialValue: 'Quiet',
    ),
    StudioStateVariable(
      id: 'mfa_service.challenge',
      name: 'Challenge',
      owner: StudioElementRef.node('mfa_service'),
      description: 'The state of the current additional-factor challenge.',
      domain: [
        'Available',
        'Waiting for response',
        'Approved',
        'Denied',
        'Unavailable',
      ],
      initialValue: 'Available',
    ),
  ],
  // --- Dynamics -------------------------------------------------------
  //
  // A deliberately small demonstration: one attacker action, two automatic
  // behaviours, and the chain that connects them. It exists to prove the
  // architecture, not to model authentication exhaustively.
  eventTypes: [
    StudioEventType(
      id: 'authentication_attempted',
      name: 'Authentication attempted',
      description: 'Someone offered credentials to the login interface.',
      declaredBy: StudioElementRef.node('login_interface'),
    ),
    StudioEventType(
      id: 'authentication_succeeded',
      name: 'Authentication succeeded',
      description: 'The engine accepted the evidence it was given.',
      declaredBy: StudioElementRef.node('authentication_engine'),
    ),
    StudioEventType(
      id: 'authentication_failed',
      name: 'Authentication failed',
      description: 'The engine refused the evidence it was given.',
      declaredBy: StudioElementRef.node('authentication_engine'),
    ),
    StudioEventType(
      id: 'mfa_challenge_required',
      name: 'Additional factor required',
      description:
          'The offered credentials were accepted, and authentication is not '
          'finished: a second factor still has to answer.',
      declaredBy: StudioElementRef.node('authentication_engine'),
    ),
    StudioEventType(
      id: 'mfa_challenge_answered',
      name: 'Additional factor answered',
      description:
          'The service that holds the second factor has produced a result. '
          'What that result is lives in the service\'s own challenge state, '
          'and what it means for the authentication is the engine\'s to '
          'decide.',
      declaredBy: StudioElementRef.node('mfa_service'),
    ),
    StudioEventType(
      id: 'security_alert_raised',
      name: 'Security alert raised',
      description: 'Monitoring reported authentication behaviour worth '
          'someone looking at.',
      declaredBy: StudioElementRef.node('security_monitoring'),
    ),
  ],
  actionDefinitions: [
    StudioActionDefinition(
      id: 'attacker.attempt_authentication',
      name: 'Attempt authentication',
      description:
          'Offer a credential to the login interface and see what comes back.',
      initiator: StudioElementRef.node('attacker'),
      target: StudioElementRef.node('login_interface'),
      // Availability only. A locked account gives the attacker nothing to
      // push against.
      precondition: StudioStateNotEquals(
        variableId: 'user_account.access',
        value: 'Locked',
      ),
      outcomes: [
        StudioOutcome(
          condition: StudioStateEquals(
            variableId: 'login_interface.stage',
            value: 'Idle',
          ),
          effects: [
            StudioAssignState(
              variableId: 'login_interface.stage',
              value: 'Collecting credentials',
            ),
          ],
          emits: ['authentication_attempted'],
          explanation:
              'The login interface was idle, so it took the credential and '
              'passed the attempt on to be evaluated.',
          guidingQuestion:
              'What has the system learned about who is at the keyboard?',
        ),
      ],
      otherwise: StudioOutcome.otherwise(
        explanation:
            'The login interface was already mid-exchange, so this attempt '
            'went nowhere.',
      ),
    ),
    StudioActionDefinition(
      id: 'administrator.lock_account',
      name: 'Lock the account',
      description:
          'Stop further authentication attempts against this account while '
          'the situation is understood.',
      initiator: StudioElementRef.node('administrator'),
      target: StudioElementRef.node('user_account'),
      precondition: StudioStateNotEquals(
        variableId: 'user_account.access',
        value: 'Locked',
      ),
      outcomes: [
        StudioOutcome(
          condition: StudioStateNotEquals(
            variableId: 'user_account.access',
            value: 'Locked',
          ),
          effects: [
            StudioAssignState(
              variableId: 'user_account.access',
              value: 'Locked',
            ),
          ],
          explanation:
              'The administrator closed the account to further attempts.',
          guidingQuestion:
              'This stops the attacker. Who else does it stop?',
        ),
      ],
      otherwise: StudioOutcome.otherwise(
        explanation: 'The account was already locked.',
      ),
    ),
  ],
  behaviorDefinitions: [
    StudioBehaviorDefinition(
      id: 'authentication_engine.evaluate_attempt',
      name: 'Evaluate authentication attempt',
      description:
          'Compare the offered evidence against what is stored and decide.',
      owner: StudioElementRef.node('authentication_engine'),
      trigger: 'authentication_attempted',
      // A locked or degraded engine does not evaluate.
      condition: StudioStateEquals(
        variableId: 'authentication_engine.mode',
        value: 'Ready',
      ),
      outcomes: [
        StudioOutcome(
          // The offered evidence passes. Only reachable once something has
          // compromised the store, which nothing in this demonstration does
          // yet — it is what a scenario sets up to explore the other branch.
          condition: StudioStateEquals(
            variableId: 'credential_store.integrity',
            value: 'Compromised',
          ),
          effects: [
            // Passing the password is not being let in. The engine is now
            // mid-authentication, waiting on a second factor, and the account
            // is untouched until that answers.
            StudioAssignState(
              variableId: 'authentication_engine.mode',
              value: 'Challenging',
            ),
            StudioAssignState(
              variableId: 'login_interface.stage',
              value: 'Waiting for response',
            ),
          ],
          emits: ['mfa_challenge_required'],
          explanation:
              'The stored verifier could no longer be trusted, so the engine '
              'accepted the evidence — and asked for a second factor before '
              'letting anyone in.',
          guidingQuestion:
              'The password is no longer the only thing standing in the way. '
              'What is?',
        ),
      ],
      otherwise: StudioOutcome.otherwise(
        effects: [
          StudioAssignState(
            variableId: 'login_interface.stage',
            value: 'Access denied',
          ),
        ],
        emits: ['authentication_failed'],
        explanation:
            'The evidence did not match, so the engine refused the attempt.',
        guidingQuestion:
            'A refusal protects the account. What does it also reveal?',
      ),
    ),
    StudioBehaviorDefinition(
      id: 'mfa_service.answer_challenge',
      name: 'Answer the additional-factor challenge',
      description:
          'Decide whether the second factor is satisfied, and report that '
          'back.',
      owner: StudioElementRef.node('mfa_service'),
      trigger: 'mfa_challenge_required',
      // The service can only answer a challenge it is able to receive, which
      // is what the command channel from the engine is for. No other event
      // travels that channel, so nothing else can put MFA into this position.
      //
      // What it does with the answer is narrow on purpose. This service
      // validates a factor; it does not decide an authentication, and it does
      // not reach into the state of the engine that asked it. It records its
      // own result and says so.
      outcomes: [
        StudioOutcome(
          // A device the system already trusts satisfies the second factor.
          // Deterministic and authored: nothing here is guessed, and nobody
          // types a code.
          condition: StudioStateEquals(
            variableId: 'user_device.trust',
            value: 'Trusted',
          ),
          effects: [
            StudioAssignState(
              variableId: 'mfa_service.challenge',
              value: 'Approved',
            ),
          ],
          emits: ['mfa_challenge_answered'],
          explanation:
              'The device presenting the factor was one the system already '
              'trusts, so the challenge was satisfied.',
        ),
      ],
      otherwise: StudioOutcome.otherwise(
        effects: [
          StudioAssignState(
            variableId: 'mfa_service.challenge',
            value: 'Denied',
          ),
        ],
        emits: ['mfa_challenge_answered'],
        explanation:
            'Nothing satisfied the challenge, so the service refused it.',
      ),
    ),
    StudioBehaviorDefinition(
      id: 'authentication_engine.complete_authentication',
      name: 'Complete the authentication',
      description:
          'Take the second-factor result and return the authentication '
          'decision.',
      owner: StudioElementRef.node('authentication_engine'),
      trigger: 'mfa_challenge_answered',
      // Only an engine that is waiting on a factor has an authentication to
      // complete. Anything else hearing this answer has nothing to do with it.
      condition: StudioStateEquals(
        variableId: 'authentication_engine.mode',
        value: 'Challenging',
      ),
      outcomes: [
        StudioOutcome(
          // The engine reads the service's result rather than being told what
          // to conclude from it. Deciding is the engine's job.
          condition: StudioStateEquals(
            variableId: 'mfa_service.challenge',
            value: 'Approved',
          ),
          effects: [
            StudioAssignState(
              variableId: 'authentication_engine.mode',
              value: 'Ready',
            ),
            StudioAssignState(
              variableId: 'login_interface.stage',
              value: 'Access granted',
            ),
            StudioAssignState(
              variableId: 'user_account.access',
              value: 'Compromised',
            ),
          ],
          emits: ['authentication_succeeded'],
          explanation:
              'Both factors were satisfied, so the engine completed the '
              'authentication and let the attempt through.',
          guidingQuestion:
              'A stolen password was not enough on its own. What made it '
              'enough here?',
        ),
      ],
      otherwise: StudioOutcome.otherwise(
        effects: [
          StudioAssignState(
            variableId: 'authentication_engine.mode',
            value: 'Ready',
          ),
          StudioAssignState(
            variableId: 'login_interface.stage',
            value: 'Access denied',
          ),
        ],
        emits: ['authentication_failed'],
        explanation:
            'The second factor was not satisfied, so the engine refused the '
            'attempt even though the password had been accepted.',
        guidingQuestion:
            'The password was right and the account is still safe. What did '
            'the work?',
      ),
    ),
    StudioBehaviorDefinition(
      id: 'security_monitoring.notice_failure',
      name: 'Notice a failed authentication',
      description:
          'Watch refusals and decide whether they are worth reporting.',
      owner: StudioElementRef.node('security_monitoring'),
      trigger: 'authentication_failed',
      outcomes: [
        StudioOutcome(
          condition: StudioStateNotEquals(
            variableId: 'security_monitoring.signal',
            value: 'Alerting',
          ),
          effects: [
            StudioAssignState(
              variableId: 'security_monitoring.signal',
              value: 'Alerting',
            ),
          ],
          emits: ['security_alert_raised'],
          explanation:
              'Monitoring saw the refusal and raised an alert.',
          guidingQuestion:
              'The alert now exists. Who, if anyone, is in a position to see '
              'it?',
        ),
      ],
      otherwise: StudioOutcome.otherwise(
        explanation:
            'Monitoring is already alerting, so a further refusal adds '
            'nothing new to report.',
      ),
    ),
  ],
  scenarios: [
    StudioScenario(
      id: 'attempted_account_takeover',
      name: 'Attempted Account Takeover',
      description:
          'An attacker tries to get into an account that is not theirs. '
          'Everything else about the system starts as declared — what '
          'happens next is up to whoever acts.',
      initialActors: {StudioElementRef.node('attacker')},
      // No state overrides. The declared starting values already describe a
      // system at rest with nobody logged in and nothing yet detected, which
      // is exactly where this situation begins. Restating them here would
      // duplicate the system's own declarations and let the two drift apart.
    ),
    StudioScenario(
      id: 'compromised_credential_store',
      name: 'Compromised Credential Store',
      // Describes where things stand, not what follows from it. What happens
      // is still decided by whoever acts.
      description:
          'The stored verifiers can no longer be trusted, and the device in '
          'use is one the system already recognises. Everything else starts '
          'as declared.',
      initialActors: {StudioElementRef.node('attacker')},
      initialStateOverrides: {
        // The store can no longer tell genuine evidence from forged, so the
        // engine has nothing left to refuse on. This is the only condition
        // in the system that reads this variable, and no action or behaviour
        // can reach this value — a situation is the only way to establish it.
        'credential_store.integrity': 'Compromised',
        // A device the system already recognises. Declared rather than left
        // at its default because the default leads to a refusal that nothing
        // in this system is able to observe, and a situation should not be
        // built around a silence.
        'user_device.trust': 'Trusted',
      },
    ),
    StudioScenario(
      id: 'compromised_store_unrecognised_device',
      name: 'Compromised Credential Store — Unrecognised Device',
      // Differs from the situation above in one fact. Which fact that is, and
      // what follows from it, is the learner's to find.
      description:
          'The stored verifiers can no longer be trusted, and the device in '
          'use is one the system does not recognise. Everything else starts '
          'as declared.',
      initialActors: {StudioElementRef.node('attacker')},
      initialStateOverrides: {
        'credential_store.integrity': 'Compromised',
        // The same value the system declares, stated anyway. This situation
        // depends on it — it is what the second factor is judged against —
        // and inheriting a dependency silently would leave the situation
        // true by luck. Stating it also puts the one fact that separates this
        // from the situation above in front of the learner, rather than
        // leaving them to notice an absence.
        'user_device.trust': 'Untrusted',
      },
    ),
  ],
  relationships: [
    StudioRelationship(
      id: 'user_uses_login_interface',
      sourceId: 'user',
      targetId: 'login_interface',
      type: StudioRelationshipType.interactsWith,
      label: 'uses',
      description:
          'The user submits identity and authentication information through the login interface.',
    ),
    StudioRelationship(
      id: 'login_interface_sends_to_engine',
      sourceId: 'login_interface',
      targetId: 'authentication_engine',
      type: StudioRelationshipType.sendsDataTo,
      label: 'sends authentication request',
    ),
    StudioRelationship(
      id: 'engine_verifies_store',
      sourceId: 'authentication_engine',
      targetId: 'credential_store',
      type: StudioRelationshipType.verifies,
      label: 'verifies credentials against',
    ),
    StudioRelationship(
      id: 'engine_requests_mfa',
      sourceId: 'authentication_engine',
      targetId: 'mfa_service',
      type: StudioRelationshipType.sendsCommandTo,
      label: 'requests challenge from',
      // A command channel, not a feed. The engine can ask this service for a
      // second factor; that is not a reason for the service to be told about
      // every refusal the engine ever issues.
      carriedEventTypeIds: ['mfa_challenge_required'],
    ),
    StudioRelationship(
      id: 'mfa_reports_to_engine',
      sourceId: 'mfa_service',
      targetId: 'authentication_engine',
      type: StudioRelationshipType.sendsDataTo,
      label: 'returns factor result to',
      description:
          'The answer to a challenge goes back to whoever asked for it. A '
          'separate path from the request, because asking and answering are '
          'different things and each carries only its own.',
      carriedEventTypeIds: ['mfa_challenge_answered'],
    ),
    StudioRelationship(
      id: 'engine_protects_account',
      sourceId: 'authentication_engine',
      targetId: 'user_account',
      type: StudioRelationshipType.protects,
      label: 'controls access to',
      strength: StudioRelationshipStrength.critical,
    ),
    StudioRelationship(
      id: 'credential_store_stores_credentials',
      sourceId: 'credential_store',
      targetId: 'credentials',
      type: StudioRelationshipType.stores,
      label: 'stores',
      strength: StudioRelationshipStrength.critical,
    ),
    StudioRelationship(
      id: 'monitoring_monitors_engine',
      sourceId: 'security_monitoring',
      targetId: 'authentication_engine',
      type: StudioRelationshipType.monitors,
      label: 'monitors',
    ),
    StudioRelationship(
      id: 'monitoring_notifies_administrator',
      sourceId: 'security_monitoring',
      targetId: 'administrator',
      type: StudioRelationshipType.notifies,
      label: 'raises alerts to',
      description:
          'Monitoring delivers its alerts to whoever is responsible for '
          'acting on them. Without this edge the alert still exists, and '
          'nobody hears it.',
      // Alerts, not everything monitoring ever notices. Being the person who
      // gets told about incidents is not the same as watching the feed.
      carriedEventTypeIds: ['security_alert_raised'],
    ),
    StudioRelationship(
      id: 'recovery_affects_account',
      sourceId: 'account_recovery',
      targetId: 'user_account',
      type: StudioRelationshipType.recovers,
      label: 'restores access to',
    ),
    StudioRelationship(
      id: 'attacker_threatens_credentials',
      sourceId: 'attacker',
      targetId: 'credentials',
      type: StudioRelationshipType.threatens,
      label: 'targets',
      strength: StudioRelationshipStrength.critical,
    ),
  ],
  failureModes: [
    StudioFailureMode(
      id: 'weak_password_failure',
      title: 'Weak or Reused Password',
      description:
          'The credential can be guessed, cracked, or reused from another breach.',
      causes: [
        'Short password',
        'Common password',
        'Password reuse',
        'Poor password storage',
      ],
      effects: [
        'Unauthorized access',
        'Account takeover',
        'Credential reuse across services',
      ],
      controls: [
        'Long unique passwords',
        'Password managers',
        'MFA',
        'Credential breach monitoring',
      ],
    ),
    StudioFailureMode(
      id: 'credential_phishing_failure',
      title: 'Credential Phishing',
      description:
          'A user is tricked into submitting credentials to an attacker-controlled system.',
      causes: [
        'Deceptive email or message',
        'Look-alike login page',
        'Urgency or social pressure',
      ],
      effects: [
        'Credential theft',
        'Account takeover',
        'Further phishing from the compromised account',
      ],
      controls: [
        'Phishing-resistant MFA',
        'User awareness',
        'Domain and link inspection',
        'Suspicious-login detection',
      ],
    ),
    StudioFailureMode(
      id: 'mfa_fatigue_failure',
      title: 'MFA Fatigue',
      description:
          'Repeated prompts pressure a user into approving an illegitimate request.',
      causes: [
        'Stolen primary credential',
        'Repeated push notifications',
        'Poor prompt context',
      ],
      effects: ['Unauthorized MFA approval', 'Account takeover'],
      controls: [
        'Number matching',
        'Rate limiting',
        'Phishing-resistant factors',
        'Clear prompt context',
      ],
    ),
    StudioFailureMode(
      id: 'recovery_abuse_failure',
      title: 'Account Recovery Abuse',
      description:
          'An attacker exploits recovery procedures to bypass normal authentication.',
      causes: [
        'Weak identity verification',
        'Compromised email or phone',
        'Help-desk social engineering',
      ],
      effects: [
        'Credential reset',
        'Loss of legitimate access',
        'Account takeover',
      ],
      controls: [
        'Stronger recovery verification',
        'Recovery alerts',
        'Delay for high-risk changes',
        'Administrative review',
      ],
    ),
  ],
  perspectives: [
    StudioPerspectiveDefinition(
      id: 'user_perspective',
      name: 'User',
      description:
          'Focuses on convenient, understandable, and reliable access.',
      icon: Icons.person_outline,
      goals: [
        'Sign in successfully',
        'Avoid account compromise',
        'Recover access safely',
      ],
      concerns: [
        'Complex passwords',
        'MFA inconvenience',
        'Phishing',
        'Account lockout',
      ],
      decisions: [
        'Which password or passkey to use',
        'Whether to approve an MFA request',
        'When to report suspicious activity',
      ],
    ),
    StudioPerspectiveDefinition(
      id: 'attacker_perspective',
      name: 'Attacker',
      description:
          'Focuses on weaknesses in credentials, workflows, users, and recovery paths.',
      icon: Icons.warning_amber_outlined,
      goals: [
        'Obtain valid authentication evidence',
        'Avoid detection',
        'Maintain account access',
      ],
      concerns: [
        'MFA',
        'Lockout controls',
        'Risk-based detection',
        'Security alerts',
      ],
      decisions: [
        'Whether to phish, guess, reuse, or steal credentials',
        'Which user or system to target',
        'How to bypass the second factor',
      ],
    ),
    StudioPerspectiveDefinition(
      id: 'defender_perspective',
      name: 'Defender',
      description:
          'Focuses on preventing, detecting, limiting, and recovering from account takeover.',
      icon: Icons.shield_outlined,
      goals: [
        'Reduce successful unauthorized access',
        'Detect suspicious authentication behavior',
        'Preserve legitimate access',
      ],
      concerns: [
        'Credential theft',
        'False positives',
        'Recovery abuse',
        'Monitoring gaps',
      ],
      decisions: [
        'Which factors to require',
        'When to lock or challenge an account',
        'How to investigate suspicious access',
      ],
    ),
  ],
  simulations: [
    StudioSimulationDefinition(
      id: 'password_cracking_simulation',
      title: 'Password Cracking',
      description:
          'Explore how password length, predictability, and attack assumptions change estimated cracking time.',
      icon: Icons.timer_outlined,
      route: '/password_cracking',
      explorationQuestions: [
        'How much does length change resistance?',
        'Why are predictable substitutions weak?',
        'How does the attack model affect the result?',
      ],
      tags: ['password', 'cracking', 'brute force', 'entropy'],
    ),
  ],
  incidents: [
    StudioIncidentDefinition(
      id: 'credential_stuffing_case',
      title: 'Credential Stuffing Across Services',
      summary:
          'Credentials exposed at one service are reused automatically against unrelated services.',
      systemEffects: [
        'Large numbers of login attempts',
        'Account takeover without cracking the password',
        'Fraud and data exposure',
      ],
      lessons: [
        'Password reuse connects otherwise separate systems',
        'Authentication risk extends beyond the local credential store',
        'MFA and breached-password detection reduce systemic exposure',
      ],
      relatedSystemIds: ['cybersecurity.phishing', 'cybersecurity.networking'],
    ),
  ],
  references: [
    StudioReferenceDefinition(
      id: 'nist_digital_identity',
      title: 'Digital Identity Guidelines',
      source: 'NIST',
      description:
          'Guidance for digital identity, authentication, lifecycle management, and authenticator assurance.',
      referenceType: StudioReferenceType.standard,
    ),
    StudioReferenceDefinition(
      id: 'owasp_authentication',
      title: 'Authentication Guidance',
      source: 'OWASP',
      description:
          'Application-security guidance for authentication design and implementation.',
      referenceType: StudioReferenceType.guidance,
    ),
  ],
  tags: [
    'authentication',
    'passwords',
    'identity',
    'mfa',
    'account takeover',
    'credential theft',
    'account recovery',
  ],
);

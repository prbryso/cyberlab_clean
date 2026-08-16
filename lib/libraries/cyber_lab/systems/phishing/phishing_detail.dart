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

/// Phishing, as a system rather than a lesson.
///
/// The subject is the **delivery and judgement of a deceptive message**: what
/// decides whether it arrives, who can tell what about it, and who finds out
/// what happened. Malware behaviour is a different system and is deliberately
/// outside this boundary.
///
/// The point of modelling it is the asymmetry. A gateway reads headers a
/// person never sees; a person sees a subject line and an attachment; a
/// security team sees neither unless somebody tells them. Those differences
/// are authored as observation capabilities and structural relationships, not
/// narrated, so that a run can show them rather than assert them.
///
/// Not const: scenarios arrive in a later phase and name their initial actors
/// as a Set of [StudioElementRef], which defines its own equality and cannot
/// be a const Set element.
final phishingDetail = StudioSystemDetail(
  systemId: 'cybersecurity.phishing',
  summary:
      'Explore how a deceptive message reaches a person, what each part of '
      'the system can tell about it, and who learns what afterwards.',
  purpose:
      'Deliver legitimate mail while limiting deception, credential theft, '
      'and the silence that follows a successful attempt.',
  guidingQuestions: [
    'Who in this system can tell that a message is not what it claims?',
    'What does the person reading it actually have to go on?',
    'If something goes wrong, how would anyone find out?',
  ],
  facets: StudioNodeFacets(
    goals: StudioFacet.known([
      'Deliver messages people need',
      'Limit deception reaching a person',
      'Learn when something got through',
    ]),
    observationCapabilities: StudioFacet.unknown(),
  ),
  actors: [
    StudioActor(
      id: 'attacker',
      name: 'Attacker',
      description:
          'Sends a message designed to be believed, and controls what happens '
          'to anyone who acts on it.',
      icon: Icons.warning_amber_outlined,
      facets: StudioNodeFacets(
        actions: StudioFacet.known([
          'Compose a message that resembles a legitimate one',
          'Send it to one or many recipients',
          'Collect whatever is submitted to a page they control',
        ]),
        goals: StudioFacet.known([
          'Have the message believed',
          'Obtain credentials without being noticed',
          'Avoid being reported',
        ]),
        observationCapabilities: StudioFacet.known([
          'Whether anyone acted on the page they control',
        ]),
        // What a defender does about it is not something the sender is told.
        eventTypes: StudioFacet.notApplicable(),
      ),
    ),
    StudioActor(
      id: 'recipient',
      name: 'Recipient',
      description:
          'The person the message is written for, deciding what to do with '
          'something that looks ordinary.',
      icon: Icons.person_outline,
      facets: StudioNodeFacets(
        actions: StudioFacet.known([
          'Read a message that arrived',
          'Open a link it contains',
          'Sign in on a page a link led to',
          'Report it to whoever handles such things',
        ]),
        goals: StudioFacet.known([
          'Get on with the work the message appears to be about',
          'Avoid being taken in',
        ]),
        // Deliberately narrow, and the point of the model: this is everything
        // a person has to go on. It is far less than the gateway has.
        observationCapabilities: StudioFacet.known([
          'The subject line and who the message appears to be from',
          'Whether an attachment is present',
          'Whether they were expecting it',
        ]),
        // What a person would recognise as having happened. Deliberately
        // symmetrical about the two things they might do, because the model
        // does not treat either as the notable one.
        eventTypes: StudioFacet.known([
          'A message appearing in their view',
          'A link they chose to follow',
          'A page appearing in front of them',
          'Credentials they chose to submit',
          'A message they chose to report',
        ]),
      ),
    ),
    StudioActor(
      id: 'security_team',
      name: 'Security Team',
      description:
          'Responsible for the organisation\'s exposure to messages like this '
          'one, and dependent on being told about them.',
      icon: Icons.shield_outlined,
      facets: StudioNodeFacets(
        actions: StudioFacet.known([
          'Investigate a reported message',
          'Block a sender at the gateway',
        ]),
        goals: StudioFacet.known([
          'Reduce what reaches people',
          'Find out when something got through',
        ]),
        // The whole of it, and both halves are things they are told rather
        // than things they watch. What the gateway did not recognise, and
        // nobody reported, reaches them by no route at all.
        observationCapabilities: StudioFacet.known([
          'Detections raised by the gateway about messages it held back',
          'Reports raised by people who received something',
        ]),
        eventTypes: StudioFacet.known([
          'A message the gateway recognised',
          'A reported message',
        ]),
      ),
    ),
  ],
  assets: [
    StudioAsset(
      id: 'message',
      name: 'Message',
      description:
          'The thing being judged. It carries the marks that would give it '
          'away, to anyone in a position to read them.',
      icon: Icons.mail_outline,
      protectionGoals: ['Integrity of what it claims to be'],
      facets: StudioNodeFacets(
        // A message does nothing and wants nothing. Saying so is more useful
        // than leaving it unknown.
        actions: StudioFacet.notApplicable(),
        goals: StudioFacet.notApplicable(),
        observationCapabilities: StudioFacet.notApplicable(),
        // The red flags, held by the thing that has them rather than spread
        // across every element that might notice one.
        eventTypes: StudioFacet.known([
          'Sender name does not match the sending address',
          'Recipient is one of many undisclosed recipients',
          'Unexpected attachment',
          'Subject is urgent but says little',
        ]),
      ),
    ),
    StudioAsset(
      id: 'corporate_account',
      name: 'Corporate Account',
      description:
          'The access a successful message is aimed at obtaining.',
      icon: Icons.account_circle_outlined,
      protectionGoals: ['Confidentiality', 'Authorised access only'],
      facets: StudioNodeFacets(
        actions: StudioFacet.notApplicable(),
        goals: StudioFacet.notApplicable(),
        observationCapabilities: StudioFacet.notApplicable(),
        // An account announces nothing about itself. Its being reached by
        // someone it does not belong to is not an occurrence it produces, and
        // that silence is why nobody defending it finds out.
        eventTypes: StudioFacet.notApplicable(),
      ),
    ),
  ],
  subsystems: [
    StudioSubsystem(
      id: 'message_delivery',
      name: 'Message Delivery',
      description:
          'Decides whether a message arrives, and presents it when it does.',
      icon: Icons.markunread_mailbox_outlined,
      purpose:
          'Let wanted mail through while holding back what it can recognise '
          'as unwanted.',
      facets: StudioNodeFacets(
        goals: StudioFacet.known([
          'Deliver what people are expecting',
          'Hold back what it can recognise',
        ]),
        observationCapabilities: StudioFacet.known([
          'Everything the message carries, including what it does not display',
        ]),
      ),
      components: [
        StudioComponent(
          id: 'mail_gateway',
          name: 'Mail Gateway',
          description:
              'Screens arriving messages and decides whether to deliver, hold, '
              'or pass them through.',
          icon: Icons.filter_alt_outlined,
          componentType: StudioComponentType.service,
          responsibilities: [
            'Screen arriving messages',
            'Hold back what it recognises',
            'Deliver what it does not',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Examine a message before anyone reads it',
              'Hold a message back',
              'Deliver a message onward',
            ]),
            goals: StudioFacet.known([
              'Let legitimate mail through',
              'Recognise what should not arrive',
            ]),
            // What the person reading the message will never see. The
            // difference between this list and the recipient's is the system
            // fact worth exploring.
            observationCapabilities: StudioFacet.known([
              'The real sending server recorded in the Received headers',
              'Whether replies would be redirected to a different address',
              'Whether the message went to many undisclosed recipients',
            ]),
            eventTypes: StudioFacet.known([
              'A message held back',
              'A message recognised as deceptive',
              'A message delivered',
            ]),
          ),
        ),
        StudioComponent(
          id: 'inbox',
          name: 'Inbox',
          description:
              'Where a delivered message waits, and the only view of it the '
              'recipient gets.',
          icon: Icons.inbox_outlined,
          componentType: StudioComponentType.software,
          responsibilities: [
            'Hold delivered messages',
            'Present them to the person they were addressed to',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Present a message to its recipient',
            ]),
            goals: StudioFacet.known([
              'Show what arrived, as it arrived',
            ]),
            // It shows what it was given. It judges nothing.
            observationCapabilities: StudioFacet.notApplicable(),
            // Exactly one occurrence, and deliberately not the message's red
            // flags: the inbox displays a message, it does not read it. The
            // marks that would give it away belong to the thing that has
            // them.
            eventTypes: StudioFacet.known([
              'A message appearing in the recipient\'s view',
            ]),
          ),
        ),
      ],
    ),
    StudioSubsystem(
      id: 'incident_response',
      name: 'Incident Response',
      description:
          'How something a person noticed reaches the people who can act on '
          'it.',
      icon: Icons.report_gmailerrorred_outlined,
      purpose: 'Carry what one person saw to whoever is responsible for it.',
      facets: StudioNodeFacets(
        goals: StudioFacet.known([
          'Make it easy to say that something looked wrong',
        ]),
      ),
      components: [
        StudioComponent(
          id: 'reporting_channel',
          name: 'Reporting Channel',
          description:
              'The route by which a recipient tells the security team about a '
              'message. Without it, noticing achieves nothing.',
          icon: Icons.outgoing_mail,
          componentType: StudioComponentType.procedure,
          responsibilities: [
            'Accept a report from whoever raises it',
            'Deliver it to the people responsible',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Accept a report',
              'Pass it to the security team',
            ]),
            goals: StudioFacet.known([
              'Lose nothing that someone took the trouble to raise',
            ]),
            observationCapabilities: StudioFacet.known([
              'That a report was raised, and about what',
            ]),
            eventTypes: StudioFacet.known([
              'A reported message',
            ]),
          ),
        ),
      ],
    ),
    StudioSubsystem(
      id: 'attacker_infrastructure',
      name: 'Attacker Infrastructure',
      description:
          'The part of the system the attacker runs. Inside the boundary '
          'because what it does is part of how this system behaves, and '
          'outside anybody else\'s control.',
      icon: Icons.dns_outlined,
      purpose: 'Receive and keep whatever a convinced person submits.',
      components: [
        StudioComponent(
          id: 'link_target',
          name: 'Link Target',
          description:
              'The page a link in the message leads to. It looks like '
              'somewhere ordinary and keeps what is typed into it.',
          icon: Icons.link_outlined,
          componentType: StudioComponentType.externalSystem,
          responsibilities: [
            'Present a convincing page',
            'Keep what is submitted to it',
            'Tell whoever runs it',
          ],
          facets: StudioNodeFacets(
            actions: StudioFacet.known([
              'Present a page that resembles a legitimate one',
              'Accept and keep what is submitted',
            ]),
            goals: StudioFacet.known([
              'Be indistinguishable from the real thing',
            ]),
            observationCapabilities: StudioFacet.known([
              'Everything submitted to it',
            ]),
            eventTypes: StudioFacet.known([
              'A page shown to whoever followed the link',
              'Credentials submitted',
            ]),
          ),
        ),
      ],
    ),
  ],
  stateVariables: [
    StudioStateVariable(
      id: 'mail_gateway.filtering',
      name: 'Filtering',
      owner: StudioElementRef.node('mail_gateway'),
      description:
          'How much the gateway is currently able to recognise about what it '
          'is screening.',
      domain: ['Active', 'Degraded', 'Bypassed'],
      initialValue: 'Active',
    ),
    StudioStateVariable(
      id: 'message.delivery',
      name: 'Delivery',
      owner: StudioElementRef.node('message'),
      description: 'How far this message has got.',
      domain: ['Undelivered', 'Quarantined', 'Delivered'],
      initialValue: 'Undelivered',
    ),
    StudioStateVariable(
      id: 'message.classification',
      name: 'Classification',
      owner: StudioElementRef.node('message'),
      description: 'What the system currently believes this message to be.',
      // Symbolic rather than a score: what matters is the change in posture,
      // not a confidence number nobody can act on differently.
      domain: ['Unknown', 'Suspected', 'Confirmed'],
      initialValue: 'Unknown',
    ),
    StudioStateVariable(
      id: 'link_target.contact',
      name: 'Contact',
      owner: StudioElementRef.node('link_target'),
      // A fact about the page, not about the person. It records that someone
      // arrived, which is what makes submitting something they could do — it
      // says nothing about what they think of what they are looking at.
      description: 'Whether anyone has reached this page.',
      domain: ['None', 'Reached'],
      initialValue: 'None',
    ),
    StudioStateVariable(
      id: 'corporate_account.access',
      name: 'Access',
      owner: StudioElementRef.node('corporate_account'),
      description: 'Whether this account is still only reachable by its owner.',
      domain: ['Active', 'Compromised'],
      initialValue: 'Active',
    ),
  ],
  scenarios: [
    // Ordered deliberately. The first situation is the one that exercises the
    // whole system, because a learner who meets a system for the first time
    // should be able to see it work before seeing it decline to.
    StudioScenario(
      id: 'a_message_that_looks_right',
      name: 'A Message That Looks Right',
      // Describes where things stand. What follows is still decided by
      // whoever acts.
      description:
          'The gateway is running, but not in a condition to recognise this '
          'sender. Everything else starts as declared.',
      initialActors: {StudioElementRef.node('attacker')},
      initialStateOverrides: {
        // The only condition in the system that reads this variable is the
        // gateway's screening branch. Degraded is what leaves it with nothing
        // to refuse on, which is what lets the rest of the system happen at
        // all.
        'mail_gateway.filtering': 'Degraded',
      },
    ),
    StudioScenario(
      id: 'a_message_the_gateway_recognises',
      name: 'A Message the Gateway Recognises',
      description:
          'The gateway is working normally, and this sender is one it can '
          'recognise. Everything else starts as declared.',
      initialActors: {StudioElementRef.node('attacker')},
      // No state overrides. The declared starting values already describe a
      // gateway filtering normally with nothing yet delivered, which is
      // exactly where this situation begins. Restating them here would
      // duplicate the system's own declarations and let the two drift apart.
    ),
    StudioScenario(
      id: 'filtering_bypassed',
      name: 'Filtering Bypassed',
      // Differs from the first situation in one fact. Both end with the
      // message arriving; what differs is why, and what that implies about
      // the system. Which of those matters is the learner's to decide.
      description:
          'Nothing is screening arriving mail at all. Everything else starts '
          'as declared.',
      initialActors: {StudioElementRef.node('attacker')},
      initialStateOverrides: {
        'mail_gateway.filtering': 'Bypassed',
      },
    ),
  ],
  eventTypes: [
    StudioEventType(
      id: 'message_sent',
      name: 'Message sent',
      description: 'A message has arrived at the gateway to be screened.',
      declaredBy: StudioElementRef.node('attacker'),
    ),
    StudioEventType(
      id: 'message_delivered',
      name: 'Message delivered',
      description:
          'The gateway let a message through, and it is now where someone '
          'will read it.',
      declaredBy: StudioElementRef.node('mail_gateway'),
    ),
    StudioEventType(
      id: 'message_presented',
      name: 'Message presented',
      description:
          'The message reached the surface a person actually looks at. That '
          'is a separate fact from its delivery: mail can sit unread, and a '
          'system that treats arriving and being seen as one event cannot say '
          'so.',
      // The inbox presents it. The gateway's job ended when it handed the
      // message over.
      declaredBy: StudioElementRef.node('inbox'),
    ),
    StudioEventType(
      id: 'phishing_detected',
      name: 'Message recognised as deceptive',
      description:
          'The gateway read something in the message that gave it away. What '
          'the gateway can tell is not what a person can tell, which is why '
          'this occurrence exists at all.',
      declaredBy: StudioElementRef.node('mail_gateway'),
    ),
    StudioEventType(
      id: 'link_opened',
      name: 'Link opened',
      description: 'Someone followed a link the message carried.',
      declaredBy: StudioElementRef.node('recipient'),
    ),
    StudioEventType(
      id: 'page_presented',
      name: 'Page presented',
      description:
          'The page put itself in front of whoever followed the link. Being '
          'shown something is not the same as giving it anything, and the '
          'gap between the two is where a person can still notice.',
      declaredBy: StudioElementRef.node('link_target'),
    ),
    StudioEventType(
      id: 'credentials_submitted',
      name: 'Credentials submitted',
      description:
          'A page collected what was typed into it, and told whoever runs it.',
      declaredBy: StudioElementRef.node('link_target'),
    ),
    StudioEventType(
      id: 'message_reported',
      name: 'Message reported',
      description: 'Someone said that a message did not look right.',
      declaredBy: StudioElementRef.node('recipient'),
    ),
    StudioEventType(
      id: 'sender_blocked',
      name: 'Sender blocked',
      description: 'The gateway was told to stop accepting from this sender.',
      declaredBy: StudioElementRef.node('security_team'),
    ),
  ],
  actionDefinitions: [
    StudioActionDefinition(
      id: 'attacker.send_message',
      name: 'Send the message',
      description: 'Put the message into the organisation\'s mail flow.',
      initiator: StudioElementRef.node('attacker'),
      target: StudioElementRef.node('mail_gateway'),
      // Once sent, it has been sent. Sending again is a different message.
      precondition: StudioStateEquals(
        variableId: 'message.delivery',
        value: 'Undelivered',
      ),
      otherwise: StudioOutcome.otherwise(
        emits: ['message_sent'],
        explanation:
            'The message entered the mail flow like any other. Whether it '
            'goes further is not the sender\'s to decide.',
        guidingQuestion:
            'What has to be true about this system for the message to arrive?',
      ),
    ),
    StudioActionDefinition(
      id: 'recipient.open_link',
      name: 'Open the link',
      description: 'Follow where the message says to go.',
      initiator: StudioElementRef.node('recipient'),
      target: StudioElementRef.node('link_target'),
      // A link that has already been followed is not a thing left to do.
      // Because this sets contact to Reached, the second condition takes
      // itself out once the page has been reached, and what remains is the
      // decision that follows from being there.
      precondition: StudioAllOf([
        StudioStateEquals(
          variableId: 'message.delivery',
          value: 'Delivered',
        ),
        StudioStateEquals(
          variableId: 'link_target.contact',
          value: 'None',
        ),
      ]),
      otherwise: StudioOutcome.otherwise(
        effects: [
          StudioAssignState(
            variableId: 'link_target.contact',
            value: 'Reached',
          ),
        ],
        emits: ['link_opened'],
        explanation: 'The link was followed to wherever it led.',
        guidingQuestion:
            'Someone has arrived at a page. What have they given it so far?',
      ),
    ),
    StudioActionDefinition(
      id: 'recipient.submit_credentials',
      name: 'Sign in on the page',
      description: 'Enter credentials into the page the link led to.',
      initiator: StudioElementRef.node('recipient'),
      target: StudioElementRef.node('link_target'),
      // Only possible once somebody has actually reached the page. Following
      // a link and handing something over are two decisions, and the second
      // is the one this system turns on: most people who arrive do not
      // submit, and nothing here says which they should do.
      precondition: StudioStateEquals(
        variableId: 'link_target.contact',
        value: 'Reached',
      ),
      otherwise: StudioOutcome.otherwise(
        emits: ['credentials_submitted'],
        explanation:
            'What was typed went to whoever runs the page. Nothing about the '
            'page had to look unusual for that to work.',
        guidingQuestion:
            'Who holds these credentials now, and who would have to be told?',
      ),
    ),
    StudioActionDefinition(
      id: 'recipient.report_message',
      name: 'Report the message',
      description: 'Tell whoever handles this sort of thing.',
      initiator: StudioElementRef.node('recipient'),
      // The report is raised into the reporting channel, which is what the
      // authored `recipient_reports_message` edge says and what puts the
      // occurrence one hop from the security team.
      target: StudioElementRef.node('reporting_channel'),
      // Deliberately the same precondition as opening the link. Both are
      // available at once, and nothing here marks either as the right one:
      // phishing works precisely because a reasonable person can go either
      // way, and a model that graded the choice would be teaching something
      // else.
      precondition: StudioStateEquals(
        variableId: 'message.delivery',
        value: 'Delivered',
      ),
      otherwise: StudioOutcome.otherwise(
        effects: [
          StudioAssignState(
            variableId: 'message.classification',
            value: 'Suspected',
          ),
        ],
        emits: ['message_reported'],
        explanation:
            'Saying so is what turns one person\'s doubt into something the '
            'system knows.',
        // Deliberately the same shape of question as the one on opening the
        // link: what became known, and to whom. Neither asks whether the
        // choice was a good one.
        guidingQuestion:
            'The system now holds something it did not before. What can be '
            'done with it that could not be done before?',
      ),
    ),
    StudioActionDefinition(
      id: 'security_team.block_sender',
      name: 'Block the sender',
      description: 'Stop the gateway accepting anything more from this source.',
      initiator: StudioElementRef.node('security_team'),
      target: StudioElementRef.node('mail_gateway'),
      // Only worth doing about something believed to be a problem. Nothing
      // sets that but a report.
      precondition: StudioStateEquals(
        variableId: 'message.classification',
        value: 'Suspected',
      ),
      otherwise: StudioOutcome.otherwise(
        effects: [
          StudioAssignState(
            variableId: 'mail_gateway.filtering',
            value: 'Active',
          ),
        ],
        emits: ['sender_blocked'],
        explanation:
            'The gateway can now recognise what it could not before. That '
            'changes what happens next time, not what already happened.',
        guidingQuestion:
            'What about the message that already arrived does this not '
            'change?',
      ),
    ),
  ],
  behaviorDefinitions: [
    StudioBehaviorDefinition(
      id: 'mail_gateway.screen_message',
      name: 'Screen an arriving message',
      description:
          'Judge an arriving message on what it can read, and either hold it '
          'or pass it on.',
      owner: StudioElementRef.node('mail_gateway'),
      trigger: 'message_sent',
      outcomes: [
        StudioOutcome(
          condition: StudioStateEquals(
            variableId: 'mail_gateway.filtering',
            value: 'Active',
          ),
          effects: [
            StudioAssignState(
              variableId: 'message.delivery',
              value: 'Quarantined',
            ),
            StudioAssignState(
              variableId: 'message.classification',
              value: 'Suspected',
            ),
          ],
          // The gateway is the element that recognised it, so the detection
          // is its own occurrence to raise. It does not relay the message.
          emits: ['phishing_detected'],
          explanation:
              'The gateway recognised the sending pattern and held the '
              'message before anyone saw it.',
          guidingQuestion:
              'Nothing reached the recipient, and the team was told. What '
              'would have happened had the gateway not recognised it?',
        ),
      ],
      otherwise: StudioOutcome.otherwise(
        effects: [
          StudioAssignState(
            variableId: 'message.delivery',
            value: 'Delivered',
          ),
        ],
        emits: ['message_delivered'],
        explanation:
            'Filtering was not in a position to judge this message, so it '
            'arrived looking like any other.',
        guidingQuestion:
            'The message is now in front of a person. What can they actually '
            'see about it?',
      ),
    ),
    StudioBehaviorDefinition(
      id: 'inbox.present_message',
      name: 'Put the message in front of the recipient',
      description:
          'Surface a delivered message where the person it was addressed to '
          'will encounter it.',
      owner: StudioElementRef.node('inbox'),
      trigger: 'message_delivered',
      // No branch and no effect. The inbox judges nothing and changes nothing;
      // surfacing is an occurrence, not a condition the system is left in.
      // Modelling it as state would invite gating the recipient's choices on
      // it, which would say that a message not yet seen cannot be acted on —
      // a different and untrue claim.
      otherwise: StudioOutcome.otherwise(
        emits: ['message_presented'],
        explanation:
            'The message appeared in the recipient\'s view. What happens next '
            'depends on what they decide to do.',
        guidingQuestion:
            'The message is now in front of someone. What can they see before '
            'acting?',
      ),
    ),
    StudioBehaviorDefinition(
      id: 'link_target.present_page',
      name: 'Show the page to whoever arrived',
      description:
          'Put a page that resembles a legitimate one in front of whoever '
          'followed the link.',
      owner: StudioElementRef.node('link_target'),
      trigger: 'link_opened',
      // No branch and no effect, for the same reason the inbox has none: a
      // surface displays, it does not decide. Arriving at a page settles
      // nothing, which is precisely why there is still a decision to make.
      otherwise: StudioOutcome.otherwise(
        emits: ['page_presented'],
        explanation:
            'The page loaded and looked like somewhere ordinary. Nothing has '
            'been given to it.',
        guidingQuestion:
            'This page is asking for something. What could be checked before '
            'giving it?',
      ),
    ),
    StudioBehaviorDefinition(
      id: 'link_target.harvest',
      name: 'Keep what was submitted',
      description: 'Keep whatever was typed into the page.',
      owner: StudioElementRef.node('link_target'),
      // Triggered by the submission, not by the arrival. The page cannot
      // collect what nobody has given it.
      trigger: 'credentials_submitted',
      // No branch. The page does not judge who submitted to it, which is most
      // of why it works.
      otherwise: StudioOutcome.otherwise(
        effects: [
          StudioAssignState(
            variableId: 'corporate_account.access',
            value: 'Compromised',
          ),
        ],
        // Nothing is emitted: the submission was the occurrence, and the page
        // keeping it is not a second thing anyone is positioned to witness.
        explanation:
            'The page kept what it was given, and the account can now be '
            'reached by someone it does not belong to.',
        guidingQuestion: 'Who found out that this happened?',
      ),
    ),
  ],
  relationships: [
    StudioRelationship(
      id: 'attacker_sends_to_gateway',
      sourceId: 'attacker',
      targetId: 'mail_gateway',
      type: StudioRelationshipType.sendsDataTo,
      label: 'sends messages to',
    ),
    StudioRelationship(
      id: 'gateway_delivers_to_inbox',
      sourceId: 'mail_gateway',
      targetId: 'inbox',
      type: StudioRelationshipType.sendsDataTo,
      label: 'delivers to',
      description:
          'What the gateway hands over once it has decided. Only the handover '
          'travels here: the inbox is not party to the screening, and is not '
          'told how the gateway is configured.',
      // Without this the channel carried everything sourced at the gateway.
      // The inbox would learn that a message had arrived to be screened —
      // before the gateway had decided anything — and that the security team
      // had reconfigured filtering. Neither is something a mailbox is in a
      // position to know.
      carriedEventTypeIds: ['message_delivered'],
    ),
    // Authored before the general two-way interaction below, deliberately.
    // Route discovery walks relationships in this order and keeps the first
    // one that reaches a node, so this is what makes a run's causal record
    // name surfacing as the channel that reached the person, rather than the
    // generic "works in the inbox" edge.
    StudioRelationship(
      id: 'inbox_presents_to_recipient',
      sourceId: 'inbox',
      targetId: 'recipient',
      type: StudioRelationshipType.sendsDataTo,
      label: 'surfaces messages to',
      description:
          'The channel by which a message reaches a person\'s attention, as '
          'distinct from the recipient working within the inbox generally. It '
          'carries the fact that something was surfaced, and nothing about '
          'how it got there: the gateway\'s decision to deliver is the mail '
          'system\'s knowledge, not the recipient\'s.',
      // Declared rather than relied upon. Delivery is sourced at the gateway,
      // two hops away, so it could not reach the recipient regardless; saying
      // so here makes the boundary a property of the channel instead of an
      // accident of distance.
      carriedEventTypeIds: ['message_presented'],
    ),
    StudioRelationship(
      id: 'recipient_reads_inbox',
      sourceId: 'inbox',
      targetId: 'recipient',
      type: StudioRelationshipType.interactsWith,
      label: 'presents messages to',
      description:
          'A two-way relationship: the inbox shows what arrived, and the '
          'recipient acts within it. This is the standing arrangement between '
          'a person and their mail, not the arrival of any particular '
          'message; the surfacing channel above is what carries that.',
    ),
    StudioRelationship(
      id: 'recipient_reports_message',
      sourceId: 'recipient',
      targetId: 'reporting_channel',
      type: StudioRelationshipType.sendsDataTo,
      label: 'reports to',
    ),
    StudioRelationship(
      id: 'reporting_notifies_security_team',
      sourceId: 'reporting_channel',
      targetId: 'security_team',
      type: StudioRelationshipType.notifies,
      label: 'raises reports to',
      description:
          'The only path by which the security team learns anything about a '
          'message. Without this edge, noticing changes nothing.',
    ),
    StudioRelationship(
      id: 'link_target_reports_to_attacker',
      sourceId: 'link_target',
      targetId: 'attacker',
      type: StudioRelationshipType.sendsDataTo,
      label: 'returns submissions to',
      description:
          'The attacker learns that the attempt worked. Nothing carries the '
          'same fact to anyone defending the account.',
      // Whoever runs a page sees both that it was reached and what was
      // submitted to it — two different pieces of news. What it does not
      // separately report is its own act of displaying, which would tell the
      // attacker nothing they do not already know from the arrival.
      carriedEventTypeIds: ['link_opened', 'credentials_submitted'],
    ),
    StudioRelationship(
      id: 'link_target_presents_to_recipient',
      sourceId: 'link_target',
      targetId: 'recipient',
      type: StudioRelationshipType.sendsDataTo,
      label: 'shows its page to',
      description:
          'The page reaching the person who followed the link. It carries '
          'what is shown, and nothing about what the page does with what it '
          'is given.',
      carriedEventTypeIds: ['page_presented'],
    ),
    StudioRelationship(
      id: 'gateway_alerts_security_team',
      sourceId: 'mail_gateway',
      targetId: 'security_team',
      type: StudioRelationshipType.notifies,
      label: 'raises detections to',
      description:
          'What the gateway recognised, told to the people responsible for '
          'it. This carries detections only: the team is not watching the '
          'mail flow, and learns nothing about messages the gateway let '
          'through.',
      carriedEventTypeIds: ['phishing_detected'],
    ),
    StudioRelationship(
      id: 'security_team_controls_gateway',
      sourceId: 'security_team',
      targetId: 'mail_gateway',
      type: StudioRelationshipType.controls,
      label: 'configures',
    ),
    StudioRelationship(
      id: 'link_target_threatens_account',
      sourceId: 'link_target',
      targetId: 'corporate_account',
      type: StudioRelationshipType.threatens,
      label: 'targets',
      strength: StudioRelationshipStrength.critical,
    ),
  ],
  tags: [
    'phishing',
    'social engineering',
    'email',
    'credential theft',
    'reporting',
  ],
);

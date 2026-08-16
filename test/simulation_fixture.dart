import 'package:systems_studio/engine/models/studio_action_definition.dart';
import 'package:systems_studio/engine/models/studio_behavior_definition.dart';
import 'package:systems_studio/engine/models/studio_condition.dart';
import 'package:systems_studio/engine/models/studio_effect.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_event_type.dart';
import 'package:systems_studio/engine/models/studio_outcome.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_state_variable.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';

/// Small synthetic systems used by the runtime tests.
///
/// Built directly as graphs rather than through StudioGraphBuilder, so the
/// runtime is tested in isolation from the authoring pipeline.
const StudioElementRef systemRef = StudioElementRef.node('sys');
const StudioElementRef actorRef = StudioElementRef.node('actor');
const StudioElementRef engineRef = StudioElementRef.node('engine');
const StudioElementRef monitorRef = StudioElementRef.node('monitor');

const StudioStateVariable engineMode = StudioStateVariable(
  id: 'engine.mode',
  name: 'Mode',
  owner: engineRef,
  domain: ['Ready', 'Busy'],
  initialValue: 'Ready',
);

const StudioStateVariable monitorSignal = StudioStateVariable(
  id: 'monitor.signal',
  name: 'Signal',
  owner: monitorRef,
  domain: ['Quiet', 'Alerting'],
  initialValue: 'Quiet',
);

/// The monitor watches the engine, so what happens at the engine reaches the
/// monitor. Note the direction: the relationship points at what is watched,
/// while the information travels the other way.
const StudioRelationship monitorWatchesEngine = StudioRelationship(
  id: 'monitor.monitors.engine',
  sourceId: 'monitor',
  targetId: 'engine',
  type: StudioRelationshipType.monitors,
  label: 'monitors',
);

/// The monitor tells the engine. Used only by the ping-pong fixture, to give
/// information a route back that watching alone would not provide.
const StudioRelationship monitorNotifiesEngine = StudioRelationship(
  id: 'monitor.notifies.engine',
  sourceId: 'monitor',
  targetId: 'engine',
  type: StudioRelationshipType.notifies,
  label: 'notifies',
);

const List<StudioGraphNode> _nodes = [
  StudioGraphNode(id: 'sys', label: 'System', type: StudioGraphNodeType.system),
  StudioGraphNode(
    id: 'actor',
    label: 'Actor',
    type: StudioGraphNodeType.actor,
    parentId: 'sys',
  ),
  StudioGraphNode(
    id: 'engine',
    label: 'Engine',
    type: StudioGraphNodeType.component,
    parentId: 'sys',
  ),
  StudioGraphNode(
    id: 'monitor',
    label: 'Monitor',
    type: StudioGraphNodeType.component,
    parentId: 'sys',
  ),
];

/// A graph with one action and one reacting behaviour.
///
/// Chain: actor pings the engine, the engine emits `pinged`, the monitor
/// notices and emits `noticed`. Nothing reacts to `noticed`, so a run reaches
/// quiescence.
StudioSystemGraph buildBasicGraph() {
  return const StudioSystemGraph(
    systemId: 'sys',
    nodes: _nodes,
    relationships: [monitorWatchesEngine],
    stateVariables: [engineMode, monitorSignal],
    eventTypes: [
      StudioEventType(id: 'pinged', name: 'Pinged'),
      StudioEventType(id: 'noticed', name: 'Noticed'),
    ],
    actionDefinitions: [
      StudioActionDefinition(
        id: 'act.ping',
        name: 'Ping the engine',
        initiator: actorRef,
        target: engineRef,
        precondition: StudioStateEquals(
          variableId: 'engine.mode',
          value: 'Ready',
        ),
        outcomes: [
          StudioOutcome(
            condition: StudioStateEquals(
              variableId: 'engine.mode',
              value: 'Ready',
            ),
            effects: [
              StudioAssignState(variableId: 'engine.mode', value: 'Busy'),
            ],
            emits: ['pinged'],
            explanation: 'The engine was ready, so it accepted the ping.',
          ),
        ],
        otherwise: StudioOutcome.otherwise(
          explanation: 'The engine was busy, so nothing happened.',
        ),
      ),
    ],
    behaviorDefinitions: [
      StudioBehaviorDefinition(
        id: 'beh.notice',
        name: 'Notice the ping',
        owner: monitorRef,
        trigger: 'pinged',
        outcomes: [
          StudioOutcome(
            condition: StudioStateNotEquals(
              variableId: 'monitor.signal',
              value: 'Alerting',
            ),
            effects: [
              StudioAssignState(
                variableId: 'monitor.signal',
                value: 'Alerting',
              ),
            ],
            emits: ['noticed'],
            explanation: 'The monitor had been quiet, so it raised a signal.',
          ),
        ],
        otherwise: StudioOutcome.otherwise(
          explanation: 'The monitor was already alerting.',
        ),
      ),
    ],
  );
}

/// A graph whose single behaviour emits the very event that triggers it.
///
/// Exercises the safeguard that stops a behaviour reacting to its own
/// emission within one propagation.
StudioSystemGraph buildSelfEmittingGraph() {
  return const StudioSystemGraph(
    systemId: 'sys',
    nodes: _nodes,
    stateVariables: [engineMode],
    eventTypes: [StudioEventType(id: 'ping', name: 'Ping')],
    actionDefinitions: [
      StudioActionDefinition(
        id: 'act.start',
        name: 'Start',
        initiator: actorRef,
        target: engineRef,
        otherwise: StudioOutcome.otherwise(emits: ['ping']),
      ),
    ],
    behaviorDefinitions: [
      StudioBehaviorDefinition(
        id: 'beh.echo',
        name: 'Echo',
        owner: engineRef,
        trigger: 'ping',
        otherwise: StudioOutcome.otherwise(emits: ['ping']),
      ),
    ],
  );
}

/// The basic system with the monitor disconnected from the engine.
///
/// The behaviour and its trigger event are unchanged; only the line of sight
/// is gone. Used to show that matching a trigger type is no longer enough.
StudioSystemGraph buildUnobservableGraph() {
  final connected = buildBasicGraph();

  return StudioSystemGraph(
    systemId: connected.systemId,
    nodes: connected.nodes,
    relationships: const [],
    stateVariables: connected.stateVariables,
    eventTypes: connected.eventTypes,
    actionDefinitions: connected.actionDefinitions,
    behaviorDefinitions: connected.behaviorDefinitions,
  );
}

/// A three-element chain: actor -> engine -> monitor -> system.
///
/// Used to exercise fidelity. With relaying enabled, the system node is two
/// hops from the engine and so receives existence only.
StudioSystemGraph buildRelayGraph() {
  return const StudioSystemGraph(
    systemId: 'sys',
    nodes: _nodes,
    relationships: [
      StudioRelationship(
        id: 'engine.sends.monitor',
        sourceId: 'engine',
        targetId: 'monitor',
        type: StudioRelationshipType.sendsDataTo,
        label: 'sends to',
      ),
      StudioRelationship(
        id: 'monitor.sends.sys',
        sourceId: 'monitor',
        targetId: 'sys',
        type: StudioRelationshipType.sendsDataTo,
        label: 'sends to',
      ),
    ],
    eventTypes: [StudioEventType(id: 'ping', name: 'Ping')],
  );
}

/// Two behaviours that trigger each other forever.
///
/// Exercises the propagation depth bound. The self-emission safeguard does not
/// help here, because each behaviour reacts to the *other* one's emission.
StudioSystemGraph buildPingPongGraph() {
  return const StudioSystemGraph(
    systemId: 'sys',
    nodes: _nodes,
    relationships: [monitorWatchesEngine, monitorNotifiesEngine],
    eventTypes: [
      StudioEventType(id: 'ping', name: 'Ping'),
      StudioEventType(id: 'pong', name: 'Pong'),
    ],
    actionDefinitions: [
      StudioActionDefinition(
        id: 'act.start',
        name: 'Start',
        initiator: actorRef,
        target: engineRef,
        otherwise: StudioOutcome.otherwise(emits: ['ping']),
      ),
    ],
    behaviorDefinitions: [
      StudioBehaviorDefinition(
        id: 'beh.a',
        name: 'A',
        owner: engineRef,
        trigger: 'ping',
        otherwise: StudioOutcome.otherwise(emits: ['pong']),
      ),
      StudioBehaviorDefinition(
        id: 'beh.b',
        name: 'B',
        owner: monitorRef,
        trigger: 'pong',
        otherwise: StudioOutcome.otherwise(emits: ['ping']),
      ),
    ],
  );
}

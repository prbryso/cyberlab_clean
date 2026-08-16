import 'package:flutter/material.dart';

import 'studio_facets.dart';

/// A subsystem within a larger StudioSystem.
///
/// Subsystems let Systems Studio describe complex systems hierarchically:
///
/// System
///   -> Subsystem
///       -> Component
///           -> Interface
///
/// A subsystem can also contain child subsystems, allowing multiple levels of
/// decomposition without requiring the engine to know the subject area.
class StudioSubsystem {
  const StudioSubsystem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.purpose = '',
    this.facets = StudioNodeFacets.unknown,
    this.components = const [],
    this.childSubsystems = const [],
    this.interfaces = const [],
    this.inputs = const [],
    this.outputs = const [],
    this.failureModes = const [],
    this.tags = const [],
  });

  /// Unique within the parent system.
  final String id;

  final String name;

  final String description;

  final IconData icon;

  /// The role this subsystem performs within the larger system.
  ///
  /// Distinct from the Goals facet, and never derived from it. Purpose is
  /// structural — why this subsystem exists inside the whole. Goals describe
  /// what it is trying to accomplish as an element in its own right.
  final String purpose;

  /// Declared facets of this subsystem.
  final StudioNodeFacets facets;

  /// Physical, software, human, organizational, or logical components.
  final List<StudioComponent> components;

  /// Optional lower-level subsystem decomposition.
  final List<StudioSubsystem> childSubsystems;

  /// Connections to other subsystems, components, users, or external systems.
  final List<StudioInterfaceDefinition> interfaces;

  /// Signals, information, resources, commands, or materials entering it.
  final List<String> inputs;

  /// Signals, information, decisions, resources, or actions leaving it.
  final List<String> outputs;

  /// Significant ways this subsystem can fail or be compromised.
  final List<StudioSubsystemFailureMode> failureModes;

  /// Search and discovery terms.
  final List<String> tags;

  /// Returns this subsystem and all descendants in depth-first order.
  Iterable<StudioSubsystem> flatten() sync* {
    yield this;

    for (final child in childSubsystems) {
      yield* child.flatten();
    }
  }

  /// Finds a subsystem in this hierarchy.
  StudioSubsystem? findSubsystem(String subsystemId) {
    if (id == subsystemId) {
      return this;
    }

    for (final child in childSubsystems) {
      final match = child.findSubsystem(subsystemId);

      if (match != null) {
        return match;
      }
    }

    return null;
  }

  /// Finds a component in this subsystem or any descendant subsystem.
  StudioComponent? findComponent(String componentId) {
    for (final component in components) {
      if (component.id == componentId) {
        return component;
      }
    }

    for (final child in childSubsystems) {
      final match = child.findComponent(componentId);

      if (match != null) {
        return match;
      }
    }

    return null;
  }
}

/// A component contained within a subsystem.
///
/// Components can represent:
///
/// - software services;
/// - hardware devices;
/// - people or roles;
/// - databases;
/// - procedures;
/// - sensors;
/// - controllers;
/// - communication links;
/// - external organizations.
class StudioComponent {
  const StudioComponent({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.componentType = StudioComponentType.other,
    this.responsibilities = const [],
    this.facets = StudioNodeFacets.unknown,
    this.inputs = const [],
    this.outputs = const [],
    this.tags = const [],
  });

  final String id;

  final String name;

  final String description;

  final IconData icon;

  final StudioComponentType componentType;

  /// Functions or responsibilities performed by this component.
  ///
  /// Distinct from the Actions facet, and never derived from it. A
  /// responsibility is an obligation the design assigns to this component; an
  /// action is something it can do. A component may hold a responsibility it
  /// cannot currently discharge, and may be capable of actions no one made it
  /// responsible for.
  final List<String> responsibilities;

  /// Declared facets of this component.
  final StudioNodeFacets facets;

  final List<String> inputs;

  final List<String> outputs;

  // Operational states are no longer declared here. They are typed
  // StudioStateVariable declarations on StudioSystemDetail, which carry a
  // domain and an initial value that a bare list of names could not.

  final List<String> tags;
}

/// A connection or relationship between elements of a system.
class StudioInterfaceDefinition {
  const StudioInterfaceDefinition({
    required this.id,
    required this.name,
    required this.sourceId,
    required this.targetId,
    required this.description,
    this.interfaceType = StudioInterfaceType.other,
    this.direction = StudioInterfaceDirection.bidirectional,
    this.exchanges = const [],
    this.protocols = const [],
    this.trustBoundary = false,
    this.tags = const [],
  });

  final String id;

  final String name;

  /// ID of the originating subsystem, component, actor, or external system.
  final String sourceId;

  /// ID of the receiving subsystem, component, actor, or external system.
  final String targetId;

  final String description;

  final StudioInterfaceType interfaceType;

  final StudioInterfaceDirection direction;

  /// Information, commands, signals, energy, material, or resources exchanged.
  final List<String> exchanges;

  /// Optional technical or procedural protocols.
  final List<String> protocols;

  /// True when the interface crosses a security, authority, safety, privacy,
  /// organizational, or operational boundary.
  final bool trustBoundary;

  final List<String> tags;
}

/// Failure information local to a subsystem.
///
/// This remains separate from StudioFailureMode so subsystem descriptions can
/// be used independently without creating a circular model dependency.
class StudioSubsystemFailureMode {
  const StudioSubsystemFailureMode({
    required this.id,
    required this.title,
    required this.description,
    this.causes = const [],
    this.localEffects = const [],
    this.systemEffects = const [],
    this.controls = const [],
  });

  final String id;

  final String title;

  final String description;

  final List<String> causes;

  /// Effects visible within the subsystem.
  final List<String> localEffects;

  /// Effects propagated into the larger system.
  final List<String> systemEffects;

  /// Prevention, detection, mitigation, recovery, or containment measures.
  final List<String> controls;
}

enum StudioComponentType {
  person,
  role,
  organization,
  hardware,
  software,
  service,
  database,
  sensor,
  actuator,
  controller,
  communicationLink,
  procedure,
  externalSystem,
  physicalProcess,
  other,
}

enum StudioInterfaceType {
  data,
  command,
  control,
  physical,
  human,
  organizational,
  electrical,
  mechanical,
  hydraulic,
  network,
  procedural,
  other,
}

enum StudioInterfaceDirection { inbound, outbound, bidirectional }

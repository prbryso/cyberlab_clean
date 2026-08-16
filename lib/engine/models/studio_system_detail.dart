import 'package:flutter/material.dart';

import 'studio_action_definition.dart';
import 'studio_behavior_definition.dart';
import 'studio_event_type.dart';
import 'studio_facets.dart';
import 'studio_perspective_definition.dart';
import 'studio_relationship.dart';
import 'studio_scenario.dart';
import 'studio_state_variable.dart';
import 'studio_subsystem.dart';
import 'studio_system_graph.dart';

export 'studio_perspective_definition.dart';

/// Rich, exploration-oriented content for a system.
///
/// [StudioSystem] remains the lightweight catalog and navigation model.
/// [StudioSystemDetail] supplies the deeper content rendered by a future
/// SystemExplorerScreen.
class StudioSystemDetail {
  const StudioSystemDetail({
    required this.systemId,
    required this.summary,
    this.purpose = '',
    this.facets = StudioNodeFacets.unknown,
    this.guidingQuestions = const [],
    this.actors = const [],
    this.assets = const [],
    this.boundaries = const [],
    this.inputs = const [],
    this.outputs = const [],
    this.subsystems = const [],
    this.stateVariables = const [],
    this.eventTypes = const [],
    this.actionDefinitions = const [],
    this.behaviorDefinitions = const [],
    this.scenarios = const [],
    this.relationships = const [],
    this.graph,
    this.failureModes = const [],
    this.perspectives = const [],
    this.simulations = const [],
    this.incidents = const [],
    this.references = const [],
    this.tags = const [],
  });

  /// Must match the corresponding StudioSystem.id.
  final String systemId;

  /// Concise explanation of the system and what the user can explore.
  final String summary;

  /// The problem the system is intended to solve.
  ///
  /// Distinct from the Goals facet. Purpose is the reason the system exists;
  /// Goals are what the system as an element is trying to accomplish. They are
  /// often related but are not the same statement, and one is never derived
  /// from the other.
  final String purpose;

  /// Declared facets of the system considered as a single element.
  final StudioNodeFacets facets;

  /// Questions that encourage systems thinking rather than memorization.
  final List<String> guidingQuestions;

  /// People, organizations, software, devices, or external systems that
  /// participate in or influence this system.
  final List<StudioActor> actors;

  /// Information, capabilities, resources, or operations the system protects.
  final List<StudioAsset> assets;

  /// What is considered inside and outside the system being explored.
  final List<String> boundaries;

  /// Information, actions, resources, or signals entering the system.
  final List<String> inputs;

  /// Decisions, results, services, data, or actions produced by the system.
  final List<String> outputs;

  /// Hierarchical decomposition of the system.
  ///
  /// Simple systems may leave this empty. Complex systems can describe
  /// subsystems, components, interfaces, and child subsystems.
  final List<StudioSubsystem> subsystems;

  /// State variables declared by elements of this system.
  ///
  /// Declared centrally rather than on each element so that the owner is an
  /// explicit [StudioElementRef]. That keeps one authoring shape for state
  /// owned by a node and state owned by a relationship, and makes the owner
  /// something validation can check rather than something the builder infers.
  final List<StudioStateVariable> stateVariables;

  /// Event types that can occur in this system.
  final List<StudioEventType> eventTypes;

  /// Actions actors may deliberately choose.
  ///
  /// Intentional moves. Distinct from [behaviorDefinitions], which elements
  /// perform automatically.
  final List<StudioActionDefinition> actionDefinitions;

  /// Behaviours elements perform automatically in response to events.
  final List<StudioBehaviorDefinition> behaviorDefinitions;

  /// Situations this system offers for exploration.
  ///
  /// Each establishes a starting point — who is already present and what is
  /// already true — and nothing more. A scenario never describes a sequence
  /// of steps; what happens is decided by actors, as it is without one.
  ///
  /// Optional. A system with none is explored from its declared starting
  /// values, exactly as before scenarios existed.
  final List<StudioScenario> scenarios;

  /// Relationships connecting elements of the system.
  ///
  /// Relationships reference IDs belonging to actors, assets, subsystems,
  /// components, incidents, interfaces, failure modes, or package-specific
  /// elements.
  final List<StudioRelationship> relationships;

  /// Optional explicit graph representation of the system.
  ///
  /// When null, the engine may generate a graph from the typed system content.
  /// Advanced packages can supply a custom graph for specialized layouts,
  /// analysis, or visualization.
  final StudioSystemGraph? graph;

  /// Important ways the system can fail, be misused, or be defeated.
  final List<StudioFailureMode> failureModes;

  /// Different viewpoints from which the system can be examined.
  final List<StudioPerspectiveDefinition> perspectives;

  /// Interactive experiences associated with the system.
  final List<StudioSimulationDefinition> simulations;

  /// Real or representative events connected to the system.
  final List<StudioIncidentDefinition> incidents;

  /// Standards, publications, organizations, and supporting material.
  final List<StudioReferenceDefinition> references;

  /// Search and discovery terms.
  final List<String> tags;
}

/// A participant or external influence within a system.
///
/// An actor's goals and actions are declared through [facets], so that
/// "this actor has no goals" and "we do not know this actor's goals" remain
/// distinguishable.
class StudioActor {
  const StudioActor({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.facets = StudioNodeFacets.unknown,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;

  /// Declared facets of this actor.
  final StudioNodeFacets facets;
}

/// Something valuable, necessary, sensitive, or safety-critical.
class StudioAsset {
  const StudioAsset({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.protectionGoals = const [],
    this.facets = StudioNodeFacets.unknown,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;

  /// Examples: confidentiality, integrity, availability, safety, privacy.
  ///
  /// Distinct from the Goals facet. A protection goal is what the system owes
  /// this asset, not something the asset is trying to accomplish.
  final List<String> protectionGoals;

  /// Declared facets of this asset.
  ///
  /// Many assets legitimately declare Actions and Goals as not applicable.
  final StudioNodeFacets facets;
}

/// A significant way the system can fail or be compromised.
class StudioFailureMode {
  const StudioFailureMode({
    required this.id,
    required this.title,
    required this.description,
    this.causes = const [],
    this.effects = const [],
    this.controls = const [],
  });

  final String id;
  final String title;
  final String description;

  /// Conditions or actions that may produce this failure.
  final List<String> causes;

  /// What happens when the failure occurs.
  final List<String> effects;

  /// Measures that prevent, detect, limit, or recover from the failure.
  final List<String> controls;
}

/// Metadata for an interactive simulation.
///
/// The actual simulation widget remains registered through routing or a
/// simulation registry. This model describes it for discovery and display.
class StudioSimulationDefinition {
  const StudioSimulationDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.explorationQuestions = const [],
    this.tags = const [],
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String route;

  /// Questions users can consider while experimenting.
  final List<String> explorationQuestions;

  final List<String> tags;
}

/// A real or representative event that illustrates system behavior.
class StudioIncidentDefinition {
  const StudioIncidentDefinition({
    required this.id,
    required this.title,
    required this.summary,
    this.year,
    this.systemEffects = const [],
    this.lessons = const [],
    this.relatedSystemIds = const [],
    this.referenceIds = const [],
  });

  final String id;
  final String title;
  final String summary;
  final int? year;

  /// Consequences observed within or across systems.
  final List<String> systemEffects;

  /// Systems-thinking observations—not test answers.
  final List<String> lessons;

  /// Other StudioSystem IDs related to this incident.
  final List<String> relatedSystemIds;

  /// IDs of supporting StudioReferenceDefinition entries.
  final List<String> referenceIds;
}

/// Supporting material for deeper study.
class StudioReferenceDefinition {
  const StudioReferenceDefinition({
    required this.id,
    required this.title,
    required this.source,
    this.description = '',
    this.url,
    this.referenceType = StudioReferenceType.other,
  });

  final String id;
  final String title;
  final String source;
  final String description;
  final Uri? url;
  final StudioReferenceType referenceType;
}

enum StudioReferenceType {
  standard,
  framework,
  guidance,
  article,
  book,
  paper,
  organization,
  website,
  other,
}

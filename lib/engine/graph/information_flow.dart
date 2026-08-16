import 'package:systems_studio/engine/models/studio_relationship.dart';

/// Which way information travels along a relationship, relative to the edge.
///
/// This is separate from [StudioRelationshipDirection], which says how the
/// *relationship* should be read. A relationship can point one way while the
/// information it carries travels the other: a monitor points at the engine it
/// watches, but what the monitor learns flows from the engine back to it.
/// Collapsing the two would make "watches" and "tells" the same statement.
enum StudioInformationFlow {
  /// Carries no information. The default.
  none,

  /// Information travels from source to target.
  forward,

  /// Information travels from target to source.
  backward,

  /// Information travels both ways.
  both,
}

/// How each relationship type carries information.
///
/// This classification is **engine semantics**, not content. It is a property
/// of the relationship type, expressed in typed code, and every library gets
/// the same physics. If a library could supply its own classification, each
/// one would invent different rules for what "monitors" means.
///
/// The classification is deliberately narrow. Most relationships describe
/// structure, dependency, or intent rather than information: containment does
/// not carry a signal, and neither does protecting or threatening something.
/// Assuming otherwise would make almost everything observable to almost
/// everyone, which is the opposite of what a perspective model needs. Adding a
/// type to this list should be a deliberate act.
extension StudioRelationshipInformationFlow on StudioRelationshipType {
  StudioInformationFlow get informationFlow {
    return switch (this) {
      // Mutual exchange: both parties learn from the interaction.
      StudioRelationshipType.interactsWith ||
      StudioRelationshipType.communicatesWith => StudioInformationFlow.both,

      // Directed delivery: the target learns something.
      StudioRelationshipType.sendsDataTo ||
      StudioRelationshipType.sendsCommandTo ||
      StudioRelationshipType.notifies => StudioInformationFlow.forward,

      // Watching: the source learns about the target.
      StudioRelationshipType.monitors ||
      StudioRelationshipType.detects => StudioInformationFlow.backward,

      // Everything else describes structure, dependency, protection, threat,
      // or provenance rather than the movement of information.
      _ => StudioInformationFlow.none,
    };
  }

  /// True when this type can carry information at all.
  bool get carriesInformation =>
      informationFlow != StudioInformationFlow.none;
}

/// How information moves along one concrete relationship.
///
/// Combines the type's information semantics with the instance's declared
/// direction, so a relationship marked reverse carries information the other
/// way and a bidirectional one carries it both ways.
extension StudioRelationshipInformationPath on StudioRelationship {
  /// True when information can travel from [fromId] to [toId] along this
  /// relationship.
  bool carriesInformationFrom(String fromId, String toId) {
    if (!involves(fromId) || otherEndpoint(fromId) != toId) {
      return false;
    }

    final flow = type.informationFlow;

    if (flow == StudioInformationFlow.none) {
      return false;
    }

    // A bidirectional or undirected relationship carries whatever its type
    // carries, in both directions.
    if (direction == StudioRelationshipDirection.bidirectional ||
        direction == StudioRelationshipDirection.undirected ||
        flow == StudioInformationFlow.both) {
      return true;
    }

    final reversed = direction == StudioRelationshipDirection.reverse;

    final effectiveFlow = reversed
        ? (flow == StudioInformationFlow.forward
              ? StudioInformationFlow.backward
              : StudioInformationFlow.forward)
        : flow;

    return switch (effectiveFlow) {
      StudioInformationFlow.forward => sourceId == fromId,
      StudioInformationFlow.backward => targetId == fromId,
      _ => false,
    };
  }
}

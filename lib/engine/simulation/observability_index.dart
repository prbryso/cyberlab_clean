import 'dart:collection';

import 'package:systems_studio/engine/graph/information_flow.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/models/studio_relationship.dart';
import 'package:systems_studio/engine/models/studio_system_graph.dart';
import 'package:systems_studio/engine/simulation/studio_event.dart';
import 'package:systems_studio/engine/simulation/studio_observation.dart';

/// One structural route by which information reaches an observer.
class StudioObservationRoute {
  const StudioObservationRoute({
    required this.observer,
    required this.distance,
    required this.relationshipIds,
    required this.viaNotification,
  });

  final StudioElementRef observer;
  final int distance;
  final List<String> relationshipIds;

  /// True when the last hop was an explicit notification rather than
  /// information the observer picked up by being connected.
  final bool viaNotification;
}

/// Who can observe occurrences originating at each element.
///
/// Observability is a property of the **graph**, not of a run: it depends on
/// how elements are connected, and the graph is immutable. So it is computed
/// once per graph and reused for every event, rather than re-running a
/// traversal for each occurrence. With cascades, per-event traversal would be
/// O(events x observers x graph).
///
/// The index answers, for a source element: which elements does information
/// reach, how far away are they, and along which relationships.
///
/// This file is intentionally free of Flutter dependencies.
class StudioObservabilityIndex {
  StudioObservabilityIndex._(
    this._routesBySource,
    this._carriedByRelationship,
    this.maximumDistance,
  );

  /// Beyond this many hops, information is treated as not arriving at all.
  final int maximumDistance;

  final Map<String, List<StudioObservationRoute>> _routesBySource;

  /// What each relationship is allowed to carry, or null where unrestricted.
  ///
  /// Read off the graph once, alongside the routes. Restriction is a property
  /// of the system, not of a run, so it is precomputed with everything else —
  /// answering "can this route carry this event?" stays a lookup rather than
  /// becoming a second traversal.
  final Map<String, List<String>?> _carriedByRelationship;

  /// Builds the index for [graph].
  ///
  /// [maximumDistance] bounds how far information travels, and defaults to a
  /// single hop. That default is a deliberate semantic position: **an element
  /// is not a wire.** Multi-hop structural observation would mean every
  /// element silently relays everything it perceives, so an administrator
  /// connected to a monitor would learn every failure the monitor ever saw,
  /// whether or not the monitor thought it worth reporting.
  ///
  /// What actually happens in a system is that an element which wants others
  /// to know something *emits its own occurrence*, and that occurrence is
  /// observed directly. The Password Security demonstration turns on exactly
  /// this: monitoring does not pass the failure along, it raises an alert, and
  /// the alert is what reaches the administrator.
  ///
  /// A larger distance can be requested by a model that genuinely wants
  /// second-hand awareness. Beyond the first hop, observers receive
  /// [StudioObservationFidelity.existenceOnly].
  factory StudioObservabilityIndex.forGraph(
    StudioSystemGraph graph, {
    int maximumDistance = 1,
  }) {
    final routes = <String, List<StudioObservationRoute>>{};

    for (final node in graph.nodes) {
      routes[node.id] = _routesFrom(graph, node.id, maximumDistance);
    }

    return StudioObservabilityIndex._(
      routes,
      {
        for (final relationship in graph.relationships)
          relationship.id: relationship.carriedEventTypeIds,
      },
      maximumDistance,
    );
  }

  /// Structural routes from [sourceNodeId], nearest first.
  ///
  /// Every route information could take, before asking what information. This
  /// is the shape of the system and does not depend on what has happened.
  List<StudioObservationRoute> routesFrom(String sourceNodeId) {
    return _routesBySource[sourceNodeId] ?? const [];
  }

  /// Routes from [sourceNodeId] that can carry [eventTypeId].
  ///
  /// A filter over the precomputed routes rather than a second index: the
  /// structural work is already done, and this only asks whether each hop of
  /// an existing route is willing to carry this particular occurrence.
  List<StudioObservationRoute> routesCarrying(
    String sourceNodeId,
    String eventTypeId,
  ) {
    return List<StudioObservationRoute>.unmodifiable(
      routesFrom(sourceNodeId).where((route) => _carries(route, eventTypeId)),
    );
  }

  /// True when every relationship along [route] carries [eventTypeId].
  ///
  /// Every hop, not just the last: a chain is as permissive as its narrowest
  /// link, and information that cannot complete a leg of the journey does not
  /// arrive having made the rest of it.
  bool _carries(StudioObservationRoute route, String eventTypeId) {
    for (final relationshipId in route.relationshipIds) {
      final carried = _carriedByRelationship[relationshipId];

      // Unrestricted, or not a relationship this index knows about.
      if (carried == null) {
        continue;
      }

      if (!carried.contains(eventTypeId)) {
        return false;
      }
    }

    return true;
  }

  /// The route by which [observer] receives occurrences from [sourceNodeId],
  /// or null when information does not reach them.
  StudioObservationRoute? routeBetween(
    String sourceNodeId,
    StudioElementRef observer,
  ) {
    for (final route in routesFrom(sourceNodeId)) {
      if (route.observer == observer) {
        return route;
      }
    }

    return null;
  }

  /// Every observation of [event], in a stable order.
  ///
  /// Participants come first and receive full fidelity: they were there.
  /// Structural observers follow, ordered by distance. A direct connection or
  /// an explicit notification gives full fidelity; anything further away gives
  /// existence only.
  List<StudioObservation> observationsOf(StudioEvent event) {
    final observations = <StudioObservation>[];
    final seen = <StudioElementRef>{};

    for (final participant in event.participants) {
      if (!seen.add(participant)) {
        continue;
      }

      observations.add(
        StudioObservation(
          observer: participant,
          event: event,
          basis: StudioObservationBasis.participation,
          fidelity: StudioObservationFidelity.full,
        ),
      );
    }

    if (!event.source.isNode) {
      return List<StudioObservation>.unmodifiable(observations);
    }

    // Only the routes willing to carry this occurrence. A route that cannot
    // carry it yields no observation at all — not a vaguer one. "This channel
    // does not carry that" is different from "they heard something".
    for (final route in routesCarrying(event.source.id, event.typeId)) {
      if (!seen.add(route.observer)) {
        continue;
      }

      final basis = route.viaNotification
          ? StudioObservationBasis.notification
          : StudioObservationBasis.informationFlow;

      final fidelity =
          route.distance <= 1 || route.viaNotification
          ? StudioObservationFidelity.full
          : StudioObservationFidelity.existenceOnly;

      observations.add(
        StudioObservation(
          observer: route.observer,
          event: event,
          basis: basis,
          fidelity: fidelity,
          channelRelationshipIds: route.relationshipIds,
          distance: route.distance,
        ),
      );
    }

    return List<StudioObservation>.unmodifiable(observations);
  }

  /// Whether [observer] can perceive [event] at all.
  ///
  /// Asked of this specific occurrence, not of the connection in general: a
  /// behaviour may react only to an event it can observe, so a channel that
  /// does not carry this event type cannot be what lets it react.
  ///
  /// Taking part still overrides everything. Being there is not a matter of
  /// what a channel carries.
  bool canObserve(StudioElementRef observer, StudioEvent event) {
    if (event.participants.contains(observer)) {
      return true;
    }

    if (!event.source.isNode) {
      return false;
    }

    for (final route in routesCarrying(event.source.id, event.typeId)) {
      if (route.observer == observer) {
        return true;
      }
    }

    return false;
  }

  /// Breadth-first traversal across information-bearing relationships.
  ///
  /// Traversal follows the direction information actually moves, which is not
  /// always the direction the relationship points.
  static List<StudioObservationRoute> _routesFrom(
    StudioSystemGraph graph,
    String sourceNodeId,
    int maximumDistance,
  ) {
    final routes = <StudioObservationRoute>[];
    final visited = <String>{sourceNodeId};

    final queue = Queue<_Hop>()
      ..add(_Hop(nodeId: sourceNodeId, distance: 0, path: const []));

    while (queue.isNotEmpty) {
      final hop = queue.removeFirst();

      if (hop.distance >= maximumDistance) {
        continue;
      }

      for (final relationship in graph.relationships) {
        if (!relationship.involves(hop.nodeId)) {
          continue;
        }

        final otherId = relationship.otherEndpoint(hop.nodeId);

        if (otherId == null || visited.contains(otherId)) {
          continue;
        }

        if (!relationship.carriesInformationFrom(hop.nodeId, otherId)) {
          continue;
        }

        visited.add(otherId);

        final path = <String>[...hop.path, relationship.id];

        routes.add(
          StudioObservationRoute(
            observer: StudioElementRef.node(otherId),
            distance: hop.distance + 1,
            relationshipIds: List<String>.unmodifiable(path),
            viaNotification:
                relationship.type == StudioRelationshipType.notifies,
          ),
        );

        queue.add(
          _Hop(nodeId: otherId, distance: hop.distance + 1, path: path),
        );
      }
    }

    routes.sort((left, right) {
      final byDistance = left.distance.compareTo(right.distance);

      if (byDistance != 0) {
        return byDistance;
      }

      return left.observer.id.compareTo(right.observer.id);
    });

    return List<StudioObservationRoute>.unmodifiable(routes);
  }
}

class _Hop {
  const _Hop({
    required this.nodeId,
    required this.distance,
    required this.path,
  });

  final String nodeId;
  final int distance;
  final List<String> path;
}

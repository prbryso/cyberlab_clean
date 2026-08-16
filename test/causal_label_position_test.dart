import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:systems_studio/engine/ui/widgets/graphs/system_graph_canvas.dart';

/// A connector's label has to be readable, which means not being underneath
/// the boxes the connector joins.
void main() {
  const labelSize = Size(120, 14);

  /// The rectangle a label of [labelSize] would occupy at [origin].
  Rect rectAt(Offset origin) => origin & labelSize;

  /// Two boxes side by side, with the connector running between their facing
  /// edges — the ordinary horizontal case.
  const leftNode = Rect.fromLTWH(0, 100, 190, 92);
  const rightNode = Rect.fromLTWH(300, 100, 190, 92);

  group('a horizontal connector', () {
    test('puts its label above the line, clear of both boxes', () {
      final origin = causalLabelOrigin(
        start: const Offset(190, 146),
        end: const Offset(300, 146),
        labelSize: labelSize,
        obstacles: const [leftNode, rightNode],
      );

      final label = rectAt(origin);

      expect(label.overlaps(leftNode), isFalse);
      expect(label.overlaps(rightNode), isFalse);

      // Above, which is where a reader looks for it.
      expect(label.center.dy, lessThan(146));
    });

    test('it stays with the connector rather than wandering off', () {
      final origin = causalLabelOrigin(
        start: const Offset(190, 146),
        end: const Offset(300, 146),
        labelSize: labelSize,
        obstacles: const [leftNode, rightNode],
      );

      final label = rectAt(origin);

      // Horizontally centred on the connector it describes.
      expect(label.center.dx, closeTo(245, 0.01));

      // And near it: association has to survive being moved. The label is
      // wider than the gap between the boxes, so it clears their full height
      // — that is the most it should ever need to travel.
      expect((label.center.dy - 146).abs(), lessThan(100));
    });
  });

  group('a connector whose midpoint lands on a box', () {
    // Boxes close enough that the straight midpoint falls inside one — the
    // case that was putting text behind a node.
    const crowdingNode = Rect.fromLTWH(200, 120, 190, 92);

    test('the label is pushed clear, with a margin', () {
      final origin = causalLabelOrigin(
        start: const Offset(150, 166),
        end: const Offset(420, 166),
        labelSize: labelSize,
        obstacles: const [crowdingNode],
      );

      final label = rectAt(origin);

      expect(
        label.overlaps(crowdingNode),
        isFalse,
        reason: 'the midpoint sits inside this box, so the label cannot',
      );

      expect(
        label.bottom,
        lessThanOrEqualTo(crowdingNode.top),
        reason: 'clearing it means clearing it entirely',
      );
    });
  });

  group('a diagonal connector', () {
    // Descending left-to-right, as an actor above acting on a component below.
    const upperNode = Rect.fromLTWH(0, 0, 190, 92);
    const lowerNode = Rect.fromLTWH(260, 220, 190, 92);

    test('its label clears both ends', () {
      final origin = causalLabelOrigin(
        start: const Offset(190, 46),
        end: const Offset(260, 266),
        labelSize: labelSize,
        obstacles: const [upperNode, lowerNode],
      );

      final label = rectAt(origin);

      expect(label.overlaps(upperNode), isFalse);
      expect(label.overlaps(lowerNode), isFalse);
    });

    test('it is offset perpendicular to the path, not along it', () {
      const start = Offset(190, 46);
      const end = Offset(260, 266);

      final origin = causalLabelOrigin(
        start: start,
        end: end,
        labelSize: labelSize,
        obstacles: const [],
      );

      final label = rectAt(origin);
      const midpoint = Offset((190 + 260) / 2, (46 + 266) / 2);

      final displacement = label.center - midpoint;
      final direction = end - start;

      // Perpendicular means the dot product with the connector is zero.
      final dot =
          displacement.dx * direction.dx + displacement.dy * direction.dy;

      expect(dot.abs(), lessThan(0.01));
    });
  });

  group('degenerate and crowded cases', () {
    test('a zero-length connector still produces a usable position', () {
      // Two coincident anchors give no direction, so there is no meaningful
      // perpendicular and no "above". The contract is that the result is
      // usable and off the point — not that it lies in any given direction.
      const point = Offset(100, 100);

      final origin = causalLabelOrigin(
        start: point,
        end: point,
        labelSize: labelSize,
        obstacles: const [],
      );

      expect(origin.dx.isFinite, isTrue);
      expect(origin.dy.isFinite, isTrue);

      final label = rectAt(origin);

      expect(label.size, labelSize);
      expect(label.isEmpty, isFalse);

      // Displaced from the point rather than centred on it. Which way it
      // goes is not something the algorithm promises here.
      expect((label.center - point).distance, greaterThan(0));
    });

    test('a zero-length connector still clears a box when it can', () {
      const point = Offset(100, 100);
      const overPoint = Rect.fromLTWH(90, 90, 20, 20);

      final origin = causalLabelOrigin(
        start: point,
        end: point,
        labelSize: labelSize,
        obstacles: const [overPoint],
      );

      expect(
        rectAt(origin).overlaps(overPoint),
        isFalse,
        reason: 'having no direction is not a reason to sit on a node',
      );
    });

    test('it tries the other side when the preferred one is blocked', () {
      // A box directly above the connector, nothing below it.
      const above = Rect.fromLTWH(0, 0, 600, 195);

      final origin = causalLabelOrigin(
        start: const Offset(100, 200),
        end: const Offset(400, 200),
        labelSize: labelSize,
        obstacles: const [above],
      );

      final label = rectAt(origin);

      expect(label.overlaps(above), isFalse);
      expect(
        label.center.dy,
        greaterThan(200),
        reason: 'below is better than hidden',
      );
    });

    test('enclosed on every side, it still returns rather than looping', () {
      const everywhere = Rect.fromLTWH(-1000, -1000, 4000, 4000);

      final origin = causalLabelOrigin(
        start: const Offset(100, 200),
        end: const Offset(400, 200),
        labelSize: labelSize,
        obstacles: const [everywhere],
      );

      // No clear position exists. Sitting just off the connector is still
      // better than sitting on it, and the search is bounded.
      expect(origin.dx.isFinite, isTrue);
      expect(rectAt(origin).center.dy, lessThan(200));
    });
  });
}

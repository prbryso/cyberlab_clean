import 'package:systems_studio/engine/perspectives/overview/overview_view_model.dart';
import 'package:systems_studio/engine/perspectives/studio_perspective.dart';

/// What an element is, contains, and connects to.
///
/// Node-oriented by nature: it summarises a thing, not a connection between
/// things. When a relationship is selected it says so, rather than quietly
/// describing one of the endpoints. Substituting a different subject would
/// tell the user something false about what they are looking at.
///
/// This file is intentionally free of Flutter dependencies. Rendering the
/// result is a separate concern.
class OverviewPerspective extends StudioPerspective {
  const OverviewPerspective();

  static const String perspectiveId = 'overview';

  @override
  String get id => perspectiveId;

  @override
  String get title => 'Overview';

  @override
  String get description =>
      'Understand the purpose, structure, context, and important elements of '
      'the selected system.';

  @override
  StudioPerspectiveView view(StudioPerspectiveRequest request) {
    final selected = request.selectedElement;

    if (selected == null) {
      return const StudioPerspectiveUnsupported(
        perspectiveId: perspectiveId,
        reason: StudioPerspectiveUnsupportedReason.noSelection,
        message: 'Select an element to see an overview of it.',
      );
    }

    if (selected.isRelationship) {
      return StudioPerspectiveUnsupported(
        perspectiveId: perspectiveId,
        reason: StudioPerspectiveUnsupportedReason.relationshipNotSupported,
        message:
            'Overview describes an element. Select one end of this '
            'relationship to see an overview of it.',
        requestedElement: selected,
      );
    }

    final node = request.session.graph.nodeById(selected.id);

    if (node == null) {
      return StudioPerspectiveUnsupported(
        perspectiveId: perspectiveId,
        reason: StudioPerspectiveUnsupportedReason.elementNotFound,
        message: 'That element is not part of this system.',
        requestedElement: selected,
      );
    }

    return OverviewPerspectiveView(
      perspectiveId: perspectiveId,
      model: OverviewViewModel.fromSession(
        session: request.session,
        selectedNode: node,
      ),
    );
  }
}

/// The semantic result of the Overview perspective.
class OverviewPerspectiveView extends StudioPerspectiveView {
  const OverviewPerspectiveView({
    required super.perspectiveId,
    required this.model,
  });

  final OverviewViewModel model;
}

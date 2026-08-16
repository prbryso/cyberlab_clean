import 'package:systems_studio/engine/graph/graph_engine.dart';
import 'package:systems_studio/engine/models/studio_element_ref.dart';
import 'package:systems_studio/engine/simulation/simulation_run.dart';

/// Base contract for every graph-driven System Studio perspective.
///
/// A perspective is a reusable way of understanding the same system. It
/// answers a class of question — what is this, how is it organised, what does
/// this actor know — over the same graph and, where relevant, the same run.
///
/// A perspective produces a **semantic view model**, not a widget. That is the
/// whole point of the layer: the same result must be usable by UI rendering,
/// narration, export, and AI grounding. A widget can serve only the first.
/// Rendering is a separate concern that consumes what is produced here.
///
/// This file is intentionally free of Flutter dependencies, so the semantic
/// engine stays usable without a UI.
abstract class StudioPerspective {
  const StudioPerspective();

  /// Stable identifier used by PerspectiveCatalog.
  String get id;

  /// Human-readable title.
  String get title;

  /// Short explanation of what this perspective helps someone understand.
  String get description;

  /// Produces the semantic view for [request].
  StudioPerspectiveView view(StudioPerspectiveRequest request);
}

/// Everything a perspective may consult.
///
/// Bundled into one object so the contract does not change shape every time a
/// perspective needs a new input.
class StudioPerspectiveRequest {
  const StudioPerspectiveRequest({
    required this.session,
    this.selectedElement,
    this.run,
  });

  /// The validated graph and its query helper.
  final StudioGraphSession session;

  /// What the user is currently examining, if anything.
  ///
  /// May address a node or a relationship. A perspective decides how — or
  /// whether — it interprets each kind, and says so in its result rather than
  /// substituting something else.
  final StudioElementRef? selectedElement;

  /// The live exploration, when one is in progress.
  ///
  /// Perspectives that describe structure alone do not need it. Perspectives
  /// that describe knowledge cannot work without it.
  final SimulationRun? run;

  bool get hasRun => run != null;
}

/// The semantic result of a perspective.
///
/// Not sealed: each perspective's view type lives beside the perspective that
/// produces it, in its own library, and a sealed supertype could only be
/// extended from this file. Consumers therefore test for the variant they
/// handle. Every consumer must handle [StudioPerspectiveUnsupported], since
/// any perspective may decline any request.
abstract class StudioPerspectiveView {
  const StudioPerspectiveView({required this.perspectiveId});

  /// ID of the perspective that produced this view.
  final String perspectiveId;
}

/// Why a perspective could not produce a view.
enum StudioPerspectiveUnsupportedReason {
  /// The selection addresses a relationship and this perspective describes
  /// elements.
  relationshipNotSupported,

  /// Nothing is selected and this perspective needs a subject.
  noSelection,

  /// The selection does not resolve against the current graph.
  elementNotFound,

  /// This perspective describes a run and none is in progress.
  runRequired,

  /// The selected element is not of a kind this perspective describes.
  wrongElementKind,
}

/// A perspective declining to describe this request.
///
/// Declining explicitly matters. A perspective that quietly substitutes a
/// different subject — showing a relationship's source node when a
/// relationship was selected — tells the user something false about what they
/// are looking at. Saying "I do not describe this" is honest and lets a
/// renderer offer something better.
class StudioPerspectiveUnsupported extends StudioPerspectiveView {
  const StudioPerspectiveUnsupported({
    required super.perspectiveId,
    required this.reason,
    required this.message,
    this.requestedElement,
  });

  final StudioPerspectiveUnsupportedReason reason;

  /// Plain explanation suitable for display or narration.
  final String message;

  /// What was asked for, so a renderer can offer an alternative.
  final StudioElementRef? requestedElement;
}

import 'package:systems_studio/engine/models/studio_system_detail.dart';

import 'systems_studio_graph.dart';

/// Entry point for the Systems Studio self-model library.
///
/// Libraries describe systems. The engine interprets those descriptions.
class SystemsStudioLibrary {
  const SystemsStudioLibrary._();

  static List<StudioSystemDetail> systems() {
    return [
      StudioSystemDetail(
        systemId: 'systems_studio',
        summary:
            'Systems Studio is an interactive platform for understanding '
            'complex systems through visualization, exploration, simulation, '
            'and multiple perspectives.',
        purpose:
            'Provide a shared system model through which people and AI can '
            'explore, analyze, explain, and improve complex systems.',
        graph: SystemsStudioGraph.create(),
      ),
    ];
  }
}

import 'package:systems_studio/engine/models/studio_system_graph.dart';

class SystemsStudioGraph {
  static StudioSystemGraph create() {
    return StudioSystemGraph(
      systemId: 'systems_studio',
      nodes: [
        StudioGraphNode(
          id: 'systems_studio',
          label: 'Systems Studio',
          type: StudioGraphNodeType.system,
          description:
              'An interactive platform for understanding complex systems through visualization, exploration, simulation, and multiple perspectives.',
        ),

        StudioGraphNode(
          id: 'engine',
          label: 'Engine',
          type: StudioGraphNodeType.subsystem,
          parentId: 'systems_studio',
          description:
              'Core capabilities that provide graphing, perspectives, workspace, and system reasoning.',
        ),

        StudioGraphNode(
          id: 'libraries',
          label: 'Libraries',
          type: StudioGraphNodeType.subsystem,
          parentId: 'systems_studio',
          description:
              'Domain-specific systems modeled using the Systems Studio engine.',
        ),

        StudioGraphNode(
          id: 'cyber_lab',
          label: 'Cyber Lab',
          type: StudioGraphNodeType.subsystem,
          parentId: 'libraries',
          description: 'Cybersecurity systems and learning environments.',
        ),

        StudioGraphNode(
          id: 'workspace',
          label: 'System Workspace',
          type: StudioGraphNodeType.component,
          parentId: 'engine',
          description: 'Interactive environment for exploring system models.',
        ),

        StudioGraphNode(
          id: 'graph_engine',
          label: 'Graph Engine',
          type: StudioGraphNodeType.component,
          parentId: 'engine',
          description:
              'Provides system relationships, navigation, and analysis.',
        ),
      ],
      relationships: [],
    );
  }
}

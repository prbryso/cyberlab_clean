import 'package:systems_studio/engine/models/system_diagram.dart';

const passwordUserDiagram = SystemDiagram(
  title: "User Perspective",
  description: "How a normal login works.",
  nodes: [
    DiagramNode(id: "user", label: "User", type: DiagramNodeType.user),
    DiagramNode(
      id: "password",
      label: "Enter Password",
      type: DiagramNodeType.process,
    ),
    DiagramNode(
      id: "server",
      label: "Authentication Server",
      type: DiagramNodeType.system,
    ),
    DiagramNode(
      id: "success",
      label: "Access Granted",
      type: DiagramNodeType.success,
    ),
  ],
);

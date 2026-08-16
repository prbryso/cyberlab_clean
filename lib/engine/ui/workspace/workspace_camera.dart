import 'package:flutter/widgets.dart';

class WorkspaceCamera {
  WorkspaceCamera();

  final TransformationController transformationController =
      TransformationController();

  void dispose() {
    transformationController.dispose();
  }

  void reset() {
    transformationController.value = Matrix4.identity();
  }
}

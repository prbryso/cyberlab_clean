import 'package:flutter/foundation.dart';

import 'package:systems_studio/engine/models/system_model.dart';
import 'package:systems_studio/engine/models/system_simulation.dart';

/// ViewModel for an interactive system lesson.
///
/// Owns:
/// • SystemModel
/// • SystemSimulation
/// • Current Simulation Step
/// • Selected Node
///
/// Widgets should read state from this class instead of maintaining
/// their own copies.
class SimulationController extends ChangeNotifier {
  SimulationController({SystemModel? model, SystemSimulation? simulation})
    : _model = model,
      _simulation = simulation;

  SystemModel? _model;
  SystemSimulation? _simulation;

  int _currentStepIndex = -1;
  bool _isRunning = false;

  SystemNode? _selectedNode;

  //--------------------------------------------------------------------------
  // Public properties
  //--------------------------------------------------------------------------

  SystemModel? get model => _model;

  SystemSimulation? get simulation => _simulation;

  SystemNode? get selectedNode => _selectedNode;

  bool get hasModel => _model != null;

  bool get hasSimulation => _simulation != null && !_simulation!.isEmpty;

  bool get hasStarted => _currentStepIndex >= 0;

  bool get isRunning => _isRunning;

  bool get isFinished =>
      hasSimulation && _currentStepIndex >= _simulation!.stepCount - 1;

  int get currentStepIndex => _currentStepIndex;

  SimulationStep? get currentStep {
    if (!hasSimulation || !hasStarted) {
      return null;
    }

    return _simulation!.steps[_currentStepIndex];
  }

  double get progress {
    if (!hasSimulation) {
      return 0.0;
    }

    if (_currentStepIndex < 0) {
      return 0.0;
    }

    return (_currentStepIndex + 1) / _simulation!.stepCount;
  }

  //--------------------------------------------------------------------------
  // Loading
  //--------------------------------------------------------------------------

  void loadModel(SystemModel model) {
    _model = model;
    _selectedNode = null;
    notifyListeners();
  }

  void loadSimulation(SystemSimulation simulation) {
    _simulation = simulation;
    reset();
  }

  void load({
    required SystemModel model,
    required SystemSimulation simulation,
  }) {
    _model = model;
    _simulation = simulation;
    reset();
  }

  //--------------------------------------------------------------------------
  // Node Selection
  //--------------------------------------------------------------------------

  void selectNode(SystemNode node) {
    _selectedNode = node;
    notifyListeners();
  }

  SystemNode? findNode(String id) {
    if (_model == null) {
      return null;
    }

    for (final node in _model!.nodes) {
      if (node.id == id) {
        return node;
      }
    }

    return null;
  }

  //--------------------------------------------------------------------------
  // Simulation
  //--------------------------------------------------------------------------

  void start() {
    if (!hasSimulation) {
      return;
    }

    _isRunning = true;
    _currentStepIndex = 0;

    _syncSelectedNode();

    notifyListeners();
  }

  void next() {
    if (!hasSimulation) {
      return;
    }

    if (_currentStepIndex >= _simulation!.stepCount - 1) {
      _isRunning = false;
      notifyListeners();
      return;
    }

    _currentStepIndex++;

    _syncSelectedNode();

    notifyListeners();
  }

  void previous() {
    if (!hasSimulation) {
      return;
    }

    if (_currentStepIndex <= 0) {
      _currentStepIndex = 0;
    } else {
      _currentStepIndex--;
    }

    _syncSelectedNode();

    notifyListeners();
  }

  void goToStep(int index) {
    if (!hasSimulation) {
      return;
    }

    if (index < 0 || index >= _simulation!.stepCount) {
      return;
    }

    _currentStepIndex = index;

    _syncSelectedNode();

    notifyListeners();
  }

  void reset() {
    _currentStepIndex = -1;
    _isRunning = false;
    _selectedNode = null;

    notifyListeners();
  }

  //--------------------------------------------------------------------------
  // Internal helpers
  //--------------------------------------------------------------------------

  void _syncSelectedNode() {
    final step = currentStep;

    if (step == null) {
      _selectedNode = null;
      return;
    }

    _selectedNode = findNode(step.nodeId);
  }
}

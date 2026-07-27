import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:systems_studio/engine/controllers/simulation_controller.dart';

enum PlayerState { idle, starting, playing, paused, finished }

class SimulationPlayer extends ChangeNotifier {
  SimulationPlayer({
    required this.controller,
    this.stepDuration = const Duration(seconds: 2),
  });

  final SimulationController controller;

  Duration stepDuration;

  double playbackSpeed = 1.0;

  Timer? _timer;

  PlayerState _state = PlayerState.idle;

  PlayerState get state => _state;

  bool get isPlaying => _state == PlayerState.playing;

  bool get isPaused => _state == PlayerState.paused;

  bool get isIdle => _state == PlayerState.idle;

  bool get isFinished => _state == PlayerState.finished;

  //------------------------------------------------------------------
  // Playback
  //------------------------------------------------------------------

  void play() {
    if (!controller.hasSimulation) {
      return;
    }

    if (controller.isFinished) {
      controller.reset();
    }

    controller.start();

    _startTimer();

    _setState(PlayerState.playing);
  }

  void pause() {
    _timer?.cancel();
    _timer = null;

    _setState(PlayerState.paused);
  }

  void resume() {
    if (!controller.hasStarted) {
      play();
      return;
    }

    _startTimer();

    _setState(PlayerState.playing);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;

    controller.reset();

    _setState(PlayerState.idle);
  }

  //------------------------------------------------------------------
  // Speed
  //------------------------------------------------------------------

  void setPlaybackSpeed(double speed) {
    if (speed <= 0) {
      return;
    }

    playbackSpeed = speed;

    if (isPlaying) {
      _timer?.cancel();
      _startTimer();
    }

    notifyListeners();
  }

  //------------------------------------------------------------------
  // Internal
  //------------------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();

    final duration = Duration(
      milliseconds: (stepDuration.inMilliseconds / playbackSpeed).round(),
    );

    _timer = Timer.periodic(duration, (_) {
      if (controller.isFinished) {
        stop();

        _setState(PlayerState.finished);

        return;
      }

      controller.next();
    });
  }

  void _setState(PlayerState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

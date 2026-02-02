import 'dart:async';

import 'package:flutter/foundation.dart';

enum TimerStatus { idle, running, paused, completed }

class TimerProvider extends ChangeNotifier {
  static const int _focusMinutes = 25;
  static const int _totalSeconds = _focusMinutes * 60;

  int _remainingSeconds = _totalSeconds;
  Timer? _timer;
  TimerStatus _status = TimerStatus.idle;

  int get remainingSeconds => _remainingSeconds;
  TimerStatus get status => _status;
  int get totalSeconds => _totalSeconds;
  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isCompleted => _status == TimerStatus.completed;

  double get progress => 1 - (_remainingSeconds / _totalSeconds);

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void start() {
    if (_status == TimerStatus.completed) {
      reset();
    }
    _status = TimerStatus.running;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    if (_status != TimerStatus.running) return;
    _status = TimerStatus.paused;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void resume() {
    if (_status != TimerStatus.paused) return;
    start();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = _totalSeconds;
    _status = TimerStatus.idle;
    notifyListeners();
  }

  void _tick() {
    if (_remainingSeconds <= 0) {
      _timer?.cancel();
      _timer = null;
      _status = TimerStatus.completed;
      notifyListeners();
      return;
    }
    _remainingSeconds--;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

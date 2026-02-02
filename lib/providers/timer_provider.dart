import 'dart:async';

import 'package:flutter/foundation.dart';

enum TimerStatus { idle, running, paused, completed }

enum TimerMode { focus, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  static const List<int> durationOptions = [15, 25, 45, 60];
  static const int shortBreakMinutes = 5;
  static const int longBreakMinutes = 15;

  int _durationMinutes = 25;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  TimerStatus _status = TimerStatus.idle;
  TimerMode _mode = TimerMode.focus;
  int _completedSessions = 0;
  String _currentTask = '';

  int get durationMinutes => _durationMinutes;
  int get remainingSeconds => _remainingSeconds;
  TimerStatus get status => _status;
  TimerMode get mode => _mode;
  int get totalSeconds => _durationMinutes * 60;
  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isCompleted => _status == TimerStatus.completed;
  bool get isFocusMode => _mode == TimerMode.focus;
  bool get isBreakMode => _mode != TimerMode.focus;
  int get completedSessions => _completedSessions;
  String get currentTask => _currentTask;

  double get progress =>
      totalSeconds > 0 ? 1 - (_remainingSeconds / totalSeconds) : 0.0;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get modeLabel {
    switch (_mode) {
      case TimerMode.focus:
        return 'Focus Session';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  void setCurrentTask(String task) {
    _currentTask = task;
    notifyListeners();
  }

  void setDuration(int minutes) {
    if (!durationOptions.contains(minutes)) return;
    _durationMinutes = minutes;
    if (_status == TimerStatus.idle || _status == TimerStatus.paused) {
      _remainingSeconds = minutes * 60;
    } else if (_status == TimerStatus.running) {
      _remainingSeconds = minutes * 60;
    } else if (_status == TimerStatus.completed) {
      _remainingSeconds = minutes * 60;
      _status = TimerStatus.idle;
    }
    notifyListeners();
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
    _remainingSeconds = _durationMinutes * 60;
    _status = TimerStatus.idle;
    notifyListeners();
  }

  void startBreak({bool isLong = false}) {
    _timer?.cancel();
    _timer = null;
    _mode = isLong ? TimerMode.longBreak : TimerMode.shortBreak;
    _durationMinutes = isLong ? longBreakMinutes : shortBreakMinutes;
    _remainingSeconds = _durationMinutes * 60;
    _status = TimerStatus.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void skipBreak() {
    _timer?.cancel();
    _timer = null;
    _mode = TimerMode.focus;
    _durationMinutes = 25;
    _remainingSeconds = _durationMinutes * 60;
    _status = TimerStatus.idle;
    notifyListeners();
  }

  void _tick() {
    if (_remainingSeconds <= 0) {
      _timer?.cancel();
      _timer = null;
      _status = TimerStatus.completed;

      if (_mode == TimerMode.focus) {
        _completedSessions++;
      }

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

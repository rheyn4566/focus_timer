import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keySessionHistory = 'session_history';
const String _keyTotalSessions = 'total_sessions';
const String _keyTotalMinutes = 'total_minutes';
const String _keyCurrentStreak = 'current_streak';
const String _keyLastSessionDate = 'last_session_date';
const String _keySessionsWithTask = 'sessions_with_task';

class SessionRecord {
  final DateTime timestamp;
  final int durationMinutes;
  final String task;
  final bool completed;

  SessionRecord({
    required this.timestamp,
    required this.durationMinutes,
    required this.task,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'duration': durationMinutes,
    'task': task,
    'completed': completed,
  };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
    timestamp: DateTime.parse(json['timestamp']),
    durationMinutes: json['duration'],
    task: json['task'] ?? '',
    completed: json['completed'] ?? true,
  );
}

class StatsProvider extends ChangeNotifier {
  int _totalSessions = 0;
  int _totalMinutes = 0;
  int _currentStreak = 0;
  int _todaySessions = 0;
  int _todayMinutes = 0;
  int _sessionsWithTask = 0;
  List<SessionRecord> _sessionHistory = [];

  int get totalSessions => _totalSessions;
  int get totalMinutes => _totalMinutes;
  int get currentStreak => _currentStreak;
  int get todaySessions => _todaySessions;
  int get todayMinutes => _todayMinutes;
  int get sessionsWithTask => _sessionsWithTask;
  List<SessionRecord> get sessionHistory => _sessionHistory;

  String get totalTimeFormatted {
    final hours = _totalMinutes ~/ 60;
    final mins = _totalMinutes % 60;
    return '${hours}h ${mins}m';
  }

  String get todayTimeFormatted {
    final hours = _todayMinutes ~/ 60;
    final mins = _todayMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  StatsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalSessions = prefs.getInt(_keyTotalSessions) ?? 0;
      _totalMinutes = prefs.getInt(_keyTotalMinutes) ?? 0;
      _currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;

      final historyJson = prefs.getString(_keySessionHistory);
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _sessionHistory = decoded
            .map((e) => SessionRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      _calculateTodayStats();
      _calculateSessionsWithTask();
      _updateStreak();
      notifyListeners();
    } catch (_) {}
  }

  void _calculateSessionsWithTask() {
    _sessionsWithTask = _sessionHistory
        .where((s) => s.completed && s.task.trim().isNotEmpty)
        .length;
  }

  void _calculateTodayStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _todaySessions = 0;
    _todayMinutes = 0;

    for (final session in _sessionHistory) {
      final sessionDate = DateTime(
        session.timestamp.year,
        session.timestamp.month,
        session.timestamp.day,
      );
      if (sessionDate == today && session.completed) {
        _todaySessions++;
        _todayMinutes += session.durationMinutes;
      }
    }
  }

  Future<void> _updateStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDateStr = prefs.getString(_keyLastSessionDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastDateStr != null) {
        final lastDate = DateTime.parse(lastDateStr);
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final difference = today.difference(lastDay).inDays;

        if (difference == 0) {
          // Same day, keep streak
        } else if (difference == 1) {
          // Consecutive day, increment streak
          _currentStreak++;
        } else {
          // Streak broken
          _currentStreak = 1;
        }
      } else {
        _currentStreak = 1;
      }

      await prefs.setString(_keyLastSessionDate, today.toIso8601String());
      await prefs.setInt(_keyCurrentStreak, _currentStreak);
    } catch (_) {}
  }

  Future<void> recordSession({
    required int durationMinutes,
    required String task,
    bool completed = true,
  }) async {
    final session = SessionRecord(
      timestamp: DateTime.now(),
      durationMinutes: durationMinutes,
      task: task,
      completed: completed,
    );

    _sessionHistory.insert(0, session);
    if (_sessionHistory.length > 100) {
      _sessionHistory = _sessionHistory.sublist(0, 100);
    }

    if (completed) {
      _totalSessions++;
      _totalMinutes += durationMinutes;
      _todaySessions++;
      _todayMinutes += durationMinutes;
      if (task.trim().isNotEmpty) {
        _sessionsWithTask++;
      }
      await _updateStreak();
    }

    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyTotalSessions, _totalSessions);
      await prefs.setInt(_keyTotalMinutes, _totalMinutes);
      await prefs.setInt(_keySessionsWithTask, _sessionsWithTask);

      final historyJson = jsonEncode(
        _sessionHistory.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_keySessionHistory, historyJson);
    } catch (_) {}
  }

  List<SessionRecord> getSessionsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _sessionHistory.where((session) {
      final sessionDate = DateTime(
        session.timestamp.year,
        session.timestamp.month,
        session.timestamp.day,
      );
      return sessionDate == targetDate;
    }).toList();
  }
}

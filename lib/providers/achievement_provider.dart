import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyUnlockedAchievements = 'unlocked_achievements';

enum AchievementId {
  firstSteps,
  gettingStarted,
  dedicated,
  marathon,
  earlyBird,
  nightOwl,
  streakStarter,
  weekWarrior,
  taskMaster,
  century,
  timeMaster,
  focusChampion,
}

class Achievement {
  final AchievementId id;
  final String name;
  final String description;
  final IconData icon;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  static const Map<AchievementId, Achievement> all = {
    AchievementId.firstSteps: Achievement(
      id: AchievementId.firstSteps,
      name: 'First Steps',
      description: 'Complete your first focus session',
      icon: Icons.flag_rounded,
    ),
    AchievementId.gettingStarted: Achievement(
      id: AchievementId.gettingStarted,
      name: 'Getting Started',
      description: 'Complete 5 focus sessions',
      icon: Icons.eco_rounded,
    ),
    AchievementId.dedicated: Achievement(
      id: AchievementId.dedicated,
      name: 'Dedicated',
      description: 'Complete 10 focus sessions',
      icon: Icons.star_rounded,
    ),
    AchievementId.marathon: Achievement(
      id: AchievementId.marathon,
      name: 'Marathon',
      description: 'Complete a 60-minute focus session',
      icon: Icons.directions_run_rounded,
    ),
    AchievementId.earlyBird: Achievement(
      id: AchievementId.earlyBird,
      name: 'Early Bird',
      description: 'Complete a session before 9 AM',
      icon: Icons.wb_sunny_rounded,
    ),
    AchievementId.nightOwl: Achievement(
      id: AchievementId.nightOwl,
      name: 'Night Owl',
      description: 'Complete a session after 10 PM',
      icon: Icons.nightlight_round,
    ),
    AchievementId.streakStarter: Achievement(
      id: AchievementId.streakStarter,
      name: 'Streak Starter',
      description: 'Maintain a 3-day streak',
      icon: Icons.local_fire_department_rounded,
    ),
    AchievementId.weekWarrior: Achievement(
      id: AchievementId.weekWarrior,
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: Icons.fitness_center_rounded,
    ),
    AchievementId.taskMaster: Achievement(
      id: AchievementId.taskMaster,
      name: 'Task Master',
      description: 'Complete 5 sessions with a task name',
      icon: Icons.task_alt_rounded,
    ),
    AchievementId.century: Achievement(
      id: AchievementId.century,
      name: 'Century',
      description: 'Complete 100 total sessions',
      icon: Icons.looks_one_rounded,
    ),
    AchievementId.timeMaster: Achievement(
      id: AchievementId.timeMaster,
      name: 'Time Master',
      description: 'Reach 10 hours total focus time',
      icon: Icons.timer_rounded,
    ),
    AchievementId.focusChampion: Achievement(
      id: AchievementId.focusChampion,
      name: 'Focus Champion',
      description: 'Complete 50 total sessions',
      icon: Icons.emoji_events_rounded,
    ),
  };
}

class AchievementProvider extends ChangeNotifier {
  Set<AchievementId> _unlocked = {};
  AchievementId? _lastUnlocked;

  Set<AchievementId> get unlocked => Set.unmodifiable(_unlocked);
  AchievementId? get lastUnlocked => _lastUnlocked;
  int get unlockedCount => _unlocked.length;
  int get totalCount => AchievementId.values.length;
  double get progressPercent =>
      totalCount > 0 ? (_unlocked.length / totalCount) * 100 : 0;

  bool isUnlocked(AchievementId id) => _unlocked.contains(id);

  AchievementProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyUnlockedAchievements);
      if (json != null) {
        final List<dynamic> decoded = jsonDecode(json);
        _unlocked = decoded.map((e) => AchievementId.values[e as int]).toSet();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_unlocked.map((e) => e.index).toList());
      await prefs.setString(_keyUnlockedAchievements, json);
    } catch (_) {}
  }

  void _unlock(AchievementId id) {
    if (_unlocked.contains(id)) return;
    _unlocked.add(id);
    _lastUnlocked = id;
    _save();
    notifyListeners();
  }

  void clearLastUnlocked() {
    _lastUnlocked = null;
    notifyListeners();
  }

  void checkAndUnlock({
    required int totalSessions,
    required int totalMinutes,
    required int currentStreak,
    required int sessionsWithTask,
    required int sessionDurationMinutes,
    required DateTime sessionTime,
  }) {
    if (totalSessions >= 1) _unlock(AchievementId.firstSteps);
    if (totalSessions >= 5) _unlock(AchievementId.gettingStarted);
    if (totalSessions >= 10) _unlock(AchievementId.dedicated);
    if (totalSessions >= 50) _unlock(AchievementId.focusChampion);
    if (totalSessions >= 100) _unlock(AchievementId.century);

    if (totalMinutes >= 600) _unlock(AchievementId.timeMaster); // 10 hours
    if (sessionDurationMinutes >= 60) _unlock(AchievementId.marathon);

    final hour = sessionTime.hour;
    if (hour < 9) _unlock(AchievementId.earlyBird);
    if (hour >= 22) _unlock(AchievementId.nightOwl);

    if (currentStreak >= 3) _unlock(AchievementId.streakStarter);
    if (currentStreak >= 7) _unlock(AchievementId.weekWarrior);

    if (sessionsWithTask >= 5) _unlock(AchievementId.taskMaster);
  }
}

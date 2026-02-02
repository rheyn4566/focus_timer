import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String keyNotificationsEnabled = 'notifications_enabled';
const String keyDefaultSoundVolume = 'default_sound_volume';
const String keyAutoStartBreaks = 'auto_start_breaks';
const String keyLongBreakAfter = 'long_break_after';
const String keyFocusModeEnabled = 'focus_mode_enabled';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  double _defaultSoundVolume = 0.5;
  bool _autoStartBreaks = true;
  int _longBreakAfter = 4;
  bool _focusModeEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  double get defaultSoundVolume => _defaultSoundVolume;
  int get defaultSoundVolumePercent => (_defaultSoundVolume * 100).round();
  bool get autoStartBreaks => _autoStartBreaks;
  int get longBreakAfter => _longBreakAfter;
  bool get focusModeEnabled => _focusModeEnabled;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
      _defaultSoundVolume = prefs.getDouble(keyDefaultSoundVolume) ?? 0.5;
      _autoStartBreaks = prefs.getBool(keyAutoStartBreaks) ?? true;
      _longBreakAfter = prefs.getInt(keyLongBreakAfter) ?? 4;
      _focusModeEnabled = prefs.getBool(keyFocusModeEnabled) ?? true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotificationsEnabled, value);
    notifyListeners();
  }

  Future<void> setDefaultSoundVolume(double value) async {
    _defaultSoundVolume = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyDefaultSoundVolume, _defaultSoundVolume);
    notifyListeners();
  }

  Future<void> setAutoStartBreaks(bool value) async {
    _autoStartBreaks = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyAutoStartBreaks, value);
    notifyListeners();
  }

  Future<void> setLongBreakAfter(int value) async {
    _longBreakAfter = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLongBreakAfter, value);
    notifyListeners();
  }

  Future<void> setFocusModeEnabled(bool value) async {
    _focusModeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyFocusModeEnabled, value);
    notifyListeners();
  }

  /// Called by SoundProvider to get default volume when enabling a sound.
  static Future<double> getDefaultVolumeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(keyDefaultSoundVolume) ?? 0.5;
    } catch (_) {
      return 0.5;
    }
  }
}

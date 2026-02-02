import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_provider.dart';

enum SoundType { rain, forest, fire }

class SoundProvider extends ChangeNotifier {
  final Map<SoundType, AudioPlayer> _players = {
    SoundType.rain: AudioPlayer(),
    SoundType.forest: AudioPlayer(),
    SoundType.fire: AudioPlayer(),
  };

  final Map<SoundType, double> _volumes = {
    SoundType.rain: 0.0,
    SoundType.forest: 0.0,
    SoundType.fire: 0.0,
  };

  static const Map<SoundType, String> _volumeKeys = {
    SoundType.rain: 'sound_volume_rain',
    SoundType.forest: 'sound_volume_forest',
    SoundType.fire: 'sound_volume_fire',
  };

  static const Map<SoundType, String> _assetPaths = {
    SoundType.rain: 'audio/rain.mp3',
    SoundType.forest: 'audio/forest.mp3',
    SoundType.fire: 'audio/fire.mp3',
  };

  double getVolume(SoundType type) => _volumes[type] ?? 0.0;
  bool isPlaying(SoundType type) => (_volumes[type] ?? 0.0) > 0.0;

  SoundProvider() {
    for (final player in _players.values) {
      player.setReleaseMode(ReleaseMode.loop);
    }
    _loadVolumes();
  }

  Future<void> _loadVolumes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final type in SoundType.values) {
        final v = prefs.getDouble(_volumeKeys[type]!);
        if (v != null) _volumes[type] = v;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveVolume(SoundType type, double volume) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_volumeKeys[type]!, volume);
    } catch (_) {}
  }

  Future<void> setVolume(SoundType type, double volume) async {
    volume = volume.clamp(0.0, 1.0);
    _volumes[type] = volume;

    final player = _players[type]!;
    await player.setVolume(volume);

    if (volume > 0) {
      try {
        if (player.state != PlayerState.playing) {
          await player.setSource(AssetSource(_assetPaths[type]!));
          await player.resume();
        }
      } catch (e) {
        _volumes[type] = 0.0;
        rethrow;
      }
    } else {
      await player.stop();
    }
    await _saveVolume(type, volume);
    notifyListeners();
  }

  Future<void> toggleSound(SoundType type) async {
    final current = _volumes[type] ?? 0.0;
    if (current > 0) {
      await setVolume(type, 0.0);
    } else {
      final defaultVol = await SettingsProvider.getDefaultVolumeFromStorage();
      await setVolume(type, defaultVol);
    }
  }

  /// Pause all currently playing sounds
  Future<void> pauseAll() async {
    for (final player in _players.values) {
      if (player.state == PlayerState.playing) {
        await player.pause();
      }
    }
  }

  /// Resume sounds that have volume > 0
  Future<void> resumeAll() async {
    for (final type in SoundType.values) {
      final volume = _volumes[type] ?? 0.0;
      if (volume > 0) {
        final player = _players[type]!;
        if (player.state == PlayerState.paused) {
          await player.resume();
        } else if (player.state != PlayerState.playing) {
          try {
            await player.setSource(AssetSource(_assetPaths[type]!));
            await player.setVolume(volume);
            await player.resume();
          } catch (_) {}
        }
      }
    }
  }

  /// Stop all sounds completely
  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum SoundType { rain, forest, fire, none }

class SoundProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  SoundType _activeSound = SoundType.none;

  SoundType get activeSound => _activeSound;
  bool get isPlaying => _activeSound != SoundType.none;

  static const Map<SoundType, String> _assetPaths = {
    SoundType.rain: 'assets/audio/rain.mp3',
    SoundType.forest: 'assets/audio/forest.mp3',
    SoundType.fire: 'assets/audio/fire.mp3',
  };

  SoundProvider() {
    _player.setReleaseMode(ReleaseMode.loop);
    _player.onPlayerComplete.listen((_) {
      _activeSound = SoundType.none;
      notifyListeners();
    });
  }

  Future<void> toggleSound(SoundType type) async {
    if (_activeSound == type) {
      await stop();
      return;
    }

    await stop();
    _activeSound = type;

    try {
      final path = _assetPaths[type]!.replaceFirst('assets/', '');
      await _player.setSource(AssetSource(path));
      await _player.resume();
    } catch (e) {
      _activeSound = SoundType.none;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _activeSound = SoundType.none;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

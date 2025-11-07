import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for managing sound effects
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> playSound(SoundType type) async {
    if (!_soundEnabled) return;

    // Skip sound playback on web platform until sound files are added
    // Web platform has issues loading MP3 files that don't exist
    if (kIsWeb) {
      // TODO: Add web-compatible sound files or use Web Audio API
      return;
    }

    try {
      // For now, we'll use system beep sounds since we don't have audio files yet
      // In production, you would load actual sound files from assets
      await _audioPlayer.play(AssetSource('sounds/${_getSoundFile(type)}'));
    } catch (e) {
      // Silently fail if sound cannot be played
      // In production, you would log this error
    }
  }

  String _getSoundFile(SoundType type) {
    switch (type) {
      case SoundType.move:
        return 'move.mp3';
      case SoundType.win:
        return 'win.mp3';
      case SoundType.lose:
        return 'lose.mp3';
      case SoundType.draw:
        return 'draw.mp3';
      case SoundType.button:
        return 'button.mp3';
      case SoundType.achievement:
        return 'achievement.mp3';
      case SoundType.undo:
        return 'undo.mp3';
    }
  }

  /// Play move sound
  Future<void> playMove() async => playSound(SoundType.move);

  /// Play win sound
  Future<void> playWin() async => playSound(SoundType.win);

  /// Play lose sound
  Future<void> playLose() async => playSound(SoundType.lose);

  /// Play draw sound
  Future<void> playDraw() async => playSound(SoundType.draw);

  /// Play button click sound
  Future<void> playButton() async => playSound(SoundType.button);

  /// Play achievement unlocked sound
  Future<void> playAchievement() async => playSound(SoundType.achievement);

  /// Play undo sound
  Future<void> playUndo() async => playSound(SoundType.undo);

  void dispose() {
    _audioPlayer.dispose();
  }
}

enum SoundType {
  move,
  win,
  lose,
  draw,
  button,
  achievement,
  undo,
}

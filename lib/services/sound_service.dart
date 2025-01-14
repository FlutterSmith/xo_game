import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for managing sound effects and background music
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _isMusicPlaying = false;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get isMusicPlaying => _isMusicPlaying;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled && _isMusicPlaying) {
      stopMusic();
    } else if (enabled && !_isMusicPlaying) {
      playBackgroundMusic();
    }
  }

  Future<void> playSound(SoundType type) async {
    if (!_soundEnabled) {
      print('[SoundService] Sound disabled, skipping ${type.toString()}');
      return;
    }

    // Skip sound playback on web platform until sound files are added
    // Web platform has issues loading MP3 files that don't exist
    if (kIsWeb) {
      print('[SoundService] Web platform detected, skipping sound');
      return;
    }

    try {
      final soundFile = _getSoundFile(type);
      print('[SoundService] Playing sound: $soundFile for type: ${type.toString()}');

      // Stop any currently playing sound first
      await _audioPlayer.stop();

      // Play the new sound
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
      print('[SoundService] Successfully played sound: $soundFile');
    } catch (e) {
      // Log the error so we can debug issues
      print('[SoundService] ERROR playing sound ${type.toString()}: $e');
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

  /// Play background music (looping)
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled || kIsWeb) return;

    // Stop any currently playing music first to prevent overlap
    if (_isMusicPlaying) {
      await stopMusic();
    }

    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.3); // 30% volume for background music
      await _musicPlayer.play(AssetSource('sounds/music/background.mp3'));
      _isMusicPlaying = true;
    } catch (e) {
      // Silently fail if music cannot be played
      _isMusicPlaying = false;
    }
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
    _isMusicPlaying = false;
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    if (_musicEnabled) {
      await _musicPlayer.resume();
      _isMusicPlaying = true;
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    await _musicPlayer.setVolume(volume);
  }

  void dispose() {
    _audioPlayer.dispose();
    _musicPlayer.dispose();
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

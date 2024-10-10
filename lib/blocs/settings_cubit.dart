import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';

/// Cubit for managing app settings
class SettingsCubit extends Cubit<AppSettings> {
  final DatabaseService _db = DatabaseService.instance;
  final SoundService _soundService = SoundService();
  final VibrationService _vibrationService = VibrationService();

  SettingsCubit() : super(AppSettings.defaultSettings()) {
    loadSettings();
  }

  /// Load settings from database
  Future<void> loadSettings() async {
    final settings = await _db.getSettings();
    _soundService.setSoundEnabled(settings.soundEnabled);
    _vibrationService.setVibrationEnabled(settings.vibrationEnabled);
    emit(settings);
  }

  /// Update player name
  Future<void> updatePlayerName(String name) async {
    final updated = state.copyWith(playerName: name);
    await _db.updateSettings(updated);
    emit(updated);
  }

  /// Toggle sound on/off
  Future<void> toggleSound() async {
    final updated = state.copyWith(soundEnabled: !state.soundEnabled);
    _soundService.setSoundEnabled(updated.soundEnabled);
    await _db.updateSettings(updated);
    emit(updated);
  }

  /// Toggle vibration on/off
  Future<void> toggleVibration() async {
    final updated = state.copyWith(vibrationEnabled: !state.vibrationEnabled);
    _vibrationService.setVibrationEnabled(updated.vibrationEnabled);
    await _db.updateSettings(updated);
    emit(updated);
  }

  /// Update theme mode
  Future<void> updateThemeMode(String themeMode) async {
    final updated = state.copyWith(themeMode: themeMode);
    await _db.updateSettings(updated);
    emit(updated);
  }

  /// Update AI difficulty
  Future<void> updateAIDifficulty(String difficulty) async {
    final updated = state.copyWith(aiDifficulty: difficulty);
    await _db.updateSettings(updated);
    emit(updated);
  }

  /// Update default board size
  Future<void> updateDefaultBoardSize(int size) async {
    final updated = state.copyWith(defaultBoardSize: size);
    await _db.updateSettings(updated);
    emit(updated);
  }

  /// Mark tutorial as completed
  Future<void> completeTutorial() async {
    final updated = state.copyWith(showTutorial: false);
    await _db.updateSettings(updated);
    emit(updated);
  }

  /// Reset tutorial flag
  Future<void> resetTutorial() async {
    final updated = state.copyWith(showTutorial: true);
    await _db.updateSettings(updated);
    emit(updated);
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    final updated = state.copyWith(language: language);
    await _db.updateSettings(updated);
    emit(updated);
  }
}

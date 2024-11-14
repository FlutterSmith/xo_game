import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show debugPrint;
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
    try {
      debugPrint('[SettingsCubit] loadSettings - Starting');
      final settings = await _db.getSettings();
      debugPrint('[SettingsCubit] loadSettings - Got settings: ${settings.playerName}');
      _soundService.setSoundEnabled(settings.soundEnabled);
      _vibrationService.setVibrationEnabled(settings.vibrationEnabled);
      emit(settings);
      debugPrint('[SettingsCubit] loadSettings - Settings emitted successfully');
    } catch (e, stack) {
      debugPrint('[SettingsCubit] ERROR in loadSettings: $e');
      debugPrint('[SettingsCubit] Stack: $stack');
      // Emit default settings on error
      emit(AppSettings.defaultSettings());
    }
  }

  /// Update player name
  Future<void> updatePlayerName(String name) async {
    debugPrint('[SettingsCubit] updatePlayerName - name: $name');
    final updated = state.copyWith(playerName: name);
    debugPrint('[SettingsCubit] updatePlayerName - calling updateSettings');
    await _db.updateSettings(updated);
    debugPrint('[SettingsCubit] updatePlayerName - emitting updated settings');
    emit(updated);
    debugPrint('[SettingsCubit] updatePlayerName - complete');
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

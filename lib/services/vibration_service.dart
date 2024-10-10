import 'package:vibration/vibration.dart';

/// Service for managing haptic feedback
class VibrationService {
  static final VibrationService _instance = VibrationService._internal();
  factory VibrationService() => _instance;
  VibrationService._internal();

  bool _vibrationEnabled = true;
  bool? _hasVibrator;

  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> initialize() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
  }

  Future<void> vibrate({int duration = 50}) async {
    if (!_vibrationEnabled || _hasVibrator == false) return;

    try {
      await Vibration.vibrate(duration: duration);
    } catch (e) {
      // Silently fail if vibration is not supported
    }
  }

  /// Light vibration for button taps
  Future<void> light() async {
    await vibrate(duration: 30);
  }

  /// Medium vibration for moves
  Future<void> medium() async {
    await vibrate(duration: 50);
  }

  /// Strong vibration for game end
  Future<void> strong() async {
    await vibrate(duration: 100);
  }

  /// Success pattern (short-short)
  Future<void> success() async {
    if (!_vibrationEnabled || _hasVibrator == false) return;

    try {
      await Vibration.vibrate(duration: 50);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 50);
    } catch (e) {
      // Silently fail
    }
  }

  /// Error pattern (long)
  Future<void> error() async {
    await vibrate(duration: 200);
  }

  /// Win pattern (short-short-long)
  Future<void> win() async {
    if (!_vibrationEnabled || _hasVibrator == false) return;

    try {
      await Vibration.vibrate(duration: 50);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 50);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 150);
    } catch (e) {
      // Silently fail
    }
  }
}

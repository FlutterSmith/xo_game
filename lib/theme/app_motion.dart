import 'package:flutter/material.dart';

/// Shared animation timings & curves so every motion in the app feels related.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration page = Duration(milliseconds: 420);
  static const Duration celebrate = Duration(milliseconds: 700);

  // Curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.fastOutSlowIn;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack;

  /// Stagger delay for the [i]-th item in an entrance sequence.
  static Duration stagger(int i, {int stepMs = 70, int maxMs = 600}) {
    final ms = (i * stepMs).clamp(0, maxMs);
    return Duration(milliseconds: ms);
  }
}

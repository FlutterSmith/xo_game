import 'package:flutter/material.dart';

/// Single source of truth for color. Brand tokens are vibrant and
/// brightness-independent; surface/text tokens come in light + dark variants
/// via [AppPalette]. NO screen should hardcode a raw Color — pull from here or
/// from `Theme.of(context).colorScheme`.
class AppColors {
  AppColors._();

  // ── Brand (neon-arcade DNA) ────────────────────────────────────────────
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDeep = Color(0xFF6D28D9);
  static const Color pink = Color(0xFFEC4899);
  static const Color teal = Color(0xFF16F2B3);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color rose = Color(0xFFFB7185);

  // ── Marks ──────────────────────────────────────────────────────────────
  static const Color xMark = pink; // X draws in pink
  static const Color oMark = teal; // O draws in teal

  // ── Semantic result ──────────────────────────────────────────────────────
  static const Color win = teal;
  static const Color lose = red;
  static const Color draw = amber;

  // ── Difficulty ───────────────────────────────────────────────────────────
  static const Color easy = teal;
  static const Color medium = amber;
  static const Color hard = rose;
  static const Color impossible = violet;

  // ── Dark surfaces ────────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0A0118);
  static const Color darkBg2 = Color(0xFF1A0B2E);
  static const Color darkSurface = Color(0xFF1A1030);
  static const Color darkSurface2 = Color(0xFF241640);
  static const Color darkText = Color(0xFFF5F3FF);
  static const Color darkTextMuted = Color(0xFFA9A4C7);

  // ── Light surfaces ───────────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF6F4FF);
  static const Color lightBg2 = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF1ECFF);
  static const Color lightText = Color(0xFF1A1036);
  static const Color lightTextMuted = Color(0xFF6B6494);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [violet, pink];
  static const List<Color> coolGradient = [cyan, teal];
  static const List<Color> heroGradient = [violet, pink, teal];
  static const List<Color> winGradient = [teal, cyan];
  static const List<Color> loseGradient = [red, rose];
  static const List<Color> drawGradient = [amber, cyan];

  static const List<Color> darkBgGradient = [
    Color(0xFF0A0118),
    Color(0xFF1A0B2E),
    Color(0xFF0A0118),
  ];
  static const List<Color> lightBgGradient = [
    Color(0xFFF6F4FF),
    Color(0xFFFFFFFF),
    Color(0xFFEDE7FF),
  ];

  static List<Color> bgGradient(Brightness b) =>
      b == Brightness.dark ? darkBgGradient : lightBgGradient;

  /// Distinct color for an X/O mark string.
  static Color markColor(String mark) => mark == 'X' ? xMark : oMark;

  /// Difficulty accent by enum name ('easy'|'medium'|'hard'|'impossible').
  static Color difficulty(String name) {
    switch (name) {
      case 'easy':
        return easy;
      case 'medium':
        return medium;
      case 'hard':
        return hard;
      case 'impossible':
        return impossible;
      default:
        return violet;
    }
  }
}

/// Brightness-specific surface/text tokens. `AppPalette.of(context)` returns the
/// right set based on the active theme brightness.
class AppPalette {
  final Color bg;
  final Color bg2;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color text;
  final Color textMuted;
  final Brightness brightness;

  const AppPalette({
    required this.bg,
    required this.bg2,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.brightness,
  });

  static const AppPalette dark = AppPalette(
    bg: AppColors.darkBg,
    bg2: AppColors.darkBg2,
    surface: AppColors.darkSurface,
    surface2: AppColors.darkSurface2,
    border: Color(0x1AFFFFFF),
    text: AppColors.darkText,
    textMuted: AppColors.darkTextMuted,
    brightness: Brightness.dark,
  );

  static const AppPalette light = AppPalette(
    bg: AppColors.lightBg,
    bg2: AppColors.lightBg2,
    surface: AppColors.lightSurface,
    surface2: AppColors.lightSurface2,
    border: Color(0x1F8B5CF6),
    text: AppColors.lightText,
    textMuted: AppColors.lightTextMuted,
    brightness: Brightness.light,
  );

  bool get isDark => brightness == Brightness.dark;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

import 'package:flutter/material.dart';

/// The only two font families used in the app.
class AppFonts {
  AppFonts._();
  static const String display = 'Poppins'; // headings / numbers / CTAs
  static const String body = 'Inter'; // body / labels
}

/// Builds the app TextTheme from two ink colors (primary text + muted text).
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color text, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 46,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: text,
        height: 1.05,
      ),
      displayMedium: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: text,
        height: 1.1,
      ),
      displaySmall: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: text,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: muted,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: text,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: 0.4,
      ),
    );
  }
}

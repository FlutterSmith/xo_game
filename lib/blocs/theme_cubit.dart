import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_darkTheme);

  // Darko Style - Modern Dark Theme
  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF8b5cf6), // Violet
    scaffoldBackgroundColor: const Color(0xFF0f172a), // Deep Navy
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Raleway',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Raleway',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: Color(0xFFcbd5e0), // Light gray
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: Color(0xFFa0aec0),
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1e293b),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Raleway',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1e293b),
      elevation: 8,
      shadowColor: const Color(0xFF8b5cf6).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8b5cf6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        shadowColor: const Color(0xFF8b5cf6).withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8b5cf6), // Violet
      secondary: Color(0xFFec4899), // Pink
      tertiary: Color(0xFF16f2b3), // Green
      surface: Color(0xFF1e293b),
      background: Color(0xFF0f172a),
      error: Color(0xFFef4444),
    ),
  );

  // Darko Style - Light Mode (for toggle)
  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF8b5cf6), // Violet
    scaffoldBackgroundColor: const Color(0xFFf8fafc),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Raleway',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0f172a),
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Raleway',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0f172a),
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: Color(0xFF334155),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: Color(0xFF64748b),
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Raleway',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0f172a),
      ),
      iconTheme: IconThemeData(color: Color(0xFF0f172a)),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 8,
      shadowColor: const Color(0xFF8b5cf6).withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF8b5cf6).withOpacity(0.2),
          width: 2,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8b5cf6),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        shadowColor: const Color(0xFF8b5cf6).withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8b5cf6), // Violet
      secondary: Color(0xFFec4899), // Pink
      tertiary: Color(0xFF16f2b3), // Green
      surface: Colors.white,
      background: Color(0xFFf8fafc),
      error: Color(0xFFef4444),
    ),
  );

  void toggleTheme() =>
      emit(state.brightness == Brightness.dark ? _lightTheme : _darkTheme);

  void setLightTheme() => emit(_lightTheme);

  void setDarkTheme() => emit(_darkTheme);
}

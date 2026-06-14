import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';

/// Emits the active [ThemeData]. Public API is unchanged — it now sources its
/// light/dark themes from the centralized design-token system in `lib/theme/`.
class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.dark);

  bool get isDark => state.brightness == Brightness.dark;

  void toggleTheme() =>
      emit(state.brightness == Brightness.dark ? AppTheme.light : AppTheme.dark);

  void setLightTheme() => emit(AppTheme.light);

  void setDarkTheme() => emit(AppTheme.dark);

  /// Apply a saved themeMode string ('light' | 'dark' | 'system').
  void applyThemeMode(String mode, {Brightness platformBrightness = Brightness.dark}) {
    switch (mode) {
      case 'light':
        emit(AppTheme.light);
        break;
      case 'dark':
        emit(AppTheme.dark);
        break;
      default:
        emit(platformBrightness == Brightness.dark ? AppTheme.dark : AppTheme.light);
    }
  }
}

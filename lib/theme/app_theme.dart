import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_page_transitions.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light & dark [ThemeData] from design tokens. The ThemeCubit emits
/// one of these. Component themes here mean screens rarely need to style
/// AppBars / Cards / buttons / switches manually.
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(AppPalette.dark);
  static ThemeData get light => _build(AppPalette.light);

  static ThemeData _build(AppPalette p) {
    final isDark = p.isDark;

    final colorScheme = ColorScheme(
      brightness: p.brightness,
      primary: AppColors.violet,
      onPrimary: Colors.white,
      secondary: AppColors.pink,
      onSecondary: Colors.white,
      tertiary: AppColors.teal,
      onTertiary: const Color(0xFF052B20),
      error: AppColors.red,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.text,
      surfaceContainerHighest: p.surface2,
      outline: p.border,
    );

    final textTheme = AppTypography.textTheme(p.text, p.textMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.bg,
      fontFamily: AppFonts.body,
      textTheme: textTheme,
      primaryColor: AppColors.violet,
      splashColor: AppColors.violet.withValues(alpha: 0.12),
      highlightColor: AppColors.violet.withValues(alpha: 0.06),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeThroughPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: p.text),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shadowColor: AppColors.violet.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.rLg,
          side: BorderSide(color: p.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.violet,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconTheme: IconThemeData(color: p.text),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : (isDark ? AppColors.darkTextMuted : Colors.white),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.violet
              : (isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.violet,
        inactiveTrackColor: p.border,
        thumbColor: AppColors.pink,
        overlayColor: AppColors.violet.withValues(alpha: 0.15),
        trackHeight: 5,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.violet,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.rLg,
          side: BorderSide(color: p.border),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.surface2,
        contentTextStyle: textTheme.bodyLarge,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rMd),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: AppRadius.rSm,
        ),
        textStyle: textTheme.bodySmall,
      ),
    );
  }
}

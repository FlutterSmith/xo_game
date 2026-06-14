import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'pressable.dart';

/// The standard surface used across the app — a rounded, bordered card with a
/// subtle depth shadow (or a colored glow when [glowColor] is set). Replaces the
/// dozens of ad-hoc gradient+border+shadow Containers from the old UI.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final Gradient? gradient;
  final Color? glowColor;
  final double glowBlur;
  final bool border;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.rLg,
    this.color,
    this.gradient,
    this.glowColor,
    this.glowBlur = 26,
    this.border = true,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? p.surface) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: border
            ? Border.all(color: borderColor ?? p.border, width: 1.2)
            : null,
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.35),
              blurRadius: glowBlur,
              offset: const Offset(0, 10),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: p.isDark ? 0.30 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Pressable(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      );
    }
    return content;
  }
}

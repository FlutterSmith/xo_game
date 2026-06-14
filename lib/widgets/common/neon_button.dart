import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'pressable.dart';

enum NeonButtonVariant { primary, secondary, danger, success, ghost }

/// The single button component for the app. Variants cover every CTA style the
/// old UI reinvented per-screen.
class NeonButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final NeonButtonVariant variant;
  final bool expand;
  final bool large;

  const NeonButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.variant = NeonButtonVariant.primary,
    this.expand = true,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final theme = Theme.of(context);

    Gradient? gradient;
    Color? solid;
    Color fg;
    Color? glow;
    Border? border;

    switch (variant) {
      case NeonButtonVariant.primary:
        gradient = const LinearGradient(colors: AppColors.primaryGradient);
        fg = Colors.white;
        glow = AppColors.violet;
        break;
      case NeonButtonVariant.danger:
        gradient = const LinearGradient(colors: AppColors.loseGradient);
        fg = Colors.white;
        glow = AppColors.red;
        break;
      case NeonButtonVariant.success:
        gradient = const LinearGradient(colors: AppColors.winGradient);
        fg = const Color(0xFF052B20);
        glow = AppColors.teal;
        break;
      case NeonButtonVariant.secondary:
        solid = p.surface;
        fg = p.text;
        border = Border.all(color: p.border, width: 1.4);
        break;
      case NeonButtonVariant.ghost:
        solid = Colors.transparent;
        fg = AppColors.violet;
        break;
    }

    final labelStyle = (large
            ? theme.textTheme.titleLarge
            : theme.textTheme.labelLarge)
        ?.copyWith(color: fg, fontWeight: FontWeight.w700);

    final content = Container(
      height: large ? 60 : 52,
      padding: EdgeInsets.symmetric(horizontal: large ? AppSpacing.xl : AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        color: solid,
        borderRadius: AppRadius.rPill,
        border: border,
        boxShadow: glow != null
            ? [
                BoxShadow(
                  color: glow.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: large ? 26 : 22),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              label,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    final btn = Pressable(onTap: onTap, child: content);
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// A circular glass icon button (used for app-bar back/close and small actions).
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final btn = Pressable(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: p.surface,
          shape: BoxShape.circle,
          border: Border.all(color: p.border),
        ),
        child: Icon(icon, color: color ?? p.text, size: size * 0.5),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}

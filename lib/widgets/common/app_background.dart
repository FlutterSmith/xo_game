import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// The shared animated background: a vertical brand gradient with soft glowing
/// "blobs" for arcade depth. Used behind every screen via [AppScaffold].
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool blobs;

  const AppBackground({super.key, required this.child, this.blobs = true});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.bgGradient(p.brightness),
        ),
      ),
      child: Stack(
        children: [
          if (blobs) ...[
            Positioned(
              top: -90,
              left: -70,
              child: _Blob(color: AppColors.violet, size: 260, opacity: p.isDark ? 0.30 : 0.18),
            ),
            Positioned(
              top: 120,
              right: -90,
              child: _Blob(color: AppColors.pink, size: 240, opacity: p.isDark ? 0.22 : 0.14),
            ),
            Positioned(
              bottom: -100,
              left: -40,
              child: _Blob(color: AppColors.teal, size: 280, opacity: p.isDark ? 0.20 : 0.12),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _Blob({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

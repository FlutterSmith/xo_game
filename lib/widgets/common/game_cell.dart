import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import 'animated_mark.dart';

/// A single board cell. One parameterized widget for every board size — replaces
/// the old cell_widget / cell_widget4 / cell_widget5 triplicate. Keeps the juicy
/// tap-scale + hover glow and adds a pulsing glow for winning cells.
class GameCell extends StatefulWidget {
  final String value;
  final bool highlight; // part of the winning line
  final bool dimmed; // not winning, but game is over
  final VoidCallback onTap;
  final double markSize;

  const GameCell({
    super.key,
    required this.value,
    required this.highlight,
    required this.onTap,
    this.markSize = 56,
    this.dimmed = false,
  });

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell> with TickerProviderStateMixin {
  late final AnimationController _tap = AnimationController(
    vsync: this,
    duration: AppMotion.fast,
    lowerBound: 0,
    upperBound: 0.05,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.highlight) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant GameCell old) {
    super.didUpdateWidget(old);
    if (widget.highlight && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.highlight && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _tap.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final markColor = widget.value.isEmpty ? null : AppColors.markColor(widget.value);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _tap.forward(),
        onTapUp: (_) {
          _tap.reverse();
          widget.onTap();
        },
        onTapCancel: () => _tap.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_tap, _pulse]),
          builder: (context, child) {
            final pulse = _pulse.value; // 0..1
            Color border;
            double borderWidth;
            List<BoxShadow> shadows;

            if (widget.highlight) {
              border = Color.lerp(AppColors.teal, AppColors.cyan, pulse)!;
              borderWidth = 3;
              shadows = [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.35 + pulse * 0.35),
                  blurRadius: 18 + pulse * 12,
                  spreadRadius: pulse * 2,
                ),
              ];
            } else if (_hovered && widget.value.isEmpty) {
              border = AppColors.violet;
              borderWidth = 2;
              shadows = [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ];
            } else {
              border = p.border;
              borderWidth = 1.5;
              shadows = [
                BoxShadow(
                  color: Colors.black.withValues(alpha: p.isDark ? 0.25 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ];
            }

            return Transform.scale(
              scale: 1 - _tap.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.highlight
                        ? [
                            AppColors.teal.withValues(alpha: 0.22),
                            AppColors.cyan.withValues(alpha: 0.14),
                          ]
                        : [
                            p.surface,
                            p.surface2,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: borderWidth),
                  boxShadow: shadows,
                ),
                child: Center(
                  child: widget.value.isEmpty
                      ? const SizedBox.shrink()
                      : Opacity(
                          opacity: widget.dimmed && !widget.highlight ? 0.45 : 1,
                          child: AnimatedMark(
                            mark: widget.value,
                            markSize: widget.markSize,
                            color: markColor,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

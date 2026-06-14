import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Draws an X or O with an animated "draw-on" stroke and a neon glow.
/// Color defaults to the brand X/O colors; pass [color] to override.
class AnimatedMark extends StatefulWidget {
  final String mark;
  final double markSize;
  final Duration duration;
  final Color? color;
  final bool glow;

  const AnimatedMark({
    super.key,
    required this.mark,
    this.markSize = 80,
    this.duration = const Duration(milliseconds: 450),
    this.color,
    this.glow = true,
  });

  @override
  State<AnimatedMark> createState() => _AnimatedMarkState();
}

class _AnimatedMarkState extends State<AnimatedMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mark != widget.mark) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.markColor(widget.mark);
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.markSize),
        painter: _MarkPainter(
          mark: widget.mark,
          progress: _progress.value,
          color: color,
          glow: widget.glow,
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  final String mark;
  final double progress;
  final Color color;
  final bool glow;

  _MarkPainter({
    required this.mark,
    required this.progress,
    required this.color,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.13;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.05);
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Inset so round caps and glow don't clip the cell edges.
    final pad = size.width * 0.12;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    void drawX(Paint pnt) {
      if (progress <= 0.5) {
        final t = progress / 0.5;
        canvas.drawLine(
          Offset(pad, pad),
          Offset(pad + w * t, pad + h * t),
          pnt,
        );
      } else {
        canvas.drawLine(Offset(pad, pad), Offset(pad + w, pad + h), pnt);
        final t = (progress - 0.5) / 0.5;
        canvas.drawLine(
          Offset(pad + w, pad),
          Offset(pad + w - w * t, pad + h * t),
          pnt,
        );
      }
    }

    void drawO(Paint pnt) {
      final rect = Rect.fromLTWH(pad, pad, w, h);
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, pnt);
    }

    if (mark == 'X') {
      if (glow) drawX(glowPaint);
      drawX(paint);
    } else if (mark == 'O') {
      if (glow) drawO(glowPaint);
      drawO(paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) =>
      old.progress != progress || old.mark != mark || old.color != color;
}

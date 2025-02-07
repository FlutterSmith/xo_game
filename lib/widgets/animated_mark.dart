import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedMark extends StatefulWidget {
  final String mark;
  final double markSize;
  final Duration duration;
  const AnimatedMark({
    Key? key,
    required this.mark,
    this.markSize = 80, // Default size for 3x3 board.
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);
  @override
  _AnimatedMarkState createState() => _AnimatedMarkState();
}

class _AnimatedMarkState extends State<AnimatedMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mark != widget.mark ||
        oldWidget.markSize != widget.markSize) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.square(widget.markSize),
          painter: _MarkPainter(
              mark: widget.mark, progress: _progressAnimation.value),
        );
      },
    );
  }
}

class _MarkPainter extends CustomPainter {
  final String mark;
  final double progress;
  _MarkPainter({required this.mark, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = size.width * 0.05 // Stroke width relative to mark size.
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (mark == 'X') {
      // Draw "X" with two strokes.
      if (progress <= 0.5) {
        double strokeProgress = progress / 0.5;
        canvas.drawLine(
          Offset(0, 0),
          Offset(size.width * strokeProgress, size.height * strokeProgress),
          paint,
        );
      } else {
        // First stroke complete.
        canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
        double strokeProgress = (progress - 0.5) / 0.5;
        canvas.drawLine(
          Offset(size.width, 0),
          Offset(size.width - size.width * strokeProgress,
              size.height * strokeProgress),
          paint,
        );
      }
    } else if (mark == 'O') {
      // Draw "O" as an arc from -pi/2.
      double sweepAngle = 2 * pi * progress;
      Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawArc(rect, -pi / 2, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.mark != mark;
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../theme/app_colors.dart';

/// Star-burst confetti for win celebrations. Plays once when [shouldPlay] flips
/// to true. Colors come from the brand palette.
class WinConfetti extends StatefulWidget {
  final bool shouldPlay;
  final VoidCallback? onComplete;

  const WinConfetti({super.key, required this.shouldPlay, this.onComplete});

  @override
  State<WinConfetti> createState() => _WinConfettiState();
}

class _WinConfettiState extends State<WinConfetti> {
  late final ConfettiController _controller =
      ConfettiController(duration: const Duration(seconds: 3));

  static const _colors = [
    AppColors.pink,
    AppColors.violet,
    AppColors.teal,
    AppColors.cyan,
    AppColors.amber,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.shouldPlay) _play();
  }

  @override
  void didUpdateWidget(WinConfetti old) {
    super.didUpdateWidget(old);
    if (widget.shouldPlay && !old.shouldPlay) _play();
  }

  void _play() {
    _controller.play();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Path _star(Size size) {
    double rad(double d) => d * (pi / 180.0);
    const points = 5;
    final half = size.width / 2;
    final ext = half;
    final int_ = half / 2.5;
    final step = rad(360 / points);
    final halfStep = step / 2;
    final path = Path()..moveTo(size.width, half);
    final full = rad(360);
    for (double s = 0; s < full; s += step) {
      path.lineTo(half + ext * cos(s), half + ext * sin(s));
      path.lineTo(half + int_ * cos(s + halfStep), half + int_ * sin(s + halfStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: _colors,
              createParticlePath: _star,
              numberOfParticles: 30,
              gravity: 0.3,
              emissionFrequency: 0.05,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: -pi / 4,
              blastDirectionality: BlastDirectionality.directional,
              shouldLoop: false,
              colors: _colors,
              numberOfParticles: 14,
              gravity: 0.2,
              emissionFrequency: 0.05,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirection: -3 * pi / 4,
              blastDirectionality: BlastDirectionality.directional,
              shouldLoop: false,
              colors: _colors,
              numberOfParticles: 14,
              gravity: 0.2,
              emissionFrequency: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}

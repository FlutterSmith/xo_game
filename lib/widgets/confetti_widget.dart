import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// Confetti widget for win celebrations
class WinConfettiWidget extends StatefulWidget {
  final bool shouldPlay;
  final VoidCallback? onAnimationComplete;

  const WinConfettiWidget({
    super.key,
    required this.shouldPlay,
    this.onAnimationComplete,
  });

  @override
  State<WinConfettiWidget> createState() => _WinConfettiWidgetState();
}

class _WinConfettiWidgetState extends State<WinConfettiWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didUpdateWidget(WinConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay && !oldWidget.shouldPlay) {
      _confettiController.play();
      Future.delayed(const Duration(seconds: 3), () {
        widget.onAnimationComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Center confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // Down
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFFec4899), // Pink
              Color(0xFF8b5cf6), // Violet
              Color(0xFF16f2b3), // Green
              Color(0xFF06b6d4), // Cyan
              Color(0xFFf59e0b), // Amber
              Color(0xFFef4444), // Red
            ],
            createParticlePath: _drawStar,
            numberOfParticles: 30,
            gravity: 0.3,
            emissionFrequency: 0.05,
          ),
        ),
        // Left confetti
        Align(
          alignment: Alignment.bottomLeft,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 4, // Up-right
            blastDirectionality: BlastDirectionality.directional,
            shouldLoop: false,
            colors: const [
              Color(0xFFec4899), // Pink
              Color(0xFF8b5cf6), // Violet
              Color(0xFF16f2b3), // Green
            ],
            numberOfParticles: 15,
            gravity: 0.2,
            emissionFrequency: 0.05,
          ),
        ),
        // Right confetti
        Align(
          alignment: Alignment.bottomRight,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -3 * pi / 4, // Up-left
            blastDirectionality: BlastDirectionality.directional,
            shouldLoop: false,
            colors: const [
              Color(0xFFec4899), // Pink
              Color(0xFF8b5cf6), // Violet
              Color(0xFF16f2b3), // Green
            ],
            numberOfParticles: 15,
            gravity: 0.2,
            emissionFrequency: 0.05,
          ),
        ),
      ],
    );
  }
}

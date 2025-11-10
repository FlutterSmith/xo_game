import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Rotation animation for X and O
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Particle floating animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse/glow animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      _rotationController,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();

    // Simulate loading progress
    _simulateLoading();

    // Navigate after splash
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/menu');
      }
    });
  }

  void _simulateLoading() {
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1.0) {
            _progress = 1.0;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0d1224),
              Color(0xFF1e1436),
              Color(0xFF0f172a),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles/symbols in background
            ...List.generate(8, (index) => _buildFloatingSymbol(index, size)),

            // Glow effects
            _buildGlowEffect(Alignment.topRight, const Color(0xFFec4899)),
            _buildGlowEffect(Alignment.bottomLeft, const Color(0xFF8b5cf6)),
            _buildGlowEffect(Alignment.center, const Color(0xFF06b6d4)),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated X and O logo
                      _buildAnimatedLogo(),

                      const SizedBox(height: 40),

                      // Title with glow
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Color(0xFFec4899).withOpacity(_glowAnimation.value),
                                  Color(0xFF8b5cf6).withOpacity(_glowAnimation.value),
                                  Color(0xFF06b6d4).withOpacity(_glowAnimation.value),
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'XO GAME',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                letterSpacing: 8,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'by Ahmed Hamdy',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Poppins',
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading bar
                      _buildLoadingBar(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating ring
            Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    color: const Color(0xFFec4899).withOpacity(0.3),
                  ),
                ),
              ),
            ),

            // Inner rotating ring (opposite direction)
            Transform.rotate(
              angle: -_rotationAnimation.value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    color: const Color(0xFF8b5cf6).withOpacity(0.3),
                  ),
                ),
              ),
            ),

            // Center glassmorphism container with X and O
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFec4899).withOpacity(0.2),
                    const Color(0xFF8b5cf6).withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFec4899).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF8b5cf6).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFFec4899),
                        Color(0xFF8b5cf6),
                        Color(0xFF06b6d4),
                      ],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'X O',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingSymbol(int index, Size size) {
    final random = Random(index);
    final isX = index % 2 == 0;
    final left = random.nextDouble() * size.width * 0.8;
    final top = random.nextDouble() * size.height * 0.8;
    final delay = index * 0.5;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final movement = sin(_particleController.value * 2 * pi + delay) * 20;

        return Positioned(
          left: left,
          top: top + movement,
          child: Opacity(
            opacity: 0.1 + (_particleController.value * 0.2),
            child: Text(
              isX ? 'X' : 'O',
              style: TextStyle(
                fontSize: 40 + (index * 5.0),
                fontWeight: FontWeight.bold,
                color: isX ? const Color(0xFFec4899) : const Color(0xFF8b5cf6),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowEffect(Alignment alignment, Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Align(
          alignment: alignment,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.15 * _glowAnimation.value),
                  color.withOpacity(0.05 * _glowAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBar() {
    return Column(
      children: [
        // Progress bar container
        Container(
          width: 250,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Animated gradient progress
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 250 * _progress,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFec4899),
                        Color(0xFF8b5cf6),
                        Color(0xFF06b6d4),
                      ],
                    ),
                  ),
                ),
                // Shimmer effect
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return Positioned(
                      left: -100 + (_particleController.value * 350),
                      child: Container(
                        width: 100,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Loading text
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            final dots = '.' * ((_particleController.value * 3).toInt() + 1);
            return Text(
              'Loading$dots',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                fontFamily: 'Poppins',
                letterSpacing: 2,
              ),
            );
          },
        ),
      ],
    );
  }
}

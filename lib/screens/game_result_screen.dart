import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';
import 'package:confetti/confetti.dart';

/// Game Result Screen - Dramatic win/loss/draw display
class GameResultScreen extends StatefulWidget {
  const GameResultScreen({super.key});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _animationController.forward();

    // Trigger confetti for wins
    Future.delayed(const Duration(milliseconds: 400), () {
      final state = context.read<GameBloc>().state;
      if (state.resultMessage.toLowerCase().contains('wins') &&
          !state.resultMessage.toLowerCase().contains('o wins')) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        // Determine result type
        final isWin = state.resultMessage.toLowerCase().contains('wins') &&
            !state.resultMessage.toLowerCase().contains('o wins');
        final isDraw = state.resultMessage.toLowerCase().contains('draw');
        final isLoss = !isWin && !isDraw;

        Color resultColor;
        IconData resultIcon;
        String resultTitle;

        if (isWin) {
          resultColor = const Color(0xFF16f2b3);
          resultIcon = Icons.emoji_events_rounded;
          resultTitle = 'Victory!';
        } else if (isDraw) {
          resultColor = const Color(0xFF06b6d4);
          resultIcon = Icons.handshake_rounded;
          resultTitle = 'Draw!';
        } else {
          resultColor = const Color(0xFFef4444);
          resultIcon = Icons.sentiment_dissatisfied_rounded;
          resultTitle = 'Defeat';
        }

        return Scaffold(
          body: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF0d1224),
                            const Color(0xFF1e1436),
                            const Color(0xFF0f172a),
                          ]
                        : [
                            Colors.blue.shade50,
                            Colors.purple.shade50,
                            Colors.pink.shade50,
                          ],
                  ),
                ),
              ),

              // Confetti
              if (isWin)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: pi / 2,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    maxBlastForce: 100,
                    minBlastForce: 50,
                    gravity: 0.3,
                    colors: const [
                      Color(0xFFec4899),
                      Color(0xFF8b5cf6),
                      Color(0xFF06b6d4),
                      Color(0xFF16f2b3),
                      Color(0xFFfbbf24),
                    ],
                  ),
                ),

              // Content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Result Icon with Animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: resultColor.withOpacity(0.2),
                            border: Border.all(
                              color: resultColor,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: resultColor.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            resultIcon,
                            size: 80,
                            color: resultColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Result Title
                      Text(
                        resultTitle,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Result Message
                      Text(
                        state.resultMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Game Stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _buildStatsCards(state, isDark),
                      ),

                      const Spacer(),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildActionButton(
                              'Play Again',
                              Icons.replay_rounded,
                              const Color(0xFFec4899),
                              const Color(0xFF8b5cf6),
                              () {
                                context.read<GameBloc>().add(const ResetGame());
                                Navigator.of(context)
                                    .pushReplacementNamed('/game-play');
                              },
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSecondaryButton(
                                    'New Game',
                                    Icons.settings_rounded,
                                    () {
                                      Navigator.of(context)
                                          .pushReplacementNamed('/game-setup');
                                    },
                                    isDark,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSecondaryButton(
                                    'Main Menu',
                                    Icons.home_rounded,
                                    () {
                                      Navigator.of(context)
                                          .pushReplacementNamed('/menu');
                                    },
                                    isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSecondaryButton(
                              'View Replay',
                              Icons.play_circle_outline_rounded,
                              () {
                                Navigator.of(context).pushNamed('/replays');
                              },
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(GameState state, bool isDark) {
    // Calculate game stats
    final moveCount = state.board.where((cell) => cell.isNotEmpty).length;
    final boardSize = '${state.boardSize}×${state.boardSize}';
    final timeUsed = state.timedMode
        ? '${(state.elapsedTime / 1000).toInt()}s'
        : 'No Limit';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Moves',
            moveCount.toString(),
            Icons.touch_app_rounded,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Board',
            boardSize,
            Icons.grid_on_rounded,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Time',
            timeUsed,
            Icons.timer_rounded,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: const Color(0xFF8b5cf6),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color startColor,
    Color endColor,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: startColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF8b5cf6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

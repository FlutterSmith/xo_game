import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';
import '../widgets/board_widget3.dart';
import '../widgets/board_widget5.dart';
import '../widgets/board_widget.dart';
import '../widgets/game_timer_widget.dart';

/// Game Play Screen - Minimal focused gameplay
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        // Navigate to result screen when game ends
        // Only navigate once to prevent duplicate navigation
        if (state.gameOver && !_hasNavigated && mounted) {
          _hasNavigated = true;
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/game-result');
            }
          });
        }
        // Reset flag when game is reset
        if (!state.gameOver && _hasNavigated) {
          _hasNavigated = false;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context, isDark),
        body: Container(
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
          child: SafeArea(
            child: BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFec4899).withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -150,
                      left: -150,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF8b5cf6).withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          // Game status with timer
                          _buildGameStatus(context, state, isDark),
                          const SizedBox(height: 32),

                          // Game board
                          _buildGameBoard(context, state, isDark),
                          const SizedBox(height: 32),

                          // Move counter
                          _buildMoveCounter(state, isDark),
                          const SizedBox(height: 24),

                          // Pause button
                          _buildPauseButton(context, state, isDark),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFec4899).withOpacity(0.2),
                const Color(0xFF8b5cf6).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1e1436),
            size: 22,
          ),
        ),
        onPressed: () => _showQuitDialog(context),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
        ).createShader(bounds),
        child: const Text(
          'XO Game',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFef4444).withOpacity(0.2),
                  const Color(0xFFdc2626).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.black.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: const Color(0xFFef4444),
              size: 22,
            ),
          ),
          onPressed: () => _showQuitDialog(context),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildGameStatus(BuildContext context, GameState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1e1436).withOpacity(0.95),
                  const Color(0xFF2d1b4e).withOpacity(0.85),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  const Color(0xFFfaf5ff).withOpacity(0.95),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : const Color(0xFF8b5cf6).withOpacity(0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF8b5cf6).withOpacity(0.25)
                : const Color(0xFF8b5cf6).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Column(
            children: [
              // Current player
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
                ).createShader(bounds),
                child: Text(
                  'Player ${state.currentPlayer}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              // Turn indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFec4899).withOpacity(0.15),
                      const Color(0xFF8b5cf6).withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8b5cf6).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10b981),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10b981).withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Turn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : const Color(0xFF1e1436),
                      ),
                    ),
                  ],
                ),
              ),

              // Timer widget
              const SizedBox(height: 16),
              const GameTimerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameBoard(BuildContext context, GameState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1e1436).withOpacity(0.8),
                  const Color(0xFF2d1b4e).withOpacity(0.6),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFfaf5ff).withOpacity(0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF8b5cf6).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF8b5cf6).withOpacity(0.3)
                : const Color(0xFF8b5cf6).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: state.boardSize == 3
              ? const BoardWidget3()
              : state.boardSize == 4
                  ? const BoardWidget4()
                  : const BoardWidget5(),
        ),
      ),
    );
  }

  Widget _buildMoveCounter(GameState state, bool isDark) {
    final moveCount = state.board.where((cell) => cell.isNotEmpty).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_rounded,
            color: const Color(0xFF8b5cf6),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Moves: $moveCount',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1e1436),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseButton(BuildContext context, GameState state, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPauseDialog(context, state),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06b6d4), Color(0xFF0ea5e9)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06b6d4).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.pause_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Pause Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context, GameState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameBloc = context.read<GameBloc>();

    // Pause the timer
    gameBloc.add(const PauseTimer());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1e1436) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.pause_circle_rounded,
              color: const Color(0xFF06b6d4),
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              'Game Paused',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1e1436),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogButton(
              'Resume',
              Icons.play_arrow_rounded,
              const Color(0xFF10b981),
              () {
                gameBloc.add(const ResumeTimer());
                Navigator.of(context).pop();
              },
              isDark,
            ),
            const SizedBox(height: 12),
            _buildDialogButton(
              'Restart Game',
              Icons.refresh_rounded,
              const Color(0xFFf59e0b),
              () {
                gameBloc.add(const ResetGame());
                Navigator.of(context).pop();
              },
              isDark,
            ),
            const SizedBox(height: 12),
            _buildDialogButton(
              'Quit to Menu',
              Icons.home_rounded,
              const Color(0xFFef4444),
              () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/menu');
              },
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuitDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1e1436) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: const Color(0xFFf59e0b),
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              'Quit Game?',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1e1436),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to quit? Your game progress will be lost.',
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/menu');
            },
            child: const Text(
              'Quit',
              style: TextStyle(
                color: Color(0xFFef4444),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

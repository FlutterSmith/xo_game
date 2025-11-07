import 'package:advanced_xo_game/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';
import '../blocs/theme_cubit.dart';
import '../blocs/settings_cubit.dart';
import '../blocs/statistics_cubit.dart';
import '../models/app_settings.dart';
import '../models/game_stats.dart';
import '../services/sound_service.dart';
import '../widgets/board_widget3.dart';
import '../widgets/board_widget5.dart';
import '../widgets/board_widget.dart';
import '../widgets/confetti_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    final soundService = SoundService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, isDark, gameBloc),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0a0118),
                    const Color(0xFF1e1436),
                    const Color(0xFF0f0820),
                  ]
                : [
                    const Color(0xFFfaf5ff),
                    const Color(0xFFf3e8ff),
                    const Color(0xFFede9fe),
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
                        // Professional status display
                        _buildProfessionalStatus(context, state, isDark),
                        const SizedBox(height: 24),

                        // Game board with enhanced presentation
                        _buildEnhancedGameBoard(context, state, isDark),
                        const SizedBox(height: 24),

                        // Game controls in elegant layout
                        _buildElegantControls(context, state, isDark, gameBloc),
                        const SizedBox(height: 24),

                        // Action buttons with modern design
                        _buildModernActionButtons(context, state, gameBloc, isDark, soundService),
                      ],
                    ),
                  ),

                  // Win confetti overlay
                  if (state.gameOver && state.resultMessage.contains('Winner'))
                    Positioned.fill(
                      child: IgnorePointer(
                        child: WinConfettiWidget(
                          shouldPlay: state.gameOver && state.resultMessage.contains('Winner'),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, GameBloc gameBloc) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
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
              Icons.menu_rounded,
              color: isDark ? Colors.white : const Color(0xFF1e1436),
              size: 22,
            ),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFec4899).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/icon/icon.png',
              width: 26,
              height: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
            ).createShader(bounds),
            child: const Text(
              'XO Pro',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
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
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.white : const Color(0xFF1e1436),
              size: 22,
            ),
          ),
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        ),
        IconButton(
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
              Icons.refresh_rounded,
              color: isDark ? Colors.white : const Color(0xFF1e1436),
              size: 22,
            ),
          ),
          onPressed: () {
            soundService.playButton();
            gameBloc.add(const ResetGame());
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildProfessionalStatus(BuildContext context, GameState state, bool isDark) {
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
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Column(
            children: [
              // Main status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: ShaderMask(
                  key: ValueKey(state.gameOver ? state.resultMessage : state.currentPlayer),
                  shaderCallback: (bounds) => LinearGradient(
                    colors: state.gameOver
                        ? (state.resultMessage.contains('Draw')
                            ? [const Color(0xFF06b6d4), const Color(0xFF0ea5e9)]
                            : [const Color(0xFFec4899), const Color(0xFF8b5cf6)])
                        : [const Color(0xFFec4899), const Color(0xFF8b5cf6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    state.gameOver
                        ? state.resultMessage
                        : 'Player ${state.currentPlayer}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              if (!state.gameOver) ...[
                const SizedBox(height: 12),
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
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedGameBoard(BuildContext context, GameState state, bool isDark) {
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
          BoxShadow(
            color: isDark
                ? const Color(0xFFec4899).withOpacity(0.2)
                : const Color(0xFFec4899).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -8,
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

  Widget _buildElegantControls(BuildContext context, GameState state, bool isDark, GameBloc gameBloc) {
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF8b5cf6).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF8b5cf6).withOpacity(0.2)
                : const Color(0xFF8b5cf6).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Board Size Selector
              _buildControlRow(
                context,
                'Board Size',
                DropdownButtonHideUnderline(
                  child: Container(
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
                    child: DropdownButton<int>(
                      value: state.boardSize,
                      dropdownColor: isDark ? const Color(0xFF1e1436) : Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white : const Color(0xFF1e1436),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1e1436),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Raleway',
                      ),
                      items: [3, 4, 5].map((size) {
                        return DropdownMenuItem(
                          value: size,
                          child: Text('$size×$size'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          gameBloc.add(UpdateBoardSettings(value, value));
                        }
                      },
                    ),
                  ),
                ),
                isDark,
              ),
              const SizedBox(height: 16),

              // Game Mode Selector
              _buildControlRow(
                context,
                'Game Mode',
                DropdownButtonHideUnderline(
                  child: Container(
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
                    child: DropdownButton<GameMode>(
                      value: state.gameMode,
                      dropdownColor: isDark ? const Color(0xFF1e1436) : Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white : const Color(0xFF1e1436),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1e1436),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Raleway',
                      ),
                      items: GameMode.values.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Row(
                            children: [
                              Icon(
                                mode == GameMode.PvP
                                    ? Icons.people_rounded
                                    : Icons.smart_toy_rounded,
                                size: 18,
                                color: const Color(0xFF8b5cf6),
                              ),
                              const SizedBox(width: 8),
                              Text(mode == GameMode.PvP ? 'Player vs Player' : 'Player vs AI'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          gameBloc.add(const ToggleGameMode());
                        }
                      },
                    ),
                  ),
                ),
                isDark,
              ),
              const SizedBox(height: 16),

              // AI Difficulty Selector
              _buildControlRow(
                context,
                'AI Difficulty',
                DropdownButtonHideUnderline(
                  child: Container(
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
                    child: DropdownButton<AIDifficulty>(
                      value: state.aiDifficulty,
                      dropdownColor: isDark ? const Color(0xFF1e1436) : Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white : const Color(0xFF1e1436),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1e1436),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Raleway',
                      ),
                      items: AIDifficulty.values.where((d) => d != AIDifficulty.adaptive).map((diff) {
                        final label = diff.name.toUpperCase();
                        return DropdownMenuItem(
                          value: diff,
                          child: Row(
                            children: [
                              Icon(
                                diff == AIDifficulty.easy
                                    ? Icons.sentiment_satisfied_rounded
                                    : diff == AIDifficulty.medium
                                        ? Icons.sentiment_neutral_rounded
                                        : Icons.sentiment_very_dissatisfied_rounded,
                                size: 18,
                                color: diff == AIDifficulty.easy
                                    ? const Color(0xFF10b981)
                                    : diff == AIDifficulty.medium
                                        ? const Color(0xFFf59e0b)
                                        : const Color(0xFFef4444),
                              ),
                              const SizedBox(width: 8),
                              Text(label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          gameBloc.add(ChangeDifficulty(value));
                        }
                      },
                    ),
                  ),
                ),
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow(BuildContext context, String label, Widget control, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                label.contains('Board')
                    ? Icons.grid_4x4_rounded
                    : Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withOpacity(0.9)
                    : const Color(0xFF1e1436),
                fontFamily: 'Raleway',
              ),
            ),
          ],
        ),
        control,
      ],
    );
  }

  Widget _buildModernActionButtons(BuildContext context, GameState state, GameBloc gameBloc, bool isDark, SoundService soundService) {
    return Row(
      children: [
        Expanded(
          child: AdvancedNeumorphicButton(
            onPressed: state.undoStack.isNotEmpty
                ? () {
                    soundService.playButton();
                    gameBloc.add(const UndoMove());
                  }
                : () {},
            isEnabled: state.undoStack.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.undo_rounded,
                  color: state.undoStack.isNotEmpty ? Colors.white : Colors.white.withOpacity(0.4),
                ),
                const SizedBox(width: 8),
                Text(
                  'Undo',
                  style: TextStyle(
                    color: state.undoStack.isNotEmpty ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AdvancedNeumorphicButton(
            onPressed: state.redoStack.isNotEmpty
                ? () {
                    soundService.playButton();
                    gameBloc.add(const RedoMove());
                  }
                : () {},
            isEnabled: state.redoStack.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.redo_rounded,
                  color: state.redoStack.isNotEmpty ? Colors.white : Colors.white.withOpacity(0.4),
                ),
                const SizedBox(width: 8),
                Text(
                  'Redo',
                  style: TextStyle(
                    color: state.redoStack.isNotEmpty ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1e1436) : Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFec4899),
                  Color(0xFF8b5cf6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8b5cf6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                  ),
                ),
                const SizedBox(height: 4),
                BlocBuilder<StatisticsCubit, GameStats>(
                  builder: (context, stats) {
                    final winRate = stats.totalGames > 0
                        ? ((stats.wins / stats.totalGames) * 100).toStringAsFixed(1)
                        : '0.0';
                    return Text(
                      'Win Rate: $winRate%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  Icons.home_rounded,
                  'Home',
                  () => Navigator.pop(context),
                  isDark,
                ),
                _buildDrawerItem(
                  context,
                  Icons.bar_chart_rounded,
                  'Statistics',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/statistics');
                  },
                  isDark,
                ),
                _buildDrawerItem(
                  context,
                  Icons.emoji_events_rounded,
                  'Achievements',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/achievements');
                  },
                  isDark,
                ),
                _buildDrawerItem(
                  context,
                  Icons.movie_rounded,
                  'Game Replays',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/replays');
                  },
                  isDark,
                ),
                _buildDrawerItem(
                  context,
                  Icons.history_rounded,
                  'Game History',
                  () {
                    Navigator.pop(context);
                    // Navigate to history if route exists
                  },
                  isDark,
                ),
                const Divider(height: 32),
                _buildDrawerItem(
                  context,
                  Icons.school_rounded,
                  'How to Play',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/tutorial');
                  },
                  isDark,
                ),
                _buildDrawerItem(
                  context,
                  Icons.settings_rounded,
                  'Settings',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                  isDark,
                ),
                _buildDrawerItem(
                  context,
                  Icons.info_rounded,
                  'About',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  },
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFec4899).withOpacity(0.15),
              const Color(0xFF8b5cf6).withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF1e1436),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1e1436),
          fontFamily: 'Raleway',
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

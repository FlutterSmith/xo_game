import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:advanced_xo_game/widgets/common/common.dart';
import 'package:advanced_xo_game/blocs/game_bloc.dart';
import 'package:advanced_xo_game/blocs/game_state.dart';
import 'package:advanced_xo_game/blocs/game_event.dart';
import 'package:advanced_xo_game/blocs/statistics_cubit.dart';
import 'package:advanced_xo_game/services/achievement_service.dart';
import 'package:advanced_xo_game/services/database_service.dart';
import 'package:advanced_xo_game/services/sound_service.dart';
import 'package:advanced_xo_game/models/game_replay.dart';

/// Game Result Screen - dramatic neon-arcade win / loss / draw display.
class GameResultScreen extends StatefulWidget {
  const GameResultScreen({super.key});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Drives the WinConfetti overlay; flips to true after stats are recorded.
  bool _playConfetti = false;

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

    _animationController.forward();

    // Record statistics and check achievements.
    // Get cubits before async gap to avoid context issues.
    final gameBloc = context.read<GameBloc>();
    final statisticsCubit = context.read<StatisticsCubit>();
    final achievementService = AchievementService();

    Future.delayed(const Duration(milliseconds: 100), () async {
      final gameState = gameBloc.state;

      // Determine game result.
      String result;
      String winner;
      final isDraw = gameState.resultMessage.toLowerCase().contains('draw');
      if (isDraw) {
        result = 'draw';
        winner = 'Draw';
      } else {
        // Extract winner from result message (e.g., "Winner: X" -> "X").
        final winnerMatch =
            RegExp(r'Winner: ([XO])').firstMatch(gameState.resultMessage);
        if (winnerMatch != null) {
          winner = winnerMatch.group(1)!;
          if (gameState.gameMode == GameMode.PvP) {
            result = 'win'; // In PvP, any win counts.
          } else {
            // In PvC, check if winner matches player side.
            result = winner == gameState.playerSide ? 'win' : 'loss';
          }
        } else {
          result = 'draw'; // Fallback.
          winner = 'Draw';
        }
      }

      // Check if it's a perfect game (win without opponent scoring).
      bool isPerfectGame = false;
      if (result == 'win') {
        // Count marks on the board.
        final playerMark = gameState.playerSide;
        final opponentMark = playerMark == 'X' ? 'O' : 'X';
        final opponentMoves =
            gameState.board.where((cell) => cell == opponentMark).length;
        isPerfectGame = opponentMoves == 0;
      }

      // Play the appropriate result sound.
      final sound = SoundService();
      if (result == 'win') {
        sound.playWin();
      } else if (result == 'loss') {
        sound.playLose();
      } else {
        sound.playDraw();
      }

      // Record game in statistics.
      statisticsCubit.recordGame(
        result: result,
        gameMode: gameState.gameMode == GameMode.PvP ? 'PvP' : 'PvC',
        difficulty: gameState.gameMode == GameMode.PvC
            ? gameState.aiDifficulty.toString().split('.').last
            : null,
        boardSize: gameState.boardSize,
        isPerfectGame: isPerfectGame,
      );

      // Save game replay.
      try {
        final replay = GameReplay(
          id: 0, // Will be assigned by database.
          date: DateTime.now().toIso8601String(),
          gameMode: gameState.gameMode == GameMode.PvP ? 'PvP' : 'PvC',
          difficulty: gameState.gameMode == GameMode.PvC
              ? gameState.aiDifficulty.toString().split('.').last
              : 'N/A',
          boardSize: gameState.boardSize,
          moves: jsonEncode(gameState.gameHistory),
          result: winner == 'Draw' ? 'Draw' : '$winner Wins',
          winner: winner,
          movesCount: gameState.board.where((cell) => cell.isNotEmpty).length,
        );
        await DatabaseService.instance.saveReplay(replay);

        // Also save to legacy history.
        await DatabaseService.instance.insertHistory(gameState.resultMessage);
      } catch (e) {
        debugPrint('Error saving game replay: $e');
      }

      // Check for newly unlocked achievements.
      final stats = statisticsCubit.state;
      final newlyUnlocked = await achievementService.checkAchievements(stats);

      // Show notification for newly unlocked achievements.
      if (mounted && newlyUnlocked.isNotEmpty) {
        // Play the achievement-unlock sound (once per batch).
        sound.playAchievement();

        for (var achievement in newlyUnlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.teal,
              duration: const Duration(seconds: 3),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.rMd,
              ),
              content: Row(
                children: [
                  Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  AppSpacing.hSm,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Achievement Unlocked!',
                          style: TextStyle(
                            color: AppColors.darkBg,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
          // Keep the achievement title visible alongside the heading.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.violet,
              duration: const Duration(seconds: 3),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.rMd,
              ),
              content: Text(
                achievement.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
      }

      // Trigger confetti for wins.
      if (mounted && result == 'win') {
        setState(() => _playConfetti = true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Resolve the win / loss / draw classification from the current state.
  _ResultKind _resolveKind(GameState state) {
    final isDraw = state.resultMessage.toLowerCase().contains('draw');
    if (isDraw) return _ResultKind.draw;

    final winnerMatch =
        RegExp(r'Winner: ([XO])').firstMatch(state.resultMessage);
    if (winnerMatch != null) {
      final winner = winnerMatch.group(1)!;
      if (state.gameMode == GameMode.PvP) {
        return _ResultKind.win; // In PvP, any win is shown as a win.
      }
      return winner == state.playerSide ? _ResultKind.win : _ResultKind.loss;
    }
    return _ResultKind.draw;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final kind = _resolveKind(state);
        final isWin = kind == _ResultKind.win;

        final Color accent;
        final List<Color> gradient;
        final IconData icon;
        final String title;
        final String winnerMark;

        switch (kind) {
          case _ResultKind.win:
            accent = AppColors.win;
            gradient = AppColors.winGradient;
            icon = Icons.emoji_events_rounded;
            title = 'Victory!';
            winnerMark = state.gameMode == GameMode.PvP
                ? _extractWinner(state) ?? 'X'
                : state.playerSide;
            break;
          case _ResultKind.draw:
            accent = AppColors.draw;
            gradient = AppColors.drawGradient;
            icon = Icons.handshake_rounded;
            title = 'Draw!';
            winnerMark = '';
            break;
          case _ResultKind.loss:
            accent = AppColors.lose;
            gradient = AppColors.loseGradient;
            icon = Icons.sentiment_dissatisfied_rounded;
            title = 'Defeat';
            winnerMark = _extractWinner(state) ?? '';
            break;
        }

        return AppScaffold(
          body: Stack(
            children: [
              Padding(
                padding: AppSpacing.page,
                child: Column(
                  children: [
                    AppSpacing.vSm,
                    // ── Result emblem (elastic entrance) ─────────────────
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: _Emblem(
                                  accent: accent,
                                  gradient: gradient,
                                  icon: icon,
                                  mark: winnerMark,
                                ),
                              ),
                              AppSpacing.vLg,
                              FadeSlideIn(
                                delay: AppMotion.stagger(1),
                                child: ShaderMask(
                                  shaderCallback: (rect) => LinearGradient(
                                    colors: gradient,
                                  ).createShader(rect),
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              ),
                              AppSpacing.vXs,
                              FadeSlideIn(
                                delay: AppMotion.stagger(2),
                                child: Text(
                                  state.resultMessage,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppPalette.of(context).textMuted,
                                      ),
                                ),
                              ),
                              AppSpacing.vLg,
                              FadeSlideIn(
                                delay: AppMotion.stagger(3),
                                child: _StatsRow(state: state),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.vMd,
                    // ── Action buttons ──────────────────────────────────
                    FadeSlideIn(
                      delay: AppMotion.stagger(4),
                      child: _ActionButtons(isWin: isWin),
                    ),
                  ],
                ),
              ),

              // Win celebration overlay.
              WinConfetti(shouldPlay: _playConfetti),
            ],
          ),
        );
      },
    );
  }

  String? _extractWinner(GameState state) =>
      RegExp(r'Winner: ([XO])').firstMatch(state.resultMessage)?.group(1);
}

enum _ResultKind { win, loss, draw }

/// Big animated emblem: glowing gradient ring around the result icon, with the
/// winner's animated mark layered on a win.
class _Emblem extends StatelessWidget {
  final Color accent;
  final List<Color> gradient;
  final IconData icon;
  final String mark;

  const _Emblem({
    required this.accent,
    required this.gradient,
    required this.icon,
    required this.mark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: 0.28),
            accent.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: accent, width: 4),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: (mark == 'X' || mark == 'O')
            ? AnimatedMark(mark: mark, markSize: 96)
            : Icon(icon, size: 92, color: accent),
      ),
    );
  }
}

/// The three game-summary stat cards (moves / board / time).
class _StatsRow extends StatelessWidget {
  final GameState state;

  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final moveCount =
        state.board.where((cell) => cell.isNotEmpty).length;
    final boardLabel = '${state.boardSize}x${state.boardSize}';
    final timeUsed = state.timedMode
        ? '${(state.elapsedTime / 1000).toInt()}s'
        : 'No Limit';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.touch_app_rounded,
              label: 'Moves',
              value: moveCount,
              accent: AppColors.violet,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: StatCard(
              icon: Icons.grid_on_rounded,
              label: 'Board',
              text: boardLabel,
              accent: AppColors.pink,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: StatCard(
              icon: Icons.timer_rounded,
              label: 'Time',
              text: timeUsed,
              accent: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clear CTA hierarchy: primary Play Again, then secondary New Game / Main Menu,
/// then View Replay.
class _ActionButtons extends StatelessWidget {
  final bool isWin;

  const _ActionButtons({required this.isWin});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeonButton(
          label: 'Play Again',
          icon: Icons.replay_rounded,
          large: true,
          variant:
              isWin ? NeonButtonVariant.success : NeonButtonVariant.primary,
          onTap: () {
            context.read<GameBloc>().add(const ResetGame());
            Navigator.of(context).pushReplacementNamed('/game-play');
          },
        ),
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: NeonButton(
                label: 'New Game',
                icon: Icons.tune_rounded,
                variant: NeonButtonVariant.secondary,
                onTap: () {
                  // Reset game state before navigating.
                  context.read<GameBloc>().add(const ResetGame());
                  Navigator.of(context).pushReplacementNamed('/game-setup');
                },
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: NeonButton(
                label: 'Main Menu',
                icon: Icons.home_rounded,
                variant: NeonButtonVariant.secondary,
                onTap: () {
                  // Reset game state before navigating.
                  context.read<GameBloc>().add(const ResetGame());
                  Navigator.of(context).pushReplacementNamed('/menu');
                },
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        NeonButton(
          label: 'View Replay',
          icon: Icons.play_circle_outline_rounded,
          variant: NeonButtonVariant.ghost,
          onTap: () {
            Navigator.of(context).pushNamed('/replays');
          },
        ),
      ],
    );
  }
}

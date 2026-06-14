import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advanced_xo_game/widgets/common/common.dart';
import 'package:advanced_xo_game/blocs/game_bloc.dart';
import 'package:advanced_xo_game/blocs/game_event.dart';
import 'package:advanced_xo_game/blocs/game_state.dart';

/// Game Play Screen - neon-arcade gameplay shell.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        // Navigate to result screen when game ends.
        // Only navigate once to prevent duplicate navigation.
        if (state.gameOver && !_hasNavigated && mounted) {
          _hasNavigated = true;
          final navigator = Navigator.of(context);
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              navigator.pushReplacementNamed('/game-result');
            }
          });
        }
        // Reset flag when game is reset.
        if (!state.gameOver && _hasNavigated) {
          _hasNavigated = false;
        }
      },
      child: AppScaffold(
        showBack: true,
        onBack: () => _showQuitDialog(context),
        titleWidget: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppColors.primaryGradient,
          ).createShader(bounds),
          child: Text(
            'XO Game',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GlassIconButton(
              icon: Icons.close_rounded,
              color: AppColors.red,
              tooltip: 'Quit',
              onTap: () => _showQuitDialog(context),
            ),
          ),
        ],
        body: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: AppSpacing.page,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - AppSpacing.lg * 2,
                    ),
                    child: Column(
                      children: [
                        FadeSlideIn(
                          delay: AppMotion.stagger(0),
                          child: _StatusBar(state: state),
                        ),
                        AppSpacing.vLg,
                        FadeSlideIn(
                          delay: AppMotion.stagger(1),
                          child: _BoardSurface(state: state),
                        ),
                        AppSpacing.vLg,
                        FadeSlideIn(
                          delay: AppMotion.stagger(2),
                          child: _ControlsRow(state: state),
                        ),
                        AppSpacing.vMd,
                        FadeSlideIn(
                          delay: AppMotion.stagger(3),
                          child: NeonButton(
                            label: 'Pause Game',
                            icon: Icons.pause_rounded,
                            variant: NeonButtonVariant.secondary,
                            onTap: () => _showPauseDialog(context, state),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ── Pause dialog ──────────────────────────────────────────────────────────
  void _showPauseDialog(BuildContext context, GameState state) {
    final gameBloc = context.read<GameBloc>();

    // Pause the timer.
    gameBloc.add(const PauseTimer());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _GlassDialog(
        icon: Icons.pause_circle_rounded,
        accent: AppColors.cyan,
        title: 'Game Paused',
        children: [
          NeonButton(
            label: 'Resume',
            icon: Icons.play_arrow_rounded,
            variant: NeonButtonVariant.success,
            onTap: () {
              gameBloc.add(const ResumeTimer());
              Navigator.of(dialogContext).pop();
            },
          ),
          AppSpacing.vSm,
          NeonButton(
            label: 'Restart Game',
            icon: Icons.refresh_rounded,
            variant: NeonButtonVariant.primary,
            onTap: () {
              gameBloc.add(const ResetGame());
              Navigator.of(dialogContext).pop();
            },
          ),
          AppSpacing.vSm,
          NeonButton(
            label: 'Quit to Menu',
            icon: Icons.home_rounded,
            variant: NeonButtonVariant.danger,
            onTap: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushReplacementNamed('/menu');
            },
          ),
        ],
      ),
    );
  }

  // ── Quit dialog ───────────────────────────────────────────────────────────
  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _GlassDialog(
        icon: Icons.warning_rounded,
        accent: AppColors.amber,
        title: 'Quit Game?',
        children: [
          Text(
            'Are you sure you want to quit? Your game progress will be lost.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.of(context).textMuted,
                ),
          ),
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  label: 'Cancel',
                  variant: NeonButtonVariant.secondary,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: NeonButton(
                  label: 'Quit',
                  icon: Icons.logout_rounded,
                  variant: NeonButtonVariant.danger,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushReplacementNamed('/menu');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Top status bar: honest turn indicator + timer ─────────────────────────────
class _StatusBar extends StatelessWidget {
  final GameState state;
  const _StatusBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markColor = AppColors.markColor(state.currentPlayer);

    // Honest turn indicator. In PvC, compare the active player to the player's
    // chosen side so we never claim "Your turn" while the AI is thinking.
    final bool isAiThinking = state.gameMode == GameMode.PvC &&
        state.currentPlayer != state.playerSide &&
        !state.gameOver;

    final String statusLabel;
    final Color statusColor;
    final IconData statusIcon;
    if (state.gameOver) {
      statusLabel = 'Game Over';
      statusColor = AppColors.violet;
      statusIcon = Icons.flag_rounded;
    } else if (state.gameMode == GameMode.PvC) {
      if (isAiThinking) {
        statusLabel = 'AI thinking…';
        statusColor = AppColors.amber;
        statusIcon = Icons.smart_toy_rounded;
      } else {
        statusLabel = 'Your turn';
        statusColor = AppColors.teal;
        statusIcon = Icons.touch_app_rounded;
      }
    } else {
      statusLabel = 'Player ${state.currentPlayer}\'s turn';
      statusColor = markColor;
      statusIcon = Icons.sports_esports_rounded;
    }

    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      glowColor: markColor,
      glowBlur: 30,
      child: Column(
        children: [
          Row(
            children: [
              // Active mark token.
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: markColor.withValues(alpha: 0.14),
                  borderRadius: AppRadius.rMd,
                  border: Border.all(
                    color: markColor.withValues(alpha: 0.5),
                    width: 1.4,
                  ),
                ),
                alignment: Alignment.center,
                child: AnimatedMark(
                  key: ValueKey('status-${state.currentPlayer}'),
                  mark: state.currentPlayer,
                  markSize: 30,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.gameMode == GameMode.PvC
                          ? 'Player vs Computer'
                          : 'Player vs Player',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppPalette.of(context).textMuted,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.gapXxs,
                    Row(
                      children: [
                        _PulseDot(color: statusColor),
                        AppSpacing.hXs,
                        Flexible(
                          child: Text(
                            statusLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.hSm,
              // Difficulty / mode badge.
              _ModeBadge(state: state, icon: statusIcon),
            ],
          ),
          if (state.timedMode) ...[
            AppSpacing.vSm,
            const GameTimerWidget(),
          ],
        ],
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final GameState state;
  final IconData icon;
  const _ModeBadge({required this.state, required this.icon});

  @override
  Widget build(BuildContext context) {
    final accent = state.gameMode == GameMode.PvC
        ? AppColors.difficulty(state.aiDifficulty.name)
        : AppColors.violet;
    final label = state.gameMode == GameMode.PvC
        ? state.aiDifficulty.name.toUpperCase()
        : '${state.boardSize}×${state.boardSize}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: AppRadius.rPill,
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 16),
          AppSpacing.hXs,
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = 0.4 + _controller.value * 0.6;
        return Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: t),
                blurRadius: 10,
                spreadRadius: 1.5,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Board hero surface ────────────────────────────────────────────────────────
class _BoardSurface extends StatelessWidget {
  final GameState state;
  const _BoardSurface({required this.state});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: AppSpacing.card,
      borderRadius: AppRadius.rXl,
      glowColor: AppColors.violet,
      glowBlur: 34,
      child: const GameBoard(),
    );
  }
}

// ── Controls: move counter + undo/redo ────────────────────────────────────────
class _ControlsRow extends StatelessWidget {
  final GameState state;
  const _ControlsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final moveCount = state.board.where((cell) => cell.isNotEmpty).length;
    final canUndo = state.undoStack.isNotEmpty && !state.gameOver;
    final canRedo = state.redoStack.isNotEmpty && !state.gameOver;

    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Move counter.
          Icon(Icons.touch_app_rounded, color: AppColors.violet, size: 22),
          AppSpacing.hSm,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Moves',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPalette.of(context).textMuted,
                    ),
              ),
              CountUpText(
                value: moveCount,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const Spacer(),
          // Undo / Redo.
          GlassIconButton(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            color: canUndo
                ? AppColors.teal
                : AppPalette.of(context).textMuted.withValues(alpha: 0.4),
            onTap: canUndo
                ? () => context.read<GameBloc>().add(const UndoMove())
                : null,
          ),
          AppSpacing.hSm,
          GlassIconButton(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            color: canRedo
                ? AppColors.pink
                : AppPalette.of(context).textMuted.withValues(alpha: 0.4),
            onTap: canRedo
                ? () => context.read<GameBloc>().add(const RedoMove())
                : null,
          ),
        ],
      ),
    );
  }
}

// ── Shared glass dialog shell ─────────────────────────────────────────────────
class _GlassDialog extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final List<Widget> children;

  const _GlassDialog({
    required this.icon,
    required this.accent,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GlassPanel(
        padding: AppSpacing.page,
        borderRadius: AppRadius.rXl,
        glowColor: accent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 34),
            ),
            AppSpacing.vSm,
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            AppSpacing.vLg,
            ...children,
          ],
        ),
      ),
    );
  }
}

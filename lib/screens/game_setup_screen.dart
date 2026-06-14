import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:advanced_xo_game/blocs/game_bloc.dart';
import 'package:advanced_xo_game/blocs/game_event.dart';
import 'package:advanced_xo_game/blocs/game_state.dart';
import 'package:advanced_xo_game/widgets/common/common.dart';

/// Game Setup Screen — pre-game configuration + side selection.
/// Visual-first neon-arcade redesign. All bloc-event behavior preserved.
class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int selectedBoardSize = 3;
  GameMode selectedGameMode = GameMode.PvC;
  AIDifficulty selectedDifficulty = AIDifficulty.medium;
  bool timedMode = false;
  int timeLimit = 30;
  String playerSide = 'X';
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final isPvC = selectedGameMode == GameMode.PvC;

    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        // Navigate when board size is correctly set and we're ready to go.
        if (_isNavigating && state.boardSize == selectedBoardSize) {
          _isNavigating = false;
          Navigator.of(context).pushReplacementNamed('/game-play');
        }
      },
      child: AppScaffold(
        title: 'Game Setup',
        showBack: true,
        padding: AppSpacing.page,
        bottomBar: _buildBottomBar(),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Board size
            FadeSlideIn(
              delay: AppMotion.stagger(0),
              child: const SectionHeader(
                icon: Icons.grid_view_rounded,
                title: 'Board Size',
                subtitle: 'Pick your battlefield',
                accent: AppColors.violet,
              ),
            ),
            AppSpacing.vMd,
            FadeSlideIn(
              delay: AppMotion.stagger(1),
              child: _buildBoardSizeSelector(),
            ),
            AppSpacing.vXl,

            // Game mode
            FadeSlideIn(
              delay: AppMotion.stagger(2),
              child: const SectionHeader(
                icon: Icons.sports_esports_rounded,
                title: 'Game Mode',
                subtitle: 'Who are you up against?',
                accent: AppColors.pink,
              ),
            ),
            AppSpacing.vMd,
            FadeSlideIn(
              delay: AppMotion.stagger(3),
              child: _buildGameModeSelector(),
            ),
            AppSpacing.vXl,

            // AI difficulty (PvC only)
            if (isPvC) ...[
              FadeSlideIn(
                delay: AppMotion.stagger(4),
                child: const SectionHeader(
                  icon: Icons.psychology_rounded,
                  title: 'AI Difficulty',
                  subtitle: 'How tough should the bot be?',
                  accent: AppColors.amber,
                ),
              ),
              AppSpacing.vMd,
              FadeSlideIn(
                delay: AppMotion.stagger(5),
                child: _buildDifficultySelector(),
              ),
              AppSpacing.vXl,
            ],

            // Side picker
            FadeSlideIn(
              delay: AppMotion.stagger(6),
              child: const SectionHeader(
                icon: Icons.flag_rounded,
                title: 'Your Side',
                subtitle: 'Choose your mark',
                accent: AppColors.teal,
              ),
            ),
            AppSpacing.vMd,
            FadeSlideIn(
              delay: AppMotion.stagger(7),
              child: _buildSidePicker(),
            ),
            AppSpacing.vXl,

            // Timed mode
            FadeSlideIn(
              delay: AppMotion.stagger(8),
              child: const SectionHeader(
                icon: Icons.timer_rounded,
                title: 'Timed Mode',
                subtitle: 'Beat the clock',
                accent: AppColors.cyan,
              ),
            ),
            AppSpacing.vMd,
            FadeSlideIn(
              delay: AppMotion.stagger(9),
              child: _buildTimedModeToggle(),
            ),
            if (timedMode) ...[
              AppSpacing.vMd,
              FadeSlideIn(
                delay: AppMotion.stagger(10),
                child: _buildTimeLimitSelector(),
              ),
            ],
            AppSpacing.vLg,
          ],
        ),
      ),
    );
  }

  // ── Bottom CTA ───────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: NeonButton(
          label: 'Start Game',
          icon: Icons.play_arrow_rounded,
          large: true,
          onTap: _startGame,
        ),
      ),
    );
  }

  // ── Board size ─────────────────────────────────────────────────────────────
  Widget _buildBoardSizeSelector() {
    const sizes = [3, 4, 5];
    const labels = {3: 'Classic', 4: 'Advanced', 5: 'Expert'};
    return Row(
      children: [
        for (final size in sizes) ...[
          Expanded(
            child: _buildBoardSizeTile(size, labels[size]!),
          ),
          if (size != sizes.last) AppSpacing.hSm,
        ],
      ],
    );
  }

  Widget _buildBoardSizeTile(int size, String label) {
    final isSelected = selectedBoardSize == size;
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return GlassPanel(
      onTap: () => setState(() => selectedBoardSize = size),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xs,
      ),
      gradient: isSelected
          ? const LinearGradient(colors: AppColors.primaryGradient)
          : null,
      glowColor: isSelected ? AppColors.violet : null,
      borderColor: isSelected ? Colors.transparent : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniGrid(
            size: size,
            color: isSelected ? Colors.white : p.textMuted,
          ),
          AppSpacing.vSm,
          Text(
            '$size×$size',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : p.text,
            ),
          ),
          AppSpacing.vXs,
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.85)
                  : p.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Game mode ──────────────────────────────────────────────────────────────
  Widget _buildGameModeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildModeCard(
            'Player vs Player',
            Icons.people_alt_rounded,
            GameMode.PvP,
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: _buildModeCard(
            'Player vs Computer',
            Icons.smart_toy_rounded,
            GameMode.PvC,
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard(String title, IconData icon, GameMode mode) {
    final isSelected = selectedGameMode == mode;
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return GlassPanel(
      onTap: () => setState(() => selectedGameMode = mode),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      gradient: isSelected
          ? const LinearGradient(colors: AppColors.coolGradient)
          : null,
      glowColor: isSelected ? AppColors.cyan : null,
      borderColor: isSelected ? Colors.transparent : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 34,
            color: isSelected ? Colors.white : AppColors.cyan,
          ),
          AppSpacing.vSm,
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : p.text,
            ),
          ),
        ],
      ),
    );
  }

  // ── AI difficulty ──────────────────────────────────────────────────────────
  Widget _buildDifficultySelector() {
    const entries = [
      (AIDifficulty.easy, 'Easy', 'easy', Icons.sentiment_satisfied_rounded),
      (AIDifficulty.medium, 'Medium', 'medium', Icons.bolt_rounded),
      (AIDifficulty.hard, 'Hard', 'hard', Icons.local_fire_department_rounded),
      (AIDifficulty.impossible, 'Impossible', 'impossible', Icons.whatshot_rounded),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (diff, label, key, icon) in entries)
          _buildDifficultyChip(diff, label, AppColors.difficulty(key), icon),
      ],
    );
  }

  Widget _buildDifficultyChip(
    AIDifficulty difficulty,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = selectedDifficulty == difficulty;
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return Pressable(
      onTap: () => setState(() => selectedDifficulty = difficulty),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : p.surface,
          borderRadius: AppRadius.rPill,
          border: Border.all(
            color: isSelected ? color : p.border,
            width: 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            AppSpacing.hXs,
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : p.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Side picker ────────────────────────────────────────────────────────────
  Widget _buildSidePicker() {
    return Row(
      children: [
        Expanded(child: _buildSideTile('X')),
        AppSpacing.hSm,
        Expanded(child: _buildSideTile('O')),
      ],
    );
  }

  Widget _buildSideTile(String mark) {
    final isSelected = playerSide == mark;
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final markColor = AppColors.markColor(mark);

    return GlassPanel(
      onTap: () => setState(() => playerSide = mark),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      glowColor: isSelected ? markColor : null,
      borderColor: isSelected ? markColor : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 72,
            child: Center(
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.45,
                duration: AppMotion.fast,
                child: AnimatedMark(mark: mark, markSize: 64),
              ),
            ),
          ),
          AppSpacing.vSm,
          Text(
            'Play as $mark',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected ? markColor : p.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Timed mode ─────────────────────────────────────────────────────────────
  Widget _buildTimedModeToggle() {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return GlassPanel(
      onTap: () => setState(() => timedMode = !timedMode),
      glowColor: timedMode ? AppColors.cyan : null,
      borderColor: timedMode ? AppColors.cyan : null,
      child: Row(
        children: [
          Icon(
            timedMode ? Icons.timer_rounded : Icons.timer_off_rounded,
            color: timedMode ? AppColors.cyan : p.textMuted,
          ),
          AppSpacing.hMd,
          Expanded(
            child: Text(
              'Enable Time Limit',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
          ),
          Switch(
            value: timedMode,
            onChanged: (value) => setState(() => timedMode = value),
            activeThumbColor: AppColors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLimitSelector() {
    const options = [10, 20, 30, 60];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final seconds in options) _buildTimeChip(seconds),
      ],
    );
  }

  Widget _buildTimeChip(int seconds) {
    final isSelected = timeLimit == seconds;
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return Pressable(
      onTap: () => setState(() => timeLimit = seconds),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan : p.surface,
          borderRadius: AppRadius.rPill,
          border: Border.all(
            color: isSelected ? AppColors.cyan : p.border,
            width: 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          '${seconds}s',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : p.text,
          ),
        ),
      ),
    );
  }

  // ── Start logic (behavior preserved 1:1) ───────────────────────────────────
  void _startGame() {
    final gameBloc = context.read<GameBloc>();

    // Set flag to trigger navigation when board size is updated.
    setState(() {
      _isNavigating = true;
    });

    // Apply board settings (this also resets the game state).
    // Win conditions: 3x3 needs 3 in a row, 4x4 needs 4, 5x5 needs 4.
    final winCondition = selectedBoardSize == 3 ? 3 : 4;
    gameBloc.add(UpdateBoardSettings(selectedBoardSize, winCondition));

    // Set game mode if PvP (default is PvC, so only toggle if needed).
    if (selectedGameMode == GameMode.PvP &&
        gameBloc.state.gameMode != GameMode.PvP) {
      gameBloc.add(const ToggleGameMode());
    } else if (selectedGameMode == GameMode.PvC &&
        gameBloc.state.gameMode != GameMode.PvC) {
      gameBloc.add(const ToggleGameMode());
    }

    gameBloc.add(ChangeDifficulty(selectedDifficulty));
    gameBloc.add(SetPlayerSide(playerSide));

    if (timedMode) {
      gameBloc.add(const ToggleTimedMode());
      gameBloc.add(SetTimeLimit(timeLimit));
    }

    // Navigation will happen in BlocListener when board size is updated.
  }
}

/// A small static n×n grid preview drawn for the board-size tiles.
class _MiniGrid extends StatelessWidget {
  final int size;
  final Color color;

  const _MiniGrid({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _MiniGridPainter(size: size, color: color),
      ),
    );
  }
}

class _MiniGridPainter extends CustomPainter {
  final int size;
  final Color color;

  _MiniGridPainter({required this.size, required this.color});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final step = canvasSize.width / size;
    for (var i = 1; i < size; i++) {
      final dx = step * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, canvasSize.height), paint);
      final dy = step * i;
      canvas.drawLine(Offset(0, dy), Offset(canvasSize.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniGridPainter old) =>
      old.size != size || old.color != color;
}

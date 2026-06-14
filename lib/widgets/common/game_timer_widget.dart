import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game_bloc.dart';
import '../../blocs/game_event.dart';
import '../../blocs/game_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Per-move countdown for timed mode. Drives `TimerTick` every 100ms (the BLoC
/// resets elapsed time on each move, so this counts down per turn). Shows a
/// colored pill + thin progress bar with urgency colors.
class GameTimerWidget extends StatefulWidget {
  const GameTimerWidget({super.key});

  @override
  State<GameTimerWidget> createState() => _GameTimerWidgetState();
}

class _GameTimerWidgetState extends State<GameTimerWidget> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _ensureRunning(GameBloc bloc) {
    _timer ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
      bloc.add(const TimerTick());
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (a, b) =>
          a.elapsedTime != b.elapsedTime ||
          a.isTimerActive != b.isTimerActive ||
          a.timedMode != b.timedMode ||
          a.gameOver != b.gameOver,
      builder: (context, state) {
        final bloc = context.read<GameBloc>();
        if (state.isTimerActive && state.timedMode && !state.gameOver) {
          _ensureRunning(bloc);
        } else {
          _stop();
        }

        if (!state.timedMode) return const SizedBox.shrink();

        final remaining =
            (state.totalGameTime - state.elapsedTime / 1000).ceil().clamp(0, 9999);
        final fraction = state.totalGameTime == 0
            ? 0.0
            : (remaining / state.totalGameTime).clamp(0.0, 1.0);

        final Color color = remaining <= 5
            ? AppColors.red
            : remaining <= 10
                ? AppColors.amber
                : AppColors.teal;

        final theme = Theme.of(context);

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: AppRadius.rPill,
            border: Border.all(color: color.withValues(alpha: 0.45), width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_rounded, color: color, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${remaining}s',
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: AppRadius.rPill,
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 5,
                    backgroundColor: color.withValues(alpha: 0.18),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

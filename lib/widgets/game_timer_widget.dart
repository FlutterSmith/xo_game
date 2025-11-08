import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';

/// Timer widget for timed game mode
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

  void _startTimer(GameBloc bloc) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bloc.add(const TimerTick());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (previous, current) =>
          previous.elapsedTime != current.elapsedTime ||
          previous.isTimerActive != current.isTimerActive ||
          previous.timedMode != current.timedMode,
      builder: (context, state) {
        final bloc = context.read<GameBloc>();

        // Handle timer state
        if (state.isTimerActive && state.timedMode && !state.gameOver) {
          _startTimer(bloc);
        } else {
          _stopTimer();
        }

        if (!state.timedMode) {
          return const SizedBox.shrink();
        }

        // Calculate remaining time (in seconds)
        final remainingTime = (state.totalGameTime - (state.elapsedTime / 1000)).toInt();

        // Determine urgency color
        Color timerColor;
        if (remainingTime <= 5) {
          timerColor = const Color(0xFFef4444); // Red - critical
        } else if (remainingTime <= 10) {
          timerColor = const Color(0xFFf59e0b); // Amber - warning
        } else {
          timerColor = const Color(0xFF16f2b3); // Green - safe
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                timerColor.withOpacity(0.2),
                timerColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: timerColor.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_rounded,
                color: timerColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '${remainingTime}s',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1e1436),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

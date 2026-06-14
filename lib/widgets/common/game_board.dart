import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game_bloc.dart';
import '../../blocs/game_state.dart';
import '../../blocs/game_event.dart';
import 'game_cell.dart';

/// One board widget for 3x3 / 4x4 / 5x5 — replaces board_widget / board_widget3
/// / board_widget5. crossAxisCount and mark size derive from `state.boardSize`.
/// Tap handling preserves PvC turn-gating, which also blocks taps while the AI
/// is thinking (currentPlayer != playerSide).
class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (a, b) =>
          a.board != b.board ||
          a.winningCells != b.winningCells ||
          a.gameOver != b.gameOver ||
          a.boardSize != b.boardSize ||
          a.currentPlayer != b.currentPlayer ||
          a.playerSide != b.playerSide ||
          a.gameMode != b.gameMode,
      builder: (context, state) {
        final size = state.boardSize;
        // Smaller marks on bigger boards.
        final markSize = size == 3
            ? 64.0
            : size == 4
                ? 48.0
                : 38.0;
        final spacing = size == 3 ? 10.0 : 8.0;

        return AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: state.board.length,
            itemBuilder: (context, index) {
              final highlight = state.winningCells.contains(index);
              return GameCell(
                value: state.board[index],
                highlight: highlight,
                dimmed: state.gameOver,
                markSize: markSize,
                onTap: () {
                  if (state.board[index] != '' || state.gameOver) return;
                  // In PvC, only allow taps on the player's turn (this also
                  // blocks input while the AI is deciding).
                  if (state.gameMode == GameMode.PvC &&
                      state.currentPlayer != state.playerSide) {
                    return;
                  }
                  context.read<GameBloc>().add(MoveMade(index));
                },
              );
            },
          ),
        );
      },
    );
  }
}

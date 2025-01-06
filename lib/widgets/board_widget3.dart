import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';
import 'cell_widget.dart';

class BoardWidget3 extends StatelessWidget {
  const BoardWidget3({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        double boardSizePx = MediaQuery.of(context).size.width * 0.9;
        return AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: state.board.length,
            itemBuilder: (context, index) {
              bool highlight = state.winningCells.contains(index);
              return CellWidget(
                index: index,
                value: state.board[index],
                highlight: highlight,
                onTap: () {
                  if (state.board[index] == '' && !state.gameOver) {
                    // In PvC mode, only allow moves when it's the player's turn
                    if (state.gameMode == GameMode.PvC && state.currentPlayer != state.playerSide) {
                      return; // It's not the player's turn
                    }
                    context.read<GameBloc>().add(MoveMade(index));
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

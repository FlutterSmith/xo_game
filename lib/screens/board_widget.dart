import 'package:advanced_xo_game/screens/cell_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        double boardSize = MediaQuery.of(context).size.width * 0.9;
        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemCount: state.board.length,
            itemBuilder: (context, index) {
              bool highlight = state.winningCells.contains(index);
              return CellWidget(
                index: index,
                value: state.board[index],
                highlight: highlight,
                onTap: () {
                  if (state.board[index] == '' && !state.gameOver) {
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

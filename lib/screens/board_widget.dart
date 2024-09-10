import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        double boardSizePx = MediaQuery.of(context).size.width * 0.9;
        return SizedBox(
          width: boardSizePx,
          height: boardSizePx,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: state.boardSize,
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

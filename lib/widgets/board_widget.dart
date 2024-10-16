import 'package:advanced_xo_game/widgets/cell_widget4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';

class BoardWidget4 extends StatelessWidget {
  const BoardWidget4({super.key});
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
              crossAxisCount: 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: state.board.length,
            itemBuilder: (context, index) {
              bool highlight = state.winningCells.contains(index);
              return CellWidget4(
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

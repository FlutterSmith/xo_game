import 'package:advanced_xo_game/screens/board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';
import '../blocs/theme_cubit.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('TicTac by AH'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => gameBloc.add(const ResetGame()),
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue.shade200, Colors.blue.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    state.gameOver
                        ? state.resultMessage
                        : 'Turn: ${state.currentPlayer}',
                    style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: state.boardSize,
                      dropdownColor: Colors.blue.shade700,
                      items: [3, 4, 5]
                          .map((e) => DropdownMenuItem<int>(
                              value: e,
                              child: Text('Board: ${e}x$e',
                                  style: const TextStyle(color: Colors.white))))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          int winCond = value;
                          gameBloc.add(UpdateBoardSettings(value, winCond));
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    DropdownButton<AIDifficulty>(
                      value: state.aiDifficulty,
                      dropdownColor: Colors.blue.shade700,
                      items: AIDifficulty.values
                          .map((e) => DropdownMenuItem<AIDifficulty>(
                              value: e,
                              child: Text(
                                  e.toString().split('.').last.toUpperCase(),
                                  style: const TextStyle(color: Colors.white))))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          gameBloc.add(ChangeDifficulty(value));
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const BoardWidget(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: state.undoStack.isNotEmpty
                          ? () => gameBloc.add(const UndoMove())
                          : null,
                      child: const Text('Undo'),
                    ),
                    ElevatedButton(
                      onPressed: state.redoStack.isNotEmpty
                          ? () => gameBloc.add(const RedoMove())
                          : null,
                      child: const Text('Redo'),
                    ),
                    ElevatedButton(
                      onPressed: () => gameBloc.add(const ToggleGameMode()),
                      child:
                          Text(state.gameMode == GameMode.PvP ? 'PvP' : 'PvC'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

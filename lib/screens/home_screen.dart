import 'package:advanced_xo_game/screens/board_widget.dart';
import 'package:advanced_xo_game/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GameBloc>().add(const ResetGame()),
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.gameOver ? state.resultMessage : 'Turn: ${state.currentPlayer}', style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const BoardWidget(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: state.undoStack.isNotEmpty ? () => context.read<GameBloc>().add(const UndoMove()) : null,
                      child: const Text('Undo'),
                    ),
                    ElevatedButton(
                      onPressed: state.redoStack.isNotEmpty ? () => context.read<GameBloc>().add(const RedoMove()) : null,
                      child: const Text('Redo'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.read<GameBloc>().add(const ToggleGameMode()),
                      child: Text(state.gameMode == GameMode.PvP ? 'PvP' : 'PvC'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        AIDifficulty current = state.aiDifficulty;
                        AIDifficulty next;
                        if (current == AIDifficulty.easy) {
                          next = AIDifficulty.medium;
                        } else if (current == AIDifficulty.medium) {
                          next = AIDifficulty.hard;
                        } else {
                          next = AIDifficulty.easy;
                        }
                        context.read<GameBloc>().add(ChangeDifficulty(next));
                      },
                      child: Text(state.aiDifficulty.toString().split('.').last.toUpperCase()),
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

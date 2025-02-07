import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game History')),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.gameHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(state.gameHistory[index],
                    style: const TextStyle(fontSize: 20)),
              );
            },
          );
        },
      ),
    );
  }
}

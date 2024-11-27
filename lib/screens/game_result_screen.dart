import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';

/// Game Result Screen - Show win/loss/draw with options
/// Will be implemented in Phase 3 with full UI and animations
class GameResultScreen extends StatelessWidget {
  const GameResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        String resultText = state.resultMessage;
        Color resultColor = Colors.blue;

        if (resultText.contains('wins')) {
          resultColor = Colors.green;
        } else if (resultText.contains('Draw')) {
          resultColor = Colors.orange;
        } else if (resultText.contains('loses') || resultText.contains('timeout')) {
          resultColor = Colors.red;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Game Result'),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  resultText.contains('wins') ? Icons.emoji_events :
                  resultText.contains('Draw') ? Icons.handshake : Icons.sentiment_dissatisfied,
                  size: 100,
                  color: resultColor,
                ),
                const SizedBox(height: 20),
                Text(
                  resultText,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Rematch - same settings
                    context.read<GameBloc>().add(const ResetGame());
                    Navigator.of(context).pushReplacementNamed('/game-play');
                  },
                  child: const Text('Play Again'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // New game - back to setup
                    Navigator.of(context).pushReplacementNamed('/game-setup');
                  },
                  child: const Text('New Game'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/menu');
                  },
                  child: const Text('Main Menu'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/replays');
                  },
                  child: const Text('View Replay'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';

/// Game Setup Screen - Configure game before playing
/// Will be implemented in Phase 3 with full UI
class GameSetupScreen extends StatelessWidget {
  const GameSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Setup'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Configure Your Game',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const Text('Board Size: 3x3 (default)'),
            const SizedBox(height: 16),
            const Text('Mode: Player vs Computer (default)'),
            const SizedBox(height: 16),
            const Text('Difficulty: Medium (default)'),
            const SizedBox(height: 16),
            const Text('Time Limit: Off (default)'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Reset game with default settings
                context.read<GameBloc>().add(const ResetGame());
                Navigator.of(context).pushReplacementNamed('/game-play');
              },
              child: const Text('Start Game'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:advanced_xo_game/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';
import '../blocs/theme_cubit.dart';
import '../blocs/settings_cubit.dart';
import '../blocs/statistics_cubit.dart';
import '../widgets/board_widget3.dart';
import '../widgets/board_widget5.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'appLogo',
              child: Image.asset(
                'assets/icon/icon.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 8),
            const Text('X‑O Game'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => gameBloc.add(const ResetGame()),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Dropdown for board size selection.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Board Size:',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: state.boardSize,
                      dropdownColor: Colors.blue.shade700,
                      items: [3, 4, 5]
                          .map(
                            (e) => DropdownMenuItem<int>(
                              value: e,
                              child: Text(' ${e}x$e',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          gameBloc.add(UpdateBoardSettings(value, value));
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Dropdown for AI difficulty selection.
                DropdownButton<AIDifficulty>(
                  value: state.aiDifficulty,
                  dropdownColor: Colors.blue.shade700,
                  items: AIDifficulty.values
                      .map(
                        (e) => DropdownMenuItem<AIDifficulty>(
                          value: e,
                          child: Text(
                              e.toString().split('.').last.toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      gameBloc.add(ChangeDifficulty(value));
                    }
                  },
                ),
                const SizedBox(height: 10),
                // Display appropriate board widget.
                state.boardSize == 3
                    ? const BoardWidget3()
                    : state.boardSize == 4
                        ? const BoardWidget4()
                        : const BoardWidget5(),
                const SizedBox(height: 10),
                // Bottom control row.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AdvancedNeumorphicButton(
                      onPressed: state.undoStack.isNotEmpty
                          ? () => gameBloc.add(const UndoMove())
                          : () {},
                      child: const Text(
                        'Undo',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    AdvancedNeumorphicButton(
                      onPressed: state.redoStack.isNotEmpty
                          ? () => gameBloc.add(const RedoMove())
                          : () {},
                      child: const Text(
                        'Redo',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    AdvancedNeumorphicButton(
                      onPressed: () => gameBloc.add(const ToggleGameMode()),
                      child: Text(
                        state.gameMode == GameMode.PvP ? 'PvP' : 'PvC',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.bar_chart,
            title: 'Statistics',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/statistics');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.emoji_events,
            title: 'Achievements',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/achievements');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.movie,
            title: 'Game Replays',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/replays');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history,
            title: 'Game History',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/history');
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.school,
            title: 'How to Play',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/tutorial');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return BlocBuilder<SettingsCubit, dynamic>(
      builder: (context, settings) {
        final playerName = settings?.playerName ?? 'Player';
        return DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.blue.shade700],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
              const SizedBox(height: 12),
              Text(
                playerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              BlocBuilder<StatisticsCubit, dynamic>(
                builder: (context, stats) {
                  final winRate = stats?.winRate ?? 0.0;
                  return Text(
                    'Win Rate: ${winRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

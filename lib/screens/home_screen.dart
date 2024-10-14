import 'package:advanced_xo_game/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';
import '../blocs/theme_cubit.dart';
import '../blocs/settings_cubit.dart';
import '../blocs/statistics_cubit.dart';
import '../models/app_settings.dart';
import '../models/game_stats.dart';
import '../widgets/board_widget3.dart';
import '../widgets/board_widget5.dart';
import '../widgets/board_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'appLogo',
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFec4899).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
              ).createShader(bounds),
              child: const Text(
                'X‑O Game',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Icon(
                Icons.refresh,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: () => gameBloc.add(const ResetGame()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0f172a),
                    const Color(0xFF1e293b),
                    const Color(0xFF0d1224),
                  ]
                : [
                    const Color(0xFFf8fafc),
                    const Color(0xFFe0e7ff),
                    const Color(0xFFdbeafe),
                  ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Game Status Card
                    _buildStatusCard(context, state, isDark),
                    const SizedBox(height: 20),

                    // Game Controls Card
                    _buildControlsCard(context, state, isDark, gameBloc),
                    const SizedBox(height: 20),

                    // Game Board
                    _buildGameBoard(context, state),
                    const SizedBox(height: 20),

                    // Action Buttons
                    _buildActionButtons(context, state, gameBloc, isDark),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, GameState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1e293b).withOpacity(0.8),
                  const Color(0xFF334155).withOpacity(0.6),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF8b5cf6).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF8b5cf6).withOpacity(0.2)
                : const Color(0xFF8b5cf6).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
                ).createShader(bounds),
                child: Text(
                  state.gameOver ? state.resultMessage : 'Turn: ${state.currentPlayer}',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!state.gameOver) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state.gameMode == GameMode.PvP ? 'Player vs Player' : 'Player vs AI',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsCard(BuildContext context, GameState state, bool isDark, GameBloc gameBloc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1e293b).withOpacity(0.6),
                  const Color(0xFF334155).withOpacity(0.4),
                ]
              : [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF8b5cf6).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_4x4,
                color: isDark ? const Color(0xFFec4899) : const Color(0xFF8b5cf6),
              ),
              const SizedBox(width: 8),
              Text(
                'Board Size',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF334155)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFF8b5cf6).withOpacity(0.2),
              ),
            ),
            child: DropdownButton<int>(
              value: state.boardSize,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: isDark ? const Color(0xFF334155) : Colors.white,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? Colors.white : Colors.black87,
              ),
              items: [3, 4, 5]
                  .map(
                    (e) => DropdownMenuItem<int>(
                      value: e,
                      child: Text(
                        '${e}x$e Grid',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  gameBloc.add(UpdateBoardSettings(value, value));
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: isDark ? const Color(0xFFec4899) : const Color(0xFF8b5cf6),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Difficulty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF334155)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : const Color(0xFF8b5cf6).withOpacity(0.2),
              ),
            ),
            child: DropdownButton<AIDifficulty>(
              value: state.aiDifficulty,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: isDark ? const Color(0xFF334155) : Colors.white,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? Colors.white : Colors.black87,
              ),
              items: AIDifficulty.values
                  .map(
                    (e) => DropdownMenuItem<AIDifficulty>(
                      value: e,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _getDifficultyColors(e),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  gameBloc.add(ChangeDifficulty(value));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getDifficultyColors(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return [const Color(0xFF16f2b3), const Color(0xFF06b6d4)];
      case AIDifficulty.medium:
        return [const Color(0xFFfbbf24), const Color(0xFFf59e0b)];
      case AIDifficulty.hard:
        return [const Color(0xFFef4444), const Color(0xFFdc2626)];
      case AIDifficulty.adaptive:
        return [const Color(0xFFec4899), const Color(0xFF8b5cf6)];
    }
  }

  Widget _buildGameBoard(BuildContext context, GameState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  const Color(0xFF1e293b).withOpacity(0.6),
                  const Color(0xFF334155).withOpacity(0.4),
                ]
              : [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF8b5cf6).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8b5cf6).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: state.boardSize == 3
          ? const BoardWidget3()
          : state.boardSize == 4
              ? BoardWidget4()
              : BoardWidget5(),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameState state, GameBloc gameBloc, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: AdvancedNeumorphicButton(
            onPressed: state.undoStack.isNotEmpty
                ? () => gameBloc.add(const UndoMove())
                : () {},
            isEnabled: state.undoStack.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.undo, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text('Undo'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AdvancedNeumorphicButton(
            onPressed: state.redoStack.isNotEmpty
                ? () => gameBloc.add(const RedoMove())
                : () {},
            isEnabled: state.redoStack.isNotEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.redo, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text('Redo'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AdvancedNeumorphicButton(
            onPressed: () => gameBloc.add(const ToggleGameMode()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.gameMode == GameMode.PvP ? Icons.people : Icons.smart_toy,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(state.gameMode == GameMode.PvP ? 'PvP' : 'PvC'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0f172a),
                    const Color(0xFF1e293b),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFf8fafc),
                  ],
          ),
        ),
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
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8b5cf6).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                settings.playerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<StatisticsCubit, GameStats>(
                builder: (context, stats) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Win Rate: ${stats.winRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

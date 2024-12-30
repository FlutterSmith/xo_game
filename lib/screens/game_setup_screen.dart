import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../blocs/game_state.dart';

/// Game Setup Screen - Configure game before playing
class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int selectedBoardSize = 3;
  GameMode selectedGameMode = GameMode.PvC;
  AIDifficulty selectedDifficulty = AIDifficulty.medium;
  bool timedMode = false;
  int timeLimit = 30;
  String playerSide = 'X';
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        // Navigate when board size is correctly set and we're ready to go
        if (_isNavigating && state.boardSize == selectedBoardSize) {
          _isNavigating = false;
          Navigator.of(context).pushReplacementNamed('/game-play');
        }
      },
      child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0d1224),
                    const Color(0xFF1e1436),
                    const Color(0xFF0f172a),
                  ]
                : [
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                    Colors.pink.shade50,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Game Setup',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
              ),

              // Configuration Options
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Board Size
                      _buildSectionTitle('Board Size', Icons.grid_on, isDark),
                      const SizedBox(height: 12),
                      _buildBoardSizeSelector(isDark),
                      const SizedBox(height: 24),

                      // Game Mode
                      _buildSectionTitle(
                          'Game Mode', Icons.people, isDark),
                      const SizedBox(height: 12),
                      _buildGameModeSelector(isDark),
                      const SizedBox(height: 24),

                      // AI Difficulty (only for PvC)
                      if (selectedGameMode == GameMode.PvC) ...[
                        _buildSectionTitle(
                            'AI Difficulty', Icons.psychology, isDark),
                        const SizedBox(height: 12),
                        _buildDifficultySelector(isDark),
                        const SizedBox(height: 24),

                        // Player Side
                        _buildSectionTitle(
                            'Play As', Icons.person, isDark),
                        const SizedBox(height: 12),
                        _buildPlayerSideSelector(isDark),
                        const SizedBox(height: 24),
                      ],

                      // Time Limit
                      _buildSectionTitle(
                          'Time Limit', Icons.timer, isDark),
                      const SizedBox(height: 12),
                      _buildTimeLimitToggle(isDark),
                      if (timedMode) ...[
                        const SizedBox(height: 12),
                        _buildTimeLimitSelector(isDark),
                      ],
                      const SizedBox(height: 40),

                      // Start Game Button
                      _buildStartButton(isDark),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFec4899),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildBoardSizeSelector(bool isDark) {
    return Row(
      children: [3, 4, 5].map((size) {
        final isSelected = selectedBoardSize == size;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => selectedBoardSize = size),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${size}×$size',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isDark
                                  ? Colors.white
                                  : Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        size == 3 ? 'Classic' : size == 4 ? 'Advanced' : 'Expert',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white70
                              : isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameModeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildModeCard(
            'Player vs Player',
            'P vs P',
            Icons.people_rounded,
            GameMode.PvP,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModeCard(
            'Player vs Computer',
            'P vs PC',
            Icons.computer_rounded,
            GameMode.PvC,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard(
    String title,
    String subtitle,
    IconData icon,
    GameMode mode,
    bool isDark,
  ) {
    final isSelected = selectedGameMode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => selectedGameMode = mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF8b5cf6), Color(0xFF06b6d4)],
                  )
                : null,
            color: isSelected
                ? null
                : isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF8b5cf6),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white
                          : Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDifficultyCard(
                  'Easy', AIDifficulty.easy, Colors.green, isDark),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDifficultyCard(
                  'Medium', AIDifficulty.medium, Colors.orange, isDark),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDifficultyCard(
                  'Hard', AIDifficulty.hard, Colors.red, isDark),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDifficultyCard(
                  'Impossible', AIDifficulty.impossible, Colors.purple, isDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(
      String label, AIDifficulty difficulty, Color color, bool isDark) {
    final isSelected = selectedDifficulty == difficulty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => selectedDifficulty = difficulty),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color
                  : isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.white
                      : Colors.grey.shade900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSideSelector(bool isDark) {
    return Row(
      children: ['X', 'O'].map((side) {
        final isSelected = playerSide == side;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => playerSide = side),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF06b6d4), Color(0xFF16f2b3)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    side,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? Colors.white
                              : Colors.grey.shade900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeLimitToggle(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => timedMode = !timedMode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enable Time Limit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
              Switch(
                value: timedMode,
                onChanged: (value) => setState(() => timedMode = value),
                activeColor: const Color(0xFFec4899),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeLimitSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [10, 20, 30, 60].map((seconds) {
        final isSelected = timeLimit == seconds;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => timeLimit = seconds),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFec4899)
                    : isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFec4899)
                      : isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Text(
                '${seconds}s',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white
                          : Colors.grey.shade900,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _startGame,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFec4899), Color(0xFF8b5cf6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFec4899).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame() {
    final gameBloc = context.read<GameBloc>();

    // Set flag to trigger navigation when board size is updated
    setState(() {
      _isNavigating = true;
    });

    // Apply board settings (this also resets the game state)
    // Win conditions: 3x3 needs 3 in a row, 4x4 needs 4, 5x5 needs 4
    final winCondition = selectedBoardSize == 3 ? 3 : 4;
    gameBloc.add(UpdateBoardSettings(selectedBoardSize, winCondition));
    gameBloc.add(ChangeDifficulty(selectedDifficulty));
    gameBloc.add(SetPlayerSide(playerSide));

    if (timedMode) {
      gameBloc.add(const ToggleTimedMode());
      gameBloc.add(SetTimeLimit(timeLimit));
    }

    // Navigation will happen in BlocListener when board size is updated
  }
}

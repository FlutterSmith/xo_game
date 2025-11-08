# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

XO Game is a professional-grade Tic Tac Toe Flutter application with AI opponents, statistics tracking, achievements, and game replay functionality. Built with BLoC pattern for state management and SQLite/SharedPreferences for persistence.

**Key Stack:**
- Flutter 3.0+, Dart 2.17+
- State Management: flutter_bloc ^9.0.0
- Persistence: sqflite ^2.0.0 (mobile), shared_preferences ^2.2.2 (web)
- Platform Support: Android, iOS, Web

## Development Commands

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome

# Run on specific port (web)
flutter run -d chrome --web-port=9300

# Hot reload is enabled by default (press 'r' in terminal)
```

### Building

```bash
# Build for web (release)
flutter build web --release

# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build for iOS
flutter build ios --release
```

### Testing & Quality

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/game_logic_test.dart

# Run with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Get dependencies
flutter pub get
```

### Icons

```bash
# Generate app icons for all platforms
flutter pub run flutter_launcher_icons
```

## Architecture

### BLoC Pattern State Management

The app uses **flutter_bloc** with a clear separation between events, states, and business logic:

**Four Main BLoCs/Cubits:**

1. **GameBloc** (`lib/blocs/game_bloc.dart`)
   - Manages all game logic, board state, AI moves, undo/redo
   - Handles events: MoveMade, AITurn, UndoMove, RedoMove, ResetGame, ToggleGameMode, ChangeDifficulty, UpdateBoardSettings
   - AI logic uses minimax algorithm with alpha-beta pruning (hard difficulty)
   - Supports 3x3, 4x4, 5x5 boards with dynamic win condition checking
   - Integrates with DatabaseService for replay persistence

2. **ThemeCubit** (`lib/blocs/theme_cubit.dart`)
   - Toggles between dark/light themes
   - Emits ThemeData directly

3. **SettingsCubit** (`lib/blocs/settings_cubit.dart`)
   - Manages app settings: player name, sound, vibration, theme mode, AI difficulty, default board size
   - Persists settings via DatabaseService
   - Updates SoundService and VibrationService when settings change

4. **StatisticsCubit** (`lib/blocs/statistics_cubit.dart`)
   - Tracks game statistics: wins, losses, draws, win rate
   - Provides breakdown by game mode (PvP vs PvC) and board size
   - Loads/saves statistics via DatabaseService

**BLoC Provider Setup:**
All BLoCs are provided at app root in `main.dart` using MultiBlocProvider:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
    BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
    BlocProvider<StatisticsCubit>(create: (_) => StatisticsCubit()),
    BlocProvider<GameBloc>(create: (_) => GameBloc()..add(const LoadHistory())),
  ],
  child: const MyApp(),
)
```

### Service Layer

**DatabaseService** (`lib/services/database_service.dart`)
- **Platform-aware persistence**: Uses sqflite for mobile, shared_preferences for web
- Singleton pattern: `DatabaseService.instance`
- Key methods:
  - Settings: `getSettings()`, `updateSettings()`
  - Statistics: `getStats()`, `updateStats()`
  - Achievements: `getAchievements()`, `updateAchievementProgress()`
  - Replays: `saveReplay()`, `getReplays()`, `deleteReplay()`
- Web compatibility: Automatically switches to SharedPreferences when `kIsWeb` is true
- Type conversion: Handles Map<String, dynamic> ↔ Model conversions with `toMap()` / `fromMap()`

**SoundService** (`lib/services/sound_service.dart`)
- Manages audio playback using audioplayers package
- Sound files: move.mp3, win.mp3, lose.mp3, draw.mp3, button.mp3, achievement.mp3, undo.mp3
- Platform check: Disabled on web until audio files are added
- Methods: `playMove()`, `playWin()`, `playLose()`, `playDraw()`, `playButton()`, `setSoundEnabled()`

**VibrationService** (`lib/services/vibration_service.dart`)
- Provides haptic feedback using vibration package
- Methods: `vibrateLight()`, `vibrateMedium()`, `vibrateHeavy()`, `setVibrationEnabled()`
- Platform check: Only works on mobile devices

**AchievementService** (`lib/services/achievement_service.dart`)
- Evaluates achievement conditions after each game
- Integrates with DatabaseService to track progress
- Returns list of newly unlocked achievements

### Game Logic

**Win Detection:**
- 3x3: `utils/game_logic.dart` - `checkWinner3(board)`
- 4x4: `logic/board_logic_4.dart` - `checkWinner4(board)`
- 5x5: `logic/board_logic_5.dart` - `checkWinner5(board)`

All return `Map<String, dynamic>?` with keys: `'winner'` (String), `'winningCells'` (List<int>)

**AI Algorithm:**
Located in `GameBloc._makeAIMove()`:
- Easy: Random valid moves
- Medium: Minimax with depth limit
- Hard: Full minimax with alpha-beta pruning
- Adaptive: Adjusts based on game state

**Board Sizes:**
- 3x3: Win condition = 3 in a row
- 4x4: Win condition = 4 in a row
- 5x5: Win condition = 5 in a row

### Data Models

All models use **Equatable** and provide `toMap()` / `fromMap()` for serialization:

- **GameState** (`lib/blocs/game_state.dart`) - Game state with undo/redo stacks
- **AppSettings** (`lib/models/app_settings.dart`) - User preferences
- **GameStats** (`lib/models/game_stats.dart`) - Statistics with calculated properties
- **Achievement** (`lib/models/achievement.dart`) - Achievement definition and progress
- **GameReplay** (`lib/models/game_replay.dart`) - Replay with move history

**Type Handling in Models:**
- `AppSettings.fromMap()` includes a `_toBool()` helper to handle int/bool/String conversions
- Database stores booleans as integers (SQLite limitation)
- SharedPreferences on web stores native types

### UI Structure

**Screens** (`lib/screens/`)
- **home_screen.dart** - Main game screen with drawer navigation
  - Uses BlocBuilder to listen to GameState
  - Drawer header uses BlocBuilder<SettingsCubit> to display player name
  - Contains game board, controls, and action buttons
- **settings_screen.dart** - Settings management
- **statistics_screen.dart** - Charts and stats visualization (fl_chart)
- **achievements_screen.dart** - Achievement list with progress
- **replay_viewer_screen.dart** - Game replay with playback controls
- **tutorial_screen.dart** - Interactive tutorial
- **about_screen.dart** - App information and developer credits

**Widgets** (`lib/widgets/`)
- **board_widget3.dart** - 3x3 board with CellWidget
- **board_widget5.dart** - 4x4 and 5x5 boards (legacy name, handles both)
- **cell_widget*.dart** - Individual cells for each board size
- **animated_mark.dart** - Custom painter for animated X/O drawing
- **custom_button.dart** - Neumorphic button with scale animation
- **confetti_widget.dart** - Win celebration animation
- **game_timer_widget.dart** - Countdown timer for timed mode

### Navigation

Uses named routes defined in `main.dart`:
```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/home': (context) => const HomeScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/statistics': (context) => const StatisticsScreen(),
  '/achievements': (context) => const AchievementsScreen(),
  '/tutorial': (context) => const TutorialScreen(),
  '/about': (context) => const AboutScreen(),
  '/replays': (context) => const ReplayViewerScreen(),
  '/history': (context) => const HistoryScreen(),
}
```

## Important Implementation Details

### Web Platform Compatibility

The app supports web with specific adaptations:
- Database: Uses SharedPreferences instead of sqflite on web
- Sound: Disabled on web (check `kIsWeb` before playing)
- Vibration: Not available on web
- File operations: Use platform checks before file_picker operations

**Platform Check Pattern:**
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Web-specific code
} else {
  // Mobile-specific code
}
```

### Settings Reactivity

Settings changes must reflect across the app:
- SettingsCubit emits new state when settings change
- Use `BlocBuilder<SettingsCubit, AppSettings>` to listen for changes
- Example: Home screen drawer header displays player name from settings

### Game State Persistence

- Game replays auto-save on game completion via `_saveGameReplay()` in GameBloc
- Settings persist on every change via SettingsCubit
- Statistics update after each game via StatisticsCubit
- All persistence goes through DatabaseService singleton

### Undo/Redo Implementation

- Uses snapshot pattern: `Snapshot` class stores board state
- Stacks stored in GameState: `undoStack` and `redoStack`
- Undo creates snapshot, pushes to redoStack, restores previous state
- Redo pops from redoStack and applies
- Stacks cleared on ResetGame or board size change

### Testing

All tests in `test/game_logic_test.dart`:
- 3x3, 4x4, 5x5 win condition tests
- Horizontal, vertical, diagonal win patterns
- Draw detection
- Edge cases

**Test Pattern:**
```dart
test('Description', () {
  final board = ['X', 'X', 'X', '', '', '', '', '', ''];
  final result = checkWinner3(board);
  expect(result['winner'], 'X');
  expect(result['winningCells'], [0, 1, 2]);
});
```

## Common Pitfalls

1. **Unused imports**: GameBloc previously imported AchievementService but doesn't use it - removed to fix warnings
2. **Non-null assertions in tests**: Avoid `result!['key']`, use `result['key']` directly
3. **Platform-specific code**: Always check `kIsWeb` before using mobile-only packages
4. **Settings not reflecting**: Ensure UI uses BlocBuilder to listen to SettingsCubit
5. **Text overflow**: Use `Flexible` with `mainAxisSize: MainAxisSize.min` in constrained rows
6. **Deprecated APIs**: `withOpacity()` is deprecated, but fixing requires framework update

## Commit Guidelines

Follow conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring
- `test:` - Test additions/updates
- `docs:` - Documentation
- `style:` - Code formatting
- `chore:` - Maintenance

Always commit and push after completing each task.

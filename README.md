# XO Game - Professional Tic Tac Toe 🎮

A comprehensive, professional-grade Tic Tac Toe mobile application built with Flutter. This is not just a simple game - it's a feature-complete mobile gaming experience with AI opponents, statistics tracking, achievements, and much more.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-2.17+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

📌 **Version:** 1.0.0
📅 **Last Updated:** January 2025
👤 **Author:** Ahmed Hamdy
🔗 **Repository:** [https://github.com/FlutterSmith](https://github.com/FlutterSmith)

---

## 📖 Overview

XO Game transforms the classic Tic Tac Toe into a modern, engaging mobile application with professional features including multiple game modes, intelligent AI opponents, comprehensive statistics, achievements system, and beautiful UI/UX design.

**Key Highlights:**
- ✅ Three board sizes (3x3, 4x4, 5x5)
- ✅ Four AI difficulty levels with minimax algorithm
- ✅ Comprehensive statistics with visual charts
- ✅ Achievement system with 8 unique achievements
- ✅ Game replay system with full playback controls
- ✅ Dark/Light theme with smooth animations
- ✅ Sound effects and haptic feedback
- ✅ Export/Import statistics

---

## ✨ Features

### Core Game Features
- **Multiple Board Sizes**: Play on 3x3, 4x4, or 5x5 grids
- **Two Game Modes**:
  - Player vs Player (PvP) - Local multiplayer
  - Player vs Computer (PvC) - AI opponent
- **Four AI Difficulty Levels**:
  - Easy - Random moves for casual play
  - Medium - Strategic AI with moderate challenge
  - Hard - Advanced AI using full minimax algorithm
  - Adaptive - Dynamic difficulty that adjusts to game state
- **Undo/Redo Functionality**: Take back moves or restore them
- **Game State Persistence**: Your progress is automatically saved

### UI/UX Enhancements
- **Modern Design**: Beautiful neumorphic buttons and smooth animations
- **Dark/Light Theme**: Switch between themes with one tap
- **Responsive Layout**: Works perfectly on all screen sizes
- **Smooth Animations**: Animated marks and transitions
- **Haptic Feedback**: Feel every move with vibration feedback
- **Sound Effects**: Immersive audio for game events

### Statistics & Progress
- **Comprehensive Statistics**:
  - Total games, wins, losses, draws
  - Win rate percentage
  - PvP vs PvC breakdown
  - Performance by AI difficulty
  - Board size usage analytics
- **Visual Charts**: Pie charts and bar graphs for data visualization
- **Export/Import**: Share or backup your statistics as JSON

### Achievement System
- **8 Unique Achievements**:
  - 🏆 First Victory - Win your first game
  - 🎯 Novice Champion - Win 10 games
  - ⭐ Expert Player - Win 50 games
  - 👑 Master Champion - Win 100 games
  - 🤖 AI Slayer - Beat Hard AI
  - 🔥 Hot Streak - Win 5 games in a row
  - 🎮 Board Explorer - Play all board sizes
  - 💎 Flawless Victory - Win without opponent scoring
- **Progress Tracking**: See your progress toward locked achievements

### Game Replay System
- **Save Game Replays**: Automatically saves every completed game
- **Replay Viewer**: Watch your games move by move
- **Replay Controls**:
  - Play/Pause
  - Step forward/backward
  - Skip to start/end
  - Slider for quick navigation

### Settings & Customization
- **Player Profile**: Set your custom player name
- **Audio Controls**: Toggle sound effects on/off
- **Haptic Controls**: Enable/disable vibration feedback
- **Theme Selection**: Choose between Light and Dark modes
- **Default Settings**: Set preferred board size and AI difficulty
- **Reset Statistics**: Clear all stats with confirmation

### Additional Features
- **Interactive Tutorial**: Step-by-step guide for new players
- **Game History**: View all past game results
- **About Page**: App information and credits
- **Share Results**: Share your statistics with friends
- **Navigation Drawer**: Easy access to all features

---

## 🏗️ Architecture

The app follows clean architecture principles with the BLoC pattern:

### State Management (BLoC Pattern)
- **GameBloc**: Manages game logic, moves, AI, undo/redo
- **ThemeCubit**: Handles theme switching
- **SettingsCubit**: Manages app settings and preferences
- **StatisticsCubit**: Tracks and manages game statistics

### Service Layer
- **DatabaseService**: SQLite operations for persistence
- **SoundService**: Audio playback management
- **VibrationService**: Haptic feedback control
- **AchievementService**: Achievement logic and progression

### Data Models
- **GameStats**: Statistics data model with calculations
- **AppSettings**: User preferences and configuration
- **Achievement**: Achievement definitions and progress
- **GameReplay**: Replay data with move history

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point with routing
├── blocs/                         # State management (BLoC)
│   ├── game_bloc.dart            # Game logic BLoC
│   ├── game_state.dart           # Game state model
│   ├── game_event.dart           # Game events
│   ├── theme_cubit.dart          # Theme management
│   ├── settings_cubit.dart       # Settings management
│   └── statistics_cubit.dart     # Statistics management
├── models/                        # Data models
│   ├── game_stats.dart           # Statistics model
│   ├── app_settings.dart         # Settings model
│   ├── achievement.dart          # Achievement model
│   └── game_replay.dart          # Replay model
├── services/                      # Business logic services
│   ├── database_service.dart     # Database operations (SQLite)
│   ├── sound_service.dart        # Audio management
│   ├── vibration_service.dart    # Haptic feedback
│   └── achievement_service.dart  # Achievement logic
├── screens/                       # UI screens
│   ├── splash_screen.dart        # Splash/intro screen
│   ├── home_screen.dart          # Main game screen with drawer
│   ├── settings_screen.dart      # Settings page
│   ├── statistics_screen.dart    # Statistics with charts
│   ├── achievements_screen.dart  # Achievements list
│   ├── tutorial_screen.dart      # How to play guide
│   ├── about_screen.dart         # About page
│   ├── replay_viewer_screen.dart # Replay viewer
│   ├── history_screen.dart       # Game history
│   └── pick_side_screen.dart     # Side selection (legacy)
├── widgets/                       # Reusable widgets
│   ├── board_widget3.dart        # 3x3 board
│   ├── board_widget5.dart        # 4x4 & 5x5 boards
│   ├── cell_widget*.dart         # Cell widgets for each size
│   ├── animated_mark.dart        # Animated X/O drawing
│   └── custom_button.dart        # Neumorphic button
├── logic/                         # Game logic
│   ├── board_logic_4.dart        # 4x4 win checker
│   └── board_logic_5.dart        # 5x5 win checker
└── utils/                         # Utilities
    └── game_logic.dart           # 3x3 win checker

test/
└── game_logic_test.dart          # Comprehensive unit tests
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code with Flutter extensions
- iOS: Xcode (for iOS development)
- Android: Android SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/FlutterSmith/xo_game.git
   cd xo_game
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate app icons (optional)**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

---

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/game_logic_test.dart
```

Run with coverage:
```bash
flutter test --coverage
```

---

## 📦 Dependencies

### Core
- `flutter_bloc: ^9.0.0` - State management
- `equatable: ^2.0.3` - Value equality
- `sqflite: ^2.0.0+4` - Local database
- `shared_preferences: ^2.2.2` - Key-value storage
- `path: ^1.8.0` - Path utilities

### UI & Visualization
- `fl_chart: ^0.66.0` - Chart visualization
- `intl: ^0.18.1` - Date formatting

### Features
- `audioplayers: ^5.2.1` - Sound effects
- `vibration: ^1.8.4` - Haptic feedback
- `share_plus: ^7.2.1` - Share functionality
- `url_launcher: ^6.2.2` - Open URLs
- `path_provider: ^2.1.1` - File paths
- `file_picker: ^6.1.1` - File selection

---

## 🎨 Customization

### Adding Sound Effects

Place MP3 files in `assets/sounds/`:
- `move.mp3` - Move sound
- `win.mp3` - Win sound
- `lose.mp3` - Loss sound
- `draw.mp3` - Draw sound
- `button.mp3` - Button click
- `achievement.mp3` - Achievement unlock
- `undo.mp3` - Undo action

### Changing Themes

Edit `lib/blocs/theme_cubit.dart`:
```dart
ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blue,
  // ... customize colors
);
```

### Adding Achievements

Edit `DatabaseService._insertDefaultAchievements()`:
```dart
{
  'key': 'my_achievement',
  'title': 'Achievement Title',
  'description': 'Description',
  'icon': '🎯',
  'target': 10,
}
```

---

## 🐛 Known Issues

- Sound effects require actual audio files in `assets/sounds/`
- iOS may require additional permissions for haptic feedback
- Some older Android devices may have limited vibration support

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**Ahmed Hamdy**
- GitHub: [@FlutterSmith](https://github.com/FlutterSmith)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The open-source community for the packages used
- All contributors and testers

---

## 🗺️ Roadmap

Future enhancements planned:
- [ ] Online multiplayer with matchmaking
- [ ] Cloud save synchronization
- [ ] More achievement types and categories
- [ ] Custom board themes and skins
- [ ] Tournament mode
- [ ] Global leaderboards
- [ ] Social features and friend challenges
- [ ] Localization for multiple languages

---

**Enjoy playing XO Game! ⭕❌**

*If you find this project helpful, please consider ⭐ starring the repository!*

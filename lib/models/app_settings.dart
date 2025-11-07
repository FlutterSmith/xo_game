/// Model class for app settings
class AppSettings {
  final int id;
  final String playerName;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String themeMode; // 'light', 'dark', 'system'
  final String aiDifficulty; // 'easy', 'medium', 'hard', 'adaptive'
  final int defaultBoardSize; // 3, 4, or 5
  final bool showTutorial; // Show tutorial on next launch
  final String language; // For future localization

  AppSettings({
    required this.id,
    required this.playerName,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.themeMode,
    required this.aiDifficulty,
    required this.defaultBoardSize,
    required this.showTutorial,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerName': playerName,
      'soundEnabled': soundEnabled ? 1 : 0,
      'vibrationEnabled': vibrationEnabled ? 1 : 0,
      'themeMode': themeMode,
      'aiDifficulty': aiDifficulty,
      'defaultBoardSize': defaultBoardSize,
      'showTutorial': showTutorial ? 1 : 0,
      'language': language,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as int,
      playerName: map['playerName'] as String,
      soundEnabled: (map['soundEnabled'] as int) == 1,
      vibrationEnabled: (map['vibrationEnabled'] as int) == 1,
      themeMode: map['themeMode'] as String,
      aiDifficulty: map['aiDifficulty'] as String,
      defaultBoardSize: map['defaultBoardSize'] as int,
      showTutorial: (map['showTutorial'] as int) == 1,
      language: map['language'] as String,
    );
  }

  factory AppSettings.defaultSettings() {
    return AppSettings(
      id: 1,
      playerName: 'Player',
      soundEnabled: true,
      vibrationEnabled: true,
      themeMode: 'dark',
      aiDifficulty: 'medium',
      defaultBoardSize: 3,
      showTutorial: true,
      language: 'en',
    );
  }

  AppSettings copyWith({
    int? id,
    String? playerName,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? themeMode,
    String? aiDifficulty,
    int? defaultBoardSize,
    bool? showTutorial,
    String? language,
  }) {
    return AppSettings(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      themeMode: themeMode ?? this.themeMode,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      defaultBoardSize: defaultBoardSize ?? this.defaultBoardSize,
      showTutorial: showTutorial ?? this.showTutorial,
      language: language ?? this.language,
    );
  }
}

/// Model class for app settings
class AppSettings {
  final int id;
  final String playerName;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final String themeMode; // 'light', 'dark', 'system'
  final bool showTutorial; // Show tutorial on next launch
  final String language; // For future localization

  AppSettings({
    required this.id,
    required this.playerName,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
    required this.themeMode,
    required this.showTutorial,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerName': playerName,
      'soundEnabled': soundEnabled ? 1 : 0,
      'musicEnabled': musicEnabled ? 1 : 0,
      'vibrationEnabled': vibrationEnabled ? 1 : 0,
      'themeMode': themeMode,
      'showTutorial': showTutorial ? 1 : 0,
      'language': language,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    // Helper function to handle both int and bool types
    bool _toBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    return AppSettings(
      id: map['id'] as int,
      playerName: map['playerName'] as String,
      soundEnabled: _toBool(map['soundEnabled']),
      musicEnabled: map.containsKey('musicEnabled') ? _toBool(map['musicEnabled']) : true,
      vibrationEnabled: _toBool(map['vibrationEnabled']),
      themeMode: map['themeMode'] as String,
      showTutorial: _toBool(map['showTutorial']),
      language: map['language'] as String,
    );
  }

  factory AppSettings.defaultSettings() {
    return AppSettings(
      id: 1,
      playerName: 'Player',
      soundEnabled: true,
      musicEnabled: true,
      vibrationEnabled: true,
      themeMode: 'dark',
      showTutorial: true,
      language: 'en',
    );
  }

  AppSettings copyWith({
    int? id,
    String? playerName,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    String? themeMode,
    bool? showTutorial,
    String? language,
  }) {
    return AppSettings(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      themeMode: themeMode ?? this.themeMode,
      showTutorial: showTutorial ?? this.showTutorial,
      language: language ?? this.language,
    );
  }
}

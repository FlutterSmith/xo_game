import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:convert';
import '../models/game_stats.dart';
import '../models/app_settings.dart';
import '../models/achievement.dart';
import '../models/game_replay.dart';

/// Enhanced database service for managing all app data
/// Uses sqflite for mobile platforms and shared_preferences for web
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static SharedPreferences? _prefs;

  DatabaseService._init();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) {
      debugPrint('[DB] Returning cached prefs instance');
      return _prefs!;
    }
    debugPrint('[DB] Initializing SharedPreferences...');
    _prefs = await SharedPreferences.getInstance();
    debugPrint('[DB] SharedPreferences initialized, running _initWebDefaults');
    await _initWebDefaults();
    debugPrint('[DB] _initWebDefaults complete');
    return _prefs!;
  }

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite not supported on web. Use shared_preferences methods instead.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('xo_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for win streak tracking
      await db.execute(
          'ALTER TABLE game_stats ADD COLUMN currentWinStreak INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE game_stats ADD COLUMN longestWinStreak INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE game_stats ADD COLUMN perfectGames INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> _initWebDefaults() async {
    debugPrint('[DB] _initWebDefaults - Starting initialization');
    final prefs = _prefs!;

    // Debug: List all existing keys
    final allKeys = prefs.getKeys();
    debugPrint('[DB] _initWebDefaults - Existing keys: ${allKeys.toList()}');

    // Initialize stats if not exists
    if (!prefs.containsKey('game_stats')) {
      debugPrint('[DB] Initializing game_stats');
      await prefs.setString('game_stats', jsonEncode(GameStats.empty().toMap()));
    } else {
      debugPrint('[DB] game_stats already exists, skipping initialization');
    }

    // Initialize settings if not exists
    if (!prefs.containsKey('app_settings')) {
      debugPrint('[DB] Initializing app_settings');
      await prefs.setString('app_settings', jsonEncode(AppSettings.defaultSettings().toMap()));
    } else {
      debugPrint('[DB] app_settings already exists, skipping initialization');
      final existing = prefs.getString('app_settings');
      debugPrint('[DB] Existing app_settings: $existing');
    }

    // Initialize achievements if not exists
    if (!prefs.containsKey('achievements')) {
      debugPrint('[DB] Initializing achievements');
      await prefs.setString('achievements', jsonEncode(_getDefaultAchievements()));
    } else {
      debugPrint('[DB] achievements already exists, skipping initialization');
    }

    // Initialize empty lists if not exists
    if (!prefs.containsKey('game_replays')) {
      debugPrint('[DB] Initializing game_replays');
      await prefs.setString('game_replays', jsonEncode([]));
    } else {
      final replaysJson = prefs.getString('game_replays');
      final count = (jsonDecode(replaysJson!) as List).length;
      debugPrint('[DB] game_replays already exists with $count replays, skipping initialization');
    }

    if (!prefs.containsKey('history')) {
      debugPrint('[DB] Initializing history');
      await prefs.setString('history', jsonEncode([]));
    } else {
      debugPrint('[DB] history already exists, skipping initialization');
    }

    debugPrint('[DB] _initWebDefaults - Complete');
  }

  List<Map<String, dynamic>> _getDefaultAchievements() {
    return [
      {
        'id': 1,
        'key': 'first_win',
        'title': 'First Victory',
        'description': 'Win your first game',
        'icon': '🏆',
        'unlocked': 0,
        'progress': 0,
        'target': 1,
      },
      {
        'id': 2,
        'key': 'win_10',
        'title': 'Novice Champion',
        'description': 'Win 10 games',
        'icon': '🎯',
        'unlocked': 0,
        'progress': 0,
        'target': 10,
      },
      {
        'id': 3,
        'key': 'win_50',
        'title': 'Expert Player',
        'description': 'Win 50 games',
        'icon': '⭐',
        'unlocked': 0,
        'progress': 0,
        'target': 50,
      },
      {
        'id': 4,
        'key': 'win_100',
        'title': 'Master Champion',
        'description': 'Win 100 games',
        'icon': '👑',
        'unlocked': 0,
        'progress': 0,
        'target': 100,
      },
      {
        'id': 5,
        'key': 'beat_hard_ai',
        'title': 'AI Slayer',
        'description': 'Beat Hard AI difficulty',
        'icon': '🤖',
        'unlocked': 0,
        'progress': 0,
        'target': 1,
      },
      {
        'id': 6,
        'key': 'win_streak_5',
        'title': 'Hot Streak',
        'description': 'Win 5 games in a row',
        'icon': '🔥',
        'unlocked': 0,
        'progress': 0,
        'target': 5,
      },
      {
        'id': 7,
        'key': 'play_all_boards',
        'title': 'Board Explorer',
        'description': 'Play on all board sizes',
        'icon': '🎮',
        'unlocked': 0,
        'progress': 0,
        'target': 3,
      },
      {
        'id': 8,
        'key': 'perfect_game',
        'title': 'Flawless Victory',
        'description': 'Win without opponent scoring',
        'icon': '💎',
        'unlocked': 0,
        'progress': 0,
        'target': 1,
      },
    ];
  }

  Future _createDB(Database db, int version) async {
    // Game Statistics Table
    await db.execute('''
      CREATE TABLE game_stats (
        id INTEGER PRIMARY KEY,
        totalGames INTEGER NOT NULL DEFAULT 0,
        wins INTEGER NOT NULL DEFAULT 0,
        losses INTEGER NOT NULL DEFAULT 0,
        draws INTEGER NOT NULL DEFAULT 0,
        pvpGames INTEGER NOT NULL DEFAULT 0,
        pvpWins INTEGER NOT NULL DEFAULT 0,
        pvpDraws INTEGER NOT NULL DEFAULT 0,
        pvcGames INTEGER NOT NULL DEFAULT 0,
        pvcWins INTEGER NOT NULL DEFAULT 0,
        pvcLosses INTEGER NOT NULL DEFAULT 0,
        pvcDraws INTEGER NOT NULL DEFAULT 0,
        easyWins INTEGER NOT NULL DEFAULT 0,
        easyLosses INTEGER NOT NULL DEFAULT 0,
        mediumWins INTEGER NOT NULL DEFAULT 0,
        mediumLosses INTEGER NOT NULL DEFAULT 0,
        hardWins INTEGER NOT NULL DEFAULT 0,
        hardLosses INTEGER NOT NULL DEFAULT 0,
        board3x3Games INTEGER NOT NULL DEFAULT 0,
        board4x4Games INTEGER NOT NULL DEFAULT 0,
        board5x5Games INTEGER NOT NULL DEFAULT 0,
        currentWinStreak INTEGER NOT NULL DEFAULT 0,
        longestWinStreak INTEGER NOT NULL DEFAULT 0,
        perfectGames INTEGER NOT NULL DEFAULT 0,
        lastUpdated TEXT NOT NULL
      )
    ''');

    // App Settings Table
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY,
        playerName TEXT NOT NULL,
        soundEnabled INTEGER NOT NULL DEFAULT 1,
        vibrationEnabled INTEGER NOT NULL DEFAULT 1,
        themeMode TEXT NOT NULL DEFAULT 'dark',
        aiDifficulty TEXT NOT NULL DEFAULT 'medium',
        defaultBoardSize INTEGER NOT NULL DEFAULT 3,
        showTutorial INTEGER NOT NULL DEFAULT 1,
        language TEXT NOT NULL DEFAULT 'en'
      )
    ''');

    // Achievements Table
    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        unlocked INTEGER NOT NULL DEFAULT 0,
        unlockedDate TEXT,
        progress INTEGER NOT NULL DEFAULT 0,
        target INTEGER NOT NULL
      )
    ''');

    // Game Replays Table
    await db.execute('''
      CREATE TABLE game_replays (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        gameMode TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        boardSize INTEGER NOT NULL,
        moves TEXT NOT NULL,
        result TEXT NOT NULL,
        winner TEXT NOT NULL,
        movesCount INTEGER NOT NULL
      )
    ''');

    // Game History Table (legacy)
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result TEXT NOT NULL
      )
    ''');

    // Insert default stats and settings
    await db.insert('game_stats', GameStats.empty().toMap());
    await db.insert('app_settings', AppSettings.defaultSettings().toMap());

    // Insert default achievements
    await _insertDefaultAchievements(db);
  }

  Future<void> _insertDefaultAchievements(Database db) async {
    final achievements = [
      {
        'key': 'first_win',
        'title': 'First Victory',
        'description': 'Win your first game',
        'icon': '🏆',
        'unlocked': 0,
        'progress': 0,
        'target': 1,
      },
      {
        'key': 'win_10',
        'title': 'Novice Champion',
        'description': 'Win 10 games',
        'icon': '🎯',
        'unlocked': 0,
        'progress': 0,
        'target': 10,
      },
      {
        'key': 'win_50',
        'title': 'Expert Player',
        'description': 'Win 50 games',
        'icon': '⭐',
        'unlocked': 0,
        'progress': 0,
        'target': 50,
      },
      {
        'key': 'win_100',
        'title': 'Master Champion',
        'description': 'Win 100 games',
        'icon': '👑',
        'unlocked': 0,
        'progress': 0,
        'target': 100,
      },
      {
        'key': 'beat_hard_ai',
        'title': 'AI Slayer',
        'description': 'Beat Hard AI difficulty',
        'icon': '🤖',
        'unlocked': 0,
        'progress': 0,
        'target': 1,
      },
      {
        'key': 'win_streak_5',
        'title': 'Hot Streak',
        'description': 'Win 5 games in a row',
        'icon': '🔥',
        'unlocked': 0,
        'progress': 0,
        'target': 5,
      },
      {
        'key': 'play_all_boards',
        'title': 'Board Explorer',
        'description': 'Play on all board sizes',
        'icon': '🎮',
        'unlocked': 0,
        'progress': 0,
        'target': 3,
      },
      {
        'key': 'perfect_game',
        'title': 'Flawless Victory',
        'description': 'Win without opponent scoring',
        'icon': '💎',
        'unlocked': 0,
        'progress': 0,
        'target': 1,
      },
    ];

    for (var achievement in achievements) {
      await db.insert('achievements', achievement);
    }
  }

  // ===== GAME STATS METHODS =====

  Future<GameStats> getStats() async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final statsJson = prefs.getString('game_stats');
      if (statsJson == null) {
        final emptyStats = GameStats.empty();
        await prefs.setString('game_stats', jsonEncode(emptyStats.toMap()));
        return emptyStats;
      }
      return GameStats.fromMap(jsonDecode(statsJson));
    }

    final db = await database;
    final maps = await db.query('game_stats', where: 'id = ?', whereArgs: [1]);

    if (maps.isEmpty) {
      final emptyStats = GameStats.empty();
      await db.insert('game_stats', emptyStats.toMap());
      return emptyStats;
    }

    return GameStats.fromMap(maps.first);
  }

  Future<void> updateStats(GameStats stats) async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      await prefs.setString('game_stats', jsonEncode(stats.toMap()));
      return;
    }

    final db = await database;
    await db.update(
      'game_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );
  }

  Future<void> resetStats() async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      await prefs.setString('game_stats', jsonEncode(GameStats.empty().toMap()));
      return;
    }

    final db = await database;
    await db.update(
      'game_stats',
      GameStats.empty().toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ===== APP SETTINGS METHODS =====

  Future<AppSettings> getSettings() async {
    if (kIsWeb) {
      try {
        debugPrint('[DB] getSettings - Starting on web platform');
        final prefs = await this.prefs;
        debugPrint('[DB] getSettings - Got prefs instance');
        final settingsJson = prefs.getString('app_settings');
        debugPrint('[DB] getSettings - settingsJson: $settingsJson');
        if (settingsJson == null) {
          final defaultSettings = AppSettings.defaultSettings();
          final encoded = jsonEncode(defaultSettings.toMap());
          debugPrint('[DB] Saving default settings: $encoded');
          await prefs.setString('app_settings', encoded);
          debugPrint('[DB] Default settings saved successfully');
          return defaultSettings;
        }
        final decoded = jsonDecode(settingsJson);
        debugPrint('[DB] Decoded settings: $decoded');
        return AppSettings.fromMap(decoded);
      } catch (e, stack) {
        debugPrint('[DB] Error loading settings: $e');
        debugPrint('[DB] Stack: $stack');
        return AppSettings.defaultSettings();
      }
    }

    final db = await database;
    final maps = await db.query('app_settings', where: 'id = ?', whereArgs: [1]);

    if (maps.isEmpty) {
      final defaultSettings = AppSettings.defaultSettings();
      await db.insert('app_settings', defaultSettings.toMap());
      return defaultSettings;
    }

    return AppSettings.fromMap(maps.first);
  }

  Future<void> updateSettings(AppSettings settings) async {
    if (kIsWeb) {
      try {
        debugPrint('[DB] updateSettings - Starting on web platform');
        final prefs = await this.prefs;
        final encoded = jsonEncode(settings.toMap());
        debugPrint('[DB] updateSettings - saving: $encoded');
        final result = await prefs.setString('app_settings', encoded);
        debugPrint('[DB] updateSettings - result: $result');
      } catch (e, stack) {
        debugPrint('[DB] Error updating settings: $e');
        debugPrint('[DB] Stack: $stack');
      }
      return;
    }

    final db = await database;
    await db.update(
      'app_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  // ===== ACHIEVEMENTS METHODS =====

  Future<List<Achievement>> getAchievements() async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final achievementsJson = prefs.getString('achievements');
      if (achievementsJson == null) {
        final defaultAchievements = _getDefaultAchievements();
        await prefs.setString('achievements', jsonEncode(defaultAchievements));
        return defaultAchievements.map((map) => Achievement.fromMap(map)).toList();
      }
      final List<dynamic> decoded = jsonDecode(achievementsJson);
      return decoded.map((map) => Achievement.fromMap(map as Map<String, dynamic>)).toList();
    }

    final db = await database;
    final maps = await db.query('achievements', orderBy: 'id ASC');
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<Achievement?> getAchievementByKey(String key) async {
    if (kIsWeb) {
      final achievements = await getAchievements();
      try {
        return achievements.firstWhere((a) => a.key == key);
      } catch (e) {
        return null;
      }
    }

    final db = await database;
    final maps = await db.query(
      'achievements',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return null;
    return Achievement.fromMap(maps.first);
  }

  Future<void> updateAchievement(Achievement achievement) async {
    if (kIsWeb) {
      final achievements = await getAchievements();
      final index = achievements.indexWhere((a) => a.id == achievement.id);
      if (index != -1) {
        achievements[index] = achievement;
        final prefs = await this.prefs;
        await prefs.setString('achievements', jsonEncode(achievements.map((a) => a.toMap()).toList()));
      }
      return;
    }

    final db = await database;
    await db.update(
      'achievements',
      achievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  Future<void> unlockAchievement(String key) async {
    if (kIsWeb) {
      final achievements = await getAchievements();
      final index = achievements.indexWhere((a) => a.key == key);
      if (index != -1) {
        achievements[index] = achievements[index].copyWith(
          unlocked: true,
          unlockedDate: DateTime.now().toIso8601String(),
        );
        final prefs = await this.prefs;
        await prefs.setString('achievements', jsonEncode(achievements.map((a) => a.toMap()).toList()));
      }
      return;
    }

    final db = await database;
    await db.update(
      'achievements',
      {
        'unlocked': 1,
        'unlockedDate': DateTime.now().toIso8601String(),
      },
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<void> updateAchievementProgress(String key, int progress) async {
    final achievement = await getAchievementByKey(key);

    if (achievement != null && !achievement.unlocked) {
      if (progress >= achievement.target) {
        await unlockAchievement(key);
      } else {
        if (kIsWeb) {
          final achievements = await getAchievements();
          final index = achievements.indexWhere((a) => a.key == key);
          if (index != -1) {
            achievements[index] = achievements[index].copyWith(progress: progress);
            final prefs = await this.prefs;
            await prefs.setString('achievements', jsonEncode(achievements.map((a) => a.toMap()).toList()));
          }
        } else {
          final db = await database;
          await db.update(
            'achievements',
            {'progress': progress},
            where: 'key = ?',
            whereArgs: [key],
          );
        }
      }
    }
  }

  // ===== GAME REPLAYS METHODS =====

  Future<int> saveReplay(GameReplay replay) async {
    debugPrint('[DB] saveReplay - Starting');
    if (kIsWeb) {
      debugPrint('[DB] saveReplay - Web platform, using SharedPreferences');
      final prefs = await this.prefs;
      final replaysJson = prefs.getString('game_replays') ?? '[]';
      final List<dynamic> replays = jsonDecode(replaysJson);
      debugPrint('[DB] saveReplay - Current replays count: ${replays.length}');

      // Generate ID
      final int newId = replays.isEmpty ? 1 : (replays.map((r) => r['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
      final replayWithId = replay.toMap()..['id'] = newId;

      replays.insert(0, replayWithId); // Insert at beginning for DESC order
      await prefs.setString('game_replays', jsonEncode(replays));
      debugPrint('[DB] saveReplay - Saved with ID: $newId, total replays: ${replays.length}');
      return newId;
    }

    debugPrint('[DB] saveReplay - Mobile platform, using SQLite');
    final db = await database;
    final id = await db.insert('game_replays', replay.toMap());
    debugPrint('[DB] saveReplay - Saved with ID: $id');
    return id;
  }

  Future<List<GameReplay>> getReplays({int limit = 50}) async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final replaysJson = prefs.getString('game_replays') ?? '[]';
      final List<dynamic> decoded = jsonDecode(replaysJson);
      final replays = decoded.map((map) => GameReplay.fromMap(map as Map<String, dynamic>)).toList();
      return replays.take(limit).toList();
    }

    final db = await database;
    final maps = await db.query(
      'game_replays',
      orderBy: 'id DESC',
      limit: limit,
    );
    return maps.map((map) => GameReplay.fromMap(map)).toList();
  }

  Future<GameReplay?> getReplay(int id) async {
    if (kIsWeb) {
      final replays = await getReplays(limit: 1000);
      try {
        return replays.firstWhere((r) => r.id == id);
      } catch (e) {
        return null;
      }
    }

    final db = await database;
    final maps = await db.query(
      'game_replays',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return GameReplay.fromMap(maps.first);
  }

  Future<void> deleteReplay(int id) async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final replaysJson = prefs.getString('game_replays') ?? '[]';
      final List<dynamic> replays = jsonDecode(replaysJson);
      replays.removeWhere((r) => r['id'] == id);
      await prefs.setString('game_replays', jsonEncode(replays));
      return;
    }

    final db = await database;
    await db.delete(
      'game_replays',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllReplays() async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      await prefs.setString('game_replays', jsonEncode([]));
      return;
    }

    final db = await database;
    await db.delete('game_replays');
  }

  // ===== LEGACY HISTORY METHODS =====

  Future<int> insertHistory(String result) async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final historyJson = prefs.getString('history') ?? '[]';
      final List<dynamic> history = jsonDecode(historyJson);

      final int newId = history.isEmpty ? 1 : (history.map((h) => h['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
      history.insert(0, {'id': newId, 'result': result}); // Insert at beginning for DESC order

      await prefs.setString('history', jsonEncode(history));
      return newId;
    }

    final db = await database;
    return await db.insert('history', {'result': result});
  }

  Future<List<String>> getHistory() async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      final historyJson = prefs.getString('history') ?? '[]';
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((h) => h['result'] as String).toList();
    }

    final db = await database;
    final result = await db.query('history', orderBy: 'id DESC');
    return result.map((row) => row['result'] as String).toList();
  }

  Future<void> clearHistory() async {
    if (kIsWeb) {
      final prefs = await this.prefs;
      await prefs.setString('history', jsonEncode([]));
      return;
    }

    final db = await database;
    await db.delete('history');
  }

  // ===== DATABASE MANAGEMENT =====

  Future<void> close() async {
    if (kIsWeb) {
      // Nothing to close for shared_preferences
      return;
    }
    final db = await database;
    db.close();
  }
}

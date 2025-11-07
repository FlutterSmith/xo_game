import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game_stats.dart';
import '../models/app_settings.dart';
import '../models/achievement.dart';
import '../models/game_replay.dart';

/// Enhanced database service for managing all app data
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('xo_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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
    final db = await database;
    await db.update(
      'game_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [stats.id],
    );
  }

  Future<void> resetStats() async {
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
    final db = await database;
    final maps = await db.query('achievements', orderBy: 'id ASC');
    return maps.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<Achievement?> getAchievementByKey(String key) async {
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
    final db = await database;
    await db.update(
      'achievements',
      achievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  Future<void> unlockAchievement(String key) async {
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
    final db = await database;
    final achievement = await getAchievementByKey(key);

    if (achievement != null && !achievement.unlocked) {
      if (progress >= achievement.target) {
        await unlockAchievement(key);
      } else {
        await db.update(
          'achievements',
          {'progress': progress},
          where: 'key = ?',
          whereArgs: [key],
        );
      }
    }
  }

  // ===== GAME REPLAYS METHODS =====

  Future<int> saveReplay(GameReplay replay) async {
    final db = await database;
    return await db.insert('game_replays', replay.toMap());
  }

  Future<List<GameReplay>> getReplays({int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      'game_replays',
      orderBy: 'id DESC',
      limit: limit,
    );
    return maps.map((map) => GameReplay.fromMap(map)).toList();
  }

  Future<GameReplay?> getReplay(int id) async {
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
    final db = await database;
    await db.delete(
      'game_replays',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllReplays() async {
    final db = await database;
    await db.delete('game_replays');
  }

  // ===== LEGACY HISTORY METHODS =====

  Future<int> insertHistory(String result) async {
    final db = await database;
    return await db.insert('history', {'result': result});
  }

  Future<List<String>> getHistory() async {
    final db = await database;
    final result = await db.query('history', orderBy: 'id DESC');
    return result.map((row) => row['result'] as String).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }

  // ===== DATABASE MANAGEMENT =====

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

import '../models/achievement.dart';
import '../models/game_stats.dart';
import 'database_service.dart';

/// Service for managing achievements and tracking progress
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final DatabaseService _db = DatabaseService.instance;

  /// Check and update achievements based on game stats
  Future<List<Achievement>> checkAchievements(GameStats stats) async {
    final achievements = await _db.getAchievements();
    final newlyUnlocked = <Achievement>[];

    for (var achievement in achievements) {
      if (!achievement.unlocked) {
        final shouldUnlock = _checkAchievementCondition(achievement, stats);
        if (shouldUnlock) {
          await _db.unlockAchievement(achievement.key);
          final unlocked = await _db.getAchievementByKey(achievement.key);
          if (unlocked != null) {
            newlyUnlocked.add(unlocked);
          }
        }
      }
    }

    return newlyUnlocked;
  }

  bool _checkAchievementCondition(Achievement achievement, GameStats stats) {
    switch (achievement.key) {
      case 'first_win':
        return stats.wins >= 1;
      case 'win_10':
        return stats.wins >= 10;
      case 'win_50':
        return stats.wins >= 50;
      case 'win_100':
        return stats.wins >= 100;
      case 'beat_hard_ai':
        return stats.hardWins >= 1;
      case 'play_all_boards':
        return stats.board3x3Games > 0 &&
            stats.board4x4Games > 0 &&
            stats.board5x5Games > 0;
      case 'win_streak_5':
        // TODO: Requires win streak tracking in GameStats
        return false;
      case 'perfect_game':
        // TODO: Requires perfect game tracking in GameStats
        return false;
      default:
        return false;
    }
  }

  /// Update achievement progress
  Future<void> updateProgress(String key, int progress) async {
    await _db.updateAchievementProgress(key, progress);
  }

  /// Get all achievements
  Future<List<Achievement>> getAchievements() async {
    return await _db.getAchievements();
  }

  /// Get achievement by key
  Future<Achievement?> getAchievement(String key) async {
    return await _db.getAchievementByKey(key);
  }

  /// Get unlocked achievements count
  Future<int> getUnlockedCount() async {
    final achievements = await _db.getAchievements();
    return achievements.where((a) => a.unlocked).length;
  }

  /// Get total achievements count
  Future<int> getTotalCount() async {
    final achievements = await _db.getAchievements();
    return achievements.length;
  }
}

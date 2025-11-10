import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/game_stats.dart';
import '../services/database_service.dart';

/// Cubit for managing game statistics
class StatisticsCubit extends Cubit<GameStats> {
  final DatabaseService _db = DatabaseService.instance;

  StatisticsCubit() : super(GameStats.empty()) {
    loadStatistics();
  }

  /// Load statistics from database
  Future<void> loadStatistics() async {
    final stats = await _db.getStats();
    emit(stats);
  }

  /// Record a game result
  Future<void> recordGame({
    required String result, // 'win', 'loss', 'draw'
    required String gameMode, // 'PvP', 'PvC'
    String? difficulty, // AI difficulty if PvC
    required int boardSize,
    bool isPerfectGame = false, // Whether opponent didn't score
  }) async {
    final now = DateTime.now().toIso8601String();

    int totalGames = state.totalGames + 1;
    int wins = state.wins;
    int losses = state.losses;
    int draws = state.draws;
    int pvpGames = state.pvpGames;
    int pvpWins = state.pvpWins;
    int pvpDraws = state.pvpDraws;
    int pvcGames = state.pvcGames;
    int pvcWins = state.pvcWins;
    int pvcLosses = state.pvcLosses;
    int pvcDraws = state.pvcDraws;
    int easyWins = state.easyWins;
    int easyLosses = state.easyLosses;
    int mediumWins = state.mediumWins;
    int mediumLosses = state.mediumLosses;
    int hardWins = state.hardWins;
    int hardLosses = state.hardLosses;
    int board3x3Games = state.board3x3Games;
    int board4x4Games = state.board4x4Games;
    int board5x5Games = state.board5x5Games;
    int currentWinStreak = state.currentWinStreak;
    int longestWinStreak = state.longestWinStreak;
    int perfectGames = state.perfectGames;

    // Update overall stats
    if (result == 'win') {
      wins++;
      // Update win streak
      currentWinStreak++;
      if (currentWinStreak > longestWinStreak) {
        longestWinStreak = currentWinStreak;
      }
      // Track perfect game
      if (isPerfectGame) {
        perfectGames++;
      }
    } else if (result == 'loss') {
      losses++;
      // Reset win streak on loss
      currentWinStreak = 0;
    } else {
      draws++;
      // Reset win streak on draw
      currentWinStreak = 0;
    }

    // Update mode-specific stats
    if (gameMode == 'PvP') {
      pvpGames++;
      if (result == 'win') {
        pvpWins++;
      } else if (result == 'draw') {
        pvpDraws++;
      }
    } else {
      pvcGames++;
      if (result == 'win') {
        pvcWins++;
      } else if (result == 'loss') {
        pvcLosses++;
      } else {
        pvcDraws++;
      }

      // Update difficulty-specific stats
      if (difficulty != null) {
        switch (difficulty.toLowerCase()) {
          case 'easy':
            if (result == 'win') {
              easyWins++;
            } else if (result == 'loss') {
              easyLosses++;
            }
            break;
          case 'medium':
            if (result == 'win') {
              mediumWins++;
            } else if (result == 'loss') {
              mediumLosses++;
            }
            break;
          case 'hard':
          case 'adaptive':
            if (result == 'win') {
              hardWins++;
            } else if (result == 'loss') {
              hardLosses++;
            }
            break;
        }
      }
    }

    // Update board size stats
    switch (boardSize) {
      case 3:
        board3x3Games++;
        break;
      case 4:
        board4x4Games++;
        break;
      case 5:
        board5x5Games++;
        break;
    }

    final updatedStats = GameStats(
      id: state.id,
      totalGames: totalGames,
      wins: wins,
      losses: losses,
      draws: draws,
      pvpGames: pvpGames,
      pvpWins: pvpWins,
      pvpDraws: pvpDraws,
      pvcGames: pvcGames,
      pvcWins: pvcWins,
      pvcLosses: pvcLosses,
      pvcDraws: pvcDraws,
      easyWins: easyWins,
      easyLosses: easyLosses,
      mediumWins: mediumWins,
      mediumLosses: mediumLosses,
      hardWins: hardWins,
      hardLosses: hardLosses,
      board3x3Games: board3x3Games,
      board4x4Games: board4x4Games,
      board5x5Games: board5x5Games,
      currentWinStreak: currentWinStreak,
      longestWinStreak: longestWinStreak,
      perfectGames: perfectGames,
      lastUpdated: now,
    );

    await _db.updateStats(updatedStats);
    emit(updatedStats);
  }

  /// Reset all statistics
  Future<void> resetStatistics() async {
    await _db.resetStats();
    await loadStatistics();
  }

  /// Export statistics as JSON
  Map<String, dynamic> exportStats() {
    return state.toMap();
  }

  /// Import statistics from JSON
  Future<void> importStats(Map<String, dynamic> data) async {
    try {
      final stats = GameStats.fromMap(data);
      await _db.updateStats(stats);
      emit(stats);
    } catch (e) {
      // Handle import error
      throw Exception('Failed to import statistics: $e');
    }
  }
}

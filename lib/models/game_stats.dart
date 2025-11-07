/// Model class for game statistics
class GameStats {
  final int id;
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final int pvpGames;
  final int pvpWins;
  final int pvpDraws;
  final int pvcGames;
  final int pvcWins;
  final int pvcLosses;
  final int pvcDraws;
  final int easyWins;
  final int easyLosses;
  final int mediumWins;
  final int mediumLosses;
  final int hardWins;
  final int hardLosses;
  final int board3x3Games;
  final int board4x4Games;
  final int board5x5Games;
  final String lastUpdated;

  GameStats({
    required this.id,
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.pvpGames,
    required this.pvpWins,
    required this.pvpDraws,
    required this.pvcGames,
    required this.pvcWins,
    required this.pvcLosses,
    required this.pvcDraws,
    required this.easyWins,
    required this.easyLosses,
    required this.mediumWins,
    required this.mediumLosses,
    required this.hardWins,
    required this.hardLosses,
    required this.board3x3Games,
    required this.board4x4Games,
    required this.board5x5Games,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalGames': totalGames,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'pvpGames': pvpGames,
      'pvpWins': pvpWins,
      'pvpDraws': pvpDraws,
      'pvcGames': pvcGames,
      'pvcWins': pvcWins,
      'pvcLosses': pvcLosses,
      'pvcDraws': pvcDraws,
      'easyWins': easyWins,
      'easyLosses': easyLosses,
      'mediumWins': mediumWins,
      'mediumLosses': mediumLosses,
      'hardWins': hardWins,
      'hardLosses': hardLosses,
      'board3x3Games': board3x3Games,
      'board4x4Games': board4x4Games,
      'board5x5Games': board5x5Games,
      'lastUpdated': lastUpdated,
    };
  }

  factory GameStats.fromMap(Map<String, dynamic> map) {
    return GameStats(
      id: map['id'] as int,
      totalGames: map['totalGames'] as int,
      wins: map['wins'] as int,
      losses: map['losses'] as int,
      draws: map['draws'] as int,
      pvpGames: map['pvpGames'] as int,
      pvpWins: map['pvpWins'] as int,
      pvpDraws: map['pvpDraws'] as int,
      pvcGames: map['pvcGames'] as int,
      pvcWins: map['pvcWins'] as int,
      pvcLosses: map['pvcLosses'] as int,
      pvcDraws: map['pvcDraws'] as int,
      easyWins: map['easyWins'] as int,
      easyLosses: map['easyLosses'] as int,
      mediumWins: map['mediumWins'] as int,
      mediumLosses: map['mediumLosses'] as int,
      hardWins: map['hardWins'] as int,
      hardLosses: map['hardLosses'] as int,
      board3x3Games: map['board3x3Games'] as int,
      board4x4Games: map['board4x4Games'] as int,
      board5x5Games: map['board5x5Games'] as int,
      lastUpdated: map['lastUpdated'] as String,
    );
  }

  factory GameStats.empty() {
    return GameStats(
      id: 1,
      totalGames: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      pvpGames: 0,
      pvpWins: 0,
      pvpDraws: 0,
      pvcGames: 0,
      pvcWins: 0,
      pvcLosses: 0,
      pvcDraws: 0,
      easyWins: 0,
      easyLosses: 0,
      mediumWins: 0,
      mediumLosses: 0,
      hardWins: 0,
      hardLosses: 0,
      board3x3Games: 0,
      board4x4Games: 0,
      board5x5Games: 0,
      lastUpdated: DateTime.now().toIso8601String(),
    );
  }

  double get winRate {
    if (totalGames == 0) return 0.0;
    return (wins / totalGames) * 100;
  }

  double get pvcWinRate {
    if (pvcGames == 0) return 0.0;
    return (pvcWins / pvcGames) * 100;
  }

  double get pvpWinRate {
    if (pvpGames == 0) return 0.0;
    return (pvpWins / pvpGames) * 100;
  }
}

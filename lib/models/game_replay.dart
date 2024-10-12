/// Model class for game replays
class GameReplay {
  final int id;
  final String date;
  final String gameMode; // 'PvP' or 'PvC'
  final String difficulty; // AI difficulty if PvC
  final int boardSize;
  final String moves; // JSON encoded list of moves
  final String result; // 'X Wins', 'O Wins', 'Draw'
  final String winner; // 'X', 'O', or 'Draw'
  final int movesCount;

  GameReplay({
    required this.id,
    required this.date,
    required this.gameMode,
    required this.difficulty,
    required this.boardSize,
    required this.moves,
    required this.result,
    required this.winner,
    required this.movesCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'gameMode': gameMode,
      'difficulty': difficulty,
      'boardSize': boardSize,
      'moves': moves,
      'result': result,
      'winner': winner,
      'movesCount': movesCount,
    };
  }

  factory GameReplay.fromMap(Map<String, dynamic> map) {
    return GameReplay(
      id: map['id'] as int,
      date: map['date'] as String,
      gameMode: map['gameMode'] as String,
      difficulty: map['difficulty'] as String,
      boardSize: map['boardSize'] as int,
      moves: map['moves'] as String,
      result: map['result'] as String,
      winner: map['winner'] as String,
      movesCount: map['movesCount'] as int,
    );
  }
}

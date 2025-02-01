import 'package:equatable/equatable.dart';
import 'game_event.dart';

class Snapshot extends Equatable {
  final List<String> board;
  final String currentPlayer;
  final bool gameOver;
  final String resultMessage;
  final List<int> winningCells;
  const Snapshot({
    required this.board,
    required this.currentPlayer,
    required this.gameOver,
    required this.resultMessage,
    required this.winningCells,
  });
  @override
  List<Object> get props => [board, currentPlayer, gameOver, resultMessage, winningCells];
}

class GameState extends Equatable {
  final List<String> board;
  final String currentPlayer;
  final bool gameOver;
  final String resultMessage;
  final List<int> winningCells;
  final List<Snapshot> undoStack;
  final List<Snapshot> redoStack;
  final GameMode gameMode;
  final AIDifficulty aiDifficulty;
  final List<String> gameHistory;
  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.gameOver,
    required this.resultMessage,
    required this.winningCells,
    required this.undoStack,
    required this.redoStack,
    required this.gameMode,
    required this.aiDifficulty,
    required this.gameHistory,
  });
  factory GameState.initial() {
    return GameState(
      board: List.filled(9, ''),
      currentPlayer: 'X',
      gameOver: false,
      resultMessage: '',
      winningCells: [],
      undoStack: [],
      redoStack: [],
      gameMode: GameMode.PvP,
      aiDifficulty: AIDifficulty.hard,
      gameHistory: [],
    );
  }
  GameState copyWith({
    List<String>? board,
    String? currentPlayer,
    bool? gameOver,
    String? resultMessage,
    List<int>? winningCells,
    List<Snapshot>? undoStack,
    List<Snapshot>? redoStack,
    GameMode? gameMode,
    AIDifficulty? aiDifficulty,
    List<String>? gameHistory,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      gameOver: gameOver ?? this.gameOver,
      resultMessage: resultMessage ?? this.resultMessage,
      winningCells: winningCells ?? this.winningCells,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      gameMode: gameMode ?? this.gameMode,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      gameHistory: gameHistory ?? this.gameHistory,
    );
  }
  @override
  List<Object> get props => [board, currentPlayer, gameOver, resultMessage, winningCells, undoStack, redoStack, gameMode, aiDifficulty, gameHistory];
}

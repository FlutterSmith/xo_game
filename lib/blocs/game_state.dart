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
  final int boardSize;
  final int winCondition;
  final String aiMessage;
  final bool timedMode;
  final int totalGameTime; // TOTAL time for entire game in seconds (e.g., 10s, 20s, 30s, 60s)
  final int elapsedTime; // Time elapsed since game start in milliseconds
  final bool isGamePaused; // Whether game is paused
  final bool isTimerActive;

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
    required this.boardSize,
    required this.winCondition,
    required this.aiMessage,
    required this.timedMode,
    required this.totalGameTime,
    required this.elapsedTime,
    required this.isGamePaused,
    required this.isTimerActive,
  });

  factory GameState.initial() {
    int size = 3; // Default board: 3x3, win condition 3
    return GameState(
      board: List.filled(size * size, ''),
      currentPlayer: 'X',
      gameOver: false,
      resultMessage: '',
      winningCells: [],
      undoStack: [],
      redoStack: [],
      gameMode: GameMode.PvC, // Default to Player vs Computer
      aiDifficulty: AIDifficulty.medium,
      gameHistory: [],
      boardSize: size,
      winCondition: size,
      aiMessage: '',
      timedMode: false,
      totalGameTime: 30, // Default 30 seconds for ENTIRE game
      elapsedTime: 0, // No time elapsed initially
      isGamePaused: false,
      isTimerActive: false,
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
    int? boardSize,
    int? winCondition,
    String? aiMessage,
    bool? timedMode,
    int? totalGameTime,
    int? elapsedTime,
    bool? isGamePaused,
    bool? isTimerActive,
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
      boardSize: boardSize ?? this.boardSize,
      winCondition: winCondition ?? this.winCondition,
      aiMessage: aiMessage ?? this.aiMessage,
      timedMode: timedMode ?? this.timedMode,
      totalGameTime: totalGameTime ?? this.totalGameTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isGamePaused: isGamePaused ?? this.isGamePaused,
      isTimerActive: isTimerActive ?? this.isTimerActive,
    );
  }

  @override
  List<Object> get props => [
        board,
        currentPlayer,
        gameOver,
        resultMessage,
        winningCells,
        undoStack,
        redoStack,
        gameMode,
        aiDifficulty,
        gameHistory,
        boardSize,
        winCondition,
        aiMessage,
        timedMode,
        totalGameTime,
        elapsedTime,
        isGamePaused,
        isTimerActive,
      ];
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:advanced_xo_game/logic/board_logic_5.dart';
import 'package:advanced_xo_game/logic/board_logic_4.dart';
import 'package:bloc/bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../utils/game_logic.dart'; // Contains checkWinner3 for 3x3
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/database_service.dart';
import '../services/achievement_service.dart';
import '../models/game_replay.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final SoundService _soundService = SoundService();
  final VibrationService _vibrationService = VibrationService();
  final DatabaseService _db = DatabaseService.instance;
  final AchievementService _achievementService = AchievementService();

  final List<int> _moveHistory = []; // Track moves for replay

  GameBloc() : super(GameState.initial()) {
    on<MoveMade>(_onMoveMade);
    on<AITurn>(_onAITurn);
    on<UndoMove>(_onUndoMove);
    on<RedoMove>(_onRedoMove);
    on<ResetGame>(_onResetGame);
    on<ToggleGameMode>(_onToggleGameMode);
    on<ChangeDifficulty>(_onChangeDifficulty);
    on<UpdateBoardSettings>(_onUpdateBoardSettings);
    on<LoadHistory>(_onLoadHistory);
    on<ClearHistory>(_onClearHistory);
    on<SetPlayerSide>(_onSetPlayerSide);
    _vibrationService.initialize();
  }

  FutureOr<void> _onMoveMade(MoveMade event, Emitter<GameState> emit) async {
    if (state.gameOver || state.board[event.index] != '') return;

    // Play sound and vibration feedback
    _soundService.playMove();
    _vibrationService.medium();

    // Track move for replay
    _moveHistory.add(event.index);

    final snapshot = Snapshot(
      board: List.from(state.board),
      currentPlayer: state.currentPlayer,
      gameOver: state.gameOver,
      resultMessage: state.resultMessage,
      winningCells: List.from(state.winningCells),
    );
    final newUndoStack = List<Snapshot>.from(state.undoStack)..add(snapshot);
    final newBoard = List<String>.from(state.board);
    newBoard[event.index] = state.currentPlayer;

    Map<String, dynamic>? result;
    if (state.boardSize == 3) {
      result = checkWinner3(newBoard);
    } else if (state.boardSize == 4) {
      result = checkWinner4x4(newBoard);
    } else if (state.boardSize == 5) {
      result = checkWinner5x5(newBoard);
    } else {
      result = null;
    }

    if (result != null) {
      final newHistory = List<String>.from(state.gameHistory);
      String outcome =
          result['winner'] == 'Draw' ? "Draw" : "Winner: ${result['winner']}";
      newHistory.add(outcome);

      // Play game end sounds and vibration
      if (result['winner'] == 'Draw') {
        _soundService.playDraw();
        _vibrationService.medium();
      } else {
        _soundService.playWin();
        _vibrationService.win();
      }

      // Save game replay
      await _saveGameReplay(newBoard, result['winner'] as String, outcome);

      // Add to legacy history
      await _db.insertHistory(outcome);

      emit(state.copyWith(
        board: newBoard,
        gameOver: true,
        resultMessage: outcome,
        winningCells: List<int>.from(result['winningCells'] as List),
        currentPlayer: state.currentPlayer,
        undoStack: newUndoStack,
        redoStack: [],
        gameHistory: newHistory,
        aiMessage: "",
      ));
      return;
    } else {
      String nextPlayer = state.currentPlayer == 'X' ? 'O' : 'X';
      emit(state.copyWith(
        board: newBoard,
        currentPlayer: nextPlayer,
        undoStack: newUndoStack,
        redoStack: [],
        aiMessage: "",
      ));
      if (state.gameMode == GameMode.PvC && nextPlayer == 'O') {
        await Future.delayed(const Duration(milliseconds: 300));
        add(const AITurn());
      }
      return;
    }
  }

  FutureOr<void> _onAITurn(AITurn event, Emitter<GameState> emit) {
    if (state.gameOver) {
      emit(state.copyWith(aiMessage: "Game Over - No AI move"));
      return null;
    }
    final move = _getAIMove(state.board, state.aiDifficulty, 'O', 'X');
    if (move == -1) {
      emit(state.copyWith(aiMessage: "No valid move for AI"));
      return null;
    }
    emit(state.copyWith(aiMessage: "AI chooses cell $move"));
    add(MoveMade(move));
    return null;
  }

  FutureOr<void> _onUndoMove(UndoMove event, Emitter<GameState> emit) {
    if (state.undoStack.isEmpty) return null;

    // Play undo sound and vibration
    _soundService.playUndo();
    _vibrationService.light();

    // Remove last move from history
    if (_moveHistory.isNotEmpty) {
      _moveHistory.removeLast();
    }

    final lastSnapshot = state.undoStack.last;
    final newUndoStack = List<Snapshot>.from(state.undoStack)..removeLast();
    final newRedoStack = List<Snapshot>.from(state.redoStack);
    final currentSnapshot = Snapshot(
      board: List.from(state.board),
      currentPlayer: state.currentPlayer,
      gameOver: state.gameOver,
      resultMessage: state.resultMessage,
      winningCells: List.from(state.winningCells),
    );
    newRedoStack.add(currentSnapshot);
    emit(state.copyWith(
      board: lastSnapshot.board,
      currentPlayer: lastSnapshot.currentPlayer,
      gameOver: lastSnapshot.gameOver,
      resultMessage: lastSnapshot.resultMessage,
      winningCells: lastSnapshot.winningCells,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
      aiMessage: "",
    ));
    return null;
  }

  FutureOr<void> _onRedoMove(RedoMove event, Emitter<GameState> emit) {
    if (state.redoStack.isEmpty) return null;

    // Play button sound and vibration
    _soundService.playButton();
    _vibrationService.light();

    final lastSnapshot = state.redoStack.last;
    final newRedoStack = List<Snapshot>.from(state.redoStack)..removeLast();
    final newUndoStack = List<Snapshot>.from(state.undoStack);
    final currentSnapshot = Snapshot(
      board: List.from(state.board),
      currentPlayer: state.currentPlayer,
      gameOver: state.gameOver,
      resultMessage: state.resultMessage,
      winningCells: List.from(state.winningCells),
    );
    newUndoStack.add(currentSnapshot);
    emit(state.copyWith(
      board: lastSnapshot.board,
      currentPlayer: lastSnapshot.currentPlayer,
      gameOver: lastSnapshot.gameOver,
      resultMessage: lastSnapshot.resultMessage,
      winningCells: lastSnapshot.winningCells,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
      aiMessage: "",
    ));
    return null;
  }

  FutureOr<void> _onResetGame(ResetGame event, Emitter<GameState> emit) {
    // Play button sound and vibration
    _soundService.playButton();
    _vibrationService.light();

    // Clear move history for replay
    _moveHistory.clear();

    int size = state.boardSize;
    List<String> newBoard = List.filled(size * size, '');
    emit(state.copyWith(
      board: newBoard,
      currentPlayer: 'X',
      gameOver: false,
      resultMessage: '',
      winningCells: [],
      undoStack: [],
      redoStack: [],
      aiMessage: "",
    ));
    return null;
  }

  FutureOr<void> _onToggleGameMode(
      ToggleGameMode event, Emitter<GameState> emit) {
    GameMode newMode =
        state.gameMode == GameMode.PvP ? GameMode.PvC : GameMode.PvP;
    int size = state.boardSize;
    List<String> newBoard = List.filled(size * size, '');
    emit(state.copyWith(
      board: newBoard,
      currentPlayer: 'X', // Reset starting player.
      gameOver: false,
      resultMessage: '',
      winningCells: [],
      undoStack: [],
      redoStack: [],
      gameMode: newMode,
      aiMessage: "",
    ));
    return null;
  }

  FutureOr<void> _onChangeDifficulty(
      ChangeDifficulty event, Emitter<GameState> emit) {
    emit(GameState.initial().copyWith(
      gameMode: state.gameMode,
      aiDifficulty: event.difficulty,
    ));
    return null;
  }

  FutureOr<void> _onUpdateBoardSettings(
      UpdateBoardSettings event, Emitter<GameState> emit) {
    int size = event.boardSize;
    // Reinitialize board with correct number of cells.
    List<String> newBoard = List.filled(size * size, '');
    emit(state.copyWith(
      board: newBoard,
      gameHistory: state.gameHistory,
      boardSize: size,
      winCondition: event.winCondition,
      currentPlayer: 'X',
      gameOver: false,
      resultMessage: '',
      winningCells: [],
      undoStack: [],
      redoStack: [],
      aiMessage: "",
    ));
    return null;
  }

  FutureOr<void> _onLoadHistory(
      LoadHistory event, Emitter<GameState> emit) async {
    emit(state.copyWith(aiMessage: "History Loaded"));
    return;
  }

  FutureOr<void> _onClearHistory(ClearHistory event, Emitter<GameState> emit) {
    emit(state.copyWith(gameHistory: []));
    return null;
  }

  int _getAIMove(List<String> board, AIDifficulty difficulty, String aiPlayer,
      String humanPlayer) {
    if (state.boardSize == 5) {
      // For a 5x5 board, limit the search depth to 3 on hard difficulty.
      if (difficulty == AIDifficulty.hard) {
        return _minimaxMove(board, aiPlayer, humanPlayer, 3);
      } else if (difficulty == AIDifficulty.medium) {
        return _minimaxMove(board, aiPlayer, humanPlayer, 2);
      } else if (difficulty == AIDifficulty.adaptive) {
        int available = board.where((e) => e == '').length;
        int depthLimit = available < 5 ? available : 3;
        return _minimaxMove(board, aiPlayer, humanPlayer, depthLimit);
      } else {
        return _randomMove(board);
      }
    } else if (state.boardSize == 4) {
      // For a 4x4 board, limit the search depth to 4 on hard difficulty.
      if (difficulty == AIDifficulty.hard) {
        return _minimaxMove(board, aiPlayer, humanPlayer, 4);
      } else if (difficulty == AIDifficulty.medium) {
        return _minimaxMove(board, aiPlayer, humanPlayer, 2);
      } else if (difficulty == AIDifficulty.adaptive) {
        int available = board.where((e) => e == '').length;
        int depthLimit = available < 5 ? available : 4;
        return _minimaxMove(board, aiPlayer, humanPlayer, depthLimit);
      } else {
        return _randomMove(board);
      }
    } else {
      // For a 3x3 board, use full depth on hard.
      switch (difficulty) {
        case AIDifficulty.easy:
          return _randomMove(board);
        case AIDifficulty.medium:
          return _minimaxMove(board, aiPlayer, humanPlayer, 2);
        case AIDifficulty.hard:
          return _minimaxMove(board, aiPlayer, humanPlayer, board.length);
        case AIDifficulty.adaptive:
          int available = board.where((e) => e == '').length;
          int depthLimit = available < 5 ? available : 3;
          return _minimaxMove(board, aiPlayer, humanPlayer, depthLimit);
        default:
          return _randomMove(board);
      }
    }
  }

  int _randomMove(List<String> board) {
    List<int> available = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') available.add(i);
    }
    if (available.isEmpty) return -1;
    return available[Random().nextInt(available.length)];
  }

  int _minimaxMove(
      List<String> board, String aiPlayer, String humanPlayer, int depthLimit) {
    int bestScore = -1000;
    int bestMove = -1;
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = aiPlayer;
        int score =
            _minimax(board, 0, false, aiPlayer, humanPlayer, depthLimit);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  FutureOr<void> _onSetPlayerSide(
      SetPlayerSide event, Emitter<GameState> emit) {
    // Update the current player based on the chosen side.
    emit(state.copyWith(currentPlayer: event.side));
    return null;
  }

  int _minimax(List<String> board, int depth, bool isMaximizing,
      String aiPlayer, String humanPlayer, int depthLimit) {
    Map<String, dynamic>? result;
    if (state.boardSize == 3) {
      result = checkWinner3(board);
    } else if (state.boardSize == 4) {
      result = checkWinner4x4(board);
    } else if (state.boardSize == 5) {
      result = checkWinner5x5(board);
    }

    if (result != null || depth >= depthLimit) {
      if (result != null) {
        if (result['winner'] == aiPlayer) return 10 - depth;
        if (result['winner'] == humanPlayer) return depth - 10;
        return 0;
      }
      return 0;
    }
    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = aiPlayer;
          int score = _minimax(
              board, depth + 1, false, aiPlayer, humanPlayer, depthLimit);
          board[i] = '';
          bestScore = bestScore < score ? score : bestScore;
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = humanPlayer;
          int score = _minimax(
              board, depth + 1, true, aiPlayer, humanPlayer, depthLimit);
          board[i] = '';
          bestScore = bestScore > score ? score : bestScore;
        }
      }
      return bestScore;
    }
  }

  /// Save game replay to database
  Future<void> _saveGameReplay(
      List<String> board, String winner, String result) async {
    try {
      final replay = GameReplay(
        id: 0, // Auto-incremented by database
        date: DateTime.now().toIso8601String(),
        gameMode: state.gameMode == GameMode.PvP ? 'PvP' : 'PvC',
        difficulty: state.aiDifficulty.toString().split('.').last,
        boardSize: state.boardSize,
        moves: jsonEncode(_moveHistory),
        result: result,
        winner: winner,
        movesCount: _moveHistory.length,
      );

      await _db.saveReplay(replay);
    } catch (e) {
      // Silently handle replay save errors
      // In production, you would log this
    }
  }
}

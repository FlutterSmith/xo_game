import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:advanced_xo_game/logic/board_logic_5.dart';
import 'package:advanced_xo_game/logic/board_logic_4.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'game_event.dart';
import 'game_state.dart';
import '../utils/game_logic.dart'; // Contains checkWinner3 for 3x3
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/database_service.dart';
import '../models/game_replay.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final SoundService _soundService = SoundService();
  final VibrationService _vibrationService = VibrationService();
  final DatabaseService _db = DatabaseService.instance;

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
    on<ToggleTimedMode>(_onToggleTimedMode);
    on<SetTimeLimit>(_onSetTimeLimit);
    on<TimerTick>(_onTimerTick);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<TimeoutMove>(_onTimeoutMove);
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
        // Check if player won or AI/opponent won
        final winner = result['winner'] as String;
        bool isPlayerWin;

        if (state.gameMode == GameMode.PvP) {
          // In PvP mode, both are players, so any win is a "player win"
          isPlayerWin = true;
        } else {
          // In PvC mode, check if winner matches the player's chosen side
          isPlayerWin = winner == state.playerSide;
        }

        if (isPlayerWin) {
          _soundService.playWin();
          _vibrationService.win();
        } else {
          _soundService.playLose();
          _vibrationService.medium();
        }
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
        isTimerActive: false, // Stop timer when game ends
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
        // Per-move timer: restart the countdown for whoever moves next.
        elapsedTime: 0,
        isTimerActive: state.timedMode,
      ));
      // Trigger the AI only when the next turn actually belongs to the AI.
      // (Fixes the double-move bug when the player chose 'O': the AI is 'X',
      // so a hardcoded `nextPlayer == 'O'` check used to auto-play the human.)
      final aiPlayer = state.playerSide == 'X' ? 'O' : 'X';
      if (state.gameMode == GameMode.PvC && nextPlayer == aiPlayer) {
        await Future.delayed(const Duration(milliseconds: 350));
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
    // Determine AI and human players based on player's chosen side
    final aiPlayer = state.playerSide == 'X' ? 'O' : 'X';
    final humanPlayer = state.playerSide;
    final move = _getAIMove(state.board, state.aiDifficulty, aiPlayer, humanPlayer);
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
      elapsedTime: 0,
      isTimerActive: state.timedMode, // Activate timer if in timed mode
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
    emit(state.copyWith(
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
      elapsedTime: 0,
      isTimerActive: false, // Timer will be activated after all settings are applied
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
    final int available = board.where((e) => e == '').length;

    if (state.boardSize == 5) {
      switch (difficulty) {
        case AIDifficulty.easy:
          return _randomMove(board);
        case AIDifficulty.medium:
          return _minimaxMove(board, aiPlayer, humanPlayer, 2);
        case AIDifficulty.hard:
          return _minimaxMove(board, aiPlayer, humanPlayer, 3);
        case AIDifficulty.impossible:
          // Deeper than hard; alpha-beta + move ordering keep it responsive.
          return _minimaxMove(board, aiPlayer, humanPlayer, available <= 13 ? 5 : 4);
      }
    } else if (state.boardSize == 4) {
      switch (difficulty) {
        case AIDifficulty.easy:
          return _randomMove(board);
        case AIDifficulty.medium:
          return _minimaxMove(board, aiPlayer, humanPlayer, 2);
        case AIDifficulty.hard:
          return _minimaxMove(board, aiPlayer, humanPlayer, 4);
        case AIDifficulty.impossible:
          return _minimaxMove(board, aiPlayer, humanPlayer, available <= 8 ? available : 6);
      }
    } else {
      // 3x3: hard and impossible both solve the game (unbeatable).
      switch (difficulty) {
        case AIDifficulty.easy:
          return _randomMove(board);
        case AIDifficulty.medium:
          return _minimaxMove(board, aiPlayer, humanPlayer, 2);
        case AIDifficulty.hard:
        case AIDifficulty.impossible:
          return _minimaxMove(board, aiPlayer, humanPlayer, board.length);
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
    int bestScore = -1000000;
    int bestMove = -1;
    for (final i in _orderedMoves(board)) {
      board[i] = aiPlayer;
      int score = _minimax(board, 0, false, aiPlayer, humanPlayer, depthLimit,
          -1000000, 1000000);
      board[i] = '';
      if (score > bestScore || bestMove == -1) {
        bestScore = score;
        bestMove = i;
      }
    }
    return bestMove;
  }

  /// Empty cells ordered center-first — improves alpha-beta pruning a lot.
  List<int> _orderedMoves(List<String> board) {
    final n = state.boardSize;
    final center = (n - 1) / 2.0;
    final moves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') moves.add(i);
    }
    moves.sort((a, b) =>
        _distToCenter(a, n, center).compareTo(_distToCenter(b, n, center)));
    return moves;
  }

  double _distToCenter(int index, int n, double center) {
    final dr = (index ~/ n) - center;
    final dc = (index % n) - center;
    return dr * dr + dc * dc;
  }

  FutureOr<void> _onSetPlayerSide(
      SetPlayerSide event, Emitter<GameState> emit) async {
    // Update playerSide to track which side the player chose.
    // Note: currentPlayer should always start as 'X' since X goes first in Tic Tac Toe,
    // regardless of which side the player selected.
    emit(state.copyWith(
      playerSide: event.side,
    ));

    // If player chose 'O', and game mode is PvC, AI (playing as 'X') should make first move
    if (event.side == 'O' && state.gameMode == GameMode.PvC && !state.gameOver) {
      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      add(const AITurn());
    }
  }

  int _minimax(List<String> board, int depth, bool isMaximizing,
      String aiPlayer, String humanPlayer, int depthLimit, int alpha, int beta) {
    Map<String, dynamic>? result;
    if (state.boardSize == 3) {
      result = checkWinner3(board);
    } else if (state.boardSize == 4) {
      result = checkWinner4x4(board);
    } else if (state.boardSize == 5) {
      result = checkWinner5x5(board);
    }

    if (result != null) {
      // Prefer faster wins / slower losses. Magnitude (100) stays well above
      // any reachable depth so a deep win never reads as a loss.
      if (result['winner'] == aiPlayer) return 100 - depth;
      if (result['winner'] == humanPlayer) return depth - 100;
      return 0; // draw
    }
    if (depth >= depthLimit) return 0;

    if (isMaximizing) {
      int best = -1000000;
      for (final i in _orderedMoves(board)) {
        board[i] = aiPlayer;
        final score = _minimax(board, depth + 1, false, aiPlayer, humanPlayer,
            depthLimit, alpha, beta);
        board[i] = '';
        if (score > best) best = score;
        if (best > alpha) alpha = best;
        if (beta <= alpha) break; // prune
      }
      return best;
    } else {
      int best = 1000000;
      for (final i in _orderedMoves(board)) {
        board[i] = humanPlayer;
        final score = _minimax(board, depth + 1, true, aiPlayer, humanPlayer,
            depthLimit, alpha, beta);
        board[i] = '';
        if (score < best) best = score;
        if (best < beta) beta = best;
        if (beta <= alpha) break; // prune
      }
      return best;
    }
  }

  /// Save game replay to database
  Future<void> _saveGameReplay(
      List<String> board, String winner, String result) async {
    try {
      debugPrint('[GameBloc] _saveGameReplay - Starting');
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

      debugPrint('[GameBloc] _saveGameReplay - Calling database saveReplay');
      await _db.saveReplay(replay);
      debugPrint('[GameBloc] _saveGameReplay - Successfully saved replay');
    } catch (e, stack) {
      debugPrint('[GameBloc] ERROR in _saveGameReplay: $e');
      debugPrint('[GameBloc] Stack: $stack');
    }
  }

  // Timer event handlers (per-move countdown; the BLoC resets elapsed time on
  // every move so each turn gets a fresh clock).
  FutureOr<void> _onToggleTimedMode(ToggleTimedMode event, Emitter<GameState> emit) {
    final newTimedMode = !state.timedMode;
    emit(state.copyWith(
      timedMode: newTimedMode,
      elapsedTime: 0,
      isTimerActive: newTimedMode, // Activate timer if enabling timed mode
    ));
  }

  FutureOr<void> _onSetTimeLimit(SetTimeLimit event, Emitter<GameState> emit) {
    emit(state.copyWith(
      totalGameTime: event.seconds,
      elapsedTime: 0,
    ));
  }

  FutureOr<void> _onTimerTick(TimerTick event, Emitter<GameState> emit) {
    if (!state.timedMode || !state.isTimerActive || state.gameOver) return null;

    // Increment elapsed time by 100ms (timer ticks every 100ms)
    final newElapsedTime = state.elapsedTime + 100;

    // Check if total game time exceeded (convert seconds to milliseconds)
    if (newElapsedTime >= state.totalGameTime * 1000) {
      // Time's up! Handle timeout
      add(const TimeoutMove());
      return null;
    }

    emit(state.copyWith(elapsedTime: newElapsedTime));
    return null;
  }

  FutureOr<void> _onPauseTimer(PauseTimer event, Emitter<GameState> emit) {
    if (!state.timedMode || state.gameOver) return null;
    emit(state.copyWith(isTimerActive: false));
    return null;
  }

  FutureOr<void> _onResumeTimer(ResumeTimer event, Emitter<GameState> emit) {
    if (!state.timedMode || state.gameOver) return null;
    emit(state.copyWith(isTimerActive: true));
    return null;
  }

  FutureOr<void> _onTimeoutMove(TimeoutMove event, Emitter<GameState> emit) async {
    if (!state.timedMode || state.gameOver) return null;

    // Stop the timer
    emit(state.copyWith(isTimerActive: false));

    // Whose turn ran out? In PvP it's always a human; in PvC the human is the
    // side whose mark equals currentPlayer. (Fixes the old assumption that the
    // human is always 'X'.)
    final isHumanTurn = state.gameMode == GameMode.PvP ||
        state.currentPlayer == state.playerSide;

    if (isHumanTurn) {
      // Current player loses on timeout.
      final winner = state.currentPlayer == 'X' ? 'O' : 'X';
      final outcome = "Winner: $winner (Timeout)";

      _soundService.playLose();
      _vibrationService.medium();

      emit(state.copyWith(
        gameOver: true,
        resultMessage: outcome,
        winningCells: const [],
        isTimerActive: false,
      ));

      await _db.insertHistory(outcome);
      return null;
    }

    // AI's turn timed out (rare) — just let the AI move now.
    add(const AITurn());
    return null;
  }
}

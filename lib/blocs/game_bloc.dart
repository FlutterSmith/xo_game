import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../utils/game_logic.dart';
import '../database_helper.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameState.initial()) {
    on<MoveMade>(_onMoveMade);
    on<AITurn>(_onAITurn);
    on<UndoMove>(_onUndoMove);
    on<RedoMove>(_onRedoMove);
    on<ResetGame>(_onResetGame);
    on<ToggleGameMode>(_onToggleGameMode);
    on<ChangeDifficulty>(_onChangeDifficulty);
    on<LoadHistory>(_onLoadHistory);
    on<UpdateBoardSettings>(_onUpdateBoardSettings);
  }
  FutureOr<void> _onMoveMade(MoveMade event, Emitter<GameState> emit) async {
    if (state.gameOver || state.board[event.index] != '') return;
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
    final result =
        checkWinnerDynamic(newBoard, state.boardSize, state.winCondition);
    if (result != null) {
      final newHistory = List<String>.from(state.gameHistory);
      String outcome =
          result['winner'] == 'Draw' ? "Draw" : "Winner: ${result['winner']}";
      newHistory.add(outcome);
      await DatabaseHelper.instance.insertHistory(outcome);
      add(const LoadHistory());
      emit(state.copyWith(
          board: newBoard,
          gameOver: true,
          resultMessage: outcome,
          winningCells: List<int>.from(result['winningCells'] as List),
          currentPlayer: state.currentPlayer,
          undoStack: newUndoStack,
          redoStack: [],
          gameHistory: newHistory));
      return;
    } else {
      String nextPlayer = state.currentPlayer == 'X' ? 'O' : 'X';
      emit(state.copyWith(
          board: newBoard,
          currentPlayer: nextPlayer,
          undoStack: newUndoStack,
          redoStack: []));
      if (state.gameMode == GameMode.PvC && nextPlayer == 'O') {
        await Future.delayed(const Duration(milliseconds: 300));
        add(const AITurn());
      }
      return;
    }
  }

  FutureOr<void> _onAITurn(AITurn event, Emitter<GameState> emit) {
    if (state.gameOver) return null;
    final move = _getAIMove(state.board, state.aiDifficulty, 'O', 'X');
    if (move == -1) return null;
    add(MoveMade(move));
    return null;
  }

  FutureOr<void> _onUndoMove(UndoMove event, Emitter<GameState> emit) {
    if (state.undoStack.isEmpty) return null;
    final lastSnapshot = state.undoStack.last;
    final newUndoStack = List<Snapshot>.from(state.undoStack)..removeLast();
    final newRedoStack = List<Snapshot>.from(state.redoStack);
    final currentSnapshot = Snapshot(
        board: List.from(state.board),
        currentPlayer: state.currentPlayer,
        gameOver: state.gameOver,
        resultMessage: state.resultMessage,
        winningCells: List.from(state.winningCells));
    newRedoStack.add(currentSnapshot);
    emit(state.copyWith(
        board: lastSnapshot.board,
        currentPlayer: lastSnapshot.currentPlayer,
        gameOver: lastSnapshot.gameOver,
        resultMessage: lastSnapshot.resultMessage,
        winningCells: lastSnapshot.winningCells,
        undoStack: newUndoStack,
        redoStack: newRedoStack));
    return null;
  }

  FutureOr<void> _onRedoMove(RedoMove event, Emitter<GameState> emit) {
    if (state.redoStack.isEmpty) return null;
    final lastSnapshot = state.redoStack.last;
    final newRedoStack = List<Snapshot>.from(state.redoStack)..removeLast();
    final newUndoStack = List<Snapshot>.from(state.undoStack);
    final currentSnapshot = Snapshot(
        board: List.from(state.board),
        currentPlayer: state.currentPlayer,
        gameOver: state.gameOver,
        resultMessage: state.resultMessage,
        winningCells: List.from(state.winningCells));
    newUndoStack.add(currentSnapshot);
    emit(state.copyWith(
        board: lastSnapshot.board,
        currentPlayer: lastSnapshot.currentPlayer,
        gameOver: lastSnapshot.gameOver,
        resultMessage: lastSnapshot.resultMessage,
        winningCells: lastSnapshot.winningCells,
        undoStack: newUndoStack,
        redoStack: newRedoStack));
    return null;
  }

  FutureOr<void> _onResetGame(ResetGame event, Emitter<GameState> emit) {
    emit(GameState.initial().copyWith(
        gameMode: state.gameMode,
        aiDifficulty: state.aiDifficulty,
        gameHistory: state.gameHistory,
        boardSize: state.boardSize,
        winCondition: state.winCondition));
    return null;
  }

  FutureOr<void> _onToggleGameMode(
      ToggleGameMode event, Emitter<GameState> emit) {
    GameMode newMode =
        state.gameMode == GameMode.PvP ? GameMode.PvC : GameMode.PvP;
    emit(GameState.initial().copyWith(
        gameMode: newMode,
        aiDifficulty: state.aiDifficulty,
        gameHistory: state.gameHistory,
        boardSize: state.boardSize,
        winCondition: state.winCondition));
    return null;
  }

  FutureOr<void> _onChangeDifficulty(
      ChangeDifficulty event, Emitter<GameState> emit) {
    emit(GameState.initial().copyWith(
        gameMode: state.gameMode,
        aiDifficulty: event.difficulty,
        gameHistory: state.gameHistory,
        boardSize: state.boardSize,
        winCondition: state.winCondition));
    return null;
  }

  FutureOr<void> _onLoadHistory(
      LoadHistory event, Emitter<GameState> emit) async {
    final history = await DatabaseHelper.instance.getHistory();
    emit(state.copyWith(gameHistory: history));
    return;
  }

  FutureOr<void> _onUpdateBoardSettings(
      UpdateBoardSettings event, Emitter<GameState> emit) {
    emit(GameState.initial().copyWith(
        gameMode: state.gameMode,
        aiDifficulty: state.aiDifficulty,
        gameHistory: state.gameHistory,
        boardSize: event.boardSize,
        winCondition: event.winCondition));
    return null;
  }

  int _getAIMove(List<String> board, AIDifficulty difficulty, String aiPlayer,
      String humanPlayer) {
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

  int _minimax(List<String> board, int depth, bool isMaximizing,
      String aiPlayer, String humanPlayer, int depthLimit) {
    final result =
        checkWinnerDynamic(board, state.boardSize, state.winCondition);
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
}

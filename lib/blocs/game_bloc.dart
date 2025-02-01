import 'dart:async';
import 'dart:math';
import 'package:advanced_xo_game/utils/game_logic.dart';
import 'package:bloc/bloc.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameState.initial()) {
    on<MoveMade>(_onMoveMade);
    on<AITurn>(_onAITurn);
    on<UndoMove>(_onUndoMove);
    on<RedoMove>(_onRedoMove);
    on<ResetGame>(_onResetGame);
    on<ToggleGameMode>(_onToggleGameMode);
    on<ChangeDifficulty>(_onChangeDifficulty);
  }
  FutureOr<void> _onMoveMade(MoveMade event, Emitter<GameState> emit) async {
    if (state.gameOver || state.board[event.index] != '') return;
    final snapshot = Snapshot(board: List.from(state.board), currentPlayer: state.currentPlayer, gameOver: state.gameOver, resultMessage: state.resultMessage, winningCells: List.from(state.winningCells));
    final newUndoStack = List<Snapshot>.from(state.undoStack)..add(snapshot);
    final newBoard = List<String>.from(state.board);
    newBoard[event.index] = state.currentPlayer;
    final result = checkWinner(newBoard);
    if (result != null) {
      final newHistory = List<String>.from(state.gameHistory);
      newHistory.add(result['winner'] == 'Draw' ? "Draw" : "Winner: ${result['winner']}");
      emit(state.copyWith(board: newBoard, gameOver: true, resultMessage: result['winner'] == 'Draw' ? "Draw" : "Winner: ${result['winner']}", winningCells: result['winningCells'], currentPlayer: state.currentPlayer, undoStack: newUndoStack, redoStack: [] , gameHistory: newHistory));
    } else {
      String nextPlayer = state.currentPlayer == 'X' ? 'O' : 'X';
      emit(state.copyWith(board: newBoard, currentPlayer: nextPlayer, undoStack: newUndoStack, redoStack: []));
      if (state.gameMode == GameMode.PvC && nextPlayer == 'O') {
        await Future.delayed(const Duration(milliseconds: 300));
        add(const AITurn());
      }
    }
  }
  FutureOr<void> _onAITurn(AITurn event, Emitter<GameState> emit) {
    if (state.gameOver) return;
    final move = _getAIMove(state.board, state.aiDifficulty, 'O', 'X');
    if (move == -1) return;
    add(MoveMade(move));
  }
  FutureOr<void> _onUndoMove(UndoMove event, Emitter<GameState> emit) {
    if (state.undoStack.isEmpty) return ;
    final lastSnapshot = state.undoStack.last;
    final newUndoStack = List<Snapshot>.from(state.undoStack)..removeLast();
    final newRedoStack = List<Snapshot>.from(state.redoStack);
    final currentSnapshot = Snapshot(board: List.from(state.board), currentPlayer: state.currentPlayer, gameOver: state.gameOver, resultMessage: state.resultMessage, winningCells: List.from(state.winningCells));
    newRedoStack.add(currentSnapshot);
    emit(state.copyWith(board: lastSnapshot.board, currentPlayer: lastSnapshot.currentPlayer, gameOver: lastSnapshot.gameOver, resultMessage: lastSnapshot.resultMessage, winningCells: lastSnapshot.winningCells, undoStack: newUndoStack, redoStack: newRedoStack));
  }
  FutureOr<void> _onRedoMove(RedoMove event, Emitter<GameState> emit) {
    if (state.redoStack.isEmpty) return;
    final lastSnapshot = state.redoStack.last;
    final newRedoStack = List<Snapshot>.from(state.redoStack)..removeLast();
    final newUndoStack = List<Snapshot>.from(state.undoStack);
    final currentSnapshot = Snapshot(board: List.from(state.board), currentPlayer: state.currentPlayer, gameOver: state.gameOver, resultMessage: state.resultMessage, winningCells: List.from(state.winningCells));
    newUndoStack.add(currentSnapshot);
    emit(state.copyWith(board: lastSnapshot.board, currentPlayer: lastSnapshot.currentPlayer, gameOver: lastSnapshot.gameOver, resultMessage: lastSnapshot.resultMessage, winningCells: lastSnapshot.winningCells, undoStack: newUndoStack, redoStack: newRedoStack));
  }
  FutureOr<void> _onResetGame(ResetGame event, Emitter<GameState> emit) {
    emit(GameState.initial().copyWith(gameMode: state.gameMode, aiDifficulty: state.aiDifficulty, gameHistory: state.gameHistory));
  }
  FutureOr<void> _onToggleGameMode(ToggleGameMode event, Emitter<GameState> emit) {
    GameMode newMode = state.gameMode == GameMode.PvP ? GameMode.PvC : GameMode.PvP;
    emit(GameState.initial().copyWith(gameMode: newMode, aiDifficulty: state.aiDifficulty, gameHistory: state.gameHistory));
  }
  FutureOr<void> _onChangeDifficulty(ChangeDifficulty event, Emitter<GameState> emit) {
    emit(GameState.initial().copyWith(gameMode: state.gameMode, aiDifficulty: event.difficulty, gameHistory: state.gameHistory));
  }
  int _getAIMove(List<String> board, AIDifficulty difficulty, String aiPlayer, String humanPlayer) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return _randomMove(board);
      case AIDifficulty.medium:
        return _minimaxMove(board, aiPlayer, humanPlayer, 2);
      case AIDifficulty.hard:
        return _minimaxMove(board, aiPlayer, humanPlayer, 9);
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
  int _minimaxMove(List<String> board, String aiPlayer, String humanPlayer, int depthLimit) {
    int bestScore = -1000;
    int bestMove = -1;
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = aiPlayer;
        int score = _minimax(board, 0, false, aiPlayer, humanPlayer, depthLimit);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }
  int _minimax(List<String> board, int depth, bool isMaximizing, String aiPlayer, String humanPlayer, int depthLimit) {
    final result = checkWinner(board);
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
          int score = _minimax(board, depth + 1, false, aiPlayer, humanPlayer, depthLimit);
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
          int score = _minimax(board, depth + 1, true, aiPlayer, humanPlayer, depthLimit);
          board[i] = '';
          bestScore = bestScore > score ? score : bestScore;
        }
      }
      return bestScore;
    }
  }
}

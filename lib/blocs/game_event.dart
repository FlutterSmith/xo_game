import 'package:equatable/equatable.dart';

enum GameMode { PvP, PvC }
enum AIDifficulty { easy, medium, hard, adaptive }

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object> get props => [];
}

class MoveMade extends GameEvent {
  final int index;
  const MoveMade(this.index);
  @override
  List<Object> get props => [index];
}

class AITurn extends GameEvent {
  const AITurn();
}

class UndoMove extends GameEvent {
  const UndoMove();
}

class RedoMove extends GameEvent {
  const RedoMove();
}

class ResetGame extends GameEvent {
  const ResetGame();
}

class ToggleGameMode extends GameEvent {
  const ToggleGameMode();
}

class ChangeDifficulty extends GameEvent {
  final AIDifficulty difficulty;
  const ChangeDifficulty(this.difficulty);
  @override
  List<Object> get props => [difficulty];
}

class UpdateBoardSettings extends GameEvent {
  final int boardSize;
  final int winCondition;
  const UpdateBoardSettings(this.boardSize, this.winCondition);
  @override
  List<Object> get props => [boardSize, winCondition];
}

class LoadHistory extends GameEvent {
  const LoadHistory();
}

class ClearHistory extends GameEvent {
  const ClearHistory();
}
class SetPlayerSide extends GameEvent {
  final String side; // "X" or "O"
  const SetPlayerSide(this.side);
  @override
  List<Object> get props => [side];
}

class ToggleTimedMode extends GameEvent {
  const ToggleTimedMode();
}

class SetTimeLimit extends GameEvent {
  final int seconds;
  const SetTimeLimit(this.seconds);
  @override
  List<Object> get props => [seconds];
}

class TimerTick extends GameEvent {
  const TimerTick();
}

class TimeoutMove extends GameEvent {
  const TimeoutMove();
}

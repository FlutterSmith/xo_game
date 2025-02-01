import 'package:equatable/equatable.dart';

enum GameMode { PvP, PvC }
enum AIDifficulty { easy, medium, hard }

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

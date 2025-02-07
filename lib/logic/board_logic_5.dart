// lib/logic/board_logic_5.dart
Map<String, dynamic>? checkWinner5x5(List<String> board) {
  int size = 5;
  int winCondition = 4; // Require 4 in a row to win.

  // Horizontal check:
  for (int row = 0; row < size; row++) {
    for (int col = 0; col <= size - winCondition; col++) {
      String first = board[row * size + col];
      if (first == '') continue;
      bool win = true;
      List<int> indices = [];
      for (int offset = 0; offset < winCondition; offset++) {
        if (board[row * size + col + offset] != first) {
          win = false;
          break;
        }
        indices.add(row * size + col + offset);
      }
      if (win) return {'winner': first, 'winningCells': indices};
    }
  }

  // Vertical check:
  for (int col = 0; col < size; col++) {
    for (int row = 0; row <= size - winCondition; row++) {
      String first = board[row * size + col];
      if (first == '') continue;
      bool win = true;
      List<int> indices = [];
      for (int offset = 0; offset < winCondition; offset++) {
        if (board[(row + offset) * size + col] != first) {
          win = false;
          break;
        }
        indices.add((row + offset) * size + col);
      }
      if (win) return {'winner': first, 'winningCells': indices};
    }
  }

  // Main diagonal check:
  for (int row = 0; row <= size - winCondition; row++) {
    for (int col = 0; col <= size - winCondition; col++) {
      String first = board[row * size + col];
      if (first == '') continue;
      bool win = true;
      List<int> indices = [];
      for (int offset = 0; offset < winCondition; offset++) {
        if (board[(row + offset) * size + col + offset] != first) {
          win = false;
          break;
        }
        indices.add((row + offset) * size + col + offset);
      }
      if (win) return {'winner': first, 'winningCells': indices};
    }
  }

  // Anti-diagonal check:
  for (int row = 0; row <= size - winCondition; row++) {
    for (int col = winCondition - 1; col < size; col++) {
      String first = board[row * size + col];
      if (first == '') continue;
      bool win = true;
      List<int> indices = [];
      for (int offset = 0; offset < winCondition; offset++) {
        if (board[(row + offset) * size + col - offset] != first) {
          win = false;
          break;
        }
        indices.add((row + offset) * size + col - offset);
      }
      if (win) return {'winner': first, 'winningCells': indices};
    }
  }

  if (!board.contains('')) return {'winner': 'Draw', 'winningCells': []};
  return null;
}

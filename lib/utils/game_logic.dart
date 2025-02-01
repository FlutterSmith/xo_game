Map<String, dynamic>? checkWinnerDynamic(List<String> board, int boardSize, int winCondition) {
  for (int row = 0; row < boardSize; row++) {
    for (int col = 0; col <= boardSize - winCondition; col++) {
      String first = board[row * boardSize + col];
      if (first == '') continue;
      bool win = true;
      List<int> indices = [];
      for (int offset = 0; offset < winCondition; offset++) {
        if (board[row * boardSize + col + offset] != first) {
          win = false;
          break;
        }
        indices.add(row * boardSize + col + offset);
      }
      if (win) return {'winner': first, 'winningCells': indices};
    }
  }
  for (int col = 0; col < boardSize; col++) {
    for (int row = 0; row <= boardSize - winCondition; row++) {
      String first = board[row * boardSize + col];
      if (first == '') continue;
      bool win = true;
      List<int> indices = [];
      for (int offset = 0; offset < winCondition; offset++) {
        if (board[(row + offset) * boardSize + col] != first) {
          win = false;
          break;
        }
        indices.add((row + offset) * boardSize + col);
      }
      if (win) return {'winner': first, 'winningCells': indices};
    }
  }
  for (int row = 0; row <= boardSize - winCondition; row++) {
    for (int col = 0; col <= boardSize - winCondition; col++) {
      String first = board[row * boardSize + col];
      if (first == '') continue;
      bool win = true;
      List<int> indices = [];
      for (int offset = 0; offset < winCondition; offset++) {
        if (board[(row + offset) * boardSize + col + offset] != first) {
          win = false;
          break;
        }
        indices.add((row + offset) * boardSize + col + offset);
      }
      if (win) return {'winner': first, 'winningCells': indices};
    }
  }
  for (int row = 0; row <= boardSize - winCondition; row++) {
    for (int col = winCondition - 1; col < boardSize; col++) {
      String first = board[row * boardSize + col];
      if (first == '') continue;
      bool win = true;
      List<int> indices = [];
      for (int offset = 0; offset < winCondition; offset++) {
        if (board[(row + offset) * boardSize + col - offset] != first) {
          win = false;
          break;
        }
        indices.add((row + offset) * boardSize + col - offset);
      }
      if (win) return {'winner': first, 'winningCells': indices};
    }
  }
  if (!board.contains('')) return {'winner': 'Draw', 'winningCells': []};
  return null;
}

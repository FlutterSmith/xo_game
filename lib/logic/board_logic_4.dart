// lib/logic/board_logic_4.dart
Map<String, dynamic>? checkWinner4x4(List<String> board) {
  int size = 4;
  // Horizontal check: one row per iteration.
  for (int row = 0; row < size; row++) {
    int start = row * size;
    if (board[start] != '' &&
        board[start] == board[start + 1] &&
        board[start + 1] == board[start + 2] &&
        board[start + 2] == board[start + 3]) {
      return {
        'winner': board[start],
        'winningCells': [start, start + 1, start + 2, start + 3]
      };
    }
  }
  // Vertical check.
  for (int col = 0; col < size; col++) {
    if (board[col] != '' &&
        board[col] == board[col + size] &&
        board[col + size] == board[col + 2 * size] &&
        board[col + 2 * size] == board[col + 3 * size]) {
      return {
        'winner': board[col],
        'winningCells': [col, col + size, col + 2 * size, col + 3 * size]
      };
    }
  }
  // Main diagonal check.
  if (board[0] != '' &&
      board[0] == board[5] &&
      board[5] == board[10] &&
      board[10] == board[15]) {
    return {'winner': board[0], 'winningCells': [0, 5, 10, 15]};
  }
  // Anti-diagonal check.
  if (board[3] != '' &&
      board[3] == board[6] &&
      board[6] == board[9] &&
      board[9] == board[12]) {
    return {'winner': board[3], 'winningCells': [3, 6, 9, 12]};
  }
  if (!board.contains('')) {
    return {'winner': 'Draw', 'winningCells': []};
  }
  return null;
}

Map<String, dynamic>? checkWinner3(List<String> board) {
  List<List<int>> winPatterns = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  for (var pattern in winPatterns) {
    if (board[pattern[0]] != '' &&
        board[pattern[0]] == board[pattern[1]] &&
        board[pattern[1]] == board[pattern[2]]) {
      return {'winner': board[pattern[0]], 'winningCells': pattern};
    }
  }
  if (!board.contains('')) return {'winner': 'Draw', 'winningCells': []};
  return null;
}

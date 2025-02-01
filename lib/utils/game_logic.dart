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

Map<String, dynamic>? checkWinner(List<String> board) {
  for (var pattern in winPatterns) {
    String a = board[pattern[0]];
    if (a != '' && a == board[pattern[1]] && a == board[pattern[2]]) {
      return {'winner': a, 'winningCells': pattern};
    }
  }
  if (!board.contains('')) {
    return {'winner': 'Draw', 'winningCells': []};
  }
  return null;
}

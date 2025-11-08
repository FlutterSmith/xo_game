import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_xo_game/utils/game_logic.dart';
import 'package:advanced_xo_game/logic/board_logic_4.dart';
import 'package:advanced_xo_game/logic/board_logic_5.dart';

void main() {
  group('3x3 Board Win Conditions', () {
    test('Horizontal win - Row 1', () {
      final board = ['X', 'X', 'X', '', '', '', '', '', ''];
      final result = checkWinner3(board);
      expect(result['winner'], 'X');
      expect(result['winningCells'], [0, 1, 2]);
    });

    test('Horizontal win - Row 2', () {
      final board = ['', '', '', 'O', 'O', 'O', '', '', ''];
      final result = checkWinner3(board);
      expect(result['winner'], 'O');
      expect(result['winningCells'], [3, 4, 5]);
    });

    test('Vertical win - Column 1', () {
      final board = ['X', '', '', 'X', '', '', 'X', '', ''];
      final result = checkWinner3(board);
      expect(result['winner'], 'X');
      expect(result['winningCells'], [0, 3, 6]);
    });

    test('Diagonal win - Main diagonal', () {
      final board = ['X', '', '', '', 'X', '', '', '', 'X'];
      final result = checkWinner3(board);
      expect(result['winner'], 'X');
      expect(result['winningCells'], [0, 4, 8]);
    });

    test('Diagonal win - Anti-diagonal', () {
      final board = ['', '', 'O', '', 'O', '', 'O', '', ''];
      final result = checkWinner3(board);
      expect(result['winner'], 'O');
      expect(result['winningCells'], [2, 4, 6]);
    });

    test('Draw game', () {
      final board = ['X', 'O', 'X', 'O', 'X', 'O', 'O', 'X', 'O'];
      final result = checkWinner3(board);
      expect(result['winner'], 'Draw');
      expect(result['winningCells'], []);
    });

    test('Game in progress', () {
      final board = ['X', 'O', 'X', '', '', '', '', '', ''];
      final result = checkWinner3(board);
      expect(result, isNull);
    });

    test('Empty board', () {
      final board = ['', '', '', '', '', '', '', '', ''];
      final result = checkWinner3(board);
      expect(result, isNull);
    });
  });

  group('4x4 Board Win Conditions', () {
    test('Horizontal win - Row 1', () {
      final board = [
        'X',
        'X',
        'X',
        'X',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      final result = checkWinner4x4(board);
      expect(result['winner'], 'X');
      expect(result['winningCells'], [0, 1, 2, 3]);
    });

    test('Vertical win - Column 2', () {
      final board = [
        '',
        'O',
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        'O',
        '',
        ''
      ];
      final result = checkWinner4x4(board);
      expect(result['winner'], 'O');
      expect(result['winningCells'], [1, 5, 9, 13]);
    });

    test('Main diagonal win', () {
      final board = [
        'X',
        '',
        '',
        '',
        '',
        'X',
        '',
        '',
        '',
        '',
        'X',
        '',
        '',
        '',
        '',
        'X'
      ];
      final result = checkWinner4x4(board);
      expect(result['winner'], 'X');
      expect(result['winningCells'], [0, 5, 10, 15]);
    });

    test('Anti-diagonal win', () {
      final board = [
        '',
        '',
        '',
        'O',
        '',
        '',
        'O',
        '',
        '',
        'O',
        '',
        '',
        'O',
        '',
        '',
        ''
      ];
      final result = checkWinner4x4(board);
      expect(result['winner'], 'O');
      expect(result['winningCells'], [3, 6, 9, 12]);
    });

    test('Draw game', () {
      final board = [
        'X',  // 0
        'O',  // 1
        'X',  // 2
        'O',  // 3
        'O',  // 4
        'O',  // 5  (Changed from X to O to break main diagonal)
        'O',  // 6
        'X',  // 7
        'O',  // 8
        'X',  // 9
        'X',  // 10 (Changed from X to X - keeping it)
        'O',  // 11
        'X',  // 12
        'O',  // 13
        'O',  // 14
        'X'   // 15
      ];
      final result = checkWinner4x4(board);
      expect(result['winner'], 'Draw');
    });

    test('Game in progress', () {
      final board = [
        'X',
        'O',
        'X',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      final result = checkWinner4x4(board);
      expect(result, isNull);
    });
  });

  group('5x5 Board Win Conditions', () {
    test('Horizontal win - Row 1', () {
      final board = [
        'X',
        'X',
        'X',
        'X',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      final result = checkWinner5x5(board);
      expect(result['winner'], 'X');
      expect(result['winningCells'], [0, 1, 2, 3]);
    });

    test('Vertical win - Column 3', () {
      final board = [
        '',
        '',
        'O',
        '',
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      final result = checkWinner5x5(board);
      expect(result['winner'], 'O');
      expect(result['winningCells'], [2, 7, 12, 17]);
    });

    test('Diagonal win - starting at 0', () {
      final board = [
        'X',
        '',
        '',
        '',
        '',
        '',
        'X',
        '',
        '',
        '',
        '',
        '',
        'X',
        '',
        '',
        '',
        '',
        '',
        'X',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      final result = checkWinner5x5(board);
      expect(result['winner'], 'X');
      expect(result['winningCells'], [0, 6, 12, 18]);
    });

    test('Anti-diagonal win', () {
      final board = [
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        'O',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      final result = checkWinner5x5(board);
      expect(result['winner'], 'O');
      expect(result['winningCells'], [3, 7, 11, 15]);
    });

    test('Game in progress - partial board', () {
      final board = [
        'X',
        'O',
        'X',
        '',
        '',
        'O',
        'X',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      final result = checkWinner5x5(board);
      expect(result, isNull);
    });

    test('No winner yet - scattered pieces', () {
      final board = [
        'X',
        '',
        'O',
        '',
        'X',
        '',
        'O',
        '',
        'X',
        '',
        'O',
        '',
        'X',
        '',
        'O',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ];
      final result = checkWinner5x5(board);
      expect(result, isNull);
    });
  });
}

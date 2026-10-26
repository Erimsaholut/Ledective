import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/games/puzzle_board.dart';
import 'package:ledective/apps/phone/phone_number.dart';
import 'package:ledective/apps/poltel/documents.dart';
import 'package:ledective/data/game_clock.dart';
import 'package:ledective/widgets/day_divider.dart';

void main() {
  group('formatPhoneNumber', () {
    test('groups numbers that start with 0 as 4-3-2-2', () {
      expect(formatPhoneNumber('0'), '0');
      expect(formatPhoneNumber('05350'), '0535 0');
      expect(formatPhoneNumber('05350315353'), '0535 031 53 53');
    });

    test('groups other numbers as 3-3-2-2', () {
      expect(formatPhoneNumber('535'), '535');
      expect(formatPhoneNumber('5350315353'), '535 031 53 53');
    });

    test('handles empty input', () {
      expect(formatPhoneNumber(''), '');
    });

    test('digitsOnly strips formatting', () {
      expect(digitsOnly('0535 031 53 53'), '05350315353');
    });
  });

  group('PuzzleBoard', () {
    test('solved board is solved', () {
      final board = PuzzleBoard.solved();
      expect(board.tiles, [1, 2, 3, 4, 5, 6, 7, 8, 0]);
      expect(board.isSolved, isTrue);
    });

    test('only tiles next to the gap can move', () {
      final board = PuzzleBoard.solved();
      expect(board.movableIndices..sort(), [5, 7]);
      expect(board.move(0), isFalse, reason: 'same column but not adjacent');
      expect(board.move(6), isFalse, reason: 'same row but not adjacent');
      expect(board.move(7), isTrue);
      expect(board.tiles, [1, 2, 3, 4, 5, 6, 7, 0, 8]);
      expect(board.isSolved, isFalse);
    });

    test('shuffled boards are never solved and always solvable', () {
      for (var seed = 0; seed < 50; seed++) {
        final board = PuzzleBoard.shuffled(random: Random(seed));
        expect(board.isSolved, isFalse);
        expect(_isSolvable(board.tiles), isTrue, reason: 'seed $seed');
      }
    });

    test('fromTiles rejects non-square input', () {
      expect(() => PuzzleBoard.fromTiles([1, 2, 0]), throwsArgumentError);
    });
  });

  group('GameClock', () {
    test('counts calendar days since the first open', () {
      final clock = GameClock(DateTime(2026, 3, 28, 23, 59));
      expect(clock.daysSinceFirstOpen(DateTime(2026, 3, 28, 0, 1)), 0);
      // Spans the European daylight-saving change on 29 March.
      expect(clock.daysSinceFirstOpen(DateTime(2026, 3, 30, 0, 30)), 2);
    });

    test('day divider text', () {
      final clock = GameClock(DateTime(2026, 1, 10));
      final today = DateTime(2026, 1, 10);
      expect(DayDivider.describe(0, clock, today), 'Bugün');
      expect(DayDivider.describe(5, clock, today), '5 gün önce');
      expect(
        DayDivider.describe(5, clock, DateTime(2026, 1, 12)),
        '7 gün önce',
      );
    });
  });

  test('every statement has one answer per question', () {
    statements.forEach((name, statement) {
      expect(
        statement.answers.length,
        statement.questions.length,
        reason: name,
      );
    });
  });
}

/// For odd-width boards a position is solvable when the number of
/// inversions is even.
bool _isSolvable(List<int> tiles) {
  final numbers = tiles.where((t) => t != 0).toList();
  var inversions = 0;
  for (var i = 0; i < numbers.length; i++) {
    for (var j = i + 1; j < numbers.length; j++) {
      if (numbers[i] > numbers[j]) inversions++;
    }
  }
  return inversions.isEven;
}

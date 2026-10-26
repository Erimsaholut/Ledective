import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/games/memory_board.dart';
import 'package:ledective/apps/games/puzzle_board.dart';
import 'package:ledective/apps/music/songs.dart';
import 'package:ledective/apps/phone/phone_number.dart';
import 'package:ledective/apps/pian/note_player.dart';
import 'package:ledective/apps/poltel/lab/jigsaw_game.dart';
import 'package:ledective/apps/shopper/shopper_app.dart';
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

  group('JigsawBoard', () {
    test('a new board is never already solved', () {
      for (var seed = 0; seed < 30; seed++) {
        expect(JigsawBoard(3, 3, random: Random(seed)).isSolved, isFalse);
      }
    });

    test('swapping pieces back solves it', () {
      final board = JigsawBoard.fromPieces(2, 2, [1, 0, 2, 3]);
      expect(board.isSolved, isFalse);
      board.swap(0, 1);
      expect(board.isSolved, isTrue);
    });
  });

  group('MemoryBoard', () {
    test('matching pairs stay face up', () {
      final board = MemoryBoard([0, 1, 0, 1]);
      expect(board.flip(0), isTrue);
      expect(board.flip(2), isTrue);
      expect(board.isMatched(0) && board.isMatched(2), isTrue);
      expect(board.moves, 1);
    });

    test('a mismatch blocks flips until hidden', () {
      final board = MemoryBoard([0, 1, 0, 1]);
      board
        ..flip(0)
        ..flip(1);
      expect(board.isShowingMismatch, isTrue);
      expect(board.flip(2), isFalse);
      board.hideOpen();
      expect(board.isFaceUp(0), isFalse);
      expect(board.flip(2), isTrue);
    });

    test('completes when every pair is found', () {
      final board = MemoryBoard([0, 1, 1, 0]);
      for (final i in [0, 3, 1, 2]) {
        board.flip(i);
      }
      expect(board.isComplete, isTrue);
      expect(board.moves, 2);
    });

    test('shuffled boards hold every value twice', () {
      final board = MemoryBoard.shuffled(8, random: Random(1));
      expect([...board.cards]..sort(), [
        for (var i = 0; i < 8; i++) ...[i, i],
      ]);
    });

    test('rejects cards without a pair', () {
      expect(() => MemoryBoard([0, 0, 1]), throwsArgumentError);
    });
  });

  group('songs', () {
    test('melody notation', () {
      final steps = parseMelody('c d- e. r');
      expect(steps.map((s) => s.note), [Note.c, Note.d, Note.e, null]);
      expect(steps.map((s) => s.beats), [1, 2, 0.5, 1]);
      expect(() => parseMelody('x'), throwsFormatException);
    });

    test('every song parses', () {
      for (final song in songs) {
        expect(song.steps, isNotEmpty, reason: song.title);
        expect(song.duration, greaterThan(Duration.zero));
      }
    });
  });

  test('formatLira', () {
    expect(formatLira(349900), '3.499,00 TL');
    expect(formatLira(4990), '49,90 TL');
    expect(formatLira(123456789), '1.234.567,89 TL');
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

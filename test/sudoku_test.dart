import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/games/sudoku/sudoku_game.dart';
import 'package:ledective/apps/games/sudoku/sudoku_puzzle.dart';

List<int> _grid(String digits) => [
  for (final c in digits.split('')) int.parse(c),
];

final _puzzle = _grid(
  '530070000600195000098000060800060003400803001700020006'
  '060000280000419005000080079',
);
final _solution = _grid(
  '534678912672195348198342567859761423426853791713924856'
  '961537284287419635345286179',
);

/// Whether [grid] is completely and correctly filled.
bool _isValidSolution(List<int> grid) {
  bool allDigits(Iterable<int> cells) =>
      ({...cells}..remove(0)).length == 9 && cells.length == 9;
  for (var n = 0; n < 9; n++) {
    final row = [for (var c = 0; c < 9; c++) grid[n * 9 + c]];
    final col = [for (var r = 0; r < 9; r++) grid[r * 9 + n]];
    final box = [
      for (var r = 0; r < 3; r++)
        for (var c = 0; c < 3; c++) grid[(n ~/ 3 * 3 + r) * 9 + n % 3 * 3 + c],
    ];
    if (!allDigits(row) || !allDigits(col) || !allDigits(box)) return false;
  }
  return true;
}

SudokuGame _knownGame() => SudokuGame(
  SudokuPuzzle(
    difficulty: SudokuDifficulty.easy,
    givens: _puzzle,
    solution: _solution,
  ),
);

void main() {
  group('SudokuSolver', () {
    test('solves a known puzzle', () {
      expect(SudokuSolver.solve(_puzzle), _solution);
      expect(SudokuSolver.countSolutions(_puzzle), 1);
    });

    test('counts up to the limit', () {
      final empty = List.filled(81, 0);
      expect(SudokuSolver.countSolutions(empty), 2);
      expect(SudokuSolver.countSolutions(empty, limit: 5), 5);
    });

    test('finds nothing for a grid that breaks the rules', () {
      final broken = List.of(_puzzle)..[2] = 5; // Second 5 in the first row.
      expect(SudokuSolver.isConsistent(broken), isFalse);
      expect(SudokuSolver.solve(broken), isNull);
      expect(SudokuSolver.countSolutions(broken), 0);
    });

    test('fills an empty grid with a valid random solution', () {
      final a = SudokuSolver.solve(List.filled(81, 0), random: Random(1))!;
      final b = SudokuSolver.solve(List.filled(81, 0), random: Random(2))!;
      expect(_isValidSolution(a), isTrue);
      expect(_isValidSolution(b), isTrue);
      expect(a, isNot(b));
    });
  });

  group('SudokuPuzzle.generate', () {
    for (final difficulty in SudokuDifficulty.values) {
      test('${difficulty.name} puzzles have a single solution', () {
        for (var seed = 0; seed < 5; seed++) {
          final puzzle = SudokuPuzzle.generate(
            difficulty,
            random: Random(seed),
          );
          final reason = 'seed $seed';
          expect(_isValidSolution(puzzle.solution), isTrue, reason: reason);
          for (var i = 0; i < 81; i++) {
            if (puzzle.givens[i] != 0) {
              expect(puzzle.givens[i], puzzle.solution[i], reason: reason);
            }
          }
          expect(SudokuSolver.countSolutions(puzzle.givens), 1, reason: reason);
          expect(SudokuSolver.solve(puzzle.givens), puzzle.solution);
          expect(puzzle.clues, greaterThanOrEqualTo(difficulty.clues));
          expect(puzzle.clues, lessThanOrEqualTo(difficulty.clues + 4));
        }
      });
    }

    test('harder puzzles give fewer clues', () {
      final clues = [
        for (final difficulty in SudokuDifficulty.values)
          SudokuPuzzle.generate(difficulty, random: Random(7)).clues,
      ];
      expect(clues[0], greaterThan(clues[1]));
      expect(clues[1], greaterThan(clues[2]));
    });
  });

  group('SudokuGame', () {
    test('givens cannot be changed', () {
      final game = _knownGame();
      expect(game.isLocked(0), isTrue);
      expect(game.enter(0, 1), isFalse);
      expect(game.erase(0), isFalse);
      expect(game.values[0], 5);
    });

    test('a wrong digit is marked and counts as a mistake', () {
      final game = _knownGame();
      expect(game.enter(2, 1), isTrue); // The solution is 4.
      expect(game.isWrong(2), isTrue);
      expect(game.mistakes, 1);
      expect(game.enter(2, 4), isTrue);
      expect(game.isWrong(2), isFalse);
      expect(game.mistakes, 1);
    });

    test('notes are toggled and cleared by a placed digit', () {
      final game = _knownGame();
      expect(game.toggleNote(2, 4), isTrue);
      expect(game.toggleNote(2, 1), isTrue);
      expect(game.toggleNote(3, 4), isTrue); // Same row as cell 2.
      expect(game.toggleNote(78, 4), isTrue); // Not a peer of cell 2.
      expect(game.hasNote(2, 4), isTrue);

      game.enter(2, 4);
      expect(game.notes[2], 0);
      expect(game.hasNote(3, 4), isFalse);
      expect(game.hasNote(78, 4), isTrue);

      expect(game.toggleNote(2, 7), isFalse, reason: 'cell has a digit');
      game.toggleNote(78, 4);
      expect(game.hasNote(78, 4), isFalse);
    });

    test('erasing empties a cell', () {
      final game = _knownGame()..enter(2, 9);
      expect(game.erase(2), isTrue);
      expect(game.values[2], 0);
      expect(game.erase(2), isFalse);
    });

    test('hints fill the selected cell, then random ones, up to the limit', () {
      final game = _knownGame();
      expect(game.hint(preferred: 2), 2);
      expect(game.values[2], 4);
      expect(game.isLocked(2), isTrue);

      final cell = game.hint(preferred: 0, random: Random(3))!;
      expect(cell, isNot(0), reason: 'cell 0 is a given');
      expect(game.values[cell], _solution[cell]);

      expect(game.hint(), isNotNull);
      expect(game.hintsLeft, 0);
      expect(game.hint(), isNull);
    });

    test('is solved once every cell matches the solution', () {
      final game = _knownGame();
      for (var i = 0; i < 81; i++) {
        if (!game.isLocked(i)) game.enter(i, _solution[i]);
      }
      expect(game.isSolved, isTrue);
      expect(game.enter(2, 1), isFalse);
      expect(game.remaining(5), 0);
    });

    test('survives a JSON round trip', () {
      final game = SudokuGame.generate(
        SudokuDifficulty.medium,
        random: Random(4),
      );
      final empty = game.values.indexOf(0);
      game
        ..enter(empty, game.puzzle.solution[empty] % 9 + 1)
        ..toggleNote(game.values.indexOf(0), 3)
        ..hint(random: Random(5))
        ..elapsed = const Duration(minutes: 3, seconds: 12);

      final copy = SudokuGame.fromJson(game.toJson());
      expect(copy.difficulty, SudokuDifficulty.medium);
      expect(copy.puzzle.givens, game.puzzle.givens);
      expect(copy.puzzle.solution, game.puzzle.solution);
      expect(copy.values, game.values);
      expect(copy.notes, game.notes);
      expect(copy.hinted, game.hinted);
      expect(copy.mistakes, 1);
      expect(copy.elapsed, game.elapsed);
    });
  });
}

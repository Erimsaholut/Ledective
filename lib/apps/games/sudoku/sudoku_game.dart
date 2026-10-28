import 'dart:math';

import 'sudoku_puzzle.dart';

/// A Sudoku being played: the player's digits and pencil notes on top of a
/// [SudokuPuzzle], with the mistakes, hints and time so far.
class SudokuGame {
  SudokuGame(
    this.puzzle, {
    List<int>? values,
    List<int>? notes,
    Set<int>? hinted,
    this.mistakes = 0,
    this.elapsed = Duration.zero,
  }) : values = values ?? List.of(puzzle.givens),
       notes = notes ?? List.filled(81, 0),
       hinted = hinted ?? {};

  factory SudokuGame.generate(SudokuDifficulty difficulty, {Random? random}) =>
      SudokuGame(SudokuPuzzle.generate(difficulty, random: random));

  factory SudokuGame.fromJson(Map<String, dynamic> json) {
    List<int> digits(String key) => [
      for (final c in (json[key] as String).split('')) int.parse(c),
    ];
    return SudokuGame(
      SudokuPuzzle(
        difficulty: SudokuDifficulty.values.byName(
          json['difficulty'] as String,
        ),
        givens: List.unmodifiable(digits('givens')),
        solution: List.unmodifiable(digits('solution')),
      ),
      values: digits('values'),
      notes: List.of((json['notes'] as List).cast<int>()),
      hinted: {...(json['hinted'] as List).cast<int>()},
      mistakes: json['mistakes'] as int,
      elapsed: Duration(seconds: json['seconds'] as int),
    );
  }

  static const maxHints = 3;

  final SudokuPuzzle puzzle;

  /// The digit in every cell, givens included; 0 when empty.
  final List<int> values;

  /// Pencil notes of every cell, as bit masks of `1 << digit`.
  final List<int> notes;

  /// Cells filled by a hint. Like givens, they can't be changed.
  final Set<int> hinted;

  int mistakes;
  Duration elapsed;

  SudokuDifficulty get difficulty => puzzle.difficulty;

  int get hintsLeft => maxHints - hinted.length;

  bool isLocked(int i) => puzzle.givens[i] != 0 || hinted.contains(i);

  /// True for a digit that doesn't match the solution.
  bool isWrong(int i) => values[i] != 0 && values[i] != puzzle.solution[i];

  bool hasNote(int i, int digit) => notes[i] & (1 << digit) != 0;

  bool get isSolved {
    for (var i = 0; i < 81; i++) {
      if (values[i] != puzzle.solution[i]) return false;
    }
    return true;
  }

  /// How many more of [digit] the solution needs.
  int remaining(int digit) {
    var placed = 0;
    for (var i = 0; i < 81; i++) {
      if (values[i] == digit && !isWrong(i)) placed++;
    }
    return 9 - placed;
  }

  /// Puts [digit] in cell [i]. A wrong digit stays, marked, and counts as a
  /// mistake. Returns false if nothing changed.
  bool enter(int i, int digit) {
    if (isLocked(i) || isSolved || values[i] == digit) return false;
    values[i] = digit;
    notes[i] = 0;
    if (isWrong(i)) {
      mistakes++;
    } else {
      _clearNotesAround(i, digit);
    }
    return true;
  }

  /// Adds or removes a pencil note in an empty cell.
  bool toggleNote(int i, int digit) {
    if (isLocked(i) || isSolved || values[i] != 0) return false;
    notes[i] ^= 1 << digit;
    return true;
  }

  /// Empties cell [i] of its digit and notes.
  bool erase(int i) {
    if (isLocked(i) || (values[i] == 0 && notes[i] == 0)) return false;
    values[i] = 0;
    notes[i] = 0;
    return true;
  }

  /// Fills a cell with its solution: [preferred] if it still needs one,
  /// otherwise a random cell that does. Returns the cell, or null when no
  /// hints are left.
  int? hint({int? preferred, Random? random}) {
    if (hintsLeft == 0 || isSolved) return null;
    bool needsHelp(int i) => values[i] != puzzle.solution[i];
    final open = [
      for (var i = 0; i < 81; i++)
        if (needsHelp(i)) i,
    ];
    final cell = preferred != null && needsHelp(preferred)
        ? preferred
        : open[(random ?? Random()).nextInt(open.length)];
    final digit = puzzle.solution[cell];
    values[cell] = digit;
    notes[cell] = 0;
    hinted.add(cell);
    _clearNotesAround(cell, digit);
    return cell;
  }

  void _clearNotesAround(int i, int digit) {
    for (final peer in peersOf(i)) {
      notes[peer] &= ~(1 << digit);
    }
  }

  /// The other cells in the row, column and box of cell [i].
  static Iterable<int> peersOf(int i) sync* {
    final row = i ~/ 9, col = i % 9;
    final boxRow = row ~/ 3 * 3, boxCol = col ~/ 3 * 3;
    for (var j = 0; j < 81; j++) {
      if (j == i) continue;
      final r = j ~/ 9, c = j % 9;
      if (r == row ||
          c == col ||
          (r ~/ 3 * 3 == boxRow && c ~/ 3 * 3 == boxCol)) {
        yield j;
      }
    }
  }

  Map<String, Object> toJson() => {
    'difficulty': difficulty.name,
    'givens': puzzle.givens.join(),
    'solution': puzzle.solution.join(),
    'values': values.join(),
    'notes': notes,
    'hinted': hinted.toList(),
    'mistakes': mistakes,
    'seconds': elapsed.inSeconds,
  };
}

import 'dart:math';

/// How hard a generated puzzle is: fewer clues leave more to work out.
enum SudokuDifficulty {
  easy('Kolay', 40),
  medium('Orta', 32),
  hard('Zor', 25);

  const SudokuDifficulty(this.label, this.clues);

  final String label;

  /// Filled cells the generator aims for. A hard puzzle may keep a few more
  /// when no clue can go without losing the unique solution.
  final int clues;
}

/// Sudoku grids are 81 cells in row order, with 0 for an empty cell.
abstract final class SudokuSolver {
  /// The first solution of [grid], or null if it has none. With [random],
  /// digits are tried in random order, which fills an empty grid with a
  /// random valid solution.
  static List<int>? solve(List<int> grid, {Random? random}) {
    final search = _Search(grid, limit: 1, random: random);
    if (!search.isConsistent) return null;
    search.run();
    return search.first;
  }

  /// Number of solutions of [grid], counting no further than [limit].
  static int countSolutions(List<int> grid, {int limit = 2}) {
    final search = _Search(grid, limit: limit);
    if (!search.isConsistent) return 0;
    search.run();
    return search.solutions;
  }

  /// Whether no digit repeats in a row, column or box of [grid].
  static bool isConsistent(List<int> grid) => _Search(grid).isConsistent;
}

/// Backtracking over bit masks of the digits used in each row, column and
/// box, always filling the cell with the fewest candidates first.
class _Search {
  _Search(List<int> grid, {this.limit = 1, this.random})
    : cells = List.of(grid) {
    if (cells.length != 81) {
      throw ArgumentError.value(grid, 'grid', 'needs 81 cells');
    }
    for (var i = 0; i < 81; i++) {
      final digit = cells[i];
      if (digit == 0) continue;
      final bit = 1 << digit;
      if ((_rows[i ~/ 9] | _cols[i % 9] | _boxes[_box(i)]) & bit != 0) {
        isConsistent = false;
      }
      _place(i, digit);
    }
  }

  static const _allDigits = 0x3FE;

  final List<int> cells;
  final int limit;
  final Random? random;
  final _rows = List.filled(9, 0);
  final _cols = List.filled(9, 0);
  final _boxes = List.filled(9, 0);

  bool isConsistent = true;
  int solutions = 0;
  List<int>? first;

  static int _box(int i) => (i ~/ 27) * 3 + (i % 9) ~/ 3;

  void _place(int i, int digit) {
    final bit = 1 << digit;
    cells[i] = digit;
    _rows[i ~/ 9] |= bit;
    _cols[i % 9] |= bit;
    _boxes[_box(i)] |= bit;
  }

  void _clear(int i) {
    final mask = ~(1 << cells[i]);
    cells[i] = 0;
    _rows[i ~/ 9] &= mask;
    _cols[i % 9] &= mask;
    _boxes[_box(i)] &= mask;
  }

  void run() {
    var best = -1;
    var bestMask = 0;
    var bestCount = 10;
    for (var i = 0; i < 81; i++) {
      if (cells[i] != 0) continue;
      final mask =
          ~(_rows[i ~/ 9] | _cols[i % 9] | _boxes[_box(i)]) & _allDigits;
      final count = _bitCount(mask);
      if (count == 0) return;
      if (count < bestCount) {
        best = i;
        bestMask = mask;
        bestCount = count;
        if (count == 1) break;
      }
    }
    if (best == -1) {
      solutions++;
      first ??= List.unmodifiable(cells);
      return;
    }
    final digits = [
      for (var d = 1; d <= 9; d++)
        if (bestMask & (1 << d) != 0) d,
    ];
    if (random != null) digits.shuffle(random);
    for (final digit in digits) {
      _place(best, digit);
      run();
      _clear(best);
      if (solutions >= limit) return;
    }
  }

  static int _bitCount(int mask) {
    var count = 0;
    for (var m = mask; m != 0; m &= m - 1) {
      count++;
    }
    return count;
  }
}

/// A puzzle with exactly one solution.
class SudokuPuzzle {
  const SudokuPuzzle({
    required this.difficulty,
    required this.givens,
    required this.solution,
  });

  /// Fills a random grid, then empties cells in random order as long as the
  /// puzzle keeps a single solution.
  factory SudokuPuzzle.generate(SudokuDifficulty difficulty, {Random? random}) {
    random ??= Random();
    final solution = SudokuSolver.solve(List.filled(81, 0), random: random)!;
    final givens = List.of(solution);
    var clues = 81;
    for (final i in List.generate(81, (i) => i)..shuffle(random)) {
      if (clues <= difficulty.clues) break;
      givens[i] = 0;
      if (SudokuSolver.countSolutions(givens) == 1) {
        clues--;
      } else {
        givens[i] = solution[i];
      }
    }
    return SudokuPuzzle(
      difficulty: difficulty,
      givens: List.unmodifiable(givens),
      solution: solution,
    );
  }

  final SudokuDifficulty difficulty;
  final List<int> givens;
  final List<int> solution;

  int get clues => givens.where((d) => d != 0).length;
}

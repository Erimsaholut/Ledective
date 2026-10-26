import 'dart:math';

/// State of an n×n sliding puzzle. Tiles are numbered 1..n²-1 and 0 is the
/// empty square. Solved means the numbers are in order with the gap last.
class PuzzleBoard {
  PuzzleBoard.solved([this.size = 3])
    : _tiles = [for (var i = 1; i < size * size; i++) i, 0];

  PuzzleBoard.fromTiles(List<int> tiles)
    : size = sqrt(tiles.length).round(),
      _tiles = [...tiles] {
    if (size * size != tiles.length) {
      throw ArgumentError.value(tiles, 'tiles', 'must form a square');
    }
  }

  /// A board shuffled by random legal moves, so it is always solvable.
  factory PuzzleBoard.shuffled({int size = 3, Random? random, int? moves}) {
    final rng = random ?? Random();
    final board = PuzzleBoard.solved(size);
    var previousEmpty = -1;
    for (var i = 0; i < (moves ?? size * size * 30); i++) {
      final options = board.movableIndices
          .where((index) => index != previousEmpty)
          .toList();
      previousEmpty = board.emptyIndex;
      board.move(options[rng.nextInt(options.length)]);
    }
    // Rarely the walk ends where it started; nudge it off the solution.
    if (board.isSolved) board.move(board.movableIndices.first);
    return board;
  }

  final int size;
  final List<int> _tiles;

  List<int> get tiles => List.unmodifiable(_tiles);

  int get emptyIndex => _tiles.indexOf(0);

  bool get isSolved {
    for (var i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) return false;
    }
    return true;
  }

  /// Indices of the tiles next to the empty square.
  List<int> get movableIndices {
    final empty = emptyIndex;
    final row = empty ~/ size;
    final col = empty % size;
    return [
      if (row > 0) empty - size,
      if (row < size - 1) empty + size,
      if (col > 0) empty - 1,
      if (col < size - 1) empty + 1,
    ];
  }

  /// Slides the tile at [index] into the empty square. Returns false if
  /// that tile isn't next to the empty square.
  bool move(int index) {
    if (!movableIndices.contains(index)) return false;
    final empty = emptyIndex;
    _tiles[empty] = _tiles[index];
    _tiles[index] = 0;
    return true;
  }
}

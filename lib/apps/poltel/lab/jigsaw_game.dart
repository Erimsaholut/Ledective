import 'dart:math';

import 'package:flutter/material.dart';

/// The order of pieces on a torn image. Tapping two pieces swaps them; the
/// image is whole again when every piece is back in its place.
class JigsawBoard {
  JigsawBoard(this.rows, this.cols, {Random? random})
    : _pieces = List.generate(rows * cols, (i) => i) {
    final rng = random ?? Random();
    do {
      _pieces.shuffle(rng);
    } while (isSolved);
  }

  JigsawBoard.fromPieces(this.rows, this.cols, List<int> pieces)
    : _pieces = [...pieces];

  final int rows;
  final int cols;
  final List<int> _pieces;

  /// Piece shown at each slot, by index.
  List<int> get pieces => List.unmodifiable(_pieces);

  bool get isSolved {
    for (var i = 0; i < _pieces.length; i++) {
      if (_pieces[i] != i) return false;
    }
    return true;
  }

  void swap(int a, int b) {
    final piece = _pieces[a];
    _pieces[a] = _pieces[b];
    _pieces[b] = piece;
  }
}

class JigsawGame extends StatefulWidget {
  const JigsawGame({
    super.key,
    required this.image,
    required this.rows,
    required this.cols,
    required this.onSolved,
    this.board,
  });

  final String image;
  final int rows;
  final int cols;
  final VoidCallback onSolved;

  /// Starting layout; shuffled when omitted. Tests pass one.
  final JigsawBoard? board;

  @override
  State<JigsawGame> createState() => _JigsawGameState();
}

class _JigsawGameState extends State<JigsawGame> {
  late final JigsawBoard _board =
      widget.board ?? JigsawBoard(widget.rows, widget.cols);
  int? _selected;

  void _tap(int slot) {
    if (_board.isSolved) return;
    final selected = _selected;
    if (selected == null) {
      setState(() => _selected = slot);
      return;
    }
    setState(() {
      if (selected != slot) _board.swap(selected, slot);
      _selected = null;
    });
    if (_board.isSolved) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final solved = _board.isSolved;
    return AspectRatio(
      aspectRatio: widget.cols / widget.rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final tileW = width / widget.cols;
          final tileH = height / widget.rows;
          return Stack(
            children: [
              for (var slot = 0; slot < _board.pieces.length; slot++)
                AnimatedPositioned(
                  key: ValueKey(_board.pieces[slot]),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  left: (slot % widget.cols) * tileW,
                  top: (slot ~/ widget.cols) * tileH,
                  width: tileW,
                  height: tileH,
                  child: GestureDetector(
                    onTap: () => _tap(slot),
                    child: _Piece(
                      image: widget.image,
                      piece: _board.pieces[slot],
                      rows: widget.rows,
                      cols: widget.cols,
                      boardSize: Size(width, height),
                      torn: !solved,
                      selected: _selected == slot,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Piece extends StatelessWidget {
  const _Piece({
    required this.image,
    required this.piece,
    required this.rows,
    required this.cols,
    required this.boardSize,
    required this.torn,
    required this.selected,
  });

  final String image;
  final int piece;
  final int rows;
  final int cols;
  final Size boardSize;
  final bool torn;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final row = piece ~/ cols;
    final col = piece % cols;
    final alignment = Alignment(
      cols == 1 ? 0 : -1 + 2 * col / (cols - 1),
      rows == 1 ? 0 : -1 + 2 * row / (rows - 1),
    );
    Widget content = ClipRect(
      child: OverflowBox(
        maxWidth: boardSize.width,
        maxHeight: boardSize.height,
        alignment: alignment,
        child: Image.asset(
          image,
          width: boardSize.width,
          height: boardSize.height,
          fit: BoxFit.cover,
        ),
      ),
    );
    if (torn) {
      content = Padding(
        padding: const EdgeInsets.all(2),
        child: ClipPath(clipper: _TornClipper(piece), child: content),
      );
      // A slight tilt so pieces look scattered on the table.
      final tilt = (Random(piece * 7919).nextDouble() - 0.5) * 0.08;
      content = Transform.rotate(angle: tilt, child: content);
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        border: selected
            ? Border.all(color: const Color(0xFFFFD60A), width: 3)
            : null,
        boxShadow: torn
            ? const [BoxShadow(color: Color(0x66000000), blurRadius: 6)]
            : null,
      ),
      child: content,
    );
  }
}

/// Ragged edges, the same for a piece every time.
class _TornClipper extends CustomClipper<Path> {
  const _TornClipper(this.seed);

  final int seed;

  @override
  Path getClip(Size size) {
    final rng = Random(seed + 1);
    const steps = 9;
    double jitter(double max) => rng.nextDouble() * max;
    final path = Path()..moveTo(jitter(4), jitter(4));
    for (var i = 1; i <= steps; i++) {
      path.lineTo(size.width * i / steps, jitter(5));
    }
    for (var i = 1; i <= steps; i++) {
      path.lineTo(size.width - jitter(5), size.height * i / steps);
    }
    for (var i = steps - 1; i >= 0; i--) {
      path.lineTo(size.width * i / steps, size.height - jitter(5));
    }
    for (var i = steps - 1; i > 0; i--) {
      path.lineTo(jitter(5), size.height * i / steps);
    }
    return path..close();
  }

  @override
  bool shouldReclip(_TornClipper old) => old.seed != seed;
}

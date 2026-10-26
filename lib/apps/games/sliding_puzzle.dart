import 'package:flutter/material.dart';

import 'puzzle_board.dart';

class SlidingPuzzle extends StatefulWidget {
  const SlidingPuzzle({super.key, this.initialBoard});

  /// Starting board; a shuffled 3×3 board when omitted.
  final PuzzleBoard? initialBoard;

  @override
  State<SlidingPuzzle> createState() => _SlidingPuzzleState();
}

class _SlidingPuzzleState extends State<SlidingPuzzle> {
  late PuzzleBoard _board = widget.initialBoard ?? PuzzleBoard.shuffled();
  int _moves = 0;

  void _shuffle() {
    setState(() {
      _board = PuzzleBoard.shuffled(size: _board.size);
      _moves = 0;
    });
  }

  void _tap(int index) {
    if (_board.isSolved || !_board.move(index)) return;
    setState(() => _moves++);
    if (_board.isSolved) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Solved!'),
          content: Text('You solved the puzzle in $_moves moves.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _shuffle();
              },
              child: const Text('Play again'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _board.tiles;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sliding Puzzle'),
        actions: [
          IconButton(
            onPressed: _shuffle,
            tooltip: 'Shuffle',
            icon: const Icon(Icons.shuffle),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Moves: $_moves',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _board.size,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  if (tile == 0) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5EA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: Material(
                      color: const Color(0xFF0A84FF),
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _tap(index),
                        child: Center(
                          child: Text(
                            '$tile',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

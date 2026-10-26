import 'dart:async';

import 'package:flutter/material.dart';

import 'memory_board.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key, this.initialBoard});

  /// Starting board; 8 shuffled pairs when omitted.
  final MemoryBoard? initialBoard;

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  static const _icons = [
    Icons.search,
    Icons.local_police,
    Icons.fingerprint,
    Icons.vpn_key,
    Icons.pets,
    Icons.coffee,
    Icons.local_phone,
    Icons.description,
  ];

  late MemoryBoard _board = widget.initialBoard ?? _newBoard();
  Timer? _hideTimer;

  MemoryBoard _newBoard() => MemoryBoard.shuffled(_icons.length);

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _restart() {
    _hideTimer?.cancel();
    setState(() => _board = _newBoard());
  }

  void _flip(int index) {
    if (!_board.flip(index)) return;
    setState(() {});
    if (_board.isShowingMismatch) {
      _hideTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) setState(_board.hideOpen);
      });
    } else if (_board.isComplete) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tebrikler!'),
          content: Text('Tüm eşleri ${_board.moves} hamlede buldun.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restart();
              },
              child: const Text('Tekrar oyna'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          IconButton(
            onPressed: _restart,
            tooltip: 'Yeniden başla',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Hamle: ${_board.moves}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _board.cards.length,
                itemBuilder: (context, index) {
                  final faceUp = _board.isFaceUp(index);
                  return Material(
                    color: _board.isMatched(index)
                        ? Colors.teal.shade200
                        : faceUp
                        ? Colors.white
                        : Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _flip(index),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: faceUp
                            ? Icon(
                                _icons[_board.cards[index]],
                                key: ValueKey(index),
                                size: 40,
                                color: Colors.teal.shade900,
                              )
                            : const SizedBox.expand(),
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

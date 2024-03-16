import 'package:flutter/material.dart';


class SlidingPuzzle extends StatefulWidget {
  @override
  _SlidingPuzzleState createState() => _SlidingPuzzleState();
}

class _SlidingPuzzleState extends State<SlidingPuzzle> {
  List<int> puzzleTiles = List.generate(9, (index) => index);

  @override
  void initState() {
    super.initState();
    _shuffleTiles();
  }

  void _shuffleTiles() {
    puzzleTiles.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sliding Puzzle'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: puzzleTiles.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                if (index == puzzleTiles.indexOf(0)) return;
                int emptyTileIndex = puzzleTiles.indexOf(0);
                if (index ~/ 3 == emptyTileIndex ~/ 3 ||
                    index % 3 == emptyTileIndex % 3) {
                  int temp = puzzleTiles[index];
                  puzzleTiles[index] = puzzleTiles[emptyTileIndex];
                  puzzleTiles[emptyTileIndex] = temp;
                }
              });
            },
            child: Container(
              margin: EdgeInsets.all(2),
              color: puzzleTiles[index] == 0 ? Colors.grey : Colors.blue,
              child: Center(
                child: Text(
                  '${puzzleTiles[index] == 0 ? "" : puzzleTiles[index]}',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

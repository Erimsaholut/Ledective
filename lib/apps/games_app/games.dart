import 'package:flutter/material.dart';
import 'package:ledective/apps/games_app/appGames/sliding_puzzle.dart';

import '../../widgets/AppWidget.dart';
import 'appGames/2048.dart';
import 'appGames/roll_dice.dart';

class Games extends StatelessWidget {
  const Games();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Games"),
        backgroundColor: Colors.redAccent,
      ),
      body: GridView.count(
        crossAxisCount: 2, // İki sütunlu bir grid oluşturulacak
mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        padding: EdgeInsets.all(8.0),
        children: [
          AppWidget(
            title: "Sudoku",
            iconData: Icons.color_lens,
            child: SlidingPuzzle(),
          ),
          AppWidget(
            title: "Dice Roll",
            iconData: Icons.add_box_outlined,
            child: RollTheDices(),
          ),
           const AppWidget(
            title: "Memory Game",
            iconData: Icons.grid_on,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}

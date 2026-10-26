import 'package:flutter/material.dart';

import '../../home/app_icon.dart';
import 'memory_game.dart';
import 'roll_dice.dart';
import 'sliding_puzzle.dart';

class GamesApp extends StatelessWidget {
  const GamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Games"),
        backgroundColor: Colors.redAccent,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        padding: const EdgeInsets.all(8.0),
        children: const [
          Center(
            child: AppIcon(
              title: "Puzzle",
              iconData: Icons.extension,
              app: SlidingPuzzle(),
            ),
          ),
          Center(
            child: AppIcon(
              title: "Dice Roll",
              iconData: Icons.casino_outlined,
              app: RollTheDice(),
            ),
          ),
          Center(
            child: AppIcon(
              title: "Memory",
              iconData: Icons.grid_on,
              app: MemoryGame(),
            ),
          ),
        ],
      ),
    );
  }
}

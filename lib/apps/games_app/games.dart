import 'package:flutter/material.dart';

import '../../widgets/AppWidget.dart';

class Games extends StatelessWidget {
  const Games();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Games"),
        backgroundColor: Colors.redAccent,
      ),
      body: const Column(
        children: [
          AppWidget(
              title: "Sudoku", iconData: Icons.color_lens, child: SizedBox()),
          AppWidget(
              title: "Baloon Game",
              iconData: Icons.music_note,
              child: SizedBox()),
          AppWidget(
              title: "Memory Game", iconData: Icons.grid_on, child: SizedBox()),
        ],
      ),
    );
  }
}

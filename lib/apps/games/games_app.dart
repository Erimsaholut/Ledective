import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'memory_game.dart';
import 'roll_dice.dart';
import 'sliding_puzzle.dart';

class GamesApp extends StatelessWidget {
  const GamesApp({super.key});

  static const _games = [
    (
      title: "Sliding Puzzle",
      subtitle: "Taşları sıraya diz",
      icon: Icons.extension_rounded,
      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      game: SlidingPuzzle(),
    ),
    (
      title: "Dice Roll",
      subtitle: "Şansını dene",
      icon: Icons.casino_rounded,
      colors: [Color(0xFFFF6A88), Color(0xFFFF99AC)],
      game: RollTheDice(),
    ),
    (
      title: "Memory Game",
      subtitle: "Eşleri bul",
      icon: Icons.grid_view_rounded,
      colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
      game: MemoryGame(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text("Games")),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: _games.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final game = _games[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (_) => game.game),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 130,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: game.colors),
                          ),
                          child: Icon(game.icon, size: 72, color: Colors.white),
                        ),
                        ListTile(
                          title: Text(
                            game.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Text(game.subtitle),
                          trailing: FilledButton.tonal(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => game.game,
                              ),
                            ),
                            child: const Text("OYNA"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: Text(
              "Daha fazla oyun yakında",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}

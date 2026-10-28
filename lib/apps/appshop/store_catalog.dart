import 'package:flutter/material.dart';

import '../../home/app_icon.dart';
import '../games/sudoku/sudoku_app.dart';

/// A game that can be downloaded from AppShop. Once installed it gets its
/// own icon on the home screen.
class StoreGame {
  const StoreGame({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    required this.app,
    this.glyphColor = Colors.white,
    this.dataKeys = const [],
  });

  /// Saved with the installed games; never change it once released.
  final String id;
  final String title;
  final String description;
  final IconData icon;

  /// Icon gradient, top to bottom.
  final List<Color> colors;
  final Color glyphColor;
  final Widget app;

  /// SharedPreferences keys the game saves to, removed when it's deleted.
  final List<String> dataKeys;

  AppIcon get homeIcon => AppIcon(
    title: title,
    app: app,
    iconData: icon,
    colors: colors,
    glyphColor: glyphColor,
  );
}

/// Everything AppShop offers. Adding a game takes one entry here.
const List<StoreGame> storeGames = [
  StoreGame(
    id: 'sudoku',
    title: "Sudoku",
    description:
        "Klasik sayı bulmacası. Üç zorluk seviyesi, kalem notları ve ipuçları.",
    icon: Icons.grid_3x3_rounded,
    colors: [Color(0xFF5B8DEF), Color(0xFF1F3F9A)],
    app: SudokuApp(),
    dataKeys: [SudokuApp.saveKey],
  ),
];

/// The store games in [ids], in that order; unknown ids are skipped.
List<StoreGame> storeGamesWithIds(Iterable<String> ids) => [
  for (final id in ids) ...storeGames.where((game) => game.id == id),
];

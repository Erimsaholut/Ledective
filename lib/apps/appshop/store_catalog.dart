import 'package:flutter/material.dart';

import '../../home/app_icon.dart';
import '../games/farm/farm_app.dart';
import '../games/space_runner/space_runner_app.dart';
import '../games/sudoku/sudoku_app.dart';
import '../games/word_hunt/word_hunt_app.dart';

/// A game that can be downloaded from AppShop. Once installed it gets its
/// own icon on the home screen.
class StoreGame {
  const StoreGame({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    this.app,
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

  /// The game itself, or null for one not offered in the player's country:
  /// the store lists it but won't download it.
  final Widget? app;

  /// SharedPreferences keys the game saves to, removed when it's deleted.
  final List<String> dataKeys;

  bool get isAvailable => app != null;

  /// The icon of an available game.
  AppIcon get homeIcon => AppIcon(
    title: title,
    app: app!,
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
  StoreGame(
    id: 'farm',
    title: "Bereket Çiftliği",
    description:
        "Tarlanı ek, ürünlerini sat, yeni tarlalar ve aletler al. Ürünler "
        "sen yokken de büyür.",
    icon: Icons.agriculture_rounded,
    colors: [Color(0xFF9BE15D), Color(0xFF2E7D32)],
    app: FarmApp(),
    dataKeys: [FarmApp.saveKey],
  ),
  StoreGame(
    id: 'space-runner',
    title: "Uzay Kaçağı",
    description:
        "Asteroitlerin arasından geç, yakıtın bitmeden galaksiden kaç.",
    icon: Icons.rocket_launch_rounded,
    colors: [Color(0xFF7F5AF0), Color(0xFF16123F)],
    app: SpaceRunnerApp(),
    dataKeys: [SpaceRunnerApp.bestKey],
  ),
  StoreGame(
    id: 'word-hunt',
    title: "Kelime Avı",
    description:
        "Karışık harflerden kelime türet, süre dolmadan en yüksek puanı topla.",
    icon: Icons.abc_rounded,
    colors: [Color(0xFFFFD166), Color(0xFFF77F00)],
    app: WordHuntApp(),
    dataKeys: [WordHuntApp.bestKey],
  ),
  StoreGame(
    id: 'castle-guard',
    title: "Kale Muhafızı",
    description: "Kuleler kur, dalga dalga gelen düşmanlara karşı kaleni koru.",
    icon: Icons.castle_rounded,
    colors: [Color(0xFF8D99AE), Color(0xFF2B2D42)],
  ),
  StoreGame(
    id: 'track-monster',
    title: "Pist Canavarı",
    description: "Arabanı modifiye et, virajlarda drift at, rakiplerini geç.",
    icon: Icons.sports_motorsports_rounded,
    colors: [Color(0xFFFF6B6B), Color(0xFFC0392B)],
  ),
];

/// The store games in [ids], in that order; unknown and unavailable ids
/// are skipped.
List<StoreGame> storeGamesWithIds(Iterable<String> ids) => [
  for (final id in ids)
    ...storeGames.where((game) => game.id == id && game.isAvailable),
];

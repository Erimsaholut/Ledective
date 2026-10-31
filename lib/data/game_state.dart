import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../story/story_data.dart';
import '../story/story_progress.dart';
import 'bank_account.dart';
import 'camera_roll.dart';
import 'game_clock.dart';
import 'installed_games.dart';
import 'private_chats.dart';
import 'recent_calls.dart';
import 'wallpaper.dart';

/// Loads the saved game state into memory. Runs at startup and again after
/// the player resets their progress.
Future<void> loadGameState() async {
  if (StoryData.current.conversations.isEmpty) {
    await StoryData.load(rootBundle.loadString);
  }
  final prefs = await SharedPreferences.getInstance();
  await GameClock.load(prefs);
  WallpaperSetting.load(prefs);
  InstalledGames.load(prefs);
  RecentCalls.load(prefs);
  StoryProgress.instance.load(prefs);
  PrivateChats.instance.load(prefs);
  BankAccount.instance.load(prefs);
  await CameraRoll.instance.load();
}

/// The games from AppShop that are games of their own, with the prefix of
/// their saved data and their AppShop id. Starting the story over can keep
/// them.
const separateGames = [
  (prefix: 'castleGuard.', id: 'castle-guard'),
  (prefix: 'farm.', id: 'farm'),
];

/// Erases all saved progress and starts the game over. With [keepGames]
/// the [separateGames] stay installed and keep their progress.
Future<void> resetGameState({bool keepGames = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final kept = <String, Object>{
    if (keepGames)
      for (final key in prefs.getKeys())
        if (separateGames.any((g) => key.startsWith(g.prefix)))
          key: prefs.get(key)!,
  };
  final installed = [
    if (keepGames)
      for (final g in separateGames)
        if (InstalledGames.isInstalled(g.id)) g.id,
  ];
  await prefs.clear();
  for (final MapEntry(:key, :value) in kept.entries) {
    switch (value) {
      case final String v:
        await prefs.setString(key, v);
      case final int v:
        await prefs.setInt(key, v);
      case final bool v:
        await prefs.setBool(key, v);
      case final double v:
        await prefs.setDouble(key, v);
      case final List<String> v:
        await prefs.setStringList(key, v);
    }
  }
  await CameraRoll.instance.clear();
  await loadGameState();
  for (final id in installed) {
    await InstalledGames.install(id);
  }
}

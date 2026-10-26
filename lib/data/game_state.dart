import 'package:shared_preferences/shared_preferences.dart';

import 'game_clock.dart';
import 'home_colors.dart';
import 'recent_calls.dart';

/// Loads the saved game state into memory. Runs at startup and again after
/// the player resets their progress.
Future<void> loadGameState() async {
  final prefs = await SharedPreferences.getInstance();
  await GameClock.load(prefs);
  HomeColors.load(prefs);
  RecentCalls.load(prefs);
}

/// Erases all saved progress and starts the game over.
Future<void> resetGameState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await loadGameState();
}

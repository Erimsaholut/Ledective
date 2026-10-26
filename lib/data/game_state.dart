import 'package:shared_preferences/shared_preferences.dart';

import '../story/story_progress.dart';
import 'camera_roll.dart';
import 'game_clock.dart';
import 'private_chats.dart';
import 'recent_calls.dart';
import 'wallpaper.dart';

/// Loads the saved game state into memory. Runs at startup and again after
/// the player resets their progress.
Future<void> loadGameState() async {
  final prefs = await SharedPreferences.getInstance();
  await GameClock.load(prefs);
  WallpaperSetting.load(prefs);
  RecentCalls.load(prefs);
  StoryProgress.instance.load(prefs);
  PrivateChats.instance.load(prefs);
  await CameraRoll.instance.load();
}

/// Erases all saved progress and starts the game over.
Future<void> resetGameState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await CameraRoll.instance.clear();
  await loadGameState();
}

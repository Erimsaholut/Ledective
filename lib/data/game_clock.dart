import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the day the game was first opened, so chat history can be
/// shown relative to the player's first session ("3 gün önce").
class GameClock {
  GameClock(DateTime firstOpen)
    : firstOpen = DateTime(firstOpen.year, firstOpen.month, firstOpen.day);

  static const _dayKey = 'firstOpenDay';
  static const _monthKey = 'firstOpenMonth';
  static const _yearKey = 'firstOpenYear';

  /// The clock for the running game. Replaced by [load] at startup.
  static GameClock current = GameClock(DateTime.now());

  final DateTime firstOpen;

  /// Reads the first-open date, storing today's date on the very first run.
  static Future<GameClock> load(SharedPreferences prefs) async {
    final day = prefs.getInt(_dayKey);
    final month = prefs.getInt(_monthKey);
    final year = prefs.getInt(_yearKey);
    if (day != null && month != null && year != null) {
      return current = GameClock(DateTime(year, month, day));
    }

    final now = DateTime.now();
    await prefs.setInt(_dayKey, now.day);
    await prefs.setInt(_monthKey, now.month);
    await prefs.setInt(_yearKey, now.year);
    return current = GameClock(now);
  }

  int daysSinceFirstOpen([DateTime? now]) {
    final today = now ?? DateTime.now();
    // Compare in UTC so a daylight-saving change can't shave off a day.
    final start = DateTime.utc(firstOpen.year, firstOpen.month, firstOpen.day);
    final end = DateTime.utc(today.year, today.month, today.day);
    return end.difference(start).inDays;
  }
}

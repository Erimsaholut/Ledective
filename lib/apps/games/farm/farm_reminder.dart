import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../story/story_progress.dart';
import 'farm_state.dart';

/// Tells the player through the phone's notifications when every field
/// on the farm is ready to harvest, as a real farm game would while it is
/// closed. The time is saved, so it holds across restarts, and goes when
/// the game is deleted or the progress reset.
class FarmReminder {
  FarmReminder._();

  static const saveKey = 'farm.reminder';

  /// The app the notification belongs to and opens.
  static const app = "Bereket Çiftliği";

  /// Whether the farm is on screen; it says so itself then.
  static bool farmOpen = false;

  /// Saves when [farm]'s last growing crop is ready, or clears the
  /// reminder if nothing is growing.
  static Future<void> schedule(FarmState farm, DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final at = farm.allReadyAt(now);
    if (at == null) {
      await prefs.remove(saveKey);
      return;
    }
    final fields = farm.plots.where((p) => !p.isEmpty).length;
    await prefs.setString(
      saveKey,
      json.encode({'at': at.millisecondsSinceEpoch, 'fields': fields}),
    );
  }

  /// Raises the notification once its time has come, unless the farm is
  /// open. Runs on the phone's clock tick.
  static Future<void> tick(AlertQueue alerts, {DateTime? now}) async {
    if (farmOpen) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(saveKey);
    if (saved == null) return;
    final Map<String, dynamic> reminder;
    try {
      reminder = json.decode(saved) as Map<String, dynamic>;
    } on Object {
      await prefs.remove(saveKey);
      return;
    }
    final at = DateTime.fromMillisecondsSinceEpoch(reminder['at'] as int);
    if ((now ?? DateTime.now()).isBefore(at) || farmOpen) return;
    await prefs.remove(saveKey);
    final fields = reminder['fields'] as int? ?? 0;
    alerts.push(
      StoryAlert(
        app: app,
        title: "Hasat zamanı! 🌾",
        body: fields > 1
            ? "$fields tarlanın hepsi hazır. Ürünler seni bekliyor."
            : "Tarlan hazır. Ürünler seni bekliyor.",
      ),
    );
  }
}

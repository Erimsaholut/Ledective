import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ids of the games downloaded from AppShop, in the order they were
/// installed.
class InstalledGames {
  InstalledGames._();

  static const _prefsKey = 'installedGames';

  static final ids = ValueNotifier<List<String>>(const []);

  static void load(SharedPreferences prefs) {
    ids.value = List.unmodifiable(prefs.getStringList(_prefsKey) ?? const []);
  }

  static bool isInstalled(String id) => ids.value.contains(id);

  static Future<void> install(String id) async {
    if (isInstalled(id)) return;
    await _save([...ids.value, id]);
  }

  /// Removes the game and its saved [data] keys, as deleting an app does.
  static Future<void> uninstall(
    String id, {
    Iterable<String> data = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in data) {
      await prefs.remove(key);
    }
    await _save([...ids.value.where((other) => other != id)]);
  }

  static Future<void> _save(List<String> value) async {
    ids.value = List.unmodifiable(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, value);
  }
}

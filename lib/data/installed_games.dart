import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ids of the games downloaded from AppShop, in the order they were
/// installed.
class InstalledGames {
  InstalledGames._();

  static const _prefsKey = 'installedGames';

  static final ids = ValueNotifier<List<String>>(const []);

  /// How long a download takes.
  static const downloadTime = Duration(milliseconds: 1600);

  /// Games being downloaded, with when each began. A download carries on
  /// when the store is closed, as on a real phone.
  static final downloads = ValueNotifier<Map<String, DateTime>>(const {});
  static final Map<String, Timer> _timers = {};

  static void load(SharedPreferences prefs) {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    downloads.value = const {};
    ids.value = List.unmodifiable(prefs.getStringList(_prefsKey) ?? const []);
  }

  static bool isInstalled(String id) => ids.value.contains(id);

  static bool isDownloading(String id) => downloads.value.containsKey(id);

  /// Starts downloading [id]; it is installed when the download is done.
  static void download(String id) {
    if (isInstalled(id) || isDownloading(id)) return;
    _timers[id] = Timer(downloadTime, () async {
      await install(id);
      _endDownload(id);
    });
    downloads.value = Map.unmodifiable({
      ...downloads.value,
      id: DateTime.now(),
    });
  }

  static void cancelDownload(String id) {
    _timers[id]?.cancel();
    _endDownload(id);
  }

  static void _endDownload(String id) {
    _timers.remove(id);
    if (!isDownloading(id)) return;
    downloads.value = Map.unmodifiable({...downloads.value}..remove(id));
  }

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

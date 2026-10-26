import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notes start out with the story notes from the bundled JSON asset. Once the
/// player edits the list it is kept in shared preferences.
class NotesRepository {
  NotesRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const _assetPath = 'assets/apps/notesApp/notesAppNotes.json';
  static const _prefsKey = 'notes';

  final AssetBundle _bundle;

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored =
        prefs.getString(_prefsKey) ?? await _bundle.loadString(_assetPath);
    final data = json.decode(stored) as Map<String, dynamic>;
    return [
      for (final note in data['notes'] as List)
        (note as Map<String, dynamic>)['message'] as String,
    ];
  }

  Future<void> save(List<String> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode({
        'notes': [
          for (final note in notes) {'message': note},
        ],
      }),
    );
  }
}

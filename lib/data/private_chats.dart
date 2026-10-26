import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Messages the player typed to contacts they added themselves. These people
/// aren't part of the story, so they never answer.
class PrivateChats extends ChangeNotifier {
  PrivateChats._();

  static final PrivateChats instance = PrivateChats._();

  static const _prefsKey = 'privateChats';

  final Map<String, List<String>> _messages = {};

  /// Numbers with at least one message, most recently used first.
  List<String> get numbers => _messages.keys.toList().reversed.toList();

  List<String> messagesTo(String number) =>
      List.unmodifiable(_messages[number] ?? const <String>[]);

  void load(SharedPreferences prefs) {
    _messages.clear();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      (json.decode(stored) as Map<String, dynamic>).forEach(
        (number, list) => _messages[number] = (list as List).cast<String>(),
      );
    }
    notifyListeners();
  }

  Future<void> send(String number, String text) async {
    // Re-insert so the chat moves to the top of the list.
    final messages = [...?_messages.remove(number), text];
    _messages[number] = messages;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(_messages));
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contacts_repository.dart';

/// The Phone app's "Recents" list, newest call first.
class RecentCalls {
  RecentCalls._();

  static const _prefsKey = 'recentCalls';

  static const _initialCalls = [
    Contact(name: 'Hayalet', number: '0530303030'),
    Contact(name: 'Harun', number: '0303033003'),
  ];

  static final calls = ValueNotifier<List<Contact>>(_initialCalls);

  static void load(SharedPreferences prefs) {
    final stored = prefs.getString(_prefsKey);
    calls.value = stored == null
        ? _initialCalls
        : [
            for (final item in json.decode(stored) as List)
              Contact.fromJson(item as Map<String, dynamic>),
          ];
  }

  static Future<void> add(Contact call) async {
    calls.value = [call, ...calls.value];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode([for (final c in calls.value) c.toJson()]),
    );
  }
}

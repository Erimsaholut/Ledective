import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contact {
  const Contact({
    required this.name,
    required this.number,
    this.userAdded = false,
  });

  factory Contact.fromJson(
    Map<String, dynamic> json, {
    bool userAdded = false,
  }) => Contact(
    name: json['name'] as String,
    number: json['number'] as String,
    userAdded: userAdded,
  );

  final String name;
  final String number;

  /// Contacts the player added themselves; only these can be deleted.
  final bool userAdded;

  Map<String, dynamic> toJson() => {'name': name, 'number': number};
}

/// Story contacts come from the bundled JSON asset. Contacts the player adds
/// are kept in shared preferences, because assets are read-only at runtime.
class ContactsRepository {
  ContactsRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const _assetPath = 'assets/contacts/contacts.json';
  static const _prefsKey = 'userContacts';

  final AssetBundle _bundle;

  Future<List<Contact>> loadStoryContacts() async {
    final data =
        json.decode(await _bundle.loadString(_assetPath))
            as Map<String, dynamic>;
    return [
      for (final item in data['contacts'] as List)
        Contact.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<List<Contact>> loadAll() async {
    return [...await loadStoryContacts(), ...await _loadUserContacts()];
  }

  Future<void> add(Contact contact) async {
    final contacts = await _loadUserContacts();
    await _saveUserContacts([...contacts, contact]);
  }

  Future<void> remove(Contact contact) async {
    final contacts = await _loadUserContacts();
    contacts.removeWhere(
      (c) => c.name == contact.name && c.number == contact.number,
    );
    await _saveUserContacts(contacts);
  }

  Future<List<Contact>> _loadUserContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == null) return [];
    return [
      for (final item in json.decode(stored) as List)
        Contact.fromJson(item as Map<String, dynamic>, userAdded: true),
    ];
  }

  Future<void> _saveUserContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode([for (final c in contacts) c.toJson()]),
    );
  }
}

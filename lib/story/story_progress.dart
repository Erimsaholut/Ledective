import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'conversations.dart';
import 'dialogue.dart';

export 'story_flags.dart';

/// The player's progress through the story: choices in every conversation,
/// unlocked story flags and personality points. Saved in shared preferences.
class StoryProgress extends ChangeNotifier {
  StoryProgress._();

  static final StoryProgress instance = StoryProgress._();

  static const _prefsKey = 'story';

  final Set<String> _flags = {};
  final Map<String, List<int>> _choices = {};
  final Map<Trait, int> _traits = {};
  final Map<String, int> _seenIncoming = {};
  final Set<String> _seenItems = {};

  bool has(String flag) => _flags.contains(flag);

  int trait(Trait trait) => _traits[trait] ?? 0;

  List<int> choicesFor(String person) =>
      List.unmodifiable(_choices[person] ?? const <int>[]);

  void load(SharedPreferences prefs) {
    _flags.clear();
    _choices.clear();
    _traits.clear();
    _seenIncoming.clear();
    _seenItems.clear();

    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      final data = json.decode(stored) as Map<String, dynamic>;
      _flags.addAll((data['flags'] as List).cast<String>());
      (data['choices'] as Map<String, dynamic>).forEach(
        (person, list) => _choices[person] = (list as List).cast<int>(),
      );
      (data['traits'] as Map<String, dynamic>).forEach((name, value) {
        final trait = Trait.values.where((t) => t.name == name).firstOrNull;
        if (trait != null) _traits[trait] = value as int;
      });
      (data['seen'] as Map<String, dynamic>).forEach(
        (person, count) => _seenIncoming[person] = count as int,
      );
      _seenItems.addAll((data['seenItems'] as List? ?? const []).cast());
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode({
        'flags': _flags.toList(),
        'choices': _choices,
        'traits': {for (final e in _traits.entries) e.key.name: e.value},
        'seen': _seenIncoming,
        'seenItems': _seenItems.toList(),
      }),
    );
  }

  /// A dialogue walker for [person], already advanced to the saved position.
  /// Returns it together with the full transcript so far.
  (DialogueState, List<ChatEntry>) restore(String person) {
    final conversation = conversations[person] ?? const Conversation();
    final state = DialogueState(conversation.dialogue, hasFlag: has);
    final transcript = [
      ...conversation.history,
      ...state.replay(choicesFor(person)),
    ];
    return (state, transcript);
  }

  /// Picks option [index] in [person]'s conversation.
  Future<DialogueOption> choose(
    String person,
    DialogueState state,
    int index,
  ) async {
    final option = state.choose(index);
    (_choices[person] ??= []).add(index);
    for (final t in option.traits) {
      _traits[t] = trait(t) + 1;
    }
    _flags.addAll(option.unlocks);
    notifyListeners();
    await _save();
    return option;
  }

  int _incomingCount(String person) =>
      restore(person).$2.whereType<IncomingMessage>().length;

  int _initialSeen(String person) =>
      (conversations[person]?.history ?? const [])
          .whereType<IncomingMessage>()
          .length;

  /// Messages from [person] the player hasn't read yet.
  int unreadCount(String person) {
    final seen = _seenIncoming[person] ?? _initialSeen(person);
    final unread = _incomingCount(person) - seen;
    return unread < 0 ? 0 : unread;
  }

  int get totalUnread => conversations.keys.map(unreadCount).fold(0, _sum);

  static int _sum(int a, int b) => a + b;

  Future<void> markRead(String person) async {
    final count = _incomingCount(person);
    if (_seenIncoming[person] == count) return;
    _seenIncoming[person] = count;
    notifyListeners();
    await _save();
  }

  /// Whether the player has opened an unlockable item, such as a document.
  bool hasSeen(String item) => _seenItems.contains(item);

  Future<void> markSeen(String item) async {
    if (!_seenItems.add(item)) return;
    notifyListeners();
    await _save();
  }

  /// Questions and answers recorded while the player chatted with
  /// [person], for statements built from an interrogation.
  List<({String question, String answer})> testimonyFrom(String person) {
    final dialogue = conversations[person]?.dialogue;
    if (dialogue == null) return const [];
    final state = DialogueState(dialogue, hasFlag: has)..arrive();
    final records = <({String question, String answer})>[];
    for (final index in choicesFor(person)) {
      if (index < 0 || index >= state.options.length) break;
      final option = state.choose(index);
      state.arrive();
      final answer = option.testimony;
      if (answer != null) {
        records.add((question: option.message, answer: answer));
      }
    }
    return records;
  }
}

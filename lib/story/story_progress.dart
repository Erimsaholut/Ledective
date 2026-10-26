import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dialogue.dart';
import 'story_data.dart';

export 'story_flags.dart';

/// A banner the phone shows when something new arrives.
class StoryAlert {
  const StoryAlert({
    required this.app,
    required this.title,
    required this.body,
  });

  /// Name of the app the news belongs to, e.g. "MatesApp".
  final String app;
  final String title;
  final String body;
}

/// Banners waiting to be shown, oldest first.
class AlertQueue extends ChangeNotifier {
  final List<StoryAlert> _items = [];

  StoryAlert? get current => _items.firstOrNull;

  void push(StoryAlert alert) {
    _items.add(alert);
    notifyListeners();
  }

  /// Drops the banner on screen and moves on to the next one.
  void dismiss() {
    if (_items.isEmpty) return;
    _items.removeAt(0);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// An officer out on a mission, or back from one.
class Mission {
  const Mission({
    required this.taskId,
    required this.officer,
    required this.startedAt,
    required this.endsAt,
  });

  final String taskId;
  final String officer;
  final DateTime startedAt;
  final DateTime endsAt;

  Map<String, Object> toJson() => {
    'officer': officer,
    'start': startedAt.millisecondsSinceEpoch,
    'end': endsAt.millisecondsSinceEpoch,
  };

  static Mission fromJson(String taskId, Map<String, dynamic> json) => Mission(
    taskId: taskId,
    officer: json['officer'] as String,
    startedAt: DateTime.fromMillisecondsSinceEpoch(json['start'] as int),
    endsAt: DateTime.fromMillisecondsSinceEpoch(json['end'] as int),
  );
}

/// The player's progress through the story: choices in every conversation,
/// unlocked story flags, missions, lab results and personality points.
/// Saved in shared preferences.
class StoryProgress extends ChangeNotifier {
  StoryProgress._();

  static final StoryProgress instance = StoryProgress._();

  static const _prefsKey = 'story';

  /// Banners for things that just arrived.
  final alerts = AlertQueue();

  final Set<String> _flags = {};
  final Map<String, List<int>> _choices = {};
  final Map<Trait, int> _traits = {};
  final Map<String, int> _seenIncoming = {};
  final Set<String> _seenItems = {};
  final Map<String, Mission> _activeMissions = {};
  final Map<String, Mission> _finishedMissions = {};
  final Set<String> _inspected = {};

  /// Divides mission durations, so story writers can test quickly.
  bool fastMissions = false;

  StoryData get _story => StoryData.current;

  bool has(String flag) => _flags.contains(flag);

  bool meets(Condition condition) => condition.isMetBy(has);

  int trait(Trait trait) => _traits[trait] ?? 0;

  List<int> choicesFor(String person) =>
      List.unmodifiable(_choices[person] ?? const <int>[]);

  void load(SharedPreferences prefs) {
    _flags.clear();
    _choices.clear();
    _traits.clear();
    _seenIncoming.clear();
    _seenItems.clear();
    _activeMissions.clear();
    _finishedMissions.clear();
    _inspected.clear();
    alerts.clear();
    fastMissions = prefs.getBool('fastMissions') ?? false;

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
      (data['missions'] as Map<String, dynamic>? ?? const {}).forEach(
        (id, m) => _activeMissions[id] = Mission.fromJson(
          id,
          m as Map<String, dynamic>,
        ),
      );
      (data['reports'] as Map<String, dynamic>? ?? const {}).forEach(
        (id, m) => _finishedMissions[id] = Mission.fromJson(
          id,
          m as Map<String, dynamic>,
        ),
      );
      _inspected.addAll((data['inspected'] as List? ?? const []).cast());
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
        'missions': {
          for (final m in _activeMissions.values) m.taskId: m.toJson(),
        },
        'reports': {
          for (final m in _finishedMissions.values) m.taskId: m.toJson(),
        },
        'inspected': _inspected.toList(),
      }),
    );
  }

  Future<void> setFastMissions(bool value) async {
    fastMissions = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fastMissions', value);
  }

  /* ---------- Unlocking and alerts ---------- */

  /// What the player can currently see, to spot what a change delivered.
  Map<String, Set<String>> _snapshot() => {
    'chat': {
      for (final person in _story.conversations.keys)
        for (var i = 0; i < unreadCount(person); i++) '$person#$i',
    },
    'poltel': {
      for (final d in _story.documents)
        if (meets(d.requires)) d.id,
    },
    'evidence': {
      for (final e in _story.evidence)
        if (meets(e.requires)) e.id,
    },
    'map': {
      for (final l in _story.map.locations)
        if (meets(l.requires)) l.id,
    },
    'sms': {
      for (final t in _story.smsThreads)
        if (meets(t.requires)) t.sender,
    },
    'mail': {
      for (final m in _story.storyMails)
        if (meets(m.requires)) m.id,
    },
    'bank': {
      for (final t in _story.bank.transactions)
        if (meets(t.requires)) t.id,
    },
    'voice': {
      for (final r in _story.recordings)
        if (meets(r.requires)) r.id,
    },
  };

  /// Sets [flags] and raises a banner for everything that arrives because
  /// of them. Chats with [except] don't raise one (the player is in it).
  void _unlock(Iterable<String> flags, {String? except}) {
    final before = _snapshot();
    _flags.addAll(flags);
    final after = _snapshot();
    for (final MapEntry(key: kind, value: items) in after.entries) {
      for (final item in items.difference(before[kind]!)) {
        final alert = _alertFor(kind, item, except);
        if (alert != null) alerts.push(alert);
      }
    }
  }

  StoryAlert? _alertFor(String kind, String item, String? except) {
    switch (kind) {
      case 'chat':
        final person = item.split('#').first;
        if (person == except) return null;
        final last = restore(person).$2.whereType<IncomingMessage>().lastOrNull;
        return StoryAlert(
          app: 'MatesApp',
          title: person,
          body: last?.text ?? '',
        );
      case 'poltel':
        final d = _story.documents.firstWhere((d) => d.id == item);
        return StoryAlert(app: 'Poltel', title: 'Yeni belge', body: d.title);
      case 'evidence':
        final e = _story.evidence.firstWhere((e) => e.id == item);
        return StoryAlert(
          app: 'Delil Panosu',
          title: 'Yeni delil',
          body: e.name,
        );
      case 'map':
        final l = _story.map.locations.firstWhere((l) => l.id == item);
        return StoryAlert(app: 'Harita', title: 'Yeni konum', body: l.name);
      case 'sms':
        final t = _story.smsThreads.firstWhere((t) => t.sender == item);
        return StoryAlert(
          app: 'Messages',
          title: t.sender,
          body: t.messages.last,
        );
      case 'mail':
        final m = _story.storyMails.firstWhere((m) => m.id == item);
        return StoryAlert(app: 'Mail', title: m.sender, body: m.body);
      case 'bank':
        final t = _story.bank.transactions.firstWhere((t) => t.id == item);
        return StoryAlert(
          app: _story.bank.bank,
          title: t.title,
          body: t.detail,
        );
      case 'voice':
        final r = _story.recordings.firstWhere((r) => r.id == item);
        return StoryAlert(
          app: 'Kayıtlar',
          title: r.kind == RecordingKind.voicemail
              ? 'Yeni sesli mesaj'
              : 'Yeni kayıt',
          body: r.from,
        );
    }
    return null;
  }

  /// Sets flags discovered outside conversations, e.g. by opening a
  /// Sinstagram profile.
  Future<void> discover(Iterable<String> flags) async {
    if (flags.every(has)) return;
    _unlock(flags);
    notifyListeners();
    await _save();
  }

  /* ---------- Conversations ---------- */

  /// A dialogue walker for [person], already advanced to the saved position.
  /// Returns it together with the full transcript so far.
  (DialogueState, List<ChatEntry>) restore(String person) {
    final conversation = _story.conversations[person] ?? const Conversation();
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
    _unlock(option.unlocks, except: person);
    notifyListeners();
    await _save();
    return option;
  }

  int _incomingCount(String person) =>
      restore(person).$2.whereType<IncomingMessage>().length;

  int _initialSeen(String person) =>
      (_story.conversations[person]?.history ?? const [])
          .whereType<IncomingMessage>()
          .length;

  /// Messages from [person] the player hasn't read yet.
  int unreadCount(String person) {
    final seen = _seenIncoming[person] ?? _initialSeen(person);
    final unread = _incomingCount(person) - seen;
    return unread < 0 ? 0 : unread;
  }

  int get totalUnread =>
      _story.conversations.keys.map(unreadCount).fold(0, _sum);

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
    final dialogue = _story.conversations[person]?.dialogue;
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

  /* ---------- Missions ---------- */

  Mission? activeMission(String taskId) => _activeMissions[taskId];

  Mission? finishedMission(String taskId) => _finishedMissions[taskId];

  /// Finished missions, newest first.
  List<Mission> get reports =>
      _finishedMissions.values.toList()
        ..sort((a, b) => b.endsAt.compareTo(a.endsAt));

  List<Mission> get activeMissions => _activeMissions.values.toList();

  /// The mission [officer] is out on, if any.
  Mission? missionOf(String officer) =>
      _activeMissions.values.where((m) => m.officer == officer).firstOrNull;

  int get unreadReports =>
      reports.where((m) => !hasSeen('report:${m.taskId}')).length;

  /// How long [task] takes right now, with [fastMissions] taken into account.
  Duration durationOf(MissionTask task) =>
      fastMissions ? task.duration ~/ 30 : task.duration;

  /// Sends [officer] to do [task]. Returns false if they're busy or the
  /// task was already done or started.
  Future<bool> startMission(
    MissionTask task,
    String officer, {
    DateTime? now,
  }) async {
    if (missionOf(officer) != null ||
        _activeMissions.containsKey(task.id) ||
        _finishedMissions.containsKey(task.id)) {
      return false;
    }
    final start = now ?? DateTime.now();
    final duration = durationOf(task);
    _activeMissions[task.id] = Mission(
      taskId: task.id,
      officer: officer,
      startedAt: start,
      endsAt: start.add(duration),
    );
    notifyListeners();
    await _save();
    return true;
  }

  /// Completes every mission whose time is up. Called regularly while the
  /// game runs.
  Future<void> completeDueMissions({DateTime? now}) async {
    final time = now ?? DateTime.now();
    final due = _activeMissions.values.where((m) => !m.endsAt.isAfter(time));
    if (due.isEmpty) return;
    for (final mission in due.toList()) {
      _activeMissions.remove(mission.taskId);
      _finishedMissions[mission.taskId] = mission;
      final task = _story.map.task(mission.taskId);
      final location = _story.map.locationOf(mission.taskId);
      alerts.push(
        StoryAlert(
          app: 'Harita',
          title: '${mission.officer} · ${location?.name ?? ''}',
          body: task?.report ?? 'Görev tamamlandı.',
        ),
      );
      if (task != null) _unlock(task.unlocks);
    }
    notifyListeners();
    await _save();
  }

  /* ---------- Evidence ---------- */

  bool isInspected(String evidenceId) => _inspected.contains(evidenceId);

  /// Records a solved lab minigame and its findings.
  Future<void> completeInspection(Evidence evidence) async {
    if (!_inspected.add(evidence.id)) return;
    _unlock(evidence.inspection?.unlocks ?? const []);
    notifyListeners();
    await _save();
  }
}

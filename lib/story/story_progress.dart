import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/game_clock.dart';
import 'dialogue.dart';
import 'news_feed.dart';
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
/// unlocked story flags and numbers, missions, timers, lab results and
/// personality points. Saved in shared preferences.
class StoryProgress extends ChangeNotifier implements StoryState {
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
  final Map<String, int> _values = {};

  /// Play time each started timer has run for, in milliseconds.
  final Map<String, int> _timers = {};
  final Set<String> _timersDone = {};
  DateTime? _lastTick;

  /// When each story article reached the feed.
  final Map<String, DateTime> _newsArrivals = {};

  /// Scheduled and everyday news already in the feed, so only new ones
  /// raise a banner. Null until the first tick.
  Set<String>? _newsOnTick;

  /// Divides mission durations, so story writers can test quickly.
  bool fastMissions = false;

  StoryData get _story => StoryData.current;

  @override
  bool has(String flag) => _flags.contains(flag);

  /// A number from `state.json`, a trait (`trait:merhamet`) or the money
  /// sent to a payee (`paid:<id>`, in lira).
  @override
  int value(String stat) {
    if (stat.startsWith('trait:')) {
      final name = stat.substring(6).toLowerCase();
      final t = Trait.values.where(
        (t) => t.name == name || t.label.toLowerCase() == name,
      );
      return t.isEmpty ? 0 : trait(t.first);
    }
    return _values[stat] ?? _story.state.stats[stat]?.start ?? 0;
  }

  bool meets(Condition condition) => condition.isMetBy(this);

  /// The lock that keeps [app] closed right now, if any.
  AppLock? lockOf(String app) => _story.state.locks
      .where((l) => l.app == app && meets(l.lockedWhen))
      .firstOrNull;

  /// True once the conditions in `endings.json` hold.
  bool get isOver =>
      _story.endings.sections.isNotEmpty && meets(_story.endings.requires);

  /// How [section] of the ending turns out for this player.
  EndingVariant? ending(EndingSection section) =>
      section.variants.where((v) => meets(v.requires)).firstOrNull;

  /// Every flag set so far, for the story writer's debug page.
  Set<String> get flags => Set.unmodifiable(_flags);

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
    _values.clear();
    _timers.clear();
    _timersDone.clear();
    _lastTick = null;
    _newsArrivals.clear();
    _newsOnTick = null;
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
      _values.addAll((data['values'] as Map? ?? const {}).cast());
      _timers.addAll((data['timers'] as Map? ?? const {}).cast());
      _timersDone.addAll((data['timersDone'] as List? ?? const []).cast());
      (data['news'] as Map<String, dynamic>? ?? const {}).forEach(
        (id, time) => _newsArrivals[id] = DateTime.fromMillisecondsSinceEpoch(
          time as int,
        ),
      );
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
        'values': _values,
        'timers': _timers,
        'timersDone': _timersDone.toList(),
        'news': {
          for (final e in _newsArrivals.entries)
            e.key: e.value.millisecondsSinceEpoch,
        },
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
    // Scheduled news arrives with time, see [_announceNews].
    'news': {
      for (final a in _story.news.articles)
        if (!a.archive && a.dayOffset == null && meets(a.requires)) a.id,
    },
  };

  /// The News feed right now, newest first.
  List<NewsItem> newsFeedAt([DateTime? now]) => newsFeed(
    _story.news,
    firstOpen: GameClock.current.firstOpen,
    now: now ?? DateTime.now(),
    meets: meets,
    arrivedAt: (id) => _newsArrivals[id],
  );

  /// Raises a banner for scheduled and everyday news that came out since
  /// the last tick. Returns whether any did.
  bool _announceNews(DateTime now) {
    final items = {
      for (final item in newsFeedAt(now))
        if (item.article.dayOffset != null ||
            _story.news.filler.articles.contains(item.article))
          item.key: item,
    };
    final before = _newsOnTick;
    _newsOnTick = items.keys.toSet();
    if (before == null) return false;
    var arrived = false;
    for (final item in items.values) {
      if (before.contains(item.key)) continue;
      arrived = true;
      alerts.push(
        StoryAlert(
          app: _story.news.outlet(item.article.outlet).name,
          title: 'Gündem',
          body: item.article.title,
        ),
      );
    }
    return arrived;
  }

  /// Applies [effects] (see [Effect]) and raises a banner for everything
  /// that arrives because of them. Chats with [except] don't raise one (the
  /// player is in it). Returns whether anything changed.
  bool _apply(Iterable<String> effects, {String? except}) {
    final before = _snapshot();
    var changed = false;
    for (final term in effects) {
      switch (Effect.parse(term)) {
        case SetFlag(:final flag):
          changed |= _flags.add(flag);
        case ClearFlag(:final flag):
          changed |= _flags.remove(flag);
        case ChangeStat(:final stat, :final delta):
          changed |= _setValue(stat, value(stat) + delta);
        case SetStat(:final stat, value: final v):
          changed |= _setValue(stat, v);
      }
    }
    if (!changed) return false;
    _startTimers();
    _fireEvents();
    final after = _snapshot();
    for (final MapEntry(key: kind, value: items) in after.entries) {
      for (final item in items.difference(before[kind]!)) {
        if (kind == 'news') _newsArrivals[item] = DateTime.now();
        final alert = _alertFor(kind, item, except);
        if (alert != null) alerts.push(alert);
      }
    }
    return true;
  }

  bool _setValue(String stat, int v) {
    final clamped = _story.state.stats[stat]?.clamp(v) ?? v;
    if (value(stat) == clamped) return false;
    _values[stat] = clamped;
    return true;
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
      case 'news':
        final a = _story.news.articles.firstWhere((a) => a.id == item);
        return StoryAlert(
          app: _story.news.outlet(a.outlet).name,
          title: 'Son dakika',
          body: a.title,
        );
    }
    return null;
  }

  /// Applies effects discovered outside conversations, e.g. by opening a
  /// Sinstagram profile.
  Future<void> discover(Iterable<String> effects) async {
    if (!_apply(effects)) return;
    notifyListeners();
    await _save();
  }

  /* ---------- Conversations ---------- */

  /// A dialogue walker for [person], already advanced to the saved position.
  /// Returns it together with the full transcript so far.
  (DialogueState, List<ChatEntry>) restore(String person) {
    final conversation = _story.conversations[person] ?? const Conversation();
    final state = DialogueState(conversation.dialogue, state: this);
    final transcript = [
      ...conversation.history,
      ...state.replay(choicesFor(person)),
    ];
    return (state, transcript);
  }

  /// Lets conversations whose events are ready move on by themselves.
  void _fireEvents() {
    for (final person in _story.conversations.keys) {
      final (state, _) = restore(person);
      // A chain of events can't loop forever: each fires once per node.
      for (var i = 0; i < 50 && state.fireEvent(); i++) {
        (_choices[person] ??= []).add(state.choices.last);
      }
    }
  }

  /// Picks option [index] in [person]'s conversation.
  Future<DialogueOption> choose(
    String person,
    DialogueState state,
    int index,
  ) async {
    final option = state.choose(index);
    (_choices[person] ??= []).add(state.choices.last);
    for (final t in option.traits) {
      _traits[t] = trait(t) + 1;
    }
    // The option may lead straight to a node whose event is ready.
    if (!_apply(option.unlocks, except: person)) _fireEvents();
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
    final records = <({String question, String answer})>[];
    DialogueState(dialogue, state: this).replay(
      choicesFor(person),
      onChoice: (option) {
        final answer = option.testimony;
        if (answer != null) {
          records.add((question: option.message, answer: answer));
        }
      },
    );
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
      if (task != null) _apply(task.unlocks);
    }
    notifyListeners();
    await _save();
  }

  /* ---------- Evidence ---------- */

  bool isInspected(String evidenceId) => _inspected.contains(evidenceId);

  /// Records a solved lab minigame and its findings.
  Future<void> completeInspection(Evidence evidence) async {
    if (!_inspected.add(evidence.id)) return;
    _apply(evidence.inspection?.unlocks ?? const []);
    notifyListeners();
    await _save();
  }

  /* ---------- Money ---------- */

  /// Records [amount] kuruş sent to [payee] (the bank has already taken
  /// it). Adds to `paid:<id>` and applies the payee's effects if the
  /// amount is enough.
  Future<void> recordTransfer(Payee payee, int amount) async {
    final key = 'paid:${payee.id}';
    _values[key] = value(key) + amount ~/ 100;
    _apply([
      if (amount >= payee.minAmount) ...payee.unlocks,
      'sent:${payee.id}',
    ]);
    notifyListeners();
    await _save();
  }

  /* ---------- Timers ---------- */

  /// Starts timers whose condition just started holding.
  void _startTimers() {
    for (final t in _story.state.timers) {
      if (!_timers.containsKey(t.id) &&
          !_timersDone.contains(t.id) &&
          meets(t.when)) {
        _timers[t.id] = 0;
      }
    }
  }

  /// How long [timer] runs right now, with [fastMissions] taken into
  /// account.
  Duration timerDuration(StoryTimer timer) =>
      fastMissions ? timer.duration ~/ 30 : timer.duration;

  /// Ids of the timers that are running.
  Iterable<String> get runningTimers => _timers.keys;

  /// Play time left on [timerId], or null if it isn't running.
  Duration? timeLeft(String timerId) {
    final elapsed = _timers[timerId];
    final timer = _story.state.timers.where((t) => t.id == timerId).firstOrNull;
    if (elapsed == null || timer == null) return null;
    return timerDuration(timer) - Duration(milliseconds: elapsed);
  }

  /// Moves running timers on by [elapsed] play time and fires the ones that
  /// are due.
  Future<void> advanceTimers(Duration elapsed) async {
    _startTimers();
    if (_timers.isEmpty) return;
    for (final t in _story.state.timers) {
      final ran = _timers[t.id];
      if (ran == null) continue;
      if (!t.unless.isAlways && meets(t.unless)) {
        _timers.remove(t.id);
        _timersDone.add(t.id);
        continue;
      }
      final now = ran + elapsed.inMilliseconds;
      if (now < timerDuration(t).inMilliseconds) {
        _timers[t.id] = now;
        continue;
      }
      _timers.remove(t.id);
      _timersDone.add(t.id);
      final alert = t.alert;
      if (alert != null) {
        alerts.push(
          StoryAlert(app: alert.app, title: alert.title, body: alert.body),
        );
      }
      _apply(t.unlocks);
    }
    notifyListeners();
    await _save();
  }

  /// Called regularly while the game runs: brings officers back and moves
  /// timers on. Timers only count play time, so a gap longer than a few
  /// seconds (the phone was asleep) counts as one tick.
  Future<void> tick({DateTime? now}) async {
    final time = now ?? DateTime.now();
    await completeDueMissions(now: time);
    if (_announceNews(time)) notifyListeners();
    final last = _lastTick;
    _lastTick = time;
    if (last == null) return;
    var elapsed = time.difference(last);
    if (elapsed.isNegative) return;
    if (elapsed > const Duration(seconds: 10)) {
      elapsed = const Duration(seconds: 2);
    }
    await advanceTimers(elapsed);
  }
}

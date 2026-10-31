import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/game_clock.dart';
import '../theme/turkish_text.dart';
import 'breakdown.dart';
import 'demo.dart';
import 'dialogue.dart';
import 'drip_feed.dart';
import 'news_feed.dart';
import 'story_data.dart';

export 'story_flags.dart';

/// A notification the phone shows when something new arrives.
class StoryAlert {
  StoryAlert({
    required this.app,
    required this.title,
    required this.body,
    String? source,
    this.thread,
    DateTime? time,
  }) : source = source ?? app,
       time = time ?? DateTime.now();

  /// The home screen app it opens, e.g. "MatesApp".
  final String app;

  /// The name in the header, e.g. the paper for a news alert.
  final String source;
  final String title;
  final String body;

  /// What it opens inside [app], such as the chat with a person.
  final String? thread;
  final DateTime time;

  /// Notifications of the same group stack together, e.g. one person's
  /// messages.
  String get group => '$app|${thread ?? title}';
}

/// The phone's notifications, oldest first. The banner shows the fresh
/// ones; the notification centre lists them all until they're cleared.
class AlertQueue extends ChangeNotifier {
  static const _limit = 80;

  final List<StoryAlert> _items = [];
  final List<StoryAlert> _fresh = [];

  /// Time between notifications that come together, so a burst arrives
  /// one app after another, as on a phone. Null shows them all at once;
  /// the app sets it.
  Duration? spacing;

  /// Notifications waiting for their turn, see [spacing].
  final List<StoryAlert> _waiting = [];
  DateTime? _nextAt;

  List<StoryAlert> get items => List.unmodifiable(_items);

  StoryAlert? get latest => _items.lastOrNull;

  void push(StoryAlert alert) => pushAll([alert]);

  void pushAll(Iterable<StoryAlert> alerts) {
    if (spacing == null) {
      _show(alerts.toList());
      return;
    }
    _waiting.addAll(alerts);
    release();
  }

  /// Shows the next waiting notifications, all of the same app, if their
  /// turn has come. Called regularly while the game runs.
  void release([DateTime? now]) {
    final gap = spacing;
    if (_waiting.isEmpty || gap == null) return;
    final time = now ?? DateTime.now();
    if (_nextAt case final next? when time.isBefore(next)) return;
    final app = _waiting.first.app;
    final batch = [
      for (final alert in _waiting)
        if (alert.app == app) alert,
    ];
    _waiting.removeWhere((alert) => alert.app == app);
    _nextAt = time.add(gap);
    _show(batch);
  }

  void _show(List<StoryAlert> alerts) {
    for (final alert in alerts) {
      _items.add(alert);
      _fresh.add(alert);
    }
    while (_items.length > _limit) {
      _items.removeAt(0);
    }
    if (alerts.isNotEmpty) notifyListeners();
  }

  /// Notifications that came since the banner last took them.
  List<StoryAlert> takeFresh() {
    final fresh = List.of(_fresh);
    _fresh.clear();
    return fresh;
  }

  void remove(StoryAlert alert) => _removeWhere((a) => identical(a, alert));

  /// Clears [app]'s notifications, e.g. once the player opens it.
  void clearApp(String app) => _removeWhere((a) => a.app == app);

  void clearGroup(String group) => _removeWhere((a) => a.group == group);

  void clear() => _removeWhere((_) => true);

  void _removeWhere(bool Function(StoryAlert alert) test) {
    final before = _items.length + _fresh.length;
    _items.removeWhere(test);
    _fresh.removeWhere(test);
    // Waiting ones go too: opening an app answers them.
    _waiting.removeWhere(test);
    if (_items.length + _fresh.length != before) notifyListeners();
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

  /// When each story mail reached the inbox.
  final Map<String, DateTime> _mailArrivals = {};

  /// Scheduled news already in the feed, so only new ones raise a banner.
  /// Null until the first tick.
  Set<String>? _newsOnTick;

  /// Play time so far, in milliseconds.
  int _playMs = 0;

  /// Play time mails and articles with `afterMinutes` have waited since
  /// their condition started holding, and the ones that are done waiting.
  final Map<String, int> _waiting = {};
  final Set<String> _waited = {};

  /// Everyday mail and news.
  final DripFeed _mailDrip = DripFeed();
  final DripFeed _newsDrip = DripFeed();

  /// Play time, in milliseconds, at which the hidden ending's breakdown
  /// began, and what of it has happened.
  int? _breakdownFrom;
  final Set<String> _breakdownDone = {};

  /// Divides mission durations, so story writers can test quickly.
  bool fastMissions = false;

  /// How fast play time passes for missions, timers and everyday mail and
  /// news, as the player picks in Settings › Tempo: 1, 2 or 3.
  int tempo = demoBuild ? 2 : 1;

  /// What durations are divided by right now.
  int get speed => fastMissions ? 30 : tempo;

  /// Whether hints (state.json › `hints`) raise alerts.
  bool hintsOn = true;

  /// Whether messages that arrive together show up one at a time, a few
  /// seconds apart, each with its own banner. The app turns this on; tests
  /// see every message at once unless they ask.
  bool paceMessages = false;

  /// The chat on screen, which paces its own messages.
  String? openChat;

  /// For chats whose new messages are still coming in: how many of the
  /// other person's messages show so far, and when the next one does.
  final Map<String, int> _shown = {};
  final Map<String, DateTime> _nextMessage = {};

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
      _story.endings.sections.isNotEmpty &&
      meets(_story.endings.requires) &&
      // The hidden ending waits for the phone to finish falling apart.
      !(breakingDown && !has(_story.endings.secret!.endsWith));

  /// Whether the hidden ending has begun (endings.json › `secret`).
  bool get breakingDown {
    final secret = _story.endings.secret;
    return secret != null && meets(secret.requires);
  }

  /// How far the phone has fallen apart, or null outside the hidden
  /// ending.
  Breakdown? get breakdown => breakingDown
      ? Breakdown(Duration(milliseconds: _playMs - (_breakdownFrom ?? _playMs)))
      : null;

  /// Moves the hidden ending's breakdown on. Returns whether it is under
  /// way, so the apps redraw.
  bool _advanceBreakdown() {
    if (!breakingDown) return false;
    _breakdownFrom ??= _playMs;
    final b = breakdown!;
    if (b.madMails > 0 && _breakdownDone.add('mail')) {
      alerts.pushAll([
        for (var i = 0; i < 4; i++)
          StoryAlert(
            app: 'Mail',
            title: Breakdown.madLine,
            body: List.filled(3, Breakdown.madLine).join(' '),
          ),
      ]);
    }
    if (b.finale && _breakdownDone.add('finale')) {
      _apply([_story.endings.secret!.finale]);
    }
    return true;
  }

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
    _shown.clear();
    _nextMessage.clear();
    _lastTick = null;
    _newsArrivals.clear();
    _mailArrivals.clear();
    _newsOnTick = null;
    _playMs = 0;
    _waiting.clear();
    _waited.clear();
    _mailDrip.clear();
    _newsDrip.clear();
    _breakdownFrom = null;
    _breakdownDone.clear();
    alerts.clear();
    fastMissions = prefs.getBool('fastMissions') ?? false;
    tempo = prefs.getInt('tempo') ?? tempo;
    hintsOn = prefs.getBool('hints') ?? true;

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
      (data['mail'] as Map<String, dynamic>? ?? const {}).forEach(
        (id, time) => _mailArrivals[id] = DateTime.fromMillisecondsSinceEpoch(
          time as int,
        ),
      );
      _playMs = data['play'] as int? ?? 0;
      _waiting.addAll((data['waiting'] as Map? ?? const {}).cast());
      _waited.addAll((data['waited'] as List? ?? const []).cast());
      _mailDrip.load(data['mailDrip'] as Map<String, dynamic>?);
      _newsDrip.load(data['newsDrip'] as Map<String, dynamic>?);
      _breakdownFrom = data['breakdown'] as int?;
      _breakdownDone.addAll(
        (data['breakdownDone'] as List? ?? const []).cast(),
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
        'mail': {
          for (final e in _mailArrivals.entries)
            e.key: e.value.millisecondsSinceEpoch,
        },
        'play': _playMs,
        'waiting': _waiting,
        'waited': _waited.toList(),
        'mailDrip': _mailDrip.toJson(),
        'breakdown': _breakdownFrom,
        'breakdownDone': _breakdownDone.toList(),
        'newsDrip': _newsDrip.toJson(),
      }),
    );
  }

  Future<void> setFastMissions(bool value) async {
    fastMissions = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fastMissions', value);
  }

  Future<void> setTempo(int value) async {
    tempo = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tempo', value);
  }

  Future<void> setHints(bool value) async {
    hintsOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hints', value);
  }

  /* ---------- Unlocking and alerts ---------- */

  /// What the player can currently see, to spot what a change delivered.
  Map<String, Set<String>> _snapshot() => {
    'chat': {
      for (final person in _story.conversations.keys)
        for (var i = 0; i < _incomingCount(person); i++) '$person#$i',
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
    'mail': {for (final (m, _) in inbox) m.id},
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
        if (!a.archive && a.dayOffset == null && _isReady(a)) a.id,
      for (final d in _newsDrip.drops) d.key,
    },
  };

  /// Whether an article's condition holds and its `afterMinutes` are up.
  bool _isReady(Article a) => _hasArrived('news:${a.id}', a.requires, a.after);

  bool _hasArrived(String key, Condition requires, Duration after) =>
      meets(requires) && (after <= Duration.zero || _waited.contains(key));

  Mail? _poolMail(String id) =>
      _story.mailPool.mails.where((m) => m.id == id).firstOrNull;

  Article? _fillerArticle(String id) =>
      _story.news.filler.articles.where((a) => a.id == id).firstOrNull;

  /// Whether [mail] belongs to the story and so never goes to Spam: story
  /// mail, and everyday mail that waits for an event or leaves a trace.
  bool isCanonMail(Mail mail) =>
      _story.storyMails.contains(mail) ||
      !mail.requires.isAlways ||
      mail.unlocksOnView.isNotEmpty;

  /// Arrived mail the phone files under Spam, newest first: scams right
  /// away, and everyday mail the player has read once [MailPool.keepRead]
  /// newer everyday mails came after it. Mail the player marked "Spam
  /// değil" stays in the inbox.
  List<(Mail, DateTime)> get spam {
    final keep = _story.mailPool.keepRead;
    var newer = 0;
    final filed = <(Mail, DateTime)>[];
    for (final entry in inbox) {
      final mail = entry.$1;
      if (hasSeen('notspam:${mail.id}') || isCanonMail(mail)) continue;
      if (mail.spam) {
        filed.add(entry);
      } else if (newer++ >= keep && hasSeen('mail:${mail.id}')) {
        filed.add(entry);
      }
    }
    return filed;
  }

  /// Arrived mail outside Spam, newest first.
  List<(Mail, DateTime)> get inboxFolder {
    final filed = {for (final (m, _) in spam) m.id};
    return [
      for (final entry in inbox)
        if (!filed.contains(entry.$1.id)) entry,
    ];
  }

  /// Mail that has arrived, newest first, with the time it came.
  List<(Mail, DateTime)> get inbox {
    final firstOpen = GameClock.current.firstOpen;
    final mails = <(Mail, DateTime)>[
      for (final m in _story.storyMails)
        if (_hasArrived('mail:${m.id}', m.requires, m.after))
          (m, _mailArrivals[m.id] ?? firstOpen),
      for (final d in _mailDrip.drops)
        if (_poolMail(d.id) case final m?) (m, d.at),
    ];
    return mails..sort((a, b) => b.$2.compareTo(a.$2));
  }

  /// The News feed right now, newest first.
  List<NewsItem> newsFeedAt([DateTime? now]) => newsFeed(
    _story.news,
    firstOpen: GameClock.current.firstOpen,
    now: now ?? DateTime.now(),
    meets: meets,
    ready: _isReady,
    arrivedAt: (id) => _newsArrivals[id],
    filler: _everydayNews,
    read: (item) => hasSeen('news:${item.key}'),
  );

  List<NewsItem> get _everydayNews => [
    for (final d in _newsDrip.drops)
      if (_fillerArticle(d.id) case final a?) NewsItem(a, d.at, run: d.run),
  ];

  /// Everyday news that has left the feed, newest first, for the archive.
  List<NewsItem> get archivedNews => oldNews(_everydayNews, newsFeedAt());

  /// Raises a banner for scheduled news that came out since the last tick.
  /// Returns whether any did.
  bool _announceNews(DateTime now) {
    final items = {
      for (final item in newsFeedAt(now))
        if (item.article.dayOffset != null) item.key: item,
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
          app: 'News',
          source: _story.news.outlet(item.article.outlet).name,
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
  bool _apply(Iterable<String> effects, {String? except}) => _announce(() {
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
    if (changed) {
      _startTimers();
      _fireEvents();
    }
    return changed;
  }, except: except);

  /// Runs [change] and raises a banner for everything that arrives because
  /// of it. Returns what [change] returned: whether anything changed.
  bool _announce(bool Function() change, {String? except}) {
    final before = _snapshot();
    if (!change()) return false;
    final after = _snapshot();
    final now = DateTime.now();
    for (final MapEntry(key: kind, value: items) in after.entries) {
      final added = items.difference(before[kind]!);
      if (kind == 'news') {
        for (final id in added) {
          if (_fillerArticle(id.split('#').first) == null) {
            _newsArrivals[id] = now;
          }
        }
      }
      if (kind == 'mail') {
        for (final id in added) {
          _mailArrivals[id] ??= now;
        }
      }
      if (kind == 'chat') {
        if (paceMessages) {
          _queueMessages(added, except);
        } else {
          alerts.pushAll(_chatAlerts(added, except));
        }
        continue;
      }
      alerts.pushAll(
        _combine(kind, [for (final item in added) ?_alertFor(kind, item)]),
      );
    }
    return true;
  }

  /// What several unlocks of one kind are called together, e.g. "4 yeni
  /// konum". Kinds not listed get one notification each.
  static const _together = {
    'poltel': 'yeni belge',
    'evidence': 'yeni delil',
    'map': 'yeni konum',
    'voice': 'yeni kayıt',
    'bank': 'yeni hesap hareketi',
  };

  /// [batch] as a single notification that names them all, for the kinds
  /// in [_together], so a new chapter doesn't flood the screen.
  List<StoryAlert> _combine(String kind, List<StoryAlert> batch) {
    final noun = _together[kind];
    if (noun == null || batch.length < 2) return batch;
    final names = [for (final alert in batch) alert.body];
    final list = names.length == 2
        ? names.join(' ve ')
        : '${names.sublist(0, names.length - 1).join(', ')} ve ${names.last}';
    return [
      StoryAlert(
        app: batch.first.app,
        source: batch.first.source,
        title: '${batch.length} $noun',
        body: list,
      ),
    ];
  }

  /// Holds back the messages in [added] (see [paceMessages]); [deliver]
  /// shows them.
  void _queueMessages(Set<String> added, String? except) {
    final byPerson = <String, int>{};
    for (final item in added) {
      final person = item.split('#').first;
      if (person == except || person == openChat) continue;
      byPerson[person] = (byPerson[person] ?? 0) + 1;
    }
    final now = _lastTick ?? DateTime.now();
    for (final MapEntry(key: person, value: count) in byPerson.entries) {
      _shown[person] ??= _incomingCount(person) - count;
      _nextMessage[person] ??= now.add(const Duration(seconds: 1));
    }
  }

  /// Time the other person takes to type [text].
  static Duration _typingTime(String text) => Duration(
    milliseconds: (1200 + text.length * 40).clamp(2000, 6000).toInt(),
  );

  /// Shows the next held-back message of each chat whose turn it is, with a
  /// banner. Returns whether any showed.
  bool _deliverMessages(DateTime now) {
    var changed = false;
    for (final person in _shown.keys.toList()) {
      if (now.isBefore(_nextMessage[person]!)) continue;
      final incoming = _incoming(person);
      final shown = _shown[person]! + 1;
      if (shown <= incoming.length && person != openChat) {
        alerts.push(
          StoryAlert(
            app: 'MatesApp',
            title: person,
            body: incoming[shown - 1],
            thread: person,
          ),
        );
      }
      changed = true;
      if (shown >= incoming.length) {
        _shown.remove(person);
        _nextMessage.remove(person);
      } else {
        _shown[person] = shown;
        _nextMessage[person] = now.add(_typingTime(incoming[shown]));
      }
    }
    return changed;
  }

  /// Whether [person]'s messages are still coming in.
  bool isTyping(String person) => _shown.containsKey(person);

  /// [person]'s messages that haven't shown yet, which the chat that just
  /// opened shows itself. They no longer raise banners.
  int takeHeldBack(String person) {
    final shown = _shown.remove(person);
    _nextMessage.remove(person);
    return shown == null ? 0 : _incomingCount(person) - shown;
  }

  /// The chat with [person] as far as it has come in.
  List<ChatEntry> transcriptOf(String person) {
    final transcript = restore(person).$2;
    final shown = _shown[person];
    if (shown == null) return transcript;
    var seen = 0;
    for (final (i, entry) in transcript.indexed) {
      if (entry is IncomingMessage && ++seen > shown) {
        return transcript.sublist(0, i);
      }
    }
    return transcript;
  }

  List<String> _incoming(String person) => [
    for (final entry in restore(person).$2)
      if (entry case IncomingMessage(:final text)) text,
  ];

  /// One notification per new message, each with its own text.
  List<StoryAlert> _chatAlerts(Set<String> added, String? except) {
    final byPerson = <String, int>{};
    for (final item in added) {
      final person = item.split('#').first;
      if (person != except) byPerson[person] = (byPerson[person] ?? 0) + 1;
    }
    return [
      for (final MapEntry(key: person, value: count) in byPerson.entries)
        for (final text
            in restore(person).$2
                .whereType<IncomingMessage>()
                .map((m) => m.text)
                .toList()
                .reversed
                .take(count)
                .toList()
                .reversed)
          StoryAlert(
            app: 'MatesApp',
            title: person,
            body: text,
            thread: person,
          ),
    ];
  }

  bool _setValue(String stat, int v) {
    final clamped = _story.state.stats[stat]?.clamp(v) ?? v;
    if (value(stat) == clamped) return false;
    _values[stat] = clamped;
    return true;
  }

  StoryAlert? _alertFor(String kind, String item) {
    switch (kind) {
      case 'poltel':
        final d = _story.documents.firstWhere((d) => d.id == item);
        return StoryAlert(app: 'Poltel', title: 'Yeni belge', body: d.title);
      case 'evidence':
        final e = _story.evidence.firstWhere((e) => e.id == item);
        return StoryAlert(
          app: 'Pano',
          source: 'Delil Panosu',
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
          thread: t.sender,
        );
      case 'mail':
        final m =
            _story.storyMails.where((m) => m.id == item).firstOrNull ??
            _poolMail(item);
        // The filter catches scams before they ring.
        if (m == null || (m.spam && !isCanonMail(m))) return null;
        return StoryAlert(
          app: 'Mail',
          title: m.sender,
          body: m.subject.isEmpty ? m.body : m.subject,
        );
      case 'bank':
        final t = _story.bank.transactions.firstWhere((t) => t.id == item);
        return StoryAlert(
          app: 'ZaferBank',
          source: _story.bank.bank,
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
        final id = item.split('#').first;
        final filler = _fillerArticle(id);
        final a = filler ?? _story.news.articles.firstWhere((a) => a.id == id);
        return StoryAlert(
          app: 'News',
          source: _story.news.outlet(a.outlet).name,
          title: filler == null ? 'Son dakika' : 'Gündem',
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

  /// [person]'s messages that have shown, see [paceMessages].
  int _shownCount(String person) => _shown[person] ?? _incomingCount(person);

  /// Messages from [person] the player hasn't read yet.
  int unreadCount(String person) {
    final seen = _seenIncoming[person] ?? _initialSeen(person);
    final unread = _shownCount(person) - seen;
    return unread < 0 ? 0 : unread;
  }

  int get totalUnread =>
      _story.conversations.keys.map(unreadCount).fold(0, _sum);

  static int _sum(int a, int b) => a + b;

  /// Whether [person] asked something the player hasn't answered yet.
  bool awaitsReply(String person) =>
      !isTyping(person) && restore(person).$1.expectsReply;

  /// Chats with unread messages or a question waiting for an answer.
  int get chatsNeedingAttention => _story.conversations.keys
      .where((p) => unreadCount(p) > 0 || awaitsReply(p))
      .length;

  Future<void> markRead(String person) async {
    alerts.clearGroup('MatesApp|$person');
    final count = _shownCount(person);
    if (_seenIncoming[person] == count) return;
    _seenIncoming[person] = count;
    notifyListeners();
    await _save();
  }

  /// Whether the player has opened an unlockable item, such as a document.
  bool hasSeen(String item) => _seenItems.contains(item);

  /// Marks [item] opened and, the first time only, applies [effects], so
  /// opening it again doesn't count twice (`doubt += 1`).
  Future<void> markSeen(
    String item, [
    Iterable<String> effects = const [],
  ]) async {
    if (!_seenItems.add(item)) return;
    _apply(effects);
    notifyListeners();
    await _save();
  }

  /// The evidence whose hidden line [decoded] is, read back in Şifre
  /// Çözücü, or null. The first time, applies what solving it opens.
  Future<Evidence?> recognise(String decoded) async {
    final key = _letters(decoded);
    if (key.length < 6) return null;
    for (final e in _story.evidence) {
      final code = e.code;
      if (code == null || !meets(e.requires)) continue;
      if (!key.contains(_letters(code.text))) continue;
      await markSeen('code:${e.id}', code.unlocks);
      return e;
    }
    return null;
  }

  static String _letters(String text) =>
      turkishUpper(text).replaceAll(RegExp('[^A-ZÇĞİÖŞÜ0-9]'), '');

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

  /// How long [task] takes right now, with [speed] taken into account.
  Duration durationOf(MissionTask task) => task.duration ~/ speed;

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

  /// Timers and, while they are on, hints.
  Iterable<StoryTimer> get _allTimers => [
    ..._story.state.timers,
    if (hintsOn) ..._story.state.hints,
  ];

  /// Starts timers whose condition just started holding.
  void _startTimers() {
    for (final t in _allTimers) {
      if (!_timers.containsKey(t.id) &&
          !_timersDone.contains(t.id) &&
          meets(t.when)) {
        _timers[t.id] = 0;
      }
    }
  }

  /// How long [timer] runs right now, with [speed] taken into account.
  Duration timerDuration(StoryTimer timer) => timer.duration ~/ speed;

  /// Ids of the timers that are running.
  Iterable<String> get runningTimers => _timers.keys;

  /// Play time left on [timerId], or null if it isn't running.
  Duration? timeLeft(String timerId) {
    final elapsed = _timers[timerId];
    final timer = _allTimers.where((t) => t.id == timerId).firstOrNull;
    if (elapsed == null || timer == null) return null;
    return timerDuration(timer) - Duration(milliseconds: elapsed);
  }

  /// Moves running timers on by [elapsed] play time and fires the ones that
  /// are due.
  Future<void> advanceTimers(Duration elapsed) async {
    _startTimers();
    if (_timers.isEmpty) return;
    for (final t in _allTimers) {
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
    var changed = _startDrips(time);
    changed |= _deliverMessages(time);
    await completeDueMissions(now: time);
    changed |= _announceNews(time);
    final last = _lastTick;
    _lastTick = time;
    var elapsed = last == null ? Duration.zero : time.difference(last);
    if (elapsed.isNegative) elapsed = Duration.zero;
    if (elapsed > const Duration(seconds: 10)) {
      elapsed = const Duration(seconds: 2);
    }
    if (elapsed > Duration.zero) {
      _playMs += elapsed.inMilliseconds;
      changed |= _announce(() => _advanceWaits(elapsed) | _drip(time));
      changed |= _advanceBreakdown();
      // Play time is worth keeping even when nothing else changed.
      await _save();
    }
    if (changed) notifyListeners();
    if (elapsed > Duration.zero) await advanceTimers(elapsed);
  }

  /* ---------- Mail and news that come with time ---------- */

  /// Play time so far.
  Duration get playTime => Duration(milliseconds: _playMs);

  int get _seed {
    final day = GameClock.current.firstOpen;
    return day.year * 10000 + day.month * 100 + day.day;
  }

  /// Moves on the mails and articles that come `afterMinutes` after their
  /// condition. Returns whether any arrived.
  bool _advanceWaits(Duration elapsed) {
    var arrived = false;
    void wait(String key, Condition requires, Duration after) {
      if (after <= Duration.zero || _waited.contains(key)) return;
      if (!meets(requires)) return;
      final ran = (_waiting[key] ?? 0) + elapsed.inMilliseconds;
      final due = after ~/ speed;
      if (ran < due.inMilliseconds) {
        _waiting[key] = ran;
        return;
      }
      _waiting.remove(key);
      _waited.add(key);
      arrived = true;
    }

    for (final m in _story.storyMails) {
      wait('mail:${m.id}', m.requires, m.after);
    }
    for (final a in _story.news.articles) {
      wait('news:${a.id}', a.requires, a.after);
    }
    return arrived;
  }

  /// A random gap between everyday items, shorter with [speed].
  int _gap(int minMinutes, int maxMinutes, int salt) {
    final low = minMinutes < 1 ? 1 : minMinutes;
    final high = maxMinutes < low ? low : maxMinutes;
    final minutes = low + Random(_seed * 31 + salt).nextInt(high - low + 1);
    final ms = minutes * 60000;
    return ms ~/ speed;
  }

  List<String> get _mailIds => [for (final m in _story.mailPool.mails) m.id];

  List<String> get _fillerIds => [
    for (final a in _story.news.filler.articles) a.id,
  ];

  bool _mailFits(String id) {
    final mail = _poolMail(id);
    return mail != null && meets(mail.requires);
  }

  bool _articleFits(String id) {
    final article = _fillerArticle(id);
    return article != null && meets(article.requires);
  }

  /// Fills the inbox and the feed with what came before the game began, the
  /// first time it runs. No banners for these. Returns whether it did.
  bool _startDrips(DateTime now) {
    if (_mailDrip.started && _newsDrip.started) return false;
    void start(
      DripFeed feed,
      List<String> ids,
      int count,
      bool Function(String id) fits,
      int salt, {
      required bool recycle,
    }) {
      if (feed.started) return;
      // Spread over the last day or two, oldest first.
      for (var i = 0; i < count; i++) {
        final hours = (count - i) * (3 + Random(_seed + salt + i).nextInt(6));
        final drop = feed.next(
          ids,
          at: now.subtract(Duration(hours: hours)),
          seed: _seed + salt,
          eligible: fits,
          recycle: recycle,
        );
        if (drop == null) break;
        feed.drops.add(drop);
      }
      // What was there before the game began doesn't count as unseen.
      feed.seen = feed.drops.length;
      feed.dueAt = _playMs + _gap(2, 6, salt);
    }

    start(
      _mailDrip,
      _mailIds,
      _story.mailPool.start,
      _mailFits,
      1,
      recycle: false,
    );
    final filler = _story.news.filler;
    start(_newsDrip, _fillerIds, filler.start, _articleFits, 2, recycle: true);
    return true;
  }

  /// Delivers the everyday mail and news that are due. A feed waits while
  /// the player hasn't opened its app for a while (see `pauseAfter`) and
  /// goes on a few minutes after they do. Returns whether any came.
  bool _drip(DateTime now, {bool wait = true}) {
    bool step(
      DripFeed feed,
      List<String> ids,
      bool Function(String id) fits,
      int minMinutes,
      int maxMinutes,
      int pauseAfter,
      int salt, {
      required bool recycle,
    }) {
      final due = feed.dueAt;
      if (due == null || _playMs < due) return false;
      if (wait && pauseAfter > 0 && feed.unseen >= pauseAfter) {
        feed.dueAt = _playMs + _gap(1, 3, salt + feed.drops.length * 7);
        return false;
      }
      final drop = feed.next(
        ids,
        at: now,
        seed: _seed + salt,
        eligible: fits,
        recycle: recycle,
      );
      if (drop != null) feed.drops.add(drop);
      feed.dueAt =
          _playMs + _gap(minMinutes, maxMinutes, salt + feed.drops.length * 13);
      return drop != null;
    }

    final pool = _story.mailPool;
    final filler = _story.news.filler;
    final mail = step(
      _mailDrip,
      _mailIds,
      _mailFits,
      pool.minMinutes,
      pool.maxMinutes,
      pool.pauseAfter,
      1,
      recycle: false,
    );
    final news = step(
      _newsDrip,
      _fillerIds,
      _articleFits,
      filler.minMinutes,
      filler.maxMinutes,
      filler.pauseAfter,
      2,
      recycle: true,
    );
    return mail || news;
  }

  /// Delivers the next everyday mail or article right away, for the story
  /// writer's debug page.
  Future<void> dripNow({bool mail = true}) async {
    final feed = mail ? _mailDrip : _newsDrip;
    if (!feed.started) _startDrips(DateTime.now());
    feed.dueAt = _playMs;
    if (_announce(() => _drip(DateTime.now(), wait: false))) {
      notifyListeners();
    }
    await _save();
  }

  /// The player opened Mail (or News, if [mail] is false): everyday items
  /// that waited for them start coming again.
  Future<void> lookedAt({bool mail = true}) async {
    final feed = mail ? _mailDrip : _newsDrip;
    if (feed.unseen == 0) return;
    feed.seen = feed.drops.length;
    await _save();
  }
}

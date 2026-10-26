import 'dart:convert';

import 'dialogue.dart';

/// All of the game's story content, read from the JSON files in
/// `assets/story/`. See `story/STORY_FORMAT.md` for the file format.
///
/// This file only uses `dart:` libraries so the story validator in `tool/`
/// can use it without Flutter.
class StoryData {
  StoryData({
    required this.conversations,
    required this.documents,
    required this.inboxMails,
    required this.storyMails,
    required this.smsThreads,
    required this.feed,
    required this.profiles,
    required this.map,
    required this.evidence,
    required this.bank,
    required this.recordings,
    required this.calendar,
  });

  static const files = [
    'chats.json',
    'documents.json',
    'mails.json',
    'sms.json',
    'sinstagram.json',
    'map.json',
    'evidence.json',
    'bank.json',
    'voicemail.json',
    'calendar.json',
  ];

  static const directory = 'assets/story';

  /// The story the game runs. Set by [load].
  static StoryData current = StoryData.empty();

  factory StoryData.empty() => StoryData(
    conversations: const {},
    documents: const [],
    inboxMails: const [],
    storyMails: const [],
    smsThreads: const [],
    feed: const [],
    profiles: const [],
    map: const MapData(image: '', officers: [], locations: []),
    evidence: const [],
    bank: const BankData(
      bank: '',
      owner: '',
      iban: '',
      card: '',
      balance: 0,
      transactions: [],
    ),
    recordings: const [],
    calendar: const [],
  );

  final Map<String, Conversation> conversations;
  final List<StoryDocument> documents;

  /// Mails that arrive one by one when the player checks for new mail.
  final List<Mail> inboxMails;

  /// Mails the story sends once their condition is met.
  final List<Mail> storyMails;
  final List<SmsThread> smsThreads;
  final List<Post> feed;
  final List<Profile> profiles;
  final MapData map;
  final List<Evidence> evidence;
  final BankData bank;
  final List<Recording> recordings;
  final List<StoryEvent> calendar;

  /// Reads every story file with [read], which gets a path such as
  /// `assets/story/chats.json`, and makes the result [current].
  static Future<StoryData> load(
    Future<String> Function(String path) read,
  ) async {
    final json = {
      for (final file in files)
        file: jsonDecode(await read('$directory/$file')),
    };
    return current = StoryData.fromJson(json);
  }

  /// Parses the decoded contents of [files], keyed by file name.
  factory StoryData.fromJson(Map<String, Object?> files) {
    T parse<T>(String file, T Function(_Reader r) build) =>
        build(_Reader(files[file], file));

    return StoryData(
      conversations: parse(
        'chats.json',
        (r) => {
          for (final MapEntry(:key, :value) in r.map.entries)
            key: _conversation(_Reader(value, 'chats.json › $key')),
        },
      ),
      documents: parse('documents.json', (r) => r.list(_document)),
      inboxMails: parse('mails.json', (r) => r.field('inbox').list(_mail)),
      storyMails: parse('mails.json', (r) => r.field('story').list(_mail)),
      smsThreads: parse('sms.json', (r) => r.list(_sms)),
      feed: parse('sinstagram.json', (r) => r.field('feed').list(_post)),
      profiles: parse(
        'sinstagram.json',
        (r) => r.optional('profiles')?.list(_profile) ?? const [],
      ),
      map: parse('map.json', _map),
      evidence: parse('evidence.json', (r) => r.list(_evidence)),
      bank: parse('bank.json', _bank),
      recordings: parse('voicemail.json', (r) => r.list(_recording)),
      calendar: parse('calendar.json', (r) => r.list(_event)),
    );
  }
}

/* ---------- Models ---------- */

/// A document delivered to Poltel: a statement or a report.
sealed class StoryDocument {
  const StoryDocument({
    required this.id,
    required this.title,
    required this.requires,
    required this.daysBeforeFirstOpen,
  });

  final String id;
  final String title;
  final Condition requires;

  /// The document's date, counted back from the first launch.
  final int daysBeforeFirstOpen;
}

/// A statement ("İfade Tutanağı").
class Statement extends StoryDocument {
  const Statement({
    required super.id,
    required super.title,
    required super.requires,
    required super.daysBeforeFirstOpen,
    required this.name,
    required this.idNumber,
    required this.education,
    required this.maritalStatus,
    required this.gender,
    required this.takenBy,
    this.qa = const [],
    this.testimonyFrom,
  });

  final String name;
  final String idNumber;
  final String education;
  final String maritalStatus;
  final String gender;

  /// The officer who took the statement ("İfadeyi alan").
  final String takenBy;
  final List<({String question, String answer})> qa;

  /// For interrogations the player runs over MatesApp: the contact whose
  /// chat holds the questions and answers, instead of [qa].
  final String? testimonyFrom;
}

/// An official report such as an autopsy, made of [lines].
class Report extends StoryDocument {
  const Report({
    required super.id,
    required super.title,
    required super.requires,
    required super.daysBeforeFirstOpen,
    required this.subject,
    required this.authority,
    required this.heading,
    required this.lines,
  });

  final String subject;

  /// The issuing office, printed at the top of the page.
  final String authority;
  final String heading;
  final List<ReportLine> lines;
}

enum ReportLineKind { heading, subheading, field, paragraph, conclusion }

class ReportLine {
  const ReportLine(this.kind, this.text);
  final ReportLineKind kind;

  /// `{tarih}` is replaced by the report's date.
  final String text;
}

class Mail {
  const Mail({
    required this.sender,
    required this.body,
    this.requires = Condition.always,
  });

  final String sender;
  final String body;
  final Condition requires;

  String get id => '$sender|$body';
}

class SmsThread {
  const SmsThread({
    required this.sender,
    required this.messages,
    this.daysAgo = 0,
    this.requires = Condition.always,
  });

  final String sender;
  final List<String> messages;

  /// Days before the first launch the messages were received.
  final int daysAgo;
  final Condition requires;
}

class Post {
  const Post({
    required this.id,
    required this.author,
    required this.caption,
    required this.likes,
    this.image,
    this.daysAgo = 1,
    this.comments = const [],
  });

  final String id;
  final String author;
  final String caption;
  final int likes;

  /// Asset path, or null for a text-only post.
  final String? image;
  final int daysAgo;
  final List<({String author, String text})> comments;
}

/// A Sinstagram account that only turns up when the player searches for it.
class Profile {
  const Profile({
    required this.handle,
    required this.name,
    this.bio = '',
    this.followers = 0,
    this.following = 0,
    this.private = false,
    this.posts = const [],
    this.requires = Condition.always,
    this.unlocksOnView = const [],
  });

  final String handle;
  final String name;
  final String bio;
  final int followers;
  final int following;
  final bool private;
  final List<Post> posts;

  /// When the profile can be found by search.
  final Condition requires;

  /// Story flags set when the player opens the profile.
  final List<String> unlocksOnView;
}

class MapData {
  const MapData({
    required this.image,
    required this.officers,
    required this.locations,
  });

  /// Background map image, an asset path.
  final String image;

  /// Contacts who can be sent to locations.
  final List<String> officers;
  final List<MapLocation> locations;

  MissionTask? task(String id) {
    for (final location in locations) {
      for (final task in location.tasks) {
        if (task.id == id) return task;
      }
    }
    return null;
  }

  MapLocation? locationOf(String taskId) {
    for (final location in locations) {
      if (location.tasks.any((t) => t.id == taskId)) return location;
    }
    return null;
  }
}

class MapLocation {
  const MapLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.x,
    required this.y,
    required this.tasks,
    this.requires = Condition.always,
  });

  final String id;
  final String name;
  final String description;

  /// Position on the map image, from 0 (left/top) to 1 (right/bottom).
  final double x;
  final double y;
  final List<MissionTask> tasks;

  /// When the location shows up on the map.
  final Condition requires;
}

/// Something an officer can be sent to do at a location.
class MissionTask {
  const MissionTask({
    required this.id,
    required this.label,
    required this.duration,
    required this.report,
    this.requires = Condition.always,
    this.unlocks = const [],
  });

  final String id;
  final String label;

  /// Real time the officer needs.
  final Duration duration;

  /// What the officer reports back.
  final String report;
  final Condition requires;
  final List<String> unlocks;
}

class Evidence {
  const Evidence({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.requires = Condition.always,
    this.links = const [],
    this.inspection,
  });

  final String id;
  final String name;
  final String description;
  final String? image;

  /// When the evidence turns up.
  final Condition requires;

  /// Ids of related evidence, drawn as strings on the board.
  final List<String> links;
  final Inspection? inspection;
}

/// A lab minigame in Poltel that reveals what a piece of evidence means.
sealed class Inspection {
  const Inspection({
    required this.instructions,
    required this.result,
    this.unlocks = const [],
  });

  final String instructions;

  /// What the lab concludes once the minigame is solved.
  final String result;
  final List<String> unlocks;
}

/// Put a torn image back together.
class JigsawInspection extends Inspection {
  const JigsawInspection({
    required super.instructions,
    required super.result,
    super.unlocks,
    this.rows = 3,
    this.cols = 3,
  });

  final int rows;
  final int cols;
}

/// Match a fingerprint against people on file.
class FingerprintInspection extends Inspection {
  const FingerprintInspection({
    required super.instructions,
    required super.result,
    required this.options,
    required this.answer,
    super.unlocks,
  });

  final List<String> options;
  final String answer;
}

/// Sweep a UV lamp over the image to reveal hidden writing.
class UvInspection extends Inspection {
  const UvInspection({
    required super.instructions,
    required super.result,
    required this.hiddenText,
    super.unlocks,
  });

  final String hiddenText;
}

class BankData {
  const BankData({
    required this.bank,
    required this.owner,
    required this.iban,
    required this.card,
    required this.balance,
    required this.transactions,
  });

  final String bank;
  final String owner;
  final String iban;

  /// Last four digits of the card.
  final String card;

  /// Balance in kuruş before any story transactions arrive.
  final int balance;
  final List<BankTransaction> transactions;
}

class BankTransaction {
  const BankTransaction({
    required this.id,
    required this.title,
    required this.amount,
    this.detail = '',
    this.daysAgo = 0,
    this.requires = Condition.always,
  });

  final String id;
  final String title;
  final String detail;

  /// In kuruş; negative for payments.
  final int amount;
  final int daysAgo;

  /// Transactions with a condition arrive during the story and change the
  /// balance; the others are already part of it.
  final Condition requires;
}

enum RecordingKind { voicemail, memo }

class Recording {
  const Recording({
    required this.id,
    required this.kind,
    required this.from,
    required this.transcript,
    required this.seconds,
    this.daysAgo = 0,
    this.audio,
    this.requires = Condition.always,
    this.unlocksOnListen = const [],
  });

  final String id;
  final RecordingKind kind;
  final String from;
  final String transcript;
  final int seconds;
  final int daysAgo;

  /// Optional audio asset; without one the transcript plays along.
  final String? audio;
  final Condition requires;
  final List<String> unlocksOnListen;
}

/// A calendar entry: either [dayOffset] days from the first launch, or a
/// yearly date.
class StoryEvent {
  const StoryEvent({required this.title, this.dayOffset, this.month, this.day});

  final String title;
  final int? dayOffset;
  final int? month;
  final int? day;
}

/* ---------- Parsing ---------- */

/// Reads JSON values and reports the path of anything malformed.
class _Reader {
  _Reader(this.value, this.path);

  final Object? value;
  final String path;

  Never fail(String message) => throw FormatException('$path: $message');

  Map<String, Object?> get map => value is Map<String, Object?>
      ? value as Map<String, Object?>
      : fail('expected an object');

  _Reader field(String key) {
    final map = this.map;
    if (!map.containsKey(key)) fail('missing "$key"');
    return _Reader(map[key], '$path › $key');
  }

  _Reader? optional(String key) {
    final map = this.map;
    return map[key] == null ? null : _Reader(map[key], '$path › $key');
  }

  String get string =>
      value is String ? value as String : fail('expected text');

  int get integer =>
      value is int ? value as int : fail('expected a whole number');

  double get number =>
      value is num ? (value as num).toDouble() : fail('expected a number');

  bool get boolean =>
      value is bool ? value as bool : fail('expected true or false');

  List<T> list<T>(T Function(_Reader r) item) {
    if (value is! List) fail('expected a list');
    final items = value as List;
    return [
      for (var i = 0; i < items.length; i++)
        item(_Reader(items[i], '$path[$i]')),
    ];
  }

  List<String> get strings => list((r) => r.string);

  String text(String key) => field(key).string;
  String? textOr(String key) => optional(key)?.string;
  int intOr(String key, int fallback) => optional(key)?.integer ?? fallback;
  bool boolOr(String key) => optional(key)?.boolean ?? false;
  List<String> stringsOr(String key) => optional(key)?.strings ?? const [];

  /// A flag name or a list of flag names.
  List<String> _flags(String key) {
    final r = optional(key);
    if (r == null) return const [];
    return r.value is String ? [r.string] : r.strings;
  }

  /// `requires` (all of) plus `requiresAny` (one of), or another pair of
  /// keys such as `waitFor` / `waitForAny`.
  Condition condition([String key = 'requires']) =>
      Condition(all: _flags(key), any: _flags('${key}Any'));
}

Trait _trait(_Reader r) {
  final name = r.string.toLowerCase();
  for (final trait in Trait.values) {
    if (trait.label.toLowerCase() == name || trait.name == name) return trait;
  }
  r.fail(
    'unknown trait "$name", use one of '
    '${Trait.values.map((t) => t.label.toLowerCase()).join(', ')}',
  );
}

Conversation _conversation(_Reader r) {
  final history = r.optional('history')?.list((e) {
    final m = e.map;
    if (m.containsKey('in')) return IncomingMessage(e.text('in'));
    if (m.containsKey('out')) return OutgoingMessage(e.text('out'));
    if (m.containsKey('label')) return DayMarker(label: e.text('label'));
    if (m.containsKey('day')) return DayMarker(daysAgo: e.field('day').integer);
    e.fail('expected "in", "out", "day" or "label"');
  });
  final nodes = r.optional('nodes');
  return Conversation(
    history: history ?? const [],
    dialogue: nodes == null
        ? null
        : Dialogue(
            start: r.textOr('start') ?? 'start',
            nodes: {
              for (final MapEntry(:key) in nodes.map.entries)
                key: _node(nodes.field(key)),
            },
          ),
  );
}

DialogueNode _node(_Reader r) => DialogueNode(
  r.optional('options')?.list(_option) ?? const [],
  incoming: r.stringsOr('incoming'),
  waitFor: r.condition('waitFor'),
);

DialogueOption _option(_Reader r) => DialogueOption(
  label: r.text('label'),
  message: r.textOr('message'),
  replies: r.stringsOr('replies'),
  next: r.textOr('next'),
  traits: r.optional('traits')?.list(_trait) ?? const [],
  unlocks: r.stringsOr('unlocks'),
  silent: r.boolOr('silent'),
  testimony: r.textOr('testimony'),
);

StoryDocument _document(_Reader r) {
  final type = r.text('type');
  return switch (type) {
    'statement' => Statement(
      id: r.text('id'),
      title: r.text('title'),
      requires: r.condition(),
      daysBeforeFirstOpen: r.intOr('daysBeforeFirstOpen', 0),
      name: r.text('name'),
      idNumber: r.text('idNumber'),
      education: r.text('education'),
      maritalStatus: r.text('maritalStatus'),
      gender: r.text('gender'),
      takenBy: r.text('takenBy'),
      testimonyFrom: r.textOr('testimonyFrom'),
      qa:
          r
              .optional('qa')
              ?.list((q) => (question: q.text('q'), answer: q.text('a'))) ??
          const [],
    ),
    'report' => Report(
      id: r.text('id'),
      title: r.text('title'),
      requires: r.condition(),
      daysBeforeFirstOpen: r.intOr('daysBeforeFirstOpen', 0),
      subject: r.text('subject'),
      authority: r.text('authority'),
      heading: r.text('heading'),
      lines: r.field('lines').list((l) {
        final entry = l.map.entries.single;
        final kind = ReportLineKind.values
            .where((k) => k.name == entry.key)
            .firstOrNull;
        if (kind == null) l.fail('unknown line type "${entry.key}"');
        return ReportLine(kind, l.text(entry.key));
      }),
    ),
    _ => r.fail('unknown document type "$type"'),
  };
}

Mail _mail(_Reader r) => Mail(
  sender: r.text('sender'),
  body: r.text('body'),
  requires: r.condition(),
);

SmsThread _sms(_Reader r) => SmsThread(
  sender: r.text('sender'),
  messages: r.field('messages').strings,
  daysAgo: r.intOr('daysAgo', 0),
  requires: r.condition(),
);

Post _post(_Reader r, {String? author}) => Post(
  id: r.text('id'),
  author: author ?? r.text('author'),
  caption: r.text('caption'),
  likes: r.intOr('likes', 0),
  image: r.textOr('image'),
  daysAgo: r.intOr('daysAgo', 1),
  comments:
      r
          .optional('comments')
          ?.list((c) => (author: c.text('author'), text: c.text('text'))) ??
      const [],
);

Profile _profile(_Reader r) {
  final handle = r.text('handle');
  return Profile(
    handle: handle,
    name: r.text('name'),
    bio: r.textOr('bio') ?? '',
    followers: r.intOr('followers', 0),
    following: r.intOr('following', 0),
    private: r.boolOr('private'),
    posts:
        r.optional('posts')?.list((p) => _post(p, author: handle)) ?? const [],
    requires: r.condition(),
    unlocksOnView: r.stringsOr('unlocksOnView'),
  );
}

MapData _map(_Reader r) => MapData(
  image: r.text('image'),
  officers: r.field('officers').strings,
  locations: r
      .field('locations')
      .list(
        (l) => MapLocation(
          id: l.text('id'),
          name: l.text('name'),
          description: l.textOr('description') ?? '',
          x: l.field('x').number,
          y: l.field('y').number,
          requires: l.condition(),
          tasks: l
              .field('tasks')
              .list(
                (t) => MissionTask(
                  id: t.text('id'),
                  label: t.text('label'),
                  duration: Duration(
                    milliseconds: (t.field('minutes').number * 60000).round(),
                  ),
                  report: t.text('report'),
                  requires: t.condition(),
                  unlocks: t.stringsOr('unlocks'),
                ),
              ),
        ),
      ),
);

Evidence _evidence(_Reader r) => Evidence(
  id: r.text('id'),
  name: r.text('name'),
  description: r.text('description'),
  image: r.textOr('image'),
  requires: r.condition(),
  links: r.stringsOr('links'),
  inspection: switch (r.optional('inspection')) {
    null => null,
    final i => switch (i.text('type')) {
      'jigsaw' => JigsawInspection(
        instructions: i.text('instructions'),
        result: i.text('result'),
        unlocks: i.stringsOr('unlocks'),
        rows: i.intOr('rows', 3),
        cols: i.intOr('cols', 3),
      ),
      'fingerprint' => FingerprintInspection(
        instructions: i.text('instructions'),
        result: i.text('result'),
        unlocks: i.stringsOr('unlocks'),
        options: i.field('options').strings,
        answer: i.text('answer'),
      ),
      'uv' => UvInspection(
        instructions: i.text('instructions'),
        result: i.text('result'),
        unlocks: i.stringsOr('unlocks'),
        hiddenText: i.text('hiddenText'),
      ),
      final type => i.fail('unknown inspection type "$type"'),
    },
  },
);

BankData _bank(_Reader r) => BankData(
  bank: r.text('bank'),
  owner: r.text('owner'),
  iban: r.text('iban'),
  card: r.text('card'),
  balance: r.field('balance').integer,
  transactions: r
      .field('transactions')
      .list(
        (t) => BankTransaction(
          id: t.text('id'),
          title: t.text('title'),
          detail: t.textOr('detail') ?? '',
          amount: t.field('amount').integer,
          daysAgo: t.intOr('daysAgo', 0),
          requires: t.condition(),
        ),
      ),
);

Recording _recording(_Reader r) {
  final kind = r.textOr('kind') ?? 'voicemail';
  return Recording(
    id: r.text('id'),
    kind:
        RecordingKind.values.where((k) => k.name == kind).firstOrNull ??
        r.fail('unknown kind "$kind", use voicemail or memo'),
    from: r.text('from'),
    transcript: r.text('transcript'),
    seconds: r.intOr('seconds', 10),
    daysAgo: r.intOr('daysAgo', 0),
    audio: r.textOr('audio'),
    requires: r.condition(),
    unlocksOnListen: r.stringsOr('unlocksOnListen'),
  );
}

StoryEvent _event(_Reader r) => StoryEvent(
  title: r.text('title'),
  dayOffset: r.optional('dayOffset')?.integer,
  month: r.optional('month')?.integer,
  day: r.optional('day')?.integer,
);

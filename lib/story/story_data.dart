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
    required this.mailPool,
    required this.storyMails,
    required this.smsThreads,
    required this.feed,
    required this.profiles,
    required this.map,
    required this.evidence,
    required this.bank,
    required this.recordings,
    required this.calendar,
    required this.state,
    required this.news,
    required this.endings,
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
    'state.json',
    'news.json',
    'endings.json',
  ];

  static const directory = 'assets/story';

  /// The story the game runs. Set by [load].
  static StoryData current = StoryData.empty();

  factory StoryData.empty() => StoryData(
    conversations: const {},
    documents: const [],
    mailPool: const MailPool(),
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
    state: const StateData(),
    news: const NewsData(),
    endings: const EndingsData(),
  );

  final Map<String, Conversation> conversations;
  final List<StoryDocument> documents;

  /// Everyday mail that drips in at random moments of play.
  final MailPool mailPool;

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

  /// Numbers such as trust, app locks and timed events.
  final StateData state;
  final NewsData news;
  final EndingsData endings;

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
      mailPool: parse(
        'mails.json',
        (r) => switch (r.optional('pool')) {
          null => const MailPool(),
          final pool => _mailPool(pool),
        },
      ),
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
      state: parse('state.json', _state),
      news: parse('news.json', _news),
      endings: parse('endings.json', _endings),
    );
  }
}

/* ---------- Models ---------- */

/// Where Poltel files a document.
enum DocumentCategory {
  /// The case file.
  case_('case', 'Dosya'),

  /// Personnel records ("Personel Sicil"). Opening one is logged.
  personnel('personnel', 'Personel Sicilleri'),

  /// Internal affairs ("İç Denetim"). Opening one is logged.
  internal('internal', 'İç Denetim');

  const DocumentCategory(this.key, this.label);
  final String key;
  final String label;

  /// Restricted records: Poltel notes that the access was logged.
  bool get isLogged => this != case_;
}

/// A document delivered to Poltel: a statement or a report.
sealed class StoryDocument {
  const StoryDocument({
    required this.id,
    required this.title,
    required this.requires,
    required this.daysBeforeFirstOpen,
    this.category = DocumentCategory.case_,
    this.unlocksOnView = const [],
  });

  final String id;
  final String title;
  final Condition requires;
  final DocumentCategory category;

  /// Effects of opening the document, e.g. recording that a personnel file
  /// was read.
  final List<String> unlocksOnView;

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
    super.category,
    super.unlocksOnView,
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
    super.category,
    super.unlocksOnView,
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
    String? id,
    this.subject = '',
    this.requires = Condition.always,
    this.after = Duration.zero,
    this.unlocksOnView = const [],
    this.spam = false,
  }) : _id = id;

  final String? _id;
  final String sender;
  final String subject;
  final String body;
  final Condition requires;

  /// Applied the first time the player opens the mail.
  final List<String> unlocksOnView;

  /// A scam the phone's filter catches: it goes straight to Spam, with no
  /// banner.
  final bool spam;

  /// Play time the mail takes to arrive once [requires] holds.
  final Duration after;

  String get id => _id ?? '$sender|$body';
}

/// Everyday mail: one of [mails] every [minMinutes] to [maxMinutes] minutes
/// of play, in a shuffled order. A mail with a condition waits for it. Each
/// mail arrives once; the first [start] were there before the game began.
class MailPool {
  const MailPool({
    this.mails = const [],
    this.minMinutes = 5,
    this.maxMinutes = 15,
    this.start = 3,
    this.pauseAfter = 4,
    this.keepRead = 8,
  });

  final List<Mail> mails;
  final int minMinutes;
  final int maxMinutes;
  final int start;

  /// The pool waits once this many have come without the player opening
  /// Mail, and goes on when they do. 0 never waits.
  final int pauseAfter;

  /// How many of the latest everyday mails stay in the inbox; older ones
  /// the player has read go to Spam. Story mail always stays.
  final int keepRead;
}

class SmsThread {
  const SmsThread({
    required this.sender,
    required this.messages,
    this.daysAgo = 0,
    this.requires = Condition.always,
    this.unlocksOnView = const [],
  });

  final String sender;
  final List<String> messages;

  /// Days before the first launch the messages were received.
  final int daysAgo;
  final Condition requires;

  /// Applied the first time the player opens the thread.
  final List<String> unlocksOnView;
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
  final List<Officer> officers;
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

/// A contact the player can send on missions, while [requires] holds
/// (for instance only those who still trust a suspended detective).
class Officer {
  const Officer(this.name, {this.requires = Condition.always});

  final String name;
  final Condition requires;
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
    this.image,
  });

  final String id;
  final String name;
  final String description;

  /// A photo of the place, shown above its tasks.
  final String? image;

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
    this.code,
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

  /// A line on it written in a cipher, which Şifre Çözücü recognises once
  /// the player reads it back.
  final HiddenCode? code;
}

/// A line hidden in a cipher. The evidence's description shows it
/// enciphered; [text] is how it reads once solved.
class HiddenCode {
  const HiddenCode({
    required this.cipher,
    required this.text,
    this.shift = 0,
    this.unlocks = const [],
  });

  /// One of Şifre Çözücü's ciphers: caesar, atbash, morse or reverse.
  final String cipher;

  /// For caesar, how many letters along it was moved.
  final int shift;
  final String text;

  /// Applied the first time the player reads it back.
  final List<String> unlocks;
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
    this.payees = const [],
  });

  final String bank;
  final String owner;
  final String iban;

  /// Last four digits of the card.
  final String card;

  /// Balance in kuruş before any story transactions arrive.
  final int balance;
  final List<BankTransaction> transactions;

  /// People and accounts the player can send money to.
  final List<Payee> payees;
}

/// Someone the player can send money to. Every transfer adds to the
/// number `paid:<id>` (in lira); [unlocks] apply once a transfer of at
/// least [minAmount] goes through.
class Payee {
  const Payee({
    required this.id,
    required this.name,
    required this.iban,
    this.note = '',
    this.requires = Condition.always,
    this.minAmount = 0,
    this.unlocks = const [],
  });

  final String id;
  final String name;
  final String iban;

  /// Shown under the name, e.g. "Tedavi ödemesi".
  final String note;
  final Condition requires;

  /// In kuruş.
  final int minAmount;
  final List<String> unlocks;
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

/// A number the story keeps, such as a character's trust in the player.
class StatDefinition {
  const StatDefinition({
    required this.name,
    this.label = '',
    this.start = 0,
    this.min,
    this.max,
  });

  final String name;

  /// What the number means, for story writers. Never shown to the player.
  final String label;
  final int start;
  final int? min;
  final int? max;

  int clamp(int value) {
    final low = min, high = max;
    if (low != null && value < low) return low;
    if (high != null && value > high) return high;
    return value;
  }
}

/// Closes an app while [lockedWhen] holds, e.g. Poltel for a suspended
/// detective.
class AppLock {
  const AppLock({
    required this.app,
    required this.lockedWhen,
    required this.title,
    required this.message,
  });

  /// The app's name on the home screen.
  final String app;
  final Condition lockedWhen;
  final String title;
  final String message;
}

/// Something that happens a while after [when] starts holding, unless
/// [unless] holds first: a witness leaving town, a delayed call. Only time
/// spent playing counts.
class StoryTimer {
  const StoryTimer({
    required this.id,
    required this.when,
    required this.duration,
    this.unless = Condition.always,
    this.unlocks = const [],
    this.alert,
  });

  final String id;
  final Condition when;
  final Duration duration;

  /// Calls the timer off; [Condition.always] means it can't be.
  final Condition unless;
  final List<String> unlocks;
  final ({String app, String title, String body})? alert;
}

class StateData {
  const StateData({
    this.stats = const {},
    this.flags = const {},
    this.locks = const [],
    this.timers = const [],
    this.hints = const [],
    this.milestones = const [],
  });

  final Map<String, StatDefinition> stats;

  /// The main path, in order, for the story table: each step's flag and
  /// name.
  final List<({String flag, String title})> milestones;

  /// What flags mean. The validator only notes it when one of these isn't
  /// set by anything yet: it is planned.
  final Map<String, String> flags;
  final List<AppLock> locks;
  final List<StoryTimer> timers;

  /// Timers that only raise an alert, telling the player about something
  /// they can do but might not notice, such as sending money back. They
  /// unlock nothing and stay quiet when hints are off in Settings.
  final List<StoryTimer> hints;
}

class NewsOutlet {
  const NewsOutlet({required this.id, required this.name, this.color});

  final String id;
  final String name;

  /// ARGB, e.g. 0xFFB71C1C.
  final int? color;
}

/// A news article. Current ones are in the feed once [requires] holds
/// (and, with [dayOffset], once their day has come); [archive] ones only
/// turn up in a search.
class Article {
  const Article({
    required this.id,
    required this.outlet,
    required this.title,
    this.summary = '',
    this.body = const [],
    this.author = '',
    this.daysAgo = 0,
    this.dayOffset,
    this.hour = 9,
    this.date,
    this.image,
    this.tags = const [],
    this.archive = false,
    this.requires = Condition.always,
    this.after = Duration.zero,
    this.unlocksOnRead = const [],
  });

  final String id;
  final String outlet;
  final String title;
  final String summary;

  /// Paragraphs.
  final List<String> body;
  final String author;
  final int daysAgo;

  /// Publishes the article this many days after the first launch, at
  /// [hour] o'clock, instead of when [requires] starts holding.
  final int? dayOffset;
  final int hour;

  /// Printed instead of the date [daysAgo] gives, e.g. "14 Mart 2021".
  final String? date;
  final String? image;

  /// Extra words the archive search matches.
  final List<String> tags;
  final bool archive;
  final Condition requires;

  /// Play time the article takes to come out once [requires] holds.
  final Duration after;
  final List<String> unlocksOnRead;
}

/// Everyday news that keeps the feed alive: one article from [articles]
/// every [minMinutes] to [maxMinutes] minutes of play, in a shuffled order
/// that starts over once every article has run. The first [start] ran
/// before the game began.
class FillerNews {
  const FillerNews({
    this.articles = const [],
    this.minMinutes = 4,
    this.maxMinutes = 12,
    this.start = 4,
    this.keep = 6,
    this.pauseAfter = 4,
  });

  final List<Article> articles;
  final int minMinutes;
  final int maxMinutes;
  final int start;

  /// How many of the latest ones stay in the feed.
  final int keep;

  /// Everyday news waits once this many have come without the player
  /// opening News, and goes on when they do. 0 never waits.
  final int pauseAfter;
}

class NewsData {
  const NewsData({
    this.outlets = const [],
    this.articles = const [],
    this.filler = const FillerNews(),
  });

  final List<NewsOutlet> outlets;
  final List<Article> articles;
  final FillerNews filler;

  NewsOutlet outlet(String id) => outlets.firstWhere(
    (o) => o.id == id,
    orElse: () => NewsOutlet(id: id, name: id),
  );
}

/// One way a part of the ending can turn out.
class EndingVariant {
  const EndingVariant({
    required this.text,
    this.title = '',
    this.requires = Condition.always,
  });

  final String title;
  final String text;
  final Condition requires;
}

/// A part of the epilogue (the case, the detective's career, a colleague),
/// told by the first variant whose condition holds.
class EndingSection {
  const EndingSection({
    required this.id,
    required this.title,
    required this.variants,
  });

  final String id;
  final String title;
  final List<EndingVariant> variants;
}

class EndingsData {
  const EndingsData({
    this.requires = Condition.always,
    this.title = '',
    this.sections = const [],
  });

  /// When the game ends. With no sections the game never does.
  final Condition requires;
  final String title;
  final List<EndingSection> sections;
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
  ask: r.optional('ask')?.list(_option) ?? const [],
  events:
      r
          .optional('events')
          ?.list(
            (e) => DialogueEvent(next: e.text('next'), requires: e.condition()),
          ) ??
      const [],
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
  requires: r.condition(),
  once: r.optional('once')?.boolean ?? true,
);

StoryDocument _document(_Reader r) {
  final type = r.text('type');
  final categoryKey = r.textOr('category') ?? 'case';
  final category =
      DocumentCategory.values.where((c) => c.key == categoryKey).firstOrNull ??
      r.fail(
        'unknown category "$categoryKey", use '
        '${DocumentCategory.values.map((c) => c.key).join(', ')}',
      );
  return switch (type) {
    'statement' => Statement(
      id: r.text('id'),
      title: r.text('title'),
      requires: r.condition(),
      daysBeforeFirstOpen: r.intOr('daysBeforeFirstOpen', 0),
      category: category,
      unlocksOnView: r.stringsOr('unlocksOnView'),
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
      category: category,
      unlocksOnView: r.stringsOr('unlocksOnView'),
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
  id: r.textOr('id'),
  sender: r.text('sender'),
  subject: r.textOr('subject') ?? '',
  body: r.text('body'),
  requires: r.condition(),
  after: _after(r),
  unlocksOnView: r.stringsOr('unlocksOnView'),
  spam: r.boolOr('spam'),
);

MailPool _mailPool(_Reader r) => MailPool(
  mails: r.field('mails').list(_mail),
  minMinutes: r.intOr('minMinutes', 5),
  maxMinutes: r.intOr('maxMinutes', 15),
  start: r.intOr('start', 3),
  pauseAfter: r.intOr('pauseAfter', 4),
  keepRead: r.intOr('keepRead', 8),
);

/// The optional `afterMinutes` wait of mails and articles.
Duration _after(_Reader r) => switch (r.optional('afterMinutes')) {
  null => Duration.zero,
  final m => Duration(milliseconds: (m.number * 60000).round()),
};

SmsThread _sms(_Reader r) => SmsThread(
  sender: r.text('sender'),
  messages: r.field('messages').strings,
  daysAgo: r.intOr('daysAgo', 0),
  requires: r.condition(),
  unlocksOnView: r.stringsOr('unlocksOnView'),
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
  officers: r
      .field('officers')
      .list(
        (o) => o.value is String
            ? Officer(o.string)
            : Officer(o.text('name'), requires: o.condition()),
      ),
  locations: r
      .field('locations')
      .list(
        (l) => MapLocation(
          id: l.text('id'),
          name: l.text('name'),
          description: l.textOr('description') ?? '',
          image: l.textOr('image'),
          x: l.field('x').number,
          y: l.field('y').number,
          requires: l.condition(),
          tasks: l
              .field('tasks')
              .list(
                (t) => MissionTask(
                  id: t.text('id'),
                  label: t.text('label'),
                  duration: _minutes(t),
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
  code: switch (r.optional('code')) {
    null => null,
    final c => HiddenCode(
      cipher: c.text('cipher'),
      shift: c.intOr('shift', 0),
      text: c.text('text'),
      unlocks: c.stringsOr('unlocks'),
    ),
  },
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
  payees:
      r
          .optional('payees')
          ?.list(
            (p) => Payee(
              id: p.text('id'),
              name: p.text('name'),
              iban: p.textOr('iban') ?? '',
              note: p.textOr('note') ?? '',
              requires: p.condition(),
              minAmount: p.intOr('minAmount', 0),
              unlocks: p.stringsOr('unlocks'),
            ),
          ) ??
      const [],
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

Duration _minutes(_Reader r) =>
    Duration(milliseconds: (r.field('minutes').number * 60000).round());

StatDefinition _stat(String name, _Reader s) => StatDefinition(
  name: name,
  label: s.textOr('label') ?? '',
  start: s.intOr('start', 0),
  min: s.optional('min')?.integer,
  max: s.optional('max')?.integer,
);

StateData _state(_Reader r) => StateData(
  stats: switch (r.optional('stats')) {
    null => const {},
    final stats => {
      for (final name in stats.map.keys) name: _stat(name, stats.field(name)),
    },
  },
  milestones:
      r
          .optional('milestones')
          ?.list((m) => (flag: m.text('flag'), title: m.text('title'))) ??
      const [],
  flags: switch (r.optional('flags')) {
    null => const {},
    final flags => {
      for (final name in flags.map.keys) name: flags.field(name).string,
    },
  },
  locks:
      r
          .optional('locks')
          ?.list(
            (l) => AppLock(
              app: l.text('app'),
              lockedWhen: l.condition('lockedWhen'),
              title: l.text('title'),
              message: l.text('message'),
            ),
          ) ??
      const [],
  timers: r.optional('timers')?.list(_timer) ?? const [],
  hints:
      r
          .optional('hints')
          ?.list(
            (h) => StoryTimer(
              id: h.text('id'),
              when: h.condition('when'),
              duration: _minutes(h),
              unless: h.condition('unless'),
              alert: (
                app: h.text('app'),
                title: h.text('title'),
                body: h.text('body'),
              ),
            ),
          ) ??
      const [],
);

StoryTimer _timer(_Reader t) => StoryTimer(
  id: t.text('id'),
  when: t.condition('when'),
  duration: _minutes(t),
  unless: t.condition('unless'),
  unlocks: t.stringsOr('unlocks'),
  alert: switch (t.optional('alert')) {
    null => null,
    final a => (
      app: a.text('app'),
      title: a.text('title'),
      body: a.text('body'),
    ),
  },
);

NewsData _news(_Reader r) => NewsData(
  outlets:
      r
          .optional('outlets')
          ?.list(
            (o) => NewsOutlet(
              id: o.text('id'),
              name: o.text('name'),
              color: switch (o.textOr('color')) {
                null => null,
                final hex =>
                  int.tryParse(hex.replaceFirst('#', 'FF'), radix: 16) ??
                      o.fail('color must look like #B71C1C'),
              },
            ),
          ) ??
      const [],
  articles: r.optional('articles')?.list(_article) ?? const [],
  filler: switch (r.optional('filler')) {
    null => const FillerNews(),
    final f => FillerNews(
      articles: f.optional('articles')?.list(_article) ?? const [],
      minMinutes: f.intOr('minMinutes', 4),
      maxMinutes: f.intOr('maxMinutes', 12),
      start: f.intOr('start', 4),
      keep: f.intOr('keep', 6),
      pauseAfter: f.intOr('pauseAfter', 4),
    ),
  },
);

Article _article(_Reader a) => Article(
  id: a.text('id'),
  outlet: a.text('outlet'),
  title: a.text('title'),
  summary: a.textOr('summary') ?? '',
  body: switch (a.optional('body')) {
    null => const [],
    final b => b.value is String ? [b.string] : b.strings,
  },
  author: a.textOr('author') ?? '',
  daysAgo: a.intOr('daysAgo', 0),
  dayOffset: a.optional('dayOffset')?.integer,
  hour: a.intOr('hour', 9),
  date: a.textOr('date'),
  image: a.textOr('image'),
  tags: a.stringsOr('tags'),
  archive: a.boolOr('archive'),
  requires: a.condition(),
  after: _after(a),
  unlocksOnRead: a.stringsOr('unlocksOnRead'),
);

EndingsData _endings(_Reader r) => EndingsData(
  requires: r.condition(),
  title: r.textOr('title') ?? '',
  sections:
      r
          .optional('sections')
          ?.list(
            (s) => EndingSection(
              id: s.text('id'),
              title: s.text('title'),
              variants: s
                  .field('variants')
                  .list(
                    (v) => EndingVariant(
                      title: v.textOr('title') ?? '',
                      text: v.text('text'),
                      requires: v.condition(),
                    ),
                  ),
            ),
          ) ??
      const [],
);

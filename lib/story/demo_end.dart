import 'dialogue.dart';
import 'story_data.dart';

/// The slides after the demo's epilogue (`assets/story/demo.json`): the
/// player's big decisions, what they missed, the other endings, small things
/// to notice and what's coming.
class DemoEnd {
  const DemoEnd({
    this.title = '',
    this.decisions = const [],
    this.missed = const [],
    this.endingSection = '',
    this.endingSummaries = const {},
    this.secret = '',
    this.noticed = const [],
    this.about = '',
    this.coming = const [],
    this.thanks = '',
  });

  static const path = 'assets/story/demo.json';

  final String title;
  final List<DemoDecision> decisions;
  final List<DemoLine> missed;

  /// The endings.json section whose variants are the other endings, with a
  /// one-line summary for each by title.
  final String endingSection;
  final Map<String, String> endingSummaries;

  /// The only words about the hidden ending.
  final String secret;
  final List<String> noticed;
  final String about;
  final List<String> coming;
  final String thanks;

  factory DemoEnd.fromJson(Map<String, Object?> json) {
    final endings = (json['endings'] as Map<String, Object?>?) ?? const {};
    return DemoEnd(
      title: json['title'] as String? ?? '',
      decisions: [
        for (final d in _maps(json['decisions']))
          DemoDecision(
            title: d['title'] as String? ?? '',
            requires: _condition(d['requires']),
            choices: [for (final c in _maps(d['choices'])) _line(c)],
          ),
      ],
      missed: [for (final m in _maps(json['missed'])) _line(m)],
      endingSection: endings['section'] as String? ?? '',
      endingSummaries: {
        for (final MapEntry(:key, :value)
            in ((endings['summaries'] as Map<String, Object?>?) ?? const {})
                .entries)
          key: value as String,
      },
      secret: endings['secret'] as String? ?? '',
      noticed: _strings(json['noticed']),
      about: json['about'] as String? ?? '',
      coming: _strings(json['coming']),
      thanks: json['thanks'] as String? ?? '',
    );
  }

  /// What the player decided, as (decision title, what they did), for the
  /// decisions they reached.
  List<(String, String)> decided(StoryState state) => [
    for (final d in decisions)
      if (d.requires.isMetBy(state))
        if (d.choices.where((c) => c.requires.isMetBy(state)).firstOrNull
            case final choice?)
          (d.title, choice.text),
  ];

  /// What the player could have done but didn't.
  List<String> missedBy(StoryState state) => [
    for (final m in missed)
      if (m.requires.isMetBy(state)) m.text,
  ];

  /// Every ending of [endingSection], with its summary and whether it is
  /// the player's.
  List<({String title, String summary, bool yours})> endings(
    EndingsData data,
    EndingVariant? yours,
  ) {
    final section = data.sections
        .where((s) => s.id == endingSection)
        .firstOrNull;
    if (section == null) return const [];
    return [
      for (final v in section.variants)
        if (v.title.isNotEmpty)
          (
            title: v.title,
            summary: endingSummaries[v.title] ?? '',
            yours: v.title == yours?.title,
          ),
    ];
  }

  static List<Map<String, Object?>> _maps(Object? list) =>
      list is List ? list.whereType<Map<String, Object?>>().toList() : const [];

  static List<String> _strings(Object? list) =>
      list is List ? list.whereType<String>().toList() : const [];

  static Condition _condition(Object? value) => Condition(
    all: switch (value) {
      final String term => [term],
      final List<Object?> terms => terms.whereType<String>().toList(),
      _ => const [],
    },
  );

  static DemoLine _line(Map<String, Object?> m) => DemoLine(
    requires: _condition(m['requires']),
    text: m['text'] as String? ?? '',
  );
}

class DemoDecision {
  const DemoDecision({
    required this.title,
    required this.requires,
    required this.choices,
  });

  final String title;
  final Condition requires;

  /// The first one that holds is what the player did.
  final List<DemoLine> choices;
}

class DemoLine {
  const DemoLine({required this.requires, required this.text});

  final Condition requires;
  final String text;
}

/// Numbers about the game and the player's run, for the fun facts.
class DemoStats {
  const DemoStats({
    required this.mails,
    required this.mailsRead,
    required this.news,
    required this.newsRead,
    required this.evidence,
    required this.evidenceFound,
    required this.people,
    required this.lines,
  });

  /// Counts [story], with [seen] telling what the player opened and [meets]
  /// which evidence they found.
  factory DemoStats.of(
    StoryData story, {
    required bool Function(String item) seen,
    required bool Function(Condition condition) meets,
  }) {
    final mailIds = [
      for (final m in story.storyMails) m.id,
      for (final m in story.mailPool.mails) m.id,
    ];
    final newsIds = [
      for (final a in story.news.articles) a.id,
      for (final a in story.news.filler.articles) a.id,
    ];
    var lines = 0;
    for (final c in story.conversations.values) {
      lines += c.history.length;
      for (final node in c.dialogue?.nodes.values ?? <DialogueNode>[]) {
        lines += node.incoming.length;
      }
    }
    return DemoStats(
      mails: mailIds.length,
      mailsRead: mailIds.where((id) => seen('mail:$id')).length,
      news: newsIds.length,
      newsRead: newsIds.where((id) => seen('news:$id')).length,
      evidence: story.evidence.length,
      evidenceFound: story.evidence.where((e) => meets(e.requires)).length,
      people: story.conversations.length,
      lines: lines,
    );
  }

  final int mails;
  final int mailsRead;
  final int news;
  final int newsRead;
  final int evidence;
  final int evidenceFound;
  final int people;
  final int lines;
}

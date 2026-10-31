import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/story/demo.dart';
import 'package:ledective/story/demo_end.dart';
import 'package:ledective/story/dialogue.dart';
import 'package:ledective/story/story_data.dart';

void main() {
  demoEndTests();

  test('the demo closes the hidden ending but keeps option places', () {
    final files = {
      for (final f in StoryData.files)
        f: jsonDecode(File('assets/story/$f').readAsStringSync()),
    };
    final full = StoryData.fromJson(
      jsonDecode(jsonEncode(files)) as Map<String, Object?>,
    );
    closeSecret(files);
    final demo = StoryData.fromJson(files);
    expect(full.endings.secret, isNotNull);
    expect(demo.endings.secret, isNull);
    final chats = jsonEncode(files['chats.json']);
    expect(chats, contains('demo:closed'));
    expect(demo.conversations.length, full.conversations.length);
  });
}

DemoEnd _demoEnd() => DemoEnd.fromJson(
  jsonDecode(File(DemoEnd.path).readAsStringSync()) as Map<String, Object?>,
);

StoryData _story() => StoryData.fromJson({
  for (final f in StoryData.files)
    f: jsonDecode(File('assets/story/$f').readAsStringSync()),
});

void demoEndTests() {
  test('demo.json only names flags the story knows', () {
    final end = _demoEnd();
    final story = _story();
    final known = {
      ...story.state.flags.keys,
      for (final p in story.bank.payees) 'sent:${p.id}',
    };
    final terms = [
      for (final d in end.decisions) ...[
        ...d.requires.terms,
        for (final c in d.choices) ...c.requires.terms,
      ],
      for (final m in end.missed) ...m.requires.terms,
    ];
    for (final term in terms) {
      expect(known, contains(term.replaceFirst('!', '')), reason: term);
    }
  });

  test('every ending of the section has a summary', () {
    final end = _demoEnd();
    final endings = end.endings(_story().endings, null);
    expect(endings, isNotEmpty);
    for (final e in endings) {
      expect(e.summary, isNotEmpty, reason: e.title);
    }
  });

  test('the slides read the player\'s run', () {
    final end = _demoEnd();
    final state = StoryState.of({
      'mp:wrote',
      'kerem:deal',
      'girl:rescued',
      'ev:notebook',
    });
    final decided = end.decided(state);
    expect(
      decided,
      contains(('Kerem', "Kerem'e savcılık koruması sözü verdin.")),
    );
    expect(
      decided.where((d) => d.$1 == 'Rüşvet').single.$2,
      contains('hesapta tuttun'),
    );
    final missed = end.missedBy(state);
    expect(missed.any((m) => m.contains('Şifre Çözücü')), isTrue);
    expect(missed.any((m) => m.contains('Melis')), isFalse);
  });

  test('stats count what the player opened', () {
    final story = _story();
    final first = story.storyMails.first.id;
    final stats = DemoStats.of(
      story,
      seen: (item) => item == 'mail:$first',
      meets: (_) => false,
    );
    expect(stats.mailsRead, 1);
    expect(stats.mails, greaterThan(100));
    expect(stats.evidenceFound, 0);
    expect(stats.lines, greaterThan(100));
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/board/board_app.dart';
import 'package:ledective/apps/poltel/poltel_app.dart';
import 'package:ledective/apps/sinstagram/sinstagram_app.dart';
import 'package:ledective/story/dialogue.dart';
import 'package:ledective/story/story_data.dart';
import 'package:ledective/story/story_validator.dart';
import 'package:ledective/story/story_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dialogue = Dialogue(
  start: 'a',
  nodes: {
    'a': DialogueNode(
      incoming: ['hello'],
      [
        DialogueOption(label: 'to b', replies: ['b1', 'b2'], next: 'b'),
        DialogueOption(label: 'end', message: 'bye'),
      ],
    ),
    'b': DialogueNode([
      DialogueOption(label: 'done', replies: ['ok'], next: 'gated'),
      DialogueOption(label: '(ignore)', silent: true),
    ]),
    'gated': DialogueNode(
      waitFor: Condition(all: ['flag']),
      incoming: ['later'],
      [DialogueOption(label: 'fin')],
    ),
  },
);

List<String> _describe(List<ChatEntry> entries) => [
  for (final e in entries)
    switch (e) {
      OutgoingMessage(:final text) => '> $text',
      IncomingMessage(:final text) => '< $text',
      DayMarker() => '--',
    },
];

void main() {
  group('DialogueState', () {
    test('options appear once the node has arrived', () {
      final state = DialogueState(_dialogue);
      expect(state.options, isEmpty);
      expect(state.arrive(), ['hello']);
      expect(state.arrive(), isEmpty, reason: 'only delivered once');
      expect(state.options.map((o) => o.label), ['to b', 'end']);
    });

    test('follows the chosen option to the next node', () {
      final state = DialogueState(_dialogue)..arrive();
      final option = state.choose(0);
      expect(option.replies, ['b1', 'b2']);
      state.arrive();
      expect(state.options.map((o) => o.label), ['done', '(ignore)']);
      expect(state.choices, [0]);
    });

    test('finishes on an option without a next node', () {
      final state = DialogueState(_dialogue)
        ..arrive()
        ..choose(1);
      expect(state.isFinished, isTrue);
      expect(state.canReply, isFalse);
    });

    test('message defaults to the label', () {
      expect(_dialogue.nodes['a']!.options[0].message, 'to b');
      expect(_dialogue.nodes['a']!.options[1].message, 'bye');
    });

    test('waits for a story flag', () {
      var flag = false;
      final state = DialogueState(_dialogue, hasFlag: (_) => flag);
      final entries = state.replay([0, 0]);
      expect(_describe(entries), [
        '< hello',
        '> to b',
        '< b1',
        '< b2',
        '> done',
        '< ok',
      ]);
      expect(state.isWaiting, isTrue);
      expect(state.isFinished, isFalse);
      expect(state.canReply, isFalse);

      flag = true;
      expect(state.arrive(), ['later']);
      expect(state.options.single.label, 'fin');
    });

    test('silent options send nothing', () {
      final entries = DialogueState(_dialogue).replay([0, 1]);
      expect(_describe(entries).last, '< b2');
    });

    test('replay ignores saved choices that no longer fit', () {
      final state = DialogueState(_dialogue);
      expect(_describe(state.replay([5, 0])), ['< hello']);
      expect(state.choices, isEmpty);
    });

    test('a conversation without dialogue is finished', () {
      expect(DialogueState(null).isFinished, isTrue);
    });
  });

  setUpAll(() => StoryData.load((path) => File(path).readAsString()));

  test('Condition needs all of "all" and one of "any"', () {
    const c = Condition(all: ['a'], any: ['b', 'c']);
    expect(c.isMetBy({'a', 'b'}.contains), isTrue);
    expect(c.isMetBy({'a'}.contains), isFalse);
    expect(c.isMetBy({'b', 'c'}.contains), isFalse);
    expect(Condition.always.isMetBy((_) => false), isTrue);
  });

  test('the story files have no errors', () {
    final errors = validateStory(
      StoryData.current,
      assetExists: (path) => File(path).existsSync(),
    ).where((issue) => issue.isError);
    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  test('the validator catches broken links and stray flags', () {
    final story = StoryData.fromJson({
      ...{for (final f in StoryData.files) f: _emptyFile(f)},
      'chats.json': {
        'Kim': {
          'nodes': {
            'start': {
              'waitFor': 'never',
              'options': [
                {'label': 'x', 'next': 'nowhere'},
              ],
            },
          },
        },
      },
    });
    final messages = validateStory(story).map((i) => i.message).join('\n');
    expect(messages, contains('nowhere'));
    expect(messages, contains('"never"'));
  });

  test('malformed files name the broken field', () {
    expect(
      () => StoryData.fromJson({
        for (final f in StoryData.files) f: _emptyFile(f),
        'evidence.json': [
          {'id': 'x', 'name': 'x'},
        ],
      }),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('evidence.json[0]'),
        ),
      ),
    );
  });

  group('StoryProgress', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StoryProgress.instance.load(await SharedPreferences.getInstance());
    });

    Future<void> say(String person, String label) async {
      final progress = StoryProgress.instance;
      final (state, _) = progress.restore(person);
      final index = state.options.indexWhere((o) => o.label == label);
      expect(index, isNot(-1), reason: '$person has no option "$label"');
      await progress.choose(person, state, index);
    }

    test('a full playthrough unlocks every part of the case', () async {
      final progress = StoryProgress.instance;
      expect(deliveredDocuments(progress), isEmpty);
      expect(progress.unreadCount('Özge'), 1);
      expect(progress.restore('Orhun').$1.canReply, isFalse);

      await say('Özge', 'Neymiş bu kadar önemli olan durum');
      await say('Özge', 'Yakınlarının ifadesini aldınız mı ?');
      await say('Özge', 'İfadeleri bana poltel üzerinden gönder');
      expect(progress.has(StoryFlags.part1Done), isTrue);
      expect(deliveredDocuments(progress).map((d) => d.id), [
        'autopsy',
        'deniz',
        'yusuf',
      ]);
      expect(progress.alerts.current, isNotNull, reason: 'Orhun wrote');
      expect(progress.unreadCount('Orhun'), 1);
      expect(progress.unreadCount('Erdi'), 1);

      await say('Orhun', 'Madde kullanan çocuğu buldunuz mu ?');
      await say('Orhun', 'İfadesini aldınız mı uygulamada gözükmüyor.');
      await say('İnanç', 'Naptınız oğlum sorgu işini');
      await say('İnanç', 'Benim söyleyeceğim sorularla alın ifadesini.');
      await say(
        'İnanç',
        'Hayır gelmeme daha var. Buradan soracağım ben soruları',
      );
      expect(progress.has(StoryFlags.inancDone), isTrue);

      await say('Doğa', "Berat'ı nereden tanıyorsun?");
      await say(
        'Doğa',
        'Doğruyu söylersen sana yardım ederiz. Pakette ne vardı?',
      );
      await say('Doğa', 'Berat malı kimden alıyordu?');
      await say('Doğa', "Adil'i nerede bulabiliriz?");
      expect(progress.has(StoryFlags.furkanStatement), isTrue);
      expect(deliveredDocuments(progress).first.id, 'furkan');
      expect(progress.testimonyFrom('Doğa').map((r) => r.question), [
        "Berat'ı nereden tanıyorsun?",
        'Doğruyu söylersen sana yardım ederiz. Pakette ne vardı?',
        'Berat malı kimden alıyordu?',
        "Adil'i nerede bulabiliriz?",
      ]);
      expect(progress.unreadCount('Behram'), 2);
      expect(progress.trait(Trait.curiosity), 4);
      expect(progress.trait(Trait.mercy), 1);
    });

    test('progress is saved and restored', () async {
      await say('Özge', 'Kızım ben size izindeyken bana yazmayın demedim mi ?');
      await StoryProgress.instance.markRead('Özge');
      await StoryProgress.instance.markSeen('poltel:yusuf');

      final prefs = await SharedPreferences.getInstance();
      StoryProgress.instance.load(prefs);
      expect(StoryProgress.instance.choicesFor('Özge'), [0]);
      expect(StoryProgress.instance.trait(Trait.anger), 1);
      expect(StoryProgress.instance.unreadCount('Özge'), 0);
      expect(StoryProgress.instance.hasSeen('poltel:yusuf'), isTrue);
    });

    test('missions report back and unlock what they find', () async {
      final progress = StoryProgress.instance;
      final map = StoryData.current.map;
      await progress.discover(['part1Done']);
      final task = map.task('home-search')!;
      final start = DateTime(2026, 1, 1, 12);

      expect(await progress.startMission(task, 'Atakan', now: start), isTrue);
      expect(
        await progress.startMission(map.task('home-neighbours')!, 'Atakan'),
        isFalse,
        reason: 'Atakan is busy',
      );
      await progress.completeDueMissions(
        now: start.add(const Duration(minutes: 1)),
      );
      expect(progress.reports, isEmpty);

      progress.alerts.clear();
      await progress.completeDueMissions(now: start.add(task.duration));
      expect(progress.reports.single.officer, 'Atakan');
      expect(progress.has('ev:torn-photo'), isTrue);
      expect(newEvidenceCount(progress), 2);
      expect(progress.alerts.current?.app, 'Harita');
      expect(progress.missionOf('Atakan'), isNull);
      expect(
        await progress.startMission(task, 'Doğa'),
        isFalse,
        reason: 'done',
      );
    });

    test('fast missions finish thirty times sooner', () async {
      final progress = StoryProgress.instance;
      await progress.setFastMissions(true);
      final task = StoryData.current.map.task('forensics-tox')!;
      final start = DateTime(2026, 1, 1);
      await progress.startMission(task, 'Orhun', now: start);
      expect(
        progress.activeMission(task.id)!.endsAt.difference(start),
        task.duration ~/ 30,
      );
      await progress.setFastMissions(false);
    });

    test('a solved inspection unlocks its findings', () async {
      final progress = StoryProgress.instance;
      await progress.discover(['ev:torn-map']);
      final map = StoryData.current.evidence.firstWhere(
        (e) => e.id == 'torn-map',
      );
      expect(pendingInspections(progress), [map]);
      expect(
        StoryData.current.map.locations.any(
          (l) => l.id == 'slaughterhouse' && progress.meets(l.requires),
        ),
        isFalse,
      );
      await progress.completeInspection(map);
      expect(progress.isInspected('torn-map'), isTrue);
      expect(progress.has('map-restored'), isTrue);
      expect(pendingInspections(progress), isEmpty);
    });

    test('suspects only turn up in search when the story allows it', () async {
      final progress = StoryProgress.instance;
      expect(searchProfiles('furkan', progress), isEmpty);
      expect(searchProfiles('orhun', progress).single.handle, 'orhun.k');
      await progress.discover(['part1Done']);
      expect(searchProfiles('Furkan', progress).single.handle, 'furkan.shn');
      expect(searchProfiles('adil', progress), isEmpty);
      await progress.discover(['heard:adil']);
      expect(searchProfiles('adil', progress).single.private, isTrue);
      expect(searchProfiles('ozge', progress).single.handle, 'ozge.buro');
    });
  });
}

Object _emptyFile(String file) => switch (file) {
  'chats.json' => <String, Object>{},
  'mails.json' => {'inbox': [], 'story': []},
  'sinstagram.json' => {'feed': []},
  'map.json' => {
    'image': 'x.png',
    'officers': ['A'],
    'locations': [],
  },
  'bank.json' => {
    'bank': 'B',
    'owner': 'O',
    'iban': 'I',
    'card': '1',
    'balance': 0,
    'transactions': [],
  },
  _ => [],
};

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/board/board_app.dart';
import 'package:ledective/apps/news/news_app.dart';
import 'package:ledective/apps/poltel/poltel_app.dart';
import 'package:ledective/apps/sinstagram/sinstagram_app.dart';
import 'package:ledective/story/dialogue.dart';
import 'package:ledective/story/news_feed.dart';
import 'package:ledective/story/story_data.dart';
import 'package:ledective/story/story_validator.dart';
import 'package:ledective/story/story_progress.dart';
import 'package:ledective/story/story_table.dart';
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
      [DialogueOption(label: 'fin', next: 'idle')],
      ask: [
        DialogueOption(label: 'news?', replies: ['none yet']),
        DialogueOption(
          label: 'secret?',
          replies: ['psst'],
          requires: Condition(all: ['secret']),
        ),
      ],
    ),
    'idle': DialogueNode(
      [],
      ask: [
        DialogueOption(label: 'again?', replies: ['yes'], once: false),
      ],
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
      final flags = <String>{};
      final state = DialogueState(_dialogue, state: StoryState.of(flags));
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
      // Only questions until the flag is set.
      expect(state.options.map((o) => o.label), ['news?']);

      flags.add('flag');
      expect(state.arrive(), ['later']);
      expect(state.options.single.label, 'fin');
    });

    test('questions can be asked while the story waits', () {
      final flags = <String>{};
      final state = DialogueState(_dialogue, state: StoryState.of(flags))
        ..replay([0, 0]);
      expect(state.isWaiting, isTrue);
      expect(state.options.map((o) => o.label), ['news?']);
      flags.add('secret');
      expect(state.options.map((o) => o.label), ['news?', 'secret?']);
      state.choose(0);
      // Asked once, gone; the conversation stays where it was.
      expect(state.options.map((o) => o.label), ['secret?']);
      expect(state.isWaiting, isTrue);
      expect(state.choices, [0, 0, 1000]);

      flags.add('flag');
      expect(state.arrive(), ['later']);
      // While there is an answer to give, questions wait.
      expect(state.options.map((o) => o.label), ['fin']);
      state
        ..choose(0)
        ..arrive();
      state.choose(0);
      state.choose(0);
      expect(state.choices, [0, 0, 1000, 0, 2000, 2000]);
    });

    test('replay keeps questions before what came after them', () {
      final state = DialogueState(_dialogue, state: StoryState.of({'flag'}));
      expect(_describe(state.replay([0, 0, 1000])), [
        '< hello',
        '> to b',
        '< b1',
        '< b2',
        '> done',
        '< ok',
        '> news?',
        '< none yet',
        '< later',
      ]);
    });

    test('events make the other person write first, once', () {
      const desk = Dialogue(
        start: 'desk',
        nodes: {
          'desk': DialogueNode(
            [],
            events: [
              DialogueEvent(
                next: 'leak',
                requires: Condition(all: ['leak']),
              ),
            ],
          ),
          'leak': DialogueNode(
            incoming: ['Who leaked this?'],
            [DialogueOption(label: 'Not us', next: 'desk')],
          ),
        },
      );
      final flags = <String>{};
      final state = DialogueState(desk, state: StoryState.of(flags))..arrive();
      expect(state.fireEvent(), isFalse);
      flags.add('leak');
      expect(state.fireEvent(), isTrue);
      expect(state.arrive(), ['Who leaked this?']);
      state
        ..choose(0)
        ..arrive();
      // Back at the desk, the same event doesn't fire again.
      expect(state.fireEvent(), isFalse);
      expect(
        _describe(
          DialogueState(
            desk,
            state: StoryState.of(flags),
          ).replay(state.choices),
        ),
        ['< Who leaked this?', '> Not us'],
      );
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
    expect(c.isMetBy(StoryState.of({'a', 'b'})), isTrue);
    expect(c.isMetBy(StoryState.of({'a'})), isFalse);
    expect(c.isMetBy(StoryState.of({'b', 'c'})), isFalse);
    expect(Condition.always.isMetBy(StoryState.of({})), isTrue);
  });

  test('conditions can negate flags and compare numbers', () {
    final state = StoryState.of({'a'}, {'trust:Özge': 60});
    bool holds(String term) => Condition(all: [term]).isMetBy(state);
    expect(holds('!a'), isFalse);
    expect(holds('!b'), isTrue);
    expect(holds('trust:Özge >= 60'), isTrue);
    expect(holds('trust:Özge>60'), isFalse);
    expect(holds('trust:Özge != 0'), isTrue);
    expect(holds('pressure < 1'), isTrue);
    // Flag names with dashes and digits are still flags.
    expect(Requirement.parse('unknown-1'), isA<FlagRequirement>());
    expect(Effect.parse('unknown-1'), isA<SetFlag>());
    expect(Effect.parse('trust:Doğa -= 5'), isA<ChangeStat>());
  });

  test('the story files have no errors', () {
    final errors = validateStory(
      StoryData.current,
      assetExists: (path) => File(path).existsSync(),
    ).where((issue) => issue.isError);
    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  test('the story table covers every chat and milestone', () {
    final table = storyTable(StoryData.current);
    for (final person in StoryData.current.conversations.keys) {
      expect(table, contains('### $person'));
    }
    for (final m in StoryData.current.state.milestones) {
      expect(table, contains('`${m.flag}`'));
    }
    // The table in the repository is up to date.
    expect(
      File('story/HIKAYE_SEMASI.md').readAsStringSync(),
      table,
      reason: 'dart run tool/validate_story.dart --table',
    );
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

  test('the validator knows numbers and planned flags', () {
    final story = StoryData.fromJson({
      ...{for (final f in StoryData.files) f: _emptyFile(f)},
      'state.json': {
        'stats': {
          'trust:A': {'start': 50},
        },
        'flags': {'later': 'Henüz yazılmadı'},
      },
      'chats.json': {
        'Kim': {
          'nodes': {
            'start': {
              'waitFor': ['trust:A >= 60', 'later'],
              'options': [
                {
                  'label': 'x',
                  'unlocks': ['trust:A += 5', 'typo += 1', 'trait:öfke = 2'],
                },
              ],
            },
          },
        },
      },
    });
    final issues = validateStory(story);
    String at(IssueLevel level) =>
        issues.where((i) => i.level == level).map((i) => i.message).join('\n');
    expect(at(IssueLevel.error), contains('"typo"'));
    expect(at(IssueLevel.error), contains('"trait:öfke" kendiliğinden'));
    expect(at(IssueLevel.error), isNot(contains('trust:A')));
    expect(at(IssueLevel.note), contains('"later"'));
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
      Iterable<StoryDocument> caseFiles() => deliveredDocuments(
        progress,
      ).where((d) => d.category == DocumentCategory.case_);
      // Only personnel records are on Poltel before the case starts.
      expect(deliveredDocuments(progress).map((d) => d.category).toSet(), {
        DocumentCategory.personnel,
      });
      expect(progress.unreadCount('Özge'), 1);
      expect(progress.restore('Orhun').$1.canReply, isFalse);

      await say('Özge', 'Neymiş bu kadar önemli olan durum');
      await say('Özge', 'Yakınlarının ifadesini aldınız mı ?');
      await say('Özge', 'İfadeleri bana poltel üzerinden gönder');
      expect(progress.has(StoryFlags.part1Done), isTrue);
      expect(caseFiles().map((d) => d.id), ['autopsy', 'deniz', 'yusuf']);
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
      expect(caseFiles().first.id, 'furkan');
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
      // The crime scene, plus the photo and the glass from the search.
      expect(newEvidenceCount(progress), 3);
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

    test(
      'pressure climbs from Erdi to the father before money arrives',
      () async {
        final progress = StoryProgress.instance;
        final bribe = StoryData.current.bank.transactions.firstWhere(
          (t) => t.id == 'bribe',
        );
        bool wrote(String person) => progress.restore(person).$2.isNotEmpty;

        await progress.discover([StoryFlags.part1Done]);
        await say('Erdi', 'Biliyorsun nerede olduğumu');
        await say('Erdi', 'Sen içini ferah tut');
        // Erdi passes the pressure on once the case turns out to be murder.
        expect(progress.restore('Erdi').$1.isWaiting, isTrue);
        await progress.discover(['toxicology']);
        await say('Erdi', 'Geçmişine bakmadan katili nasıl bulacağız müdürüm?');
        expect(progress.has('pressure:erdi'), isTrue);

        // The district governor only calls once the detective keeps digging.
        await progress.advanceTimers(const Duration(minutes: 10));
        expect(wrote('Kaymakam'), isFalse);
        await progress.discover(['cafe:witness']);
        await progress.advanceTimers(const Duration(minutes: 4));
        expect(wrote('Kaymakam'), isTrue);
        expect(progress.meets(bribe.requires), isFalse);
        await say(
          'Kaymakam',
          'Soruşturma gizli Kaymakam Bey. Bilgiyi ancak savcılık verebilir.',
        );
        // Erdi hears about it.
        expect(progress.unreadCount('Erdi'), greaterThan(0));

        // The father writes, and sends money, after the car is traced.
        await progress.discover(['plate:mv']);
        await progress.advanceTimers(const Duration(minutes: 3));
        expect(wrote('0532 190 19 07'), isTrue);
        expect(progress.meets(bribe.requires), isTrue);
      },
    );

    test('Erdi asks who leaks each story to the press', () async {
      final progress = StoryProgress.instance;
      List<String> erdi() => [
        for (final e in progress.restore('Erdi').$2)
          if (e case IncomingMessage(:final text)) text,
      ];
      await progress.discover([StoryFlags.part1Done]);
      await say('Erdi', 'Biliyorsun nerede olduğumu');
      await say('Erdi', 'Sen içini ferah tut');
      // The plate story breaks first, while Erdi is still waiting to
      // pressure the detective: he gets to it once that's done.
      await progress.discover(['plate:mv', 'heard:adil']);
      await say('Erdi', 'Kim aradı Ankara’dan?');
      expect(erdi().last, contains('bu dosyadan alırım'));
      await say('Erdi', 'Orhun sorguladı ama sızdıran o değil.');
      await progress.discover(['toxicology']);
      expect(erdi().last, contains('Kim sızdırıyor'));
      await say('Erdi', 'Ekibi tek tek konuşturacağım.');
      expect(progress.has('leak:hunt'), isTrue);
      // Now the team can be asked about it.
      await say('Atakan', 'Neden öyle düşündün?');
      await say('Atakan', 'Gazeteyle konuştun mu?');
      expect(progress.value('trust:Atakan'), 50);
    });

    test(
      'letting Furkan go has a cost once the slaughterhouse is found',
      () async {
        final progress = StoryProgress.instance;
        String lastFromDoga() =>
            progress.restore('Doğa').$2.whereType<IncomingMessage>().last.text;
        await progress.discover([StoryFlags.inancDone]);
        await say(
          'Doğa',
          'Seni Berat\'tan paket alırken görmüşler. O pakette ne vardı?',
        );
        await say(
          'Doğa',
          'Doğruyu söylersen sana yardım ederiz. Pakette ne vardı?',
        );
        await say('Doğa', 'Berat malı kimden alıyordu?');
        await say('Doğa', 'Adil\'i nerede bulabiliriz?');
        await progress.discover(['adil:warns']);
        await say('Doğa', 'Serbest bırakın ama gözünüzü ayırmayın.');
        expect(progress.value('witnessDanger'), 25);

        await progress.discover(['mezbaha-found']);
        expect(lastFromDoga(), contains('Annesi bizi suçluyor'));
        await say('Doğa', 'Bütün ekipleri seferber et. Bulun onu.');
        expect(progress.has('furkan:missing'), isTrue);
        expect(progress.has('furkan:friday'), isFalse);
      },
    );

    test('the torn photo and the camera still lead to Kerem', () async {
      final progress = StoryProgress.instance;
      bool kerem() => progress.restore('0543 112 07 21').$2.isNotEmpty;
      await progress.discover([StoryFlags.part1Done]);
      await say('Atakan', 'Neden öyle düşündün?');
      await progress.discover(['photo-restored', 'ev:cctv']);
      // Atakan writes about the camera first.
      await say('Atakan', 'Görüntüyü netleştirmeye çalış.');
      await say(
        'Atakan',
        'Yırtık fotoğraftaki adamla kameradaki adam aynı kişi mi?',
      );
      // The lab needs time to read the card.
      expect(progress.has('card:enhanced'), isFalse);
      await progress.advanceTimers(const Duration(minutes: 8));
      await say('Atakan', 'Vakfa git, gönüllüleri sor.');
      expect(progress.has('heard:volunteer-card'), isTrue);

      final foundation = StoryData.current.map.locations.firstWhere(
        (l) => l.id == 'foundation',
      );
      expect(progress.meets(foundation.requires), isTrue);
      final start = DateTime(2026, 1, 1);
      await progress.startMission(
        StoryData.current.map.task('foundation-photo')!,
        'Orhun',
        now: start,
      );
      await progress.completeDueMissions(
        now: start.add(const Duration(hours: 1)),
      );
      expect(progress.has('heard:kerem'), isTrue);
      expect(kerem(), isFalse);
      await say('Atakan', 'Aramaya başlayın. Ama sessizce.');
      expect(progress.has('kerem:identified'), isTrue);
      expect(kerem(), isTrue);
    });

    test('Ece\'s old account names her brother', () async {
      final progress = StoryProgress.instance;
      expect(searchProfiles('ece', progress), isEmpty);
      await progress.discover(['heard:ece']);
      expect(searchProfiles('ece aydin', progress).single.handle, 'ece.aydin');
      final brother = findProfile('k.aydin')!;
      expect(brother.bio, 'Kardeşi.');
      await progress.discover(brother.unlocksOnView);
      expect(progress.has('heard:kerem'), isTrue);
    });

    test('clues about where the detective really is add up', () async {
      final progress = StoryProgress.instance;
      final mom = StoryData.current.recordings.firstWhere((r) => r.id == 'mom');
      await progress.discover(mom.unlocksOnListen);
      expect(progress.value('doubt'), 1);
    });

    group('chapter IV', () {
      const kerem = '0543 112 07 21';
      StoryProgress progress() => StoryProgress.instance;
      String lastFrom(String person) =>
          progress().restore(person).$2.whereType<IncomingMessage>().last.text;
      bool storageVisible() => progress().meets(
        StoryData.current.map.locations
            .firstWhere((l) => l.id == 'cold-storage')
            .requires,
      );
      Future<void> raid(String taskId) async {
        final start = DateTime(2026, 1, 1);
        await progress().startMission(
          StoryData.current.map.task(taskId)!,
          'Atakan',
          now: start,
        );
        await progress().completeDueMissions(
          now: start.add(const Duration(hours: 1)),
        );
      }

      // Özge waits at her desk, Kerem has written.
      Future<void> meetKerem() async {
        await progress().discover([StoryFlags.part1Done]);
        await say('Özge', 'Neymiş bu kadar önemli olan durum');
        await say('Özge', 'Yakınlarının ifadesini aldınız mı ?');
        await say('Özge', 'İfadeleri bana poltel üzerinden gönder');
        await progress().discover(['kerem:identified']);
        await say(kerem, 'Kız nerede Kerem?');
        await say(kerem, 'Ekibimden birini göndereceğim.');
      }

      test('a deal brings the girl home', () async {
        await meetKerem();
        await say(kerem, 'Özge gelecek.');
        expect(progress().has('kerem:met'), isFalse);
        await progress().advanceTimers(const Duration(minutes: 10));
        expect(lastFrom('Özge'), contains('Kerem\u2019e yarın her şeyi'));
        await say(
          'Özge',
          'Savcıyla konuşacağım. Ona koruma ve indirim sözü ver.',
        );
        expect(progress().has('case:solved'), isTrue);
        expect(storageVisible(), isTrue);
        await say(kerem, 'Önce kızı çıkaralım, sonra konuşacağız.');
        await raid('storage-raid');
        expect(progress().has('girl:rescued'), isTrue);
        expect(lastFrom(kerem), contains('Ece için'));
        // Friday passing no longer matters.
        await progress().advanceTimers(const Duration(hours: 2));
        expect(progress().has('girl:lost'), isFalse);
      });

      test(
        'an arrest leaves the girl to another trail, and time runs out',
        () async {
          await meetKerem();
          await say(kerem, 'Özge gelecek.');
          await progress().advanceTimers(const Duration(minutes: 10));
          await say('Özge', 'Gözaltına al.');
          expect(storageVisible(), isFalse);
          await progress().advanceTimers(const Duration(minutes: 60));
          expect(progress().has('girl:lost'), isTrue);
          await say('Orhun', 'İlet bakalım');
          await say('Orhun', 'İfadesini aldınız mı uygulamada gözükmüyor.');
          await say('Orhun', 'Kerem\u2019in üstünden ne çıktı?');
          expect(storageVisible(), isTrue);
          await raid('storage-late');
          expect(progress().has('girl:found-dead'), isTrue);
        },
      );

      test('a broken ambush still ends with Kerem giving the place', () async {
        await meetKerem();
        await progress().discover([StoryFlags.orhunDone, 'pressure:erdi']);
        await say('İnanç', 'Naptınız oğlum sorgu işini');
        await say(
          'İnanç',
          'Şimdi bürodaki kızlardan birini yanına al. Eleman ne söylüyorsa bana yazsın. Sen de benim sana sorduğum soruları sor ona',
        );
        await say('İnanç', 'İkimize de gönder, kayıt dışı bir şey yapmayalım.');
        await say(kerem, 'Biri gelecek. (Ekibi topla, buluşma yerini sarın.)');
        await progress().advanceTimers(const Duration(minutes: 10));
        await say('İnanç', 'Bütün çıkışları kapatın.');
        expect(progress().has('kerem:escaped-ambush'), isTrue);
        expect(storageVisible(), isFalse);
        await say(kerem, 'Kerem, kız için. Yerini söyle.');
        await progress().advanceTimers(const Duration(minutes: 15));
        expect(lastFrom(kerem), contains('soğuk hava deposu'));
        await say(kerem, 'Teşekkür ederim.');
        expect(storageVisible(), isTrue);
      });
    });

    test('choices change numbers within their limits', () async {
      final progress = StoryProgress.instance;
      expect(progress.value('trust:Özge'), 50);
      await progress.discover(['trust:Özge += 80']);
      expect(progress.value('trust:Özge'), 100);
      await progress.discover(['trust:Özge = 10', 'trust:Özge -= 5']);
      expect(progress.value('trust:Özge'), 5);
      expect(progress.meets(const Condition(all: ['trust:Özge < 10'])), isTrue);
    });

    test('flags can be cleared and close apps', () async {
      final progress = StoryProgress.instance;
      expect(progress.lockOf('Poltel'), isNull);
      await progress.discover(['status:suspended']);
      expect(progress.lockOf('Poltel')!.title, 'Erişim askıya alındı');
      await progress.discover(['!status:suspended']);
      expect(progress.lockOf('Poltel'), isNull);
    });

    test(
      'a suspended detective only gets help from those who trust them',
      () async {
        final progress = StoryProgress.instance;
        final atakan = StoryData.current.map.officers.firstWhere(
          (o) => o.name == 'Atakan',
        );
        await progress.discover(['status:suspended']);
        expect(progress.meets(atakan.requires), isFalse);
        await progress.discover(['trust:Atakan = 60']);
        expect(progress.meets(atakan.requires), isTrue);
      },
    );

    test('timers fire after play time unless called off', () async {
      final progress = StoryProgress.instance;
      await progress.discover(['mp:wrote']);
      await progress.advanceTimers(const Duration(minutes: 30));
      expect(progress.timeLeft('bribe-kept'), const Duration(minutes: 15));
      expect(progress.has('case:internal-investigation'), isFalse);
      await progress.advanceTimers(const Duration(minutes: 15));
      expect(progress.timeLeft('bribe-kept'), isNull);
      expect(progress.has('case:internal-investigation'), isTrue);
      expect(progress.value('integrity'), 55);
    });

    test('sending the bribe back calls the timer off', () async {
      final progress = StoryProgress.instance;
      await progress.discover(['mp:wrote']);
      final payee = StoryData.current.bank.payees.firstWhere(
        (p) => p.id == 'bribe-return',
      );
      await progress.recordTransfer(payee, 1000000);
      expect(progress.value('paid:bribe-return'), 10000);
      expect(progress.has('bribe:returned'), isFalse, reason: 'too little');
      await progress.recordTransfer(payee, 5000000);
      expect(progress.has('bribe:returned'), isTrue);
      await progress.advanceTimers(const Duration(hours: 2));
      expect(progress.has('case:internal-investigation'), isFalse);
    });

    test('play time stops while the phone sleeps', () async {
      final progress = StoryProgress.instance;
      await progress.discover(['mp:wrote']);
      final start = DateTime(2026, 1, 1);
      await progress.tick(now: start);
      await progress.tick(now: start.add(const Duration(seconds: 2)));
      await progress.tick(now: start.add(const Duration(hours: 5)));
      expect(
        progress.timeLeft('bribe-kept'),
        const Duration(minutes: 45) - const Duration(seconds: 4),
      );
    });

    test('the ending is told by the first variant that fits', () async {
      final progress = StoryProgress.instance;
      final endings = StoryData.current.endings;
      expect(progress.isOver, isFalse);
      final career = endings.sections.firstWhere((s) => s.id == 'career');
      final ozge = endings.sections.firstWhere((s) => s.id == 'Özge');
      expect(progress.ending(career)!.requires.isAlways, isTrue);
      await progress.discover([
        'status:suspended',
        'trust:Özge = 80',
        'final:ready',
      ]);
      expect(progress.isOver, isTrue);
      expect(progress.ending(career)!.text, contains('uzaklaştırıldı'));
      expect(progress.ending(ozge)!.text, contains('güveniyor'));
    });

    test('archived news only turns up in a search', () async {
      final progress = StoryProgress.instance;
      final filler = StoryData.current.news.filler.articles;
      Iterable<String> story() => currentNews(
        progress,
      ).where((i) => !filler.contains(i.article)).map((i) => i.key);
      expect(story(), ['berat-found']);
      String found(String query) =>
          searchArticles(query, progress).single.article.id;
      expect(found('takipsizlik'), 'old-case');
      expect(found('vakif'), 'foundation');
      expect(searchArticles('ta', progress), isEmpty);
      await progress.discover([StoryFlags.part1Done]);
      expect(story(), ['berat-murder', 'berat-found']);
    });
  });

  group('News schedule', () {
    NewsData news() => StoryData.current.news;
    final firstOpen = DateTime(2026, 3, 2);
    List<NewsItem> feedAt(DateTime now, {Set<String> flags = const {}}) =>
        newsFeed(
          news(),
          firstOpen: firstOpen,
          now: now,
          meets: (c) => c.isMetBy(StoryState.of(flags)),
        );
    bool isFiller(NewsItem i) => news().filler.articles.contains(i.article);
    bool shows(DateTime now, String id, {Set<String> flags = const {}}) =>
        feedAt(now, flags: flags).any((i) => i.article.id == id);
    // Long enough for every everyday article to run a few times.
    DateTime muchLater() => firstOpen.add(
      Duration(
        hours: news().filler.maxHours * news().filler.articles.length * 3,
      ),
    );

    test('everyday news is there from the start', () {
      final feed = feedAt(firstOpen.add(const Duration(hours: 9)));
      final everyday = feed.where(isFiller).toList();
      expect(everyday, isNotEmpty);
      expect(everyday.length, lessThanOrEqualTo(news().filler.keep));
      final times = feed.map((i) => i.published).toList();
      expect(times, [...times]..sort((a, b) => b.compareTo(a)));
    });

    test('scheduled news comes out on its day', () {
      expect(shows(DateTime(2026, 3, 8, 23), 'one-week'), isFalse);
      expect(shows(DateTime(2026, 3, 9, 8), 'one-week'), isTrue);
      // Scheduled news can wait for the story too.
      final late = DateTime(2026, 3, 20);
      expect(shows(late, 'mezbaha-residents'), isFalse);
      expect(
        shows(late, 'mezbaha-residents', flags: {'mezbaha-found'}),
        isTrue,
      );
    });

    test('everyday news runs again once it has all run', () {
      final later = muchLater();
      final everyday = feedAt(later).where(isFiller).toList();
      expect(everyday.length, news().filler.keep);
      expect(everyday.every((i) => i.run >= 1), isTrue);
      expect(everyday.map((i) => i.key).toSet().length, everyday.length);
      // The schedule is the same every time it is worked out.
      expect(
        feedAt(later).map((i) => i.key).toList(),
        feedAt(later).map((i) => i.key).toList(),
      );
    });

    test('the same everyday article never runs twice in a row', () {
      final end = muchLater();
      for (
        var t = firstOpen;
        t.isBefore(end);
        t = t.add(const Duration(days: 1))
      ) {
        final ids = feedAt(t).where(isFiller).map((i) => i.article.id).toList();
        for (var i = 1; i < ids.length; i++) {
          expect(ids[i], isNot(ids[i - 1]), reason: '$t');
        }
      }
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
  'state.json' || 'news.json' || 'endings.json' => <String, Object>{},
  _ => [],
};

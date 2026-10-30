import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/board/board_app.dart';
import 'package:ledective/apps/store_apps/cipher/ciphers.dart';
import 'package:ledective/apps/news/news_app.dart';
import 'package:ledective/apps/poltel/poltel_app.dart';
import 'package:ledective/apps/sinstagram/sinstagram_app.dart';
import 'package:ledective/story/dialogue.dart';
import 'package:ledective/story/drip_feed.dart';
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
      expect(progress.awaitsReply('Özge'), isTrue);
      expect(progress.chatsNeedingAttention, greaterThanOrEqualTo(1));
      expect(progress.restore('Orhun').$1.canReply, isFalse);

      await say('Özge', 'Neymiş bu kadar önemli olan durum');
      await say('Özge', 'Yakınlarının ifadesini aldınız mı ?');
      await say('Özge', 'İfadeleri bana poltel üzerinden gönder');
      expect(progress.has(StoryFlags.part1Done), isTrue);
      expect(caseFiles().map((d) => d.id), ['autopsy', 'deniz', 'yusuf']);
      expect(progress.alerts.latest, isNotNull, reason: 'Orhun wrote');
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
      // Each message has its own notification.
      final behram = progress
          .restore('Behram')
          .$2
          .whereType<IncomingMessage>()
          .map((m) => m.text)
          .toList();
      expect(
        progress.alerts.items
            .where((a) => a.thread == 'Behram')
            .map((a) => a.body),
        behram.sublist(behram.length - 2),
      );
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
      expect(progress.alerts.items.first.app, 'Harita');
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

    group('chapter V', () {
      StoryProgress progress() => StoryProgress.instance;
      Future<void> mission(String taskId) async {
        final start = DateTime(2026, 1, 1);
        expect(
          await progress().startMission(
            StoryData.current.map.task(taskId)!,
            'Doğa',
            now: start,
          ),
          isTrue,
          reason: taskId,
        );
        await progress().completeDueMissions(
          now: start.add(const Duration(hours: 1)),
        );
      }

      bool visible(String taskId) =>
          progress().meets(StoryData.current.map.task(taskId)!.requires);

      Future<void> ozgeAtDesk() async {
        await progress().discover([StoryFlags.part1Done]);
        await say('Özge', 'Neymiş bu kadar önemli olan durum');
        await say('Özge', 'Yakınlarının ifadesini aldınız mı ?');
        await say('Özge', 'İfadeleri bana poltel üzerinden gönder');
      }

      Future<void> erdiAtDesk() async {
        await progress().discover([StoryFlags.part1Done, 'toxicology']);
        await say('Erdi', 'Biliyorsun nerede olduğumu');
        await say('Erdi', 'Sen içini ferah tut');
        await say('Erdi', 'Anlaşıldı müdürüm. Katile odaklanıyoruz.');
        await say(
          'Erdi',
          'Benim ekibimden kimse gazeteciyle konuşmaz müdürüm.',
        );
      }

      test(
        'the prosecutor\'s way frees Emre and brings the ring down',
        () async {
          await ozgeAtDesk();
          await progress().discover(['ev:berat-phone']);
          await say('Özge', 'Savcılığa teslim et. Tutanakla.');
          expect(progress().has('heard:farm'), isTrue);
          await say('Özge', 'Savcılıktan çiftlik için arama kararı iste.');
          expect(visible('farm-warrant'), isFalse);
          await progress().advanceTimers(const Duration(minutes: 12));
          expect(visible('farm-warrant'), isTrue);
          await mission('farm-warrant');
          expect(progress().has('emre:testimony'), isTrue);
          expect(progress().has('ev:farm-tainted'), isFalse);
          await progress().advanceTimers(const Duration(minutes: 10));
          expect(progress().has('coverup:exposed'), isTrue);
        },
      );

      test('the press warns the adviser, who moves Emre and runs', () async {
        await ozgeAtDesk();
        await progress().discover(['ev:berat-phone']);
        await say('Özge', 'Selin Aras\u2019a ver. Herkes duysun.');
        await progress().advanceTimers(const Duration(minutes: 8));
        expect(progress().has('emre:moved'), isTrue);
        expect(progress().has('danisman:fled'), isTrue);
        expect(visible('farm-raid'), isFalse);
        expect(visible('farm-late'), isTrue);
      });

      test('the leak traced to the detective can cost the job', () async {
        await erdiAtDesk();
        await progress().discover(['ev:berat-phone', 'player:dirty-hands']);
        await say('Erdi', 'Ben kimseyi aramadım.');
        expect(progress().has('leak:traced'), isTrue);
        await progress().advanceTimers(const Duration(minutes: 12));
        expect(progress().has('status:suspended'), isTrue);
        expect(progress().lockOf('Poltel'), isNotNull);
        // An illegal raid on top of that ends the career.
        await progress().discover(['ev:farm-tainted']);
        await progress().advanceTimers(const Duration(minutes: 10));
        expect(progress().has('status:dismissed'), isTrue);
      });

      test('a lawyer turns suspension into a reprimand', () async {
        await erdiAtDesk();
        await progress().discover(['ev:berat-phone', 'player:dirty-hands']);
        await say('Erdi', 'Numaramı biri kullanıyor olmalı.');
        await say('Av. Nesrin Kaya', 'Tamam. Gönderiyorum.');
        final lawyer = StoryData.current.bank.payees.firstWhere(
          (p) => p.id == 'lawyer',
        );
        await progress().recordTransfer(lawyer, 1500000);
        await progress().advanceTimers(const Duration(minutes: 14));
        expect(progress().has('status:suspended'), isFalse);
        expect(progress().has('status:warned'), isTrue);
      });
    });

    group('chapter VI', () {
      StoryProgress progress() => StoryProgress.instance;

      Future<void> emreRescued() async {
        await progress().discover([StoryFlags.part1Done]);
        await say('Özge', 'Neymiş bu kadar önemli olan durum');
        await say('Özge', 'Yakınlarının ifadesini aldınız mı ?');
        await say('Özge', 'İfadeleri bana poltel üzerinden gönder');
        await progress().discover(['emre:rescued', 'farm:entered']);
        await progress().advanceTimers(const Duration(minutes: 4));
        expect(progress().has('hakan:seen'), isTrue);
      }

      Iterable<String> ozgeSaid() => progress()
          .restore('Özge')
          .$2
          .whereType<IncomingMessage>()
          .map((m) => m.text);

      test('a guard catches Hakan, and the statement ends the game', () async {
        await emreRescued();
        await say('Özge', 'Resmî koruma iste. Kapısına iki polis.');
        await progress().advanceTimers(const Duration(minutes: 6));
        expect(progress().has('hakan:caught'), isTrue);
        expect(progress().has('emre:hurt'), isFalse);
        await say(
          'Özge',
          'Eşinin tedavisi için yasal bir yol bulalım. '
              'Karşılığında her şeyi anlatsın.',
        );
        final payee = StoryData.current.bank.payees.firstWhere(
          (p) => p.id == 'hakan-wife',
        );
        expect(progress().meets(payee.requires), isTrue);
        await progress().recordTransfer(payee, payee.minAmount);
        expect(progress().has('hakan:wife-paid'), isTrue);
        expect(
          StoryData.current.smsThreads
              .where((t) => progress().meets(t.requires))
              .map((t) => t.sender),
          contains('Nermin Demir'),
        );

        await progress().discover(['mp:answered', 'heard:kerem']);
        await progress().advanceTimers(const Duration(minutes: 4));
        expect(progress().has('prosecutor:calls'), isTrue);
        const prosecutor = 'Savcı Leyla Koç';
        await say(prosecutor, 'Sorun.');
        await say(prosecutor, 'Kerem Aydın.');
        await say(prosecutor, 'Bilmiyorum.');
        await say(prosecutor, 'Bilmiyorum.');
        expect(
          progress().restore(prosecutor).$1.options.map((o) => o.label),
          isNot(contains('...Nerede olduğumu bilmiyorum.')),
          reason: 'not enough doubt',
        );
        await say(prosecutor, 'Evet. İzindeydim.');
        expect(progress().isOver, isTrue);
        final hakan = StoryData.current.endings.sections.firstWhere(
          (s) => s.id == 'hakan',
        );
        expect(progress().ending(hakan)!.text, contains('Nermin'));
      });

      test('left alone, Hakan reaches Emre', () async {
        await emreRescued();
        await progress().advanceTimers(const Duration(minutes: 15));
        expect(progress().has('emre:hurt'), isTrue);
        await progress().advanceTimers(const Duration(minutes: 6));
        expect(progress().has('hakan:caught'), isTrue);
        // The question about protecting him came too late.
        await say('Özge', 'Ne oldu Özge?');
        expect(ozgeSaid(), contains('Amirim... Hakan Emre’ye ulaşmış.'));
      });

      test('a hiding place Orhun sold is found', () async {
        await emreRescued();
        await progress().discover(['emre:hidden', 'orhun:sold']);
        await progress().advanceTimers(const Duration(minutes: 6));
        expect(progress().has('emre:hurt'), isTrue);
      });

      test('enough doubt opens the hidden answer', () async {
        await progress().discover(['prosecutor:calls', 'doubt = 3']);
        const prosecutor = 'Savcı Leyla Koç';
        await say(prosecutor, 'Sorun.');
        await say(prosecutor, 'Bilmiyorum.');
        await say(prosecutor, 'Bilmiyorum.');
        await say(prosecutor, 'Bilmiyorum.');
        await say(prosecutor, '...Nerede olduğumu bilmiyorum.');
        expect(progress().has('twist:never-abroad'), isTrue);
        expect(progress().isOver, isTrue);
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

    test('places that open together come in one notification', () async {
      final progress = StoryProgress.instance;
      await progress.discover([StoryFlags.part1Done]);
      final places = progress.alerts.items.where((a) => a.app == 'Harita');
      expect(places, hasLength(1));
      final opened = StoryData.current.map.locations
          .where((l) => progress.meets(l.requires))
          .length;
      expect(places.single.title, '$opened yeni konum');
      expect(places.single.body, contains("Berat'ın Evi"));
      expect(places.single.body, contains(' ve '));
    });

    test('Şifre Çözücü recognises the line in Berat\'s notebook', () async {
      final progress = StoryProgress.instance;
      final notebook = StoryData.current.evidence.firstWhere(
        (e) => e.id == 'notebook',
      );
      final hidden = notebook.description.split(': ').last;
      final solved = caesar(hidden, -notebook.code!.shift);
      expect(await progress.recognise(solved), isNull, reason: 'not found yet');
      await progress.discover(['ev:notebook']);
      expect(await progress.recognise(hidden), isNull, reason: 'not solved');
      expect(await progress.recognise(solved), same(notebook));
      expect(progress.has('decoded:notebook'), isTrue);
    });

    test('opening something again does not count twice', () async {
      final progress = StoryProgress.instance;
      final clinic = StoryData.current.mailPool.mails.firstWhere(
        (m) => m.id == 'clinic',
      );
      expect(clinic.unlocksOnView, ['clue:clinic']);
      await progress.markSeen('rec:test', ['doubt += 1']);
      await progress.markSeen('rec:test', ['doubt += 1']);
      expect(progress.value('doubt'), 1);
    });

    test('messages that arrive together come in one by one', () async {
      final progress = StoryProgress.instance;
      progress.paceMessages = true;
      addTearDown(() => progress.paceMessages = false);
      var clock = DateTime(2026, 3, 2, 10);
      await progress.tick(now: clock);
      await say('Özge', 'Neymiş bu kadar önemli olan durum');
      await say('Özge', 'Yakınlarının ifadesini aldınız mı ?');
      await say('Özge', 'İfadeleri bana poltel üzerinden gönder');
      expect(progress.isTyping('Özge'), isFalse, reason: 'the open chat');
      final person = StoryData.current.conversations.keys.firstWhere(
        progress.isTyping,
      );
      int shown() =>
          progress.transcriptOf(person).whereType<IncomingMessage>().length;
      int banners() =>
          progress.alerts.items.where((a) => a.thread == person).length;
      final total = progress
          .restore(person)
          .$2
          .whereType<IncomingMessage>()
          .length;
      final before = shown();
      expect(before, lessThan(total));
      expect(banners(), 0);
      expect(progress.awaitsReply(person), isFalse);

      var last = before;
      for (var i = 0; i < 40 && progress.isTyping(person); i++) {
        clock = clock.add(const Duration(seconds: 2));
        await progress.tick(now: clock);
        expect(shown() - last, lessThanOrEqualTo(1), reason: 'one at a time');
        last = shown();
        expect(banners(), shown() - before);
      }
      expect(progress.isTyping(person), isFalse);
      expect(shown(), total);
      expect(progress.unreadCount(person), greaterThan(0));
    });

    test('a chat opened mid-way takes over the rest', () async {
      final progress = StoryProgress.instance;
      progress.paceMessages = true;
      addTearDown(() => progress.paceMessages = false);
      await progress.tick(now: DateTime(2026, 3, 2, 10));
      await say('Özge', 'Neymiş bu kadar önemli olan durum');
      await say('Özge', 'Yakınlarının ifadesini aldınız mı ?');
      await say('Özge', 'İfadeleri bana poltel üzerinden gönder');
      final person = StoryData.current.conversations.keys.firstWhere(
        progress.isTyping,
      );
      expect(progress.takeHeldBack(person), greaterThan(0));
      expect(progress.isTyping(person), isFalse);
    });

    group('hints', () {
      // Hints only, not the bank's own alerts, such as the incoming EFT.
      Iterable<String> bankAlerts() {
        final hints = {
          for (final h in StoryData.current.state.hints) h.alert!.title,
        };
        return StoryProgress.instance.alerts.items
            .map((a) => a.title)
            .where(hints.contains);
      }

      test('tell the player about the refund a while later', () async {
        final progress = StoryProgress.instance;
        final flags = progress.flags.toSet();
        await progress.discover(['mp:wrote']);
        await progress.advanceTimers(const Duration(minutes: 9));
        expect(bankAlerts(), isEmpty);
        await progress.advanceTimers(const Duration(minutes: 1));
        expect(bankAlerts(), ['Hesabınıza 50.000 TL geldi']);
        expect(progress.flags.toSet(), {...flags, 'mp:wrote'});
        await progress.advanceTimers(const Duration(minutes: 30));
        expect(bankAlerts(), hasLength(1), reason: 'only once');
      });

      test('stay quiet once the player has acted', () async {
        final progress = StoryProgress.instance;
        await progress.discover(['mp:wrote']);
        final payee = StoryData.current.bank.payees.firstWhere(
          (p) => p.id == 'bribe-return',
        );
        await progress.recordTransfer(payee, 5000000);
        await progress.discover(['lawyer:offer', 'lawyer:declined']);
        await progress.advanceTimers(const Duration(minutes: 20));
        expect(bankAlerts(), isEmpty);
      });

      test('can be turned off', () async {
        final progress = StoryProgress.instance;
        await progress.setHints(false);
        await progress.discover(['heard:orhun-debt']);
        await progress.advanceTimers(const Duration(minutes: 20));
        expect(bankAlerts(), isEmpty);
        await progress.setHints(true);
        await progress.advanceTimers(const Duration(minutes: 6));
        expect(bankAlerts(), ['Kayıtlı alıcı: Orhun K.']);
      });
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
    bool shows(DateTime now, String id, {Set<String> flags = const {}}) =>
        feedAt(now, flags: flags).any((i) => i.article.id == id);

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

    test('only the latest everyday news stays in the feed', () {
      final pool = news().filler.articles;
      final feed = newsFeed(
        news(),
        firstOpen: firstOpen,
        now: firstOpen,
        meets: (_) => true,
        filler: [
          for (final (i, a) in pool.indexed)
            NewsItem(a, firstOpen.subtract(Duration(minutes: i))),
        ],
      );
      final everyday = feed.where((i) => pool.contains(i.article)).toList();
      expect(everyday.length, news().filler.keep);
      expect(everyday.first.article, pool.first);
    });
  });

  group('AlertQueue', () {
    test('spaces out a burst, one app at a time', () {
      final queue = AlertQueue()..spacing = const Duration(seconds: 2);
      // The first batch shows right away, timed by the real clock.
      final t = DateTime.now();
      StoryAlert alert(String app, String body) =>
          StoryAlert(app: app, title: app, body: body);
      queue.pushAll([
        alert('Harita', 'Kafe'),
        alert('Mail', 'Yeni mail'),
        alert('Harita', 'Üniversite'),
        alert('News', 'Son dakika'),
      ]);
      expect(queue.items.map((a) => a.body), ['Kafe', 'Üniversite']);
      queue.release(t.add(const Duration(milliseconds: 500)));
      expect(queue.items, hasLength(2), reason: 'not its turn yet');
      queue.release(t.add(const Duration(seconds: 3)));
      expect(queue.items, hasLength(3), reason: 'Mail, after its turn');
      queue.clearApp('News');
      queue.release(t.add(const Duration(seconds: 6)));
      expect(queue.items.map((a) => a.app), ['Harita', 'Harita', 'Mail']);
    });
  });

  group('DripFeed', () {
    final at = DateTime(2026, 3, 2);
    final ids = [for (var i = 0; i < 6; i++) 'item$i'];

    test('every item comes once before any comes again', () {
      final feed = DripFeed();
      for (var i = 0; i < ids.length * 3; i++) {
        feed.drops.add(feed.next(ids, at: at, seed: 7)!);
      }
      for (var round = 0; round < 3; round++) {
        final ofRound = feed.drops.skip(round * ids.length).take(ids.length);
        expect(ofRound.map((d) => d.id).toSet(), ids.toSet());
        expect(ofRound.every((d) => d.run == round), isTrue);
      }
      for (var i = 1; i < feed.drops.length; i++) {
        expect(feed.drops[i].id, isNot(feed.drops[i - 1].id));
      }
      expect(feed.drops.map((d) => d.key).toSet().length, feed.drops.length);
    });

    test('items wait for their condition and can come only once', () {
      final feed = DripFeed();
      bool early(String id) => id != 'item0';
      for (var i = 0; i < ids.length - 1; i++) {
        feed.drops.add(
          feed.next(ids, at: at, seed: 7, eligible: early, recycle: false)!,
        );
      }
      expect(feed.drops.map((d) => d.id), isNot(contains('item0')));
      expect(
        feed.next(ids, at: at, seed: 7, eligible: early, recycle: false),
        isNull,
      );
      expect(feed.next(ids, at: at, seed: 7, recycle: false)!.id, 'item0');
    });
  });

  group('Everyday mail and news', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StoryProgress.instance.load(await SharedPreferences.getInstance());
    });

    final start = DateTime(2026, 3, 2, 10);
    var clock = start;

    /// Plays for [time] in steps short enough to count as play.
    Future<void> play(Duration time) async {
      final end = clock.add(time);
      while (clock.isBefore(end)) {
        clock = clock.add(const Duration(seconds: 10));
        await StoryProgress.instance.tick(now: clock);
      }
    }

    setUp(() => clock = start);

    test('some were there before the game began, without banners', () async {
      final progress = StoryProgress.instance;
      await progress.tick(now: clock);
      final inbox = progress.inbox;
      expect(inbox.length, StoryData.current.mailPool.start);
      expect(inbox.every((e) => e.$2.isBefore(clock)), isTrue);
      final filler = StoryData.current.news.filler;
      expect(
        progress
            .newsFeedAt(clock)
            .where((i) => filler.articles.contains(i.article))
            .length,
        filler.start,
      );
      expect(progress.alerts.items, isEmpty);
    });

    test('more come as the player plays, each with a banner', () async {
      final progress = StoryProgress.instance;
      await progress.tick(now: clock);
      final before = progress.inbox.length;
      await play(
        Duration(minutes: StoryData.current.mailPool.maxMinutes * 2 + 6),
      );
      expect(progress.inbox.length, greaterThan(before));
      expect(progress.alerts.items.map((a) => a.app), contains('Mail'));
      expect(progress.alerts.items.map((a) => a.app), contains('News'));
      // Mail that waits for the story doesn't come before it.
      expect(
        progress.inbox.map((e) => e.$1.id),
        isNot(contains('journalist-1')),
      );
    });

    test('story mail can take a while to arrive', () async {
      final progress = StoryProgress.instance;
      await progress.tick(now: clock);
      await progress.discover([StoryFlags.part1Done]);
      List<String> ids() => [for (final (m, _) in progress.inbox) m.id];
      expect(ids(), contains('berat-priority'));
      expect(ids(), isNot(contains('leave-cancelled')));
      await play(const Duration(minutes: 7));
      expect(ids(), contains('leave-cancelled'));
    });

    test('scams and old read mail go to Spam, story mail never', () async {
      final progress = StoryProgress.instance;
      await progress.tick(now: clock);
      await progress.discover([StoryFlags.part1Done]);
      for (var i = 0; i < 25; i++) {
        await progress.dripNow();
      }
      // Unread mail only goes to Spam if it's a scam, and scams don't ring.
      for (final (mail, _) in progress.spam) {
        expect(mail.spam, isTrue, reason: mail.id);
        expect(
          progress.alerts.items.where((a) => a.body == mail.subject),
          isEmpty,
        );
      }
      for (final (mail, _) in progress.inbox) {
        await progress.markSeen('mail:${mail.id}');
      }
      final spam = [for (final (m, _) in progress.spam) m];
      expect(spam.where((m) => !m.spam), isNotEmpty);
      expect(spam.any(progress.isCanonMail), isFalse);
      final everyday = progress.inboxFolder.where(
        (e) => !progress.isCanonMail(e.$1),
      );
      expect(everyday, hasLength(StoryData.current.mailPool.keepRead));
      expect(
        progress.inboxFolder.map((e) => e.$1.id),
        contains('berat-priority'),
        reason: 'story mail stays',
      );
      final rescued = spam.firstWhere((m) => !m.spam);
      await progress.markSeen('notspam:${rescued.id}');
      expect(progress.inboxFolder.map((e) => e.$1), contains(rescued));
    });

    test('old everyday news moves to the archive once read', () async {
      final progress = StoryProgress.instance;
      await progress.tick(now: clock);
      for (var i = 0; i < 12; i++) {
        await progress.dripNow(mail: false);
      }
      final filler = StoryData.current.news.filler;
      final everydayIds = {for (final a in filler.articles) a.id};
      List<NewsItem> everyday() => progress
          .newsFeedAt()
          .where((i) => everydayIds.contains(i.article.id))
          .toList();
      final total = everyday().length;
      expect(total, greaterThan(filler.keep), reason: 'unread ones stay');
      expect(progress.archivedNews, isEmpty);
      for (final item in everyday()) {
        await progress.markSeen('news:${item.key}');
      }
      expect(everyday(), hasLength(filler.keep));
      expect(progress.archivedNews, hasLength(total - filler.keep));
    });

    test('wait while the player doesn\'t open Mail or News', () async {
      final progress = StoryProgress.instance;
      progress.fastMissions = true;
      addTearDown(() => progress.fastMissions = false);
      await progress.tick(now: clock);
      final pool = {for (final m in StoryData.current.mailPool.mails) m.id};
      int everydayMail() =>
          progress.inbox.where((e) => pool.contains(e.$1.id)).length;
      int newsAlerts() =>
          progress.alerts.items.where((a) => a.app == 'News').length;
      final mailAtStart = everydayMail();
      final mailPause = StoryData.current.mailPool.pauseAfter;
      final newsPause = StoryData.current.news.filler.pauseAfter;

      await play(const Duration(minutes: 15));
      expect(everydayMail(), mailAtStart + mailPause);
      expect(newsAlerts(), newsPause);

      // Opening the apps lets them come again.
      await progress.lookedAt();
      await progress.lookedAt(mail: false);
      await play(const Duration(minutes: 5));
      expect(everydayMail(), greaterThan(mailAtStart + mailPause));
      expect(newsAlerts(), greaterThan(newsPause));
    });
  });
}

Object _emptyFile(String file) => switch (file) {
  'chats.json' => <String, Object>{},
  'mails.json' => {'story': []},
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

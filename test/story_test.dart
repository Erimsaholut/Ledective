import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/messages/messages_app.dart';
import 'package:ledective/apps/poltel/documents.dart';
import 'package:ledective/apps/poltel/poltel_app.dart';
import 'package:ledective/data/game_data.dart';
import 'package:ledective/story/conversations.dart';
import 'package:ledective/story/dialogue.dart';
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
      waitFor: 'flag',
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

  group('story conversations', () {
    final unlockable = {
      for (final c in conversations.values)
        for (final node in c.dialogue?.nodes.values ?? <DialogueNode>[])
          for (final option in node.options) ...option.unlocks,
    };

    conversations.forEach((person, conversation) {
      final dialogue = conversation.dialogue;
      if (dialogue == null) return;

      test('$person: every node can be reached and every link resolves', () {
        expect(dialogue.nodes, contains(dialogue.start));
        final reached = <String>{};
        final pending = [dialogue.start];
        while (pending.isNotEmpty) {
          final id = pending.removeLast();
          if (!reached.add(id)) continue;
          final node = dialogue.nodes[id];
          expect(node, isNotNull, reason: '"$id" is linked but missing');
          expect(
            node!.options.isNotEmpty || node.incoming.isNotEmpty,
            isTrue,
            reason: '"$id" is empty',
          );
          if (node.waitFor case final flag?) {
            expect(unlockable, contains(flag), reason: '"$id" waits forever');
          }
          for (final option in node.options) {
            if (option.next != null) pending.add(option.next!);
          }
        }
        expect(
          reached,
          dialogue.nodes.keys.toSet(),
          reason: 'some nodes are unreachable',
        );
      });
    });

    test('everything the apps wait for can be unlocked', () {
      for (final document in poltelDocuments) {
        expect(unlockable, contains(document.requires), reason: document.id);
      }
      for (final mail in storyMails) {
        expect(unlockable, contains(mail.requires), reason: mail.sender);
      }
      for (final thread in smsThreads) {
        if (thread.requires != null) {
          expect(unlockable, contains(thread.requires), reason: thread.sender);
        }
      }
    });
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
  });
}

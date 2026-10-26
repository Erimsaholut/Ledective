import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/story/conversations.dart';
import 'package:ledective/story/dialogue.dart';

const _dialogue = Dialogue(
  start: 'a',
  nodes: {
    'a': DialogueNode([
      DialogueOption(label: 'to b', replies: ['b1', 'b2'], next: 'b'),
      DialogueOption(label: 'end', message: 'bye'),
    ]),
    'b': DialogueNode([
      DialogueOption(label: 'done', replies: ['ok']),
    ]),
  },
);

void main() {
  group('DialogueState', () {
    test('starts at the start node', () {
      final state = DialogueState(_dialogue);
      expect(state.options.map((o) => o.label), ['to b', 'end']);
      expect(state.isFinished, isFalse);
    });

    test('follows the chosen option to the next node', () {
      final state = DialogueState(_dialogue);
      final option = state.choose(0);
      expect(option.replies, ['b1', 'b2']);
      expect(state.options.single.label, 'done');
      expect(state.choices, [0]);
    });

    test('finishes on an option without a next node', () {
      final state = DialogueState(_dialogue)..choose(1);
      expect(state.isFinished, isTrue);
      expect(state.options, isEmpty);
    });

    test('message defaults to the label', () {
      expect(_dialogue.nodes['a']!.options[0].message, 'to b');
      expect(_dialogue.nodes['a']!.options[1].message, 'bye');
    });

    test('replay rebuilds the transcript of saved choices', () {
      final entries = DialogueState(_dialogue).replay([0, 0]);
      expect(
        entries.map(
          (e) => switch (e) {
            OutgoingMessage(:final text) => '> $text',
            IncomingMessage(:final text) => '< $text',
            DayMarker() => '--',
          },
        ),
        ['> to b', '< b1', '< b2', '> done', '< ok'],
      );
    });

    test('replay ignores saved choices that no longer fit', () {
      final state = DialogueState(_dialogue);
      final entries = state.replay([5, 0]);
      expect(entries, isEmpty);
      expect(state.choices, isEmpty);
    });

    test('a conversation without dialogue is finished', () {
      expect(DialogueState(null).isFinished, isTrue);
    });
  });

  group('story conversations', () {
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
          expect(node!.options, isNotEmpty, reason: '"$id" has no options');
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
  });
}

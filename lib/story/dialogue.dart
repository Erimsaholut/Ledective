/// One line in a chat transcript.
sealed class ChatEntry {
  const ChatEntry();
}

class IncomingMessage extends ChatEntry {
  const IncomingMessage(this.text);
  final String text;
}

class OutgoingMessage extends ChatEntry {
  const OutgoingMessage(this.text);
  final String text;
}

/// A date separator. Shows [label] when given, otherwise the number of days
/// between the message and now, where [daysAgo] counts from the day the game
/// was first opened.
class DayMarker extends ChatEntry {
  const DayMarker({this.daysAgo = 0, this.label});
  final int daysAgo;
  final String? label;
}

/// A reply the player can pick on the chat keyboard.
class DialogueOption {
  const DialogueOption({
    required this.label,
    String? message,
    this.replies = const [],
    this.next,
  }) : _message = message;

  /// Text on the keyboard button.
  final String label;
  final String? _message;

  /// Text that is sent. Defaults to [label].
  String get message => _message ?? label;

  /// Messages the other person answers with, in order.
  final List<String> replies;

  /// Id of the node to continue with, or null when the conversation is over.
  final String? next;
}

class DialogueNode {
  const DialogueNode(this.options);
  final List<DialogueOption> options;
}

class Dialogue {
  const Dialogue({required this.start, required this.nodes});
  final String start;
  final Map<String, DialogueNode> nodes;
}

/// Everything MatesApp knows about one person: the messages exchanged before
/// the game starts and the branching dialogue the player can continue with.
class Conversation {
  const Conversation({this.history = const [], this.dialogue});
  final List<ChatEntry> history;
  final Dialogue? dialogue;
}

/// Walks a [Dialogue] one choice at a time.
class DialogueState {
  DialogueState(this.dialogue) : _nodeId = dialogue?.start;

  final Dialogue? dialogue;
  String? _nodeId;
  final List<int> _choices = [];

  /// Indices of the options picked so far, used to save and restore progress.
  List<int> get choices => List.unmodifiable(_choices);

  List<DialogueOption> get options {
    final id = _nodeId;
    if (id == null) return const [];
    final node = dialogue!.nodes[id];
    if (node == null) {
      throw StateError('Dialogue has no node with id "$id"');
    }
    return node.options;
  }

  bool get isFinished => options.isEmpty;

  DialogueOption choose(int index) {
    final option = options[index];
    _choices.add(index);
    _nodeId = option.next;
    return option;
  }

  /// Replays saved [choices], returning the transcript they produced.
  /// Stops early if the saved choices no longer fit the dialogue.
  List<ChatEntry> replay(List<int> choices) {
    final entries = <ChatEntry>[];
    for (final index in choices) {
      if (index < 0 || index >= options.length) break;
      final option = choose(index);
      entries
        ..add(OutgoingMessage(option.message))
        ..addAll(option.replies.map(IncomingMessage.new));
    }
    return entries;
  }
}

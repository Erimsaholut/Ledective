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

/// A story requirement: every flag in [all] and, if given, at least one
/// flag in [any] must be set.
class Condition {
  const Condition({this.all = const [], this.any = const []});

  static const always = Condition();

  final List<String> all;
  final List<String> any;

  bool get isAlways => all.isEmpty && any.isEmpty;

  Iterable<String> get flags => [...all, ...any];

  bool isMetBy(bool Function(String flag) has) =>
      all.every(has) && (any.isEmpty || any.any(has));
}

/// The detective's personality, shaped by the player's choices
/// ("Gezici tablo" in the story design).
enum Trait {
  anger('Öfke'),
  mercy('Merhamet'),
  curiosity('Merak'),
  courage('Cesur'),
  indifference('Umursamaz'),
  caution('Temkinli');

  const Trait(this.label);
  final String label;
}

/// A reply the player can pick on the chat keyboard.
class DialogueOption {
  const DialogueOption({
    required this.label,
    String? message,
    this.replies = const [],
    this.next,
    this.traits = const [],
    this.unlocks = const [],
    this.silent = false,
    this.testimony,
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

  /// Personality points the player earns for this choice.
  final List<Trait> traits;

  /// Story flags set by this choice. Other conversations and apps wait for
  /// these (see [DialogueNode.waitFor]).
  final List<String> unlocks;

  /// When true nothing is sent, e.g. "(Cevap verme)".
  final bool silent;

  /// For interrogations: the suspect's answer to [message], recorded in the
  /// statement ("İfade Tutanağı") that is built from the conversation.
  final String? testimony;
}

class DialogueNode {
  const DialogueNode(
    this.options, {
    this.incoming = const [],
    this.waitFor = Condition.always,
  });

  /// Messages the other person sends when the conversation reaches this
  /// node. A node without [options] just delivers these and ends the chat.
  final List<String> incoming;

  /// Story flags that have to be set before [incoming] arrives and the
  /// player can answer. Until then the conversation pauses here.
  final Condition waitFor;

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
  DialogueState(this.dialogue, {bool Function(String flag)? hasFlag})
    : _hasFlag = hasFlag ?? _noFlags,
      _nodeId = dialogue?.start;

  static bool _noFlags(String _) => false;

  final Dialogue? dialogue;
  final bool Function(String flag) _hasFlag;
  String? _nodeId;
  bool _arrived = false;
  final List<int> _choices = [];

  /// Indices of the options picked so far, used to save and restore progress.
  List<int> get choices => List.unmodifiable(_choices);

  DialogueNode? get _node {
    final id = _nodeId;
    if (id == null) return null;
    final node = dialogue!.nodes[id];
    if (node == null) {
      throw StateError('Dialogue has no node with id "$id"');
    }
    return node;
  }

  /// True while the conversation waits for a story flag.
  bool get isWaiting {
    final condition = _node?.waitFor;
    return condition != null && !condition.isMetBy(_hasFlag);
  }

  List<DialogueOption> get options =>
      !_arrived || isWaiting ? const [] : _node?.options ?? const [];

  /// True when there is nothing left to answer, for now or for good.
  bool get canReply => options.isNotEmpty;

  /// True when the conversation has reached its end.
  bool get isFinished => _node == null || (_arrived && _node!.options.isEmpty);

  /// Delivers the current node's incoming messages, if it is ready and they
  /// haven't been delivered yet.
  List<String> arrive() {
    final node = _node;
    if (node == null || _arrived || isWaiting) return const [];
    _arrived = true;
    return node.incoming;
  }

  DialogueOption choose(int index) {
    final option = options[index];
    _choices.add(index);
    _nodeId = option.next;
    _arrived = false;
    return option;
  }

  /// Replays saved [choices], returning the transcript they produced,
  /// including messages of the node reached last. Stops early if the saved
  /// choices no longer fit the dialogue.
  List<ChatEntry> replay(List<int> choices) {
    final entries = <ChatEntry>[...arrive().map(IncomingMessage.new)];
    for (final index in choices) {
      if (index < 0 || index >= options.length) break;
      final option = choose(index);
      if (!option.silent) entries.add(OutgoingMessage(option.message));
      entries
        ..addAll(option.replies.map(IncomingMessage.new))
        ..addAll(arrive().map(IncomingMessage.new));
    }
    return entries;
  }
}

import 'story_terms.dart';

export 'story_terms.dart';

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

/// A story requirement: every term in [all] and, if given, at least one
/// term in [any] must hold. Terms are flags, negated flags or comparisons
/// (see [Requirement]).
class Condition {
  const Condition({this.all = const [], this.any = const []});

  static const always = Condition();

  final List<String> all;
  final List<String> any;

  bool get isAlways => all.isEmpty && any.isEmpty;

  Iterable<String> get terms => [...all, ...any];

  bool isMetBy(StoryState state) {
    bool holds(String term) => Requirement.parse(term).isMetBy(state);
    return all.every(holds) && (any.isEmpty || any.any(holds));
  }
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
    this.requires = Condition.always,
    this.once = true,
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

  /// Story flags set (and numbers changed) by this choice, see [Effect].
  /// Other conversations and apps wait for these (see
  /// [DialogueNode.waitFor]).
  final List<String> unlocks;

  /// When true nothing is sent, e.g. "(Cevap verme)".
  final bool silent;

  /// For interrogations: the suspect's answer to [message], recorded in the
  /// statement ("İfade Tutanağı") that is built from the conversation.
  final String? testimony;

  /// The option is only on the keyboard while this holds.
  final Condition requires;

  /// For [DialogueNode.ask] options: disappears once asked. When false the
  /// player can ask again and again.
  final bool once;
}

class DialogueNode {
  const DialogueNode(
    this.options, {
    this.incoming = const [],
    this.waitFor = Condition.always,
    this.ask = const [],
  });

  /// Messages the other person sends when the conversation reaches this
  /// node. A node without [options] just delivers these and ends the chat.
  final List<String> incoming;

  /// What has to hold before [incoming] arrives and the player can
  /// answer. Until then the conversation pauses here.
  final Condition waitFor;

  final List<DialogueOption> options;

  /// Questions the player can ask while the conversation waits here (for
  /// [waitFor], or for good after the last [incoming]): "Son durum ne?".
  /// They get their replies and the conversation stays where it is.
  final List<DialogueOption> ask;
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
///
/// Choices are saved as numbers: an option's place in the node's `options`,
/// or 1000 + its place in `ask` when asked before the node's messages
/// arrived, or 2000 + its place when asked after.
class DialogueState {
  DialogueState(this.dialogue, {StoryState? state})
    : _state = state ?? StoryState.of(const {}),
      _nodeId = dialogue?.start;

  static const _askedWaiting = 1000;
  static const _askedAfter = 2000;

  final Dialogue? dialogue;
  final StoryState _state;
  String? _nodeId;
  bool _arrived = false;
  final List<int> _choices = [];

  /// Ask options already asked, as "node/index".
  final Set<String> _asked = {};

  /// Saved numbers of the options picked so far, to restore progress.
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
    return condition != null && !condition.isMetBy(_state);
  }

  /// What is on the keyboard, with each option's saved number.
  List<(DialogueOption, int)> get _keyboard {
    final node = _node;
    if (node == null) return const [];
    final waiting = isWaiting;
    final answering = _arrived && !waiting && node.options.isNotEmpty;
    return [
      if (answering)
        for (final (i, o) in node.options.indexed)
          if (o.requires.isMetBy(_state)) (o, i),
      // Questions fit while nothing else is asked of the player.
      if (!answering && (waiting || _arrived))
        for (final (i, o) in node.ask.indexed)
          if (o.requires.isMetBy(_state) &&
              !(o.once && _asked.contains('$_nodeId/$i')))
            (o, (waiting ? _askedWaiting : _askedAfter) + i),
    ];
  }

  /// The options on the keyboard right now.
  List<DialogueOption> get options => [for (final (o, _) in _keyboard) o];

  /// True when there is something to answer or ask.
  bool get canReply => _keyboard.isNotEmpty;

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

  /// Picks option [index] of [options].
  DialogueOption choose(int index) {
    final (option, saved) = _keyboard[index];
    _apply(saved);
    return option;
  }

  /// Applies a saved choice, or returns null if it doesn't fit.
  DialogueOption? _apply(int saved) {
    final node = _node;
    if (node == null) return null;
    if (saved >= _askedWaiting) {
      final i = saved % _askedWaiting;
      if (i >= node.ask.length) return null;
      _asked.add('$_nodeId/$i');
      _choices.add(saved);
      return node.ask[i];
    }
    if (saved < 0 || saved >= node.options.length || !_arrived) return null;
    final option = node.options[saved];
    _choices.add(saved);
    _nodeId = option.next;
    _arrived = false;
    return option;
  }

  /// Replays saved [choices], returning the transcript they produced,
  /// including messages of the node reached last. Stops early if the saved
  /// choices no longer fit the dialogue. [onChoice] sees every option.
  List<ChatEntry> replay(
    List<int> choices, {
    void Function(DialogueOption option)? onChoice,
  }) {
    final entries = <ChatEntry>[];
    void deliver() => entries.addAll(arrive().map(IncomingMessage.new));
    for (final saved in choices) {
      // A question asked while waiting came before the node's messages.
      final whileWaiting = saved >= _askedWaiting && saved < _askedAfter;
      if (!whileWaiting) deliver();
      final option = _apply(saved);
      if (option == null) break;
      onChoice?.call(option);
      if (!option.silent) entries.add(OutgoingMessage(option.message));
      entries.addAll(option.replies.map(IncomingMessage.new));
    }
    deliver();
    return entries;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../story/dialogue.dart';
import '../../story/story_progress.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/day_divider.dart';

/// A story conversation in MatesApp. The player answers by picking one of
/// the options on the keyboard.
class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.person,
    this.replyDelay = const Duration(seconds: 1),
  });

  final String person;

  /// Time between the other person's replies.
  final Duration replyDelay;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final StoryProgress _progress = StoryProgress.instance;
  late final DialogueState _dialogue;
  late final List<ChatEntry> _entries;

  final List<Timer> _replyTimers = [];
  bool _keyboardVisible = false;

  bool get _typing => _replyTimers.any((timer) => timer.isActive);

  @override
  void initState() {
    super.initState();
    final (dialogue, transcript) = _progress.restore(widget.person);
    _dialogue = dialogue;
    _entries = transcript;
    _progress.markRead(widget.person);
  }

  @override
  void dispose() {
    for (final timer in _replyTimers) {
      timer.cancel();
    }
    // Replies that were still on their way count as read, too.
    _progress.markRead(widget.person);
    super.dispose();
  }

  Future<void> _send(int index) async {
    final option = await _progress.choose(widget.person, _dialogue, index);
    // The player is watching the replies arrive, so they count as read.
    await _progress.markRead(widget.person);
    if (!mounted) return;
    final replies = [...option.replies, ..._dialogue.arrive()];
    setState(() {
      // The keyboard stays open; it hides itself while replies are typed.
      if (!option.silent) _entries.add(OutgoingMessage(option.message));
    });

    for (var i = 0; i < replies.length; i++) {
      _replyTimers.add(
        Timer(widget.replyDelay * (i + 1), () {
          setState(() => _entries.add(IncomingMessage(replies[i])));
        }),
      );
    }
    // Rebuild once more so "typing…" shows while the replies are pending.
    setState(() {});
  }

  Widget _buildEntry(ChatEntry entry) {
    return switch (entry) {
      IncomingMessage(:final text) => ChatBubble(text: text, outgoing: false),
      OutgoingMessage(:final text) => ChatBubble(text: text, outgoing: true),
      DayMarker(:final daysAgo, :final label) => DayDivider(
        daysAgo: daysAgo,
        label: label,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final canReply = _dialogue.canReply && !_typing;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.person),
            if (_typing)
              const Text(
                "yazıyor...",
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
      backgroundColor: Colors.green.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // Reversed so the newest message stays pinned to the bottom.
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(10),
                itemCount: _entries.length,
                itemBuilder: (context, index) =>
                    _buildEntry(_entries[_entries.length - 1 - index]),
              ),
            ),
            if (canReply) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _keyboardVisible = !_keyboardVisible),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black.withValues(alpha: 0.5),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(
                      _keyboardVisible ? "Close Keyboard" : "Send Message",
                    ),
                  ),
                ),
              ),
              if (_keyboardVisible) _buildKeyboard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final options = _dialogue.options;
    return Container(
      color: Colors.grey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _send(i),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                child: Text(
                  options[i].label,
                  textAlign: TextAlign.center,
                  style: options[i].silent
                      ? const TextStyle(fontStyle: FontStyle.italic)
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

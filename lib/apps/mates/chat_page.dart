import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../story/conversations.dart';
import '../../story/dialogue.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/day_divider.dart';

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
  late final Conversation _conversation =
      conversations[widget.person] ?? const Conversation();
  late final DialogueState _dialogue = DialogueState(_conversation.dialogue);
  late final List<ChatEntry> _entries = [..._conversation.history];

  final List<Timer> _replyTimers = [];
  bool _loaded = false;
  bool _keyboardVisible = false;

  String get _prefsKey => 'chatChoices.${widget.person}';

  bool get _awaitingReply => _replyTimers.any((timer) => timer.isActive);

  @override
  void initState() {
    super.initState();
    _restoreProgress();
  }

  @override
  void dispose() {
    for (final timer in _replyTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> _restoreProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    final choices = stored == null
        ? <int>[]
        : (json.decode(stored) as List).cast<int>();
    if (!mounted) return;
    setState(() {
      _entries.addAll(_dialogue.replay(choices));
      _loaded = true;
    });
  }

  Future<void> _send(int index) async {
    final option = _dialogue.choose(index);
    setState(() {
      _entries.add(OutgoingMessage(option.message));
      if (_dialogue.isFinished) _keyboardVisible = false;
    });

    for (var i = 0; i < option.replies.length; i++) {
      _replyTimers.add(
        Timer(widget.replyDelay * (i + 1), () {
          setState(() => _entries.add(IncomingMessage(option.replies[i])));
        }),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(_dialogue.choices));
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
    final canReply = _loaded && !_dialogue.isFinished;
    return Scaffold(
      appBar: AppBar(title: Text(widget.person), backgroundColor: Colors.green),
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
                onPressed: _awaitingReply ? null : () => _send(i),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  disabledForegroundColor: Colors.black38,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                child: Text(options[i].label, textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}

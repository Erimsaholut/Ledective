import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../story/dialogue.dart';
import '../../story/story_progress.dart';
import '../../widgets/avatar.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/day_divider.dart';
import '../phone/call_screen.dart';
import 'mates_style.dart';

/// A story conversation in MatesApp. The player answers by picking one of
/// the suggested replies above the message bar.
class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.person,
    this.number,
    this.replyDelay = const Duration(seconds: 1),
  });

  final String person;

  /// The person's phone number, for the call button.
  final String? number;

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

  void _call() {
    final number = widget.number;
    if (number == null) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CallScreen(number: number, person: widget.person),
      ),
    );
  }

  /// Which side [entry] is on, or null for date markers.
  bool? _side(ChatEntry entry) => switch (entry) {
    IncomingMessage() => false,
    OutgoingMessage() => true,
    DayMarker() => null,
  };

  Widget _buildEntry(int index) {
    final entry = _entries[index];
    final previous = index > 0 ? _side(_entries[index - 1]) : null;
    return switch (entry) {
      IncomingMessage(:final text) => ChatBubble(
        text: text,
        outgoing: false,
        outgoingColor: MatesColors.outgoing,
        tail: previous != false,
      ),
      OutgoingMessage(:final text) => ChatBubble(
        text: text,
        outgoing: true,
        outgoingColor: MatesColors.outgoing,
        tail: previous != true,
      ),
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
      backgroundColor: MatesColors.chatBackground,
      appBar: AppBar(
        backgroundColor: MatesColors.header,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Avatar(name: widget.person, radius: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.person,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _typing ? "yazıyor..." : "çevrimiçi",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.number != null)
            IconButton(
              tooltip: "Ara",
              onPressed: _call,
              icon: const Icon(Icons.call_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // Reversed so the newest message stays pinned to the bottom.
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                itemCount: _entries.length,
                itemBuilder: (context, index) =>
                    _buildEntry(_entries.length - 1 - index),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.bottomCenter,
              child: canReply
                  ? _buildReplies()
                  : const SizedBox(width: double.infinity),
            ),
            ChatInputBar(
              hint: canReply
                  ? "Bir yanıt seç"
                  : _dialogue.isFinished
                  ? "Mesaj"
                  : "Yanıt bekleniyor...",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplies() {
    final options = _dialogue.options;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Önerilen yanıtlar",
            style: TextStyle(
              color: MatesColors.secondaryText,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => _send(i),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MatesColors.header,
                  side: const BorderSide(color: Color(0xFFB9DFD5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  options[i].label,
                  style: TextStyle(
                    fontSize: 15,
                    color: MatesColors.text,
                    fontStyle: options[i].silent ? FontStyle.italic : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

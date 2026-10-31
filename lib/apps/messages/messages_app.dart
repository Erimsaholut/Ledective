import 'package:flutter/material.dart';

import '../../data/game_clock.dart';
import '../../story/dialogue.dart';
import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/day_divider.dart';

/// The phone's plain text messages: operator notices, the bank and family.
class MessagesApp extends StatelessWidget {
  const MessagesApp({super.key});

  static bool _isPerson(String sender) =>
      sender == "Annem" || sender == "Bilinmeyen Numara";

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final threads = smsConversations(progress);
          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(
                backgroundColor: Colors.white,
                title: Text("Messages"),
              ),
              SliverList.separated(
                itemCount: threads.length,
                separatorBuilder: (_, _) => const Divider(indent: 76),
                itemBuilder: (context, index) {
                  final parts = threads[index];
                  final sender = parts.first.sender;
                  final unread = parts.any(
                    (t) => !progress.hasSeen('sms:${t.id}'),
                  );
                  return ListTile(
                    tileColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          child: unread
                              ? const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: AppColors.blue,
                                )
                              : null,
                        ),
                        Avatar(
                          name: sender,
                          icon: _isPerson(sender)
                              ? null
                              : Icons.business_rounded,
                        ),
                      ],
                    ),
                    title: Text(
                      sender,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      messagePreview(parts.last.messages.last),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      for (final t in parts) {
                        progress.markSeen('sms:${t.id}', t.unlocksOnView);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => _ThreadPage(
                            parts: parts,
                            isPerson: _isPerson(sender),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThreadPage extends StatelessWidget {
  const _ThreadPage({required this.parts, required this.isPerson});

  /// One sender's threads, oldest first.
  final List<SmsThread> parts;
  final bool isPerson;

  @override
  Widget build(BuildContext context) {
    final thread = parts.first;
    final messages = [for (final t in parts) ...t.messages];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        toolbarHeight: 76,
        title: Column(
          children: [
            Avatar(
              name: thread.sender,
              radius: 20,
              icon: isPerson ? null : Icons.business_rounded,
            ),
            const SizedBox(height: 4),
            Text(
              thread.sender,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Center(
            child: Text(
              DayDivider.describe(thread.daysAgo, GameClock.current),
              style: const TextStyle(
                color: AppColors.secondaryLabel,
                fontSize: 12,
              ),
            ),
          ),
          for (var i = 0; i < messages.length; i++)
            ChatBubble(
              text: messageText(messages[i]),
              photo: messagePhoto(messages[i]),
              outgoing: false,
              incomingColor: const Color(0xFFE9E9EB),
              incomingTextColor: Colors.black,
              tail: i == messages.length - 1,
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Bu numaraya yanıt verilemiyor.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryLabel, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// The threads that have come, one list per sender (oldest thread first),
/// the sender with the newest thread first.
List<List<SmsThread>> smsConversations(StoryProgress progress) {
  final bySender = <String, List<SmsThread>>{};
  for (final t in StoryData.current.smsThreads) {
    if (progress.meets(t.requires)) (bySender[t.sender] ??= []).add(t);
  }
  final order = [
    for (final (i, t) in StoryData.current.smsThreads.indexed)
      if (bySender[t.sender]?.last == t) (i, t.sender),
  ]..sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final (_, sender) in order) bySender[sender]!];
}

/// Conversations with something the player hasn't opened yet, for the home
/// screen badge.
int unreadSmsCount(StoryProgress progress) => smsConversations(
  progress,
).where((parts) => parts.any((t) => !progress.hasSeen('sms:${t.id}'))).length;

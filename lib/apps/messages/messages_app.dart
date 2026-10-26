import 'package:flutter/material.dart';

import '../../data/game_clock.dart';
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
          final threads = [
            for (final thread in StoryData.current.smsThreads.reversed)
              if (progress.meets(thread.requires)) thread,
          ];
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
                  final thread = threads[index];
                  final unread = !progress.hasSeen('sms:${thread.sender}');
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
                          name: thread.sender,
                          icon: _isPerson(thread.sender)
                              ? null
                              : Icons.business_rounded,
                        ),
                      ],
                    ),
                    title: Text(
                      thread.sender,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      thread.messages.last,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      progress.markSeen('sms:${thread.sender}');
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => _ThreadPage(
                            thread: thread,
                            isPerson: _isPerson(thread.sender),
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
  const _ThreadPage({required this.thread, required this.isPerson});

  final SmsThread thread;
  final bool isPerson;

  @override
  Widget build(BuildContext context) {
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
          for (var i = 0; i < thread.messages.length; i++)
            ChatBubble(
              text: thread.messages[i],
              outgoing: false,
              incomingColor: const Color(0xFFE9E9EB),
              incomingTextColor: Colors.black,
              tail: i == thread.messages.length - 1,
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

/// Threads the player hasn't opened yet, for the home screen badge.
int unreadSmsCount(StoryProgress progress) => StoryData.current.smsThreads
    .where(
      (t) => progress.meets(t.requires) && !progress.hasSeen('sms:${t.sender}'),
    )
    .length;

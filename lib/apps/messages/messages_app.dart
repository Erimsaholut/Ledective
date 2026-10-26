import 'package:flutter/material.dart';

import '../../story/story_progress.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/day_divider.dart';

class SmsThread {
  const SmsThread({
    required this.sender,
    required this.messages,
    this.daysAgo = 0,
    this.requires,
  });

  final String sender;
  final List<String> messages;

  /// Days before the first launch the messages were received.
  final int daysAgo;

  /// Story flag after which the thread arrives, or null if it is there
  /// from the start.
  final String? requires;
}

const List<SmsThread> smsThreads = [
  SmsThread(
    sender: "0850 222 0 555",
    daysAgo: 7,
    messages: [
      "Yurt dışına hoş geldiniz! Yurt Dışı Paketiniz tanımlanmıştır. Paketinizle 1 GB internet ve 30 dk konuşma hakkınız bulunmaktadır.",
      "Yurt dışı internet kullanımınız paketinizin %80'ine ulaşmıştır.",
    ],
  ),
  SmsThread(
    sender: "ZAFERBANK",
    daysAgo: 4,
    messages: [
      "ZaferBank kartınızla 2.450,00 TL tutarında yurt dışı harcama yapılmıştır. Siz yapmadıysanız 444 0 444'ü arayınız.",
    ],
  ),
  SmsThread(
    sender: "Annem",
    daysAgo: 2,
    messages: [
      "Tatilin nasıl geçiyor? Yemeğini düzgün ye.",
      "Haberlerde bir öğrenci ölmüş diyorlar, senin bölgende mi? Dikkat et kendine.",
    ],
  ),
  SmsThread(
    sender: "e-Devlet",
    messages: [
      "Adınıza düzenlenmiş yeni bir tebligat bulunmaktadır. Detaylar için turkiye.gov.tr adresini ziyaret ediniz.",
    ],
  ),
  SmsThread(
    sender: "Bilinmeyen Numara",
    requires: StoryFlags.furkanStatement,
    messages: [
      "Berat'ın işine burnunu sokma komiser. Çocuğu da rahat bırakın.",
    ],
  ),
];

/// The phone's plain text messages: operator notices, the bank and family.
class MessagesApp extends StatelessWidget {
  const MessagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: Colors.indigo.shade50,
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final threads = [
            for (final thread in smsThreads.reversed)
              if (thread.requires == null || progress.has(thread.requires!))
                thread,
          ];
          return ListView.separated(
            itemCount: threads.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final thread = threads[index];
              final unread = !progress.hasSeen('sms:${thread.sender}');
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade200,
                  child: const Icon(Icons.sms, color: Colors.white),
                ),
                title: Text(
                  thread.sender,
                  style: TextStyle(
                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  thread.messages.last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: unread
                    ? const Icon(Icons.circle, size: 12, color: Colors.indigo)
                    : null,
                onTap: () {
                  progress.markSeen('sms:${thread.sender}');
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => _ThreadPage(thread: thread),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ThreadPage extends StatelessWidget {
  const _ThreadPage({required this.thread});

  final SmsThread thread;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(thread.sender),
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: Colors.indigo.shade50,
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          DayDivider(daysAgo: thread.daysAgo),
          for (final message in thread.messages)
            ChatBubble(text: message, outgoing: false),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Bu numaraya yanıt verilemiyor.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

/// Threads the player hasn't opened yet, for the home screen badge.
int unreadSmsCount(StoryProgress progress) => smsThreads
    .where(
      (t) =>
          (t.requires == null || progress.has(t.requires!)) &&
          !progress.hasSeen('sms:${t.sender}'),
    )
    .length;

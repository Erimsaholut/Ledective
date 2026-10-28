import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/contacts_repository.dart';
import '../../data/private_chats.dart';
import '../../story/dialogue.dart';
import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../widgets/avatar.dart';
import 'chat_page.dart';
import 'mates_style.dart';
import 'new_message_page.dart';

class MatesApp extends StatefulWidget {
  const MatesApp({super.key});

  @override
  State<MatesApp> createState() => _MatesAppState();
}

class _MatesAppState extends State<MatesApp> {
  final StoryProgress _progress = StoryProgress.instance;
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    ContactsRepository().loadAll().then((contacts) {
      if (mounted) setState(() => _contacts = contacts);
    });
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  String _preview(List<ChatEntry> transcript) {
    for (final entry in transcript.reversed) {
      switch (entry) {
        case IncomingMessage(:final text):
          return text;
        case OutgoingMessage(:final text):
          return "Sen: $text";
        case DayMarker():
          continue;
      }
    }
    return "Sohbete başla";
  }

  Widget _tile({
    required String name,
    required String preview,
    required VoidCallback onTap,
    int unread = 0,
    bool awaitsReply = false,
  }) {
    final waiting = awaitsReply && unread == 0;
    return ListTile(
      tileColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Avatar(name: name, radius: 26),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          color: MatesColors.text,
        ),
      ),
      subtitle: Row(
        children: [
          if (waiting)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.reply_rounded,
                size: 16,
                color: MatesColors.accent,
              ),
            ),
          Expanded(
            child: Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unread > 0 || waiting
                    ? MatesColors.text
                    : MatesColors.secondaryText,
                fontWeight: unread > 0 || waiting
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      trailing: unread > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: MatesColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : waiting
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: MatesColors.accent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Yanıt bekliyor',
                style: TextStyle(
                  color: MatesColors.accent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        title: const Text(
          "MatesApp",
          style: TextStyle(
            color: MatesColors.header,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MatesColors.accent,
        foregroundColor: Colors.white,
        tooltip: "New Message",
        onPressed: () => _open(const NewMessagePage()),
        child: const Icon(Icons.add_comment_rounded),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_progress, PrivateChats.instance]),
        builder: (context, _) {
          final saved = _contacts.where((c) => !c.userAdded);
          final private = {
            for (final c in _contacts.where((c) => c.userAdded)) c.number: c,
          };
          final numbers = {for (final c in saved) c.name: c.number};
          // Story chats show up once there is something in them, including
          // ones from numbers that aren't in the contacts.
          final people = [
            ...numbers.keys,
            for (final person in StoryData.current.conversations.keys)
              if (!numbers.containsKey(person)) person,
          ];
          // Chats with something new come first, as on a real phone.
          int rank(String person) => _progress.unreadCount(person) > 0
              ? 0
              : _progress.awaitsReply(person)
              ? 1
              : 2;
          final story = [
            for (final person in people)
              if (_progress.restore(person).$2 case final transcript
                  when transcript.isNotEmpty)
                (person, transcript),
          ];
          final order = {for (final (i, c) in story.indexed) c.$1: i};
          story.sort((a, b) {
            final byRank = rank(a.$1).compareTo(rank(b.$1));
            return byRank != 0 ? byRank : order[a.$1]!.compareTo(order[b.$1]!);
          });
          final tiles = [
            for (final (person, transcript) in story)
              _tile(
                name: person,
                preview: _preview(transcript),
                unread: _progress.unreadCount(person),
                awaitsReply: _progress.awaitsReply(person),
                onTap: () =>
                    _open(ChatPage(person: person, number: numbers[person])),
              ),
            for (final number in PrivateChats.instance.numbers)
              if (private[number] case final contact?)
                _tile(
                  name: contact.name,
                  preview:
                      "Sen: ${PrivateChats.instance.messagesTo(number).last}",
                  onTap: () => _open(PrivateChatPage(contact: contact)),
                ),
          ];
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: tiles.length,
            separatorBuilder: (_, _) => const Divider(indent: 84),
            itemBuilder: (_, index) => tiles[index],
          );
        },
      ),
    );
  }
}

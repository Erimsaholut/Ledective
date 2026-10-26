import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/contacts_repository.dart';
import '../../data/private_chats.dart';
import '../../story/dialogue.dart';
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
  }) {
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
      subtitle: Text(
        preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unread > 0 ? MatesColors.text : MatesColors.secondaryText,
          fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
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
          final story = _contacts.where((c) => !c.userAdded);
          final private = {
            for (final c in _contacts.where((c) => c.userAdded)) c.number: c,
          };
          final tiles = [
            for (final contact in story)
              _tile(
                name: contact.name,
                preview: _preview(_progress.restore(contact.name).$2),
                unread: _progress.unreadCount(contact.name),
                onTap: () => _open(
                  ChatPage(person: contact.name, number: contact.number),
                ),
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

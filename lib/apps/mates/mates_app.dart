import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../data/private_chats.dart';
import '../../story/dialogue.dart';
import '../../story/story_progress.dart';
import '../../widgets/back_button.dart';
import '../contacts/contact_tile.dart';
import 'chat_page.dart';
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
    return "Tap to talk";
  }

  Widget _avatar(String name, {int unread = 0}) {
    return Badge(
      isLabelVisible: unread > 0,
      label: Text('$unread'),
      child: PersonAvatar(
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MatesApp"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green.shade700,
      ),
      backgroundColor: Colors.green,
      body: ListenableBuilder(
        listenable: Listenable.merge([_progress, PrivateChats.instance]),
        builder: (context, _) {
          final story = _contacts.where((c) => !c.userAdded);
          final private = {
            for (final c in _contacts.where((c) => c.userAdded)) c.number: c,
          };
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            children: [
              for (final contact in story)
                ContactTile(
                  avatar: _avatar(
                    contact.name,
                    unread: _progress.unreadCount(contact.name),
                  ),
                  label: _preview(_progress.restore(contact.name).$2),
                  onTap: () => _open(ChatPage(person: contact.name)),
                ),
              for (final number in PrivateChats.instance.numbers)
                if (private[number] case final contact?)
                  ContactTile(
                    avatar: _avatar(contact.name),
                    label:
                        "Sen: ${PrivateChats.instance.messagesTo(number).last}",
                    onTap: () => _open(PrivateChatPage(contact: contact)),
                  ),
            ],
          );
        },
      ),
      bottomNavigationBar: ColoredBox(
        color: Colors.green.shade700,
        child: SafeArea(
          child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const BackButtonWidget(colour: Colors.white, buttonSize: 40),
                IconButton(
                  onPressed: () => _open(const NewMessagePage()),
                  tooltip: "New Message",
                  icon: const Icon(Icons.add, color: Colors.white, size: 50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

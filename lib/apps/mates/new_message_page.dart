import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/contacts_repository.dart';
import '../../data/private_chats.dart';
import '../../widgets/avatar.dart';
import '../../widgets/chat_bubble.dart';
import 'mates_style.dart';

/// Picks a contact to write to. Story characters already have their own
/// chats, so only contacts the player added can be picked here.
class NewMessagePage extends StatefulWidget {
  const NewMessagePage({super.key});

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  List<Contact>? _contacts;

  @override
  void initState() {
    super.initState();
    ContactsRepository().loadAll().then((contacts) {
      if (mounted) setState(() => _contacts = contacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _contacts;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MatesColors.header,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        title: const Text(
          "New Message",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: contacts == null
          ? const SizedBox.shrink()
          : ListView(
              children: [
                if (!contacts.any((c) => c.userAdded))
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Add someone in Contacts to start a new conversation.",
                      style: TextStyle(
                        fontSize: 15,
                        color: MatesColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final contact in contacts)
                  ListTile(
                    tileColor: Colors.white,
                    enabled: contact.userAdded,
                    leading: Opacity(
                      opacity: contact.userAdded ? 1 : 0.4,
                      child: Avatar(name: contact.name),
                    ),
                    title: Text(contact.name),
                    subtitle: Text(
                      contact.userAdded ? contact.number : "Sohbet zaten açık",
                    ),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => PrivateChatPage(contact: contact),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// A free-text chat with a contact the player added.
class PrivateChatPage extends StatefulWidget {
  const PrivateChatPage({super.key, required this.contact});

  final Contact contact;

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    PrivateChats.instance.send(widget.contact.number, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
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
            Avatar(name: widget.contact.name, radius: 18),
            const SizedBox(width: 10),
            Text(
              widget.contact.name,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: PrivateChats.instance,
                builder: (context, _) {
                  final messages = PrivateChats.instance
                      .messagesTo(widget.contact.number)
                      .reversed
                      .toList();
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => ChatBubble(
                      text: messages[index],
                      outgoing: true,
                      outgoingColor: MatesColors.outgoing,
                      tail: index == 0,
                    ),
                  );
                },
              ),
            ),
            ChatInputBar(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
  }
}

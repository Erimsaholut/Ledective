import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../data/private_chats.dart';
import '../../widgets/chat_bubble.dart';
import '../contacts/contact_tile.dart';

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
      appBar: AppBar(
        title: const Text("New Message"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.green.shade100,
      body: contacts == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!contacts.any((c) => c.userAdded))
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Add someone in Contacts to start a new conversation.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final contact in contacts)
                  Opacity(
                    opacity: contact.userAdded ? 1 : 0.4,
                    child: ContactTile(
                      avatar: const PersonAvatar(),
                      label: contact.name,
                      onTap: contact.userAdded
                          ? () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    PrivateChatPage(contact: contact),
                              ),
                            )
                          : null,
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
      appBar: AppBar(
        title: Text(widget.contact.name),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.green.shade100,
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
                    itemBuilder: (context, index) =>
                        ChatBubble(text: messages[index], outgoing: true),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    tooltip: "Send",
                    icon: const Icon(Icons.send, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

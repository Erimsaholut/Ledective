import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
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
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    ContactsRepository().loadStoryContacts().then((contacts) {
      if (mounted) setState(() => _contacts = contacts);
    });
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        children: [
          for (final contact in _contacts)
            ContactTile(
              avatar: PersonAvatar(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              label: "Tap to talk",
              onTap: () => _open(ChatPage(person: contact.name)),
            ),
        ],
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

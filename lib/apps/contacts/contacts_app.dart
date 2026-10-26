import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../widgets/back_button.dart';
import '../phone/call_screen.dart';
import 'contact_page.dart';
import 'contact_tile.dart';

class ContactsApp extends StatefulWidget {
  const ContactsApp({super.key});

  @override
  State<ContactsApp> createState() => _ContactsAppState();
}

class _ContactsAppState extends State<ContactsApp> {
  final ContactsRepository _repository = ContactsRepository();
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final contacts = await _repository.loadAll();
    if (mounted) setState(() => _contacts = contacts);
  }

  Future<void> _showAddContactDialog() async {
    final contact = await showDialog<Contact>(
      context: context,
      builder: (context) => const _AddContactDialog(),
    );
    if (contact == null) return;
    await _repository.add(contact);
    await _reload();
  }

  Future<void> _openContact(Contact contact) async {
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => ContactPage(
          contact: contact,
          onDelete: () => _repository.remove(contact),
        ),
      ),
    );
    await _reload();
  }

  void _call(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            CallScreen(number: contact.number, person: contact.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = Colors.green.shade200;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        automaticallyImplyLeading: false,
        backgroundColor: background,
      ),
      backgroundColor: background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        children: [
          for (final contact in _contacts)
            ContactTile(
              avatar: const PersonAvatar(),
              label: contact.name,
              onTap: () => _openContact(contact),
              onLongPress: () => _call(contact),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const BackButtonWidget(colour: Colors.white, buttonSize: 40),
              IconButton(
                onPressed: _showAddContactDialog,
                tooltip: "Add Contact",
                icon: const Icon(Icons.add, color: Colors.white, size: 50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddContactDialog extends StatefulWidget {
  const _AddContactDialog();

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  final _name = TextEditingController();
  final _number = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final number = _number.text.trim();
    if (name.isEmpty || number.isEmpty) return;
    Navigator.pop(
      context,
      Contact(name: name, number: number, userAdded: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Contact"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _number,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Number"),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(onPressed: _submit, child: const Text("Add")),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../theme/app_theme.dart';
import 'contact_page.dart';
import 'contacts_list.dart';

class ContactsApp extends StatefulWidget {
  const ContactsApp({super.key});

  @override
  State<ContactsApp> createState() => _ContactsAppState();
}

class _ContactsAppState extends State<ContactsApp> {
  final ContactsRepository _repository = ContactsRepository();
  List<Contact> _contacts = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final contacts = await _repository.loadAll();
    if (mounted) setState(() => _contacts = contacts);
  }

  Future<void> _addContact() async {
    final contact = await Navigator.push(
      context,
      MaterialPageRoute<Contact>(
        fullscreenDialog: true,
        builder: (_) => const NewContactPage(),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: Colors.white,
            title: const Text("Contacts"),
            actions: [
              IconButton(
                onPressed: _addContact,
                tooltip: "Add Contact",
                icon: const Icon(Icons.add_rounded, color: AppColors.blue),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: const InputDecoration(
                  hintText: "Ara",
                  prefixIcon: Icon(Icons.search_rounded),
                  isDense: true,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ContactsList(
              contacts: _contacts,
              query: _query,
              onTap: _openContact,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "${_contacts.length} Kişi",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondaryLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen form for a new contact. Pops with the [Contact].
class NewContactPage extends StatefulWidget {
  const NewContactPage({super.key});

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  final _name = TextEditingController();
  final _number = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _number.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty && _number.text.trim().isNotEmpty;

  void _submit() {
    if (!_valid) return;
    Navigator.pop(
      context,
      Contact(
        name: _name.text.trim(),
        number: _number.text.trim(),
        userAdded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 90,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        title: const Text("New Contact"),
        actions: [
          TextButton(
            onPressed: _valid ? _submit : null,
            child: const Text(
              "Add",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          const Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFC7C7CC),
              child: Icon(Icons.person_rounded, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: "Name",
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _number,
            keyboardType: TextInputType.phone,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: "Phone",
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

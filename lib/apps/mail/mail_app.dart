import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/game_data.dart';
import '../../story/story_progress.dart';
import '../../widgets/back_button.dart';
import 'mail_tile.dart';

class MailApp extends StatefulWidget {
  const MailApp({super.key});

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  static const _countKey = 'mailCount';
  static const _deletedKey = 'deletedMails';
  static const _initialMailCount = 3;

  int _mailCount = _initialMailCount;
  Set<String> _deleted = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final count = prefs.getInt(_countKey);
      if (count != null) _mailCount = count.clamp(0, mails.length);
      _deleted = {...?prefs.getStringList(_deletedKey)};
    });
  }

  /// Story mails that have arrived, newest first, then the regular inbox.
  List<Mail> _inbox(StoryProgress progress) => [
    for (final mail in storyMails.reversed)
      if (progress.has(mail.requires!)) mail,
    ...mails.take(_mailCount),
  ].where((mail) => !_deleted.contains(mail.id)).toList();

  Future<void> _checkForNewMail() async {
    if (_mailCount >= mails.length) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("No new mail")));
      return;
    }
    setState(() => _mailCount++);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _mailCount);
  }

  Future<void> _setDeleted(Mail mail, bool deleted) async {
    setState(() {
      if (deleted) {
        _deleted.add(mail.id);
      } else {
        _deleted.remove(mail.id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_deletedKey, _deleted.toList());
  }

  void _delete(Mail mail) {
    _setDeleted(mail, true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("${mail.sender} deleted"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () => _setDeleted(mail, false),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ColoredBox(
              color: Colors.blueGrey,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 120),
                    IconButton(
                      onPressed: _checkForNewMail,
                      tooltip: "Check for new mail",
                      iconSize: 75,
                      icon: const Icon(Icons.mail, color: Colors.black),
                    ),
                    const SizedBox(height: 30),
                    const BackButtonWidget(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListenableBuilder(
              listenable: StoryProgress.instance,
              builder: (context, _) {
                final inbox = _inbox(StoryProgress.instance);
                if (inbox.isEmpty) {
                  return const Center(
                    child: Text(
                      "Inbox is empty",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 60,
                    horizontal: 15,
                  ),
                  children: [
                    for (final mail in inbox)
                      Dismissible(
                        key: ValueKey(mail.id),
                        onDismissed: (_) => _delete(mail),
                        background: const ColoredBox(
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: MailTile(mail: mail),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

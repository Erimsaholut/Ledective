import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/game_data.dart';
import '../../widgets/back_button.dart';
import 'mail_tile.dart';

class MailApp extends StatefulWidget {
  const MailApp({super.key});

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  static const _prefsKey = 'mailCount';
  static const _initialMailCount = 3;

  int _mailCount = _initialMailCount;

  @override
  void initState() {
    super.initState();
    _loadMailCount();
  }

  Future<void> _loadMailCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_prefsKey);
    if (count != null && mounted) {
      setState(() => _mailCount = count.clamp(0, mails.length));
    }
  }

  Future<void> _checkForNewMail() async {
    if (_mailCount >= mails.length) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("No new mail")));
      return;
    }
    setState(() => _mailCount++);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, _mailCount);
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
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 15),
              children: [
                for (final mail in mails.take(_mailCount)) MailTile(mail: mail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

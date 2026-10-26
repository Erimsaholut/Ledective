import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../data/recent_calls.dart';
import '../../widgets/round_icon_button.dart';
import '../contacts/contact_page.dart';
import '../contacts/contact_tile.dart';
import 'call_screen.dart';
import 'phone_number.dart';

class PhoneApp extends StatefulWidget {
  const PhoneApp({super.key});

  @override
  State<PhoneApp> createState() => _PhoneAppState();
}

class _PhoneAppState extends State<PhoneApp> {
  static const _tabs = ['KeyPad', 'Recents'];

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  String _digits = '';
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    ContactsRepository().loadAll().then((contacts) {
      if (mounted) setState(() => _contacts = contacts);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_digits.length >= maxPhoneDigits) return;
    setState(() => _digits += digit);
  }

  void _deleteDigit() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  void _clearNumber() => setState(() => _digits = '');

  void _call(String number, {String? person}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CallScreen(number: number, person: person),
      ),
    );
  }

  void _callDialedNumber() {
    if (_digits.isEmpty) return;
    final contact = _contacts
        .where((c) => digitsOnly(c.number) == _digits)
        .firstOrNull;
    _call(formatPhoneNumber(_digits), person: contact?.name);
  }

  Widget _digitButton(String digit) =>
      RoundIconButton(buttonText: digit, onPressed: () => _addDigit(digit));

  @override
  Widget build(BuildContext context) {
    final background = Colors.green.shade200;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.grey),
        backgroundColor: background,
        shadowColor: Colors.green,
        elevation: 5.0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _tabs.length; i++)
              TextButton(
                onPressed: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    color: _currentPageIndex == i
                        ? Colors.green.shade800
                        : Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      backgroundColor: background,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPageIndex = index),
        children: [_buildKeypad(), _buildRecents()],
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: FittedBox(
                child: Text(
                  formatPhoneNumber(_digits),
                  style: const TextStyle(fontSize: 50, color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final row in const [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                ])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [for (final digit in row) _digitButton(digit)],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RoundIconButton(
                      myIcon: CupertinoIcons.phone,
                      onPressed: _callDialedNumber,
                    ),
                    _digitButton('0'),
                    RoundIconButton(
                      myIcon: CupertinoIcons.delete_left,
                      onPressed: _deleteDigit,
                      onLongPressed: _clearNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecents() {
    return ValueListenableBuilder<List<Contact>>(
      valueListenable: RecentCalls.calls,
      builder: (context, calls, _) => ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          for (final call in calls)
            ContactTile(
              avatar: const PersonAvatar(),
              label: call.name,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ContactPage(contact: call),
                ),
              ),
              onLongPress: () => _call(call.number, person: call.name),
            ),
        ],
      ),
    );
  }
}

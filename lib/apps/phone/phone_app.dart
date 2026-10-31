import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../data/recent_calls.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../contacts/contact_page.dart';
import '../contacts/contacts_list.dart';
import 'call_screen.dart';
import 'phone_number.dart';

class PhoneApp extends StatefulWidget {
  const PhoneApp({super.key});

  @override
  State<PhoneApp> createState() => _PhoneAppState();
}

class _PhoneAppState extends State<PhoneApp> {
  int _tab = 2;
  String _digits = '';
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    ContactsRepository().loadAll().then((contacts) {
      if (mounted) setState(() => _contacts = contacts);
    });
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

  Contact? _contactFor(String digits) =>
      _contacts.where((c) => digitsOnly(c.number) == digits).firstOrNull;

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
    _call(formatPhoneNumber(_digits), person: _contactFor(_digits)?.name);
  }

  void _openContact(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => ContactPage(contact: contact)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _tab,
        children: [_buildRecents(), _buildContacts(), _buildKeypad()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: const Color(0xFFF9F9F9),
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time_rounded),
            selectedIcon: Icon(
              Icons.access_time_filled_rounded,
              color: AppColors.blue,
            ),
            label: 'Recents',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.blue),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.dialpad_rounded),
            selectedIcon: Icon(Icons.dialpad_rounded, color: AppColors.blue),
            label: 'KeyPad',
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    const letters = {
      '2': 'ABC',
      '3': 'DEF',
      '4': 'GHI',
      '5': 'JKL',
      '6': 'MNO',
      '7': 'PQRS',
      '8': 'TUV',
      '9': 'WXYZ',
      '0': '+',
    };
    Widget key(String digit) {
      return _KeypadButton(
        digit: digit,
        letters: letters[digit] ?? '',
        onTap: () => _addDigit(digit),
      );
    }

    final match = _contactFor(_digits);
    // Scales down on small screens instead of overflowing. The bar on top
    // is only there for its way out.
    return Column(
      children: [
        AppBar(backgroundColor: Colors.white),
        Expanded(
          child: SafeArea(
            top: false,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 90,
                      width: 330,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: FittedBox(
                              child: Text(
                                formatPhoneNumber(_digits),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.label,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            match?.name ?? '',
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final row in const [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                      ['*', '0', '#'],
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final digit in row)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: key(digit),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 106),
                        Material(
                          color: AppColors.green,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _callDialedNumber,
                            child: const SizedBox.square(
                              dimension: 78,
                              child: Icon(
                                Icons.phone_rounded,
                                color: Colors.white,
                                size: 36,
                                semanticLabel: "Ara",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 106,
                          child: _digits.isEmpty
                              ? null
                              : GestureDetector(
                                  onLongPress: _clearNumber,
                                  child: IconButton(
                                    tooltip: "Sil",
                                    onPressed: _deleteDigit,
                                    icon: const Icon(
                                      Icons.backspace_outlined,
                                      color: Color(0xFFAEAEB2),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecents() {
    return ValueListenableBuilder<List<Contact>>(
      valueListenable: RecentCalls.calls,
      builder: (context, calls, _) => CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            backgroundColor: Colors.white,
            title: Text("Recents"),
          ),
          SliverList.separated(
            itemCount: calls.length,
            separatorBuilder: (_, _) => const Divider(indent: 64),
            itemBuilder: (context, index) {
              final call = calls[index];
              return ListTile(
                leading: Avatar(name: call.name, radius: 18),
                title: Text(
                  call.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Row(
                  children: [
                    Icon(Icons.call_made_rounded, size: 14),
                    SizedBox(width: 4),
                    Text("mobil"),
                  ],
                ),
                trailing: IconButton(
                  tooltip: "Bilgi",
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.blue,
                  ),
                  onPressed: () => _openContact(call),
                ),
                onTap: () => _call(call.number, person: call.name),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContacts() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(
          backgroundColor: Colors.white,
          title: Text("Contacts"),
        ),
        SliverToBoxAdapter(
          child: ContactsList(contacts: _contacts, onTap: _openContact),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.digit,
    required this.letters,
    required this.onTap,
  });

  final String digit;
  final String letters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE5E5EA),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 78,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digit,
                style: const TextStyle(
                  fontSize: 34,
                  height: 1.1,
                  color: AppColors.label,
                ),
              ),
              if (letters.isNotEmpty)
                Text(
                  letters,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

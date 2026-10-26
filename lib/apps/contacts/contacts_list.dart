import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';

const _turkishAlphabet = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';

/// Sort key that orders Turkish letters correctly (Ç after C, Ö after O...).
String turkishSortKey(String text) {
  final buffer = StringBuffer();
  for (final char in text.toUpperCase().replaceAll('i̇', 'İ').characters) {
    final index = _turkishAlphabet.indexOf(char);
    buffer.writeCharCode(index < 0 ? 200 + char.codeUnitAt(0) : 65 + index);
  }
  return buffer.toString();
}

String _sectionLetter(String name) {
  final first = name.trim().characters.firstOrNull ?? '#';
  final upper = first == 'i' ? 'İ' : first.toUpperCase();
  return _turkishAlphabet.contains(upper) ? upper : '#';
}

/// Contacts in alphabetical sections, with an optional search query.
class ContactsList extends StatelessWidget {
  const ContactsList({
    super.key,
    required this.contacts,
    required this.onTap,
    this.query = '',
  });

  final List<Contact> contacts;
  final ValueChanged<Contact> onTap;
  final String query;

  @override
  Widget build(BuildContext context) {
    final filtered =
        contacts
            .where(
              (c) =>
                  query.isEmpty ||
                  c.name.toLowerCase().contains(query.toLowerCase()) ||
                  c.number.replaceAll(' ', '').contains(query),
            )
            .toList()
          ..sort(
            (a, b) => turkishSortKey(a.name).compareTo(turkishSortKey(b.name)),
          );

    final rows = <Widget>[];
    String? letter;
    for (final contact in filtered) {
      final current = _sectionLetter(contact.name);
      if (current != letter) {
        letter = current;
        rows.add(
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(20, 6, 16, 4),
            child: Text(
              current,
              style: const TextStyle(
                color: AppColors.secondaryLabel,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
      rows.add(
        ListTile(
          leading: Avatar(name: contact.name, radius: 18),
          title: Text(contact.name, style: const TextStyle(fontSize: 17)),
          onTap: () => onTap(contact),
        ),
      );
    }
    if (rows.isEmpty) {
      rows.add(
        const Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            "Sonuç yok",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryLabel),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

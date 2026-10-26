import 'package:flutter/material.dart';

import 'document_pages.dart';
import 'document_tile.dart';
import 'documents.dart';

class Poltel extends StatelessWidget {
  const Poltel({super.key});

  static const _inbox = ["Furkan Kasap", "Deniz Yılmaz", "Orhan Kasap"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text("Poltel"),
      ),
      backgroundColor: Colors.blue.shade100,
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          for (final name in _inbox)
            DocumentTile(
              title: name,
              page: StatementPage(statement: statements[name]!),
            ),
          const DocumentTile(title: autopsySubject, page: AutopsyPage()),
        ],
      ),
    );
  }
}

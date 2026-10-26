import 'package:flutter/material.dart';

import '../../story/story_progress.dart';
import 'document_pages.dart';
import 'document_tile.dart';
import 'documents.dart';

/// Documents unlocked so far, newest first.
List<PoltelDocument> deliveredDocuments(StoryProgress progress) => [
  for (final document in poltelDocuments.reversed)
    if (progress.has(document.requires)) document,
];

/// Delivered documents the player hasn't opened yet.
int newDocumentCount(StoryProgress progress) => deliveredDocuments(
  progress,
).where((d) => !progress.hasSeen('poltel:${d.id}')).length;

class Poltel extends StatelessWidget {
  const Poltel({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text("Poltel"),
      ),
      backgroundColor: Colors.blue.shade100,
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final documents = deliveredDocuments(progress);
          if (documents.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Gelen belge yok",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(15.0),
            children: [
              for (final document in documents)
                DocumentTile(
                  title: document.title,
                  isNew: !progress.hasSeen('poltel:${document.id}'),
                  onOpen: () => progress.markSeen('poltel:${document.id}'),
                  page: switch (document.statement) {
                    final statement? => StatementPage(statement: statement),
                    null => const AutopsyPage(),
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

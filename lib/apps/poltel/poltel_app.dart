import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/game_clock.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
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

  String _subtitle(PoltelDocument document) {
    final statement = document.statement;
    final days = statement?.daysBeforeFirstOpen ?? 2;
    final date = formatDate(GameClock.current.daysBeforeFirstOpen(days));
    return statement == null
        ? "Adli Tıp Kurumu · $date"
        : "Alan: ${statement.takenBy} · $date";
  }

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: poltelNavy,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 72,
        title: const Column(
          children: [
            Text(
              "POLTEL",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              "Emniyet Belge Sistemi",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final documents = deliveredDocuments(progress);
          if (documents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 64,
                    color: AppColors.separator,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Gelen belge yok",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Ekibin gönderdiği belgeler burada görünür.",
                    style: TextStyle(color: AppColors.secondaryLabel),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "BERAT YILMAZ DOSYASI",
                  style: TextStyle(
                    color: AppColors.secondaryLabel,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              for (final document in documents)
                DocumentTile(
                  title: document.title,
                  subtitle: _subtitle(document),
                  icon: document.statement == null
                      ? Icons.medical_information_rounded
                      : Icons.description_rounded,
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

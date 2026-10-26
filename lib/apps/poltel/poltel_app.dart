import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/game_clock.dart';
import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import 'document_pages.dart';
import 'document_tile.dart';
import 'lab/inspection_page.dart';

/// Documents unlocked so far, newest first.
List<StoryDocument> deliveredDocuments(StoryProgress progress) => [
  for (final document in StoryData.current.documents.reversed)
    if (progress.meets(document.requires)) document,
];

/// Delivered documents the player hasn't opened yet, plus evidence waiting
/// for the lab.
int newDocumentCount(StoryProgress progress) =>
    deliveredDocuments(
      progress,
    ).where((d) => !progress.hasSeen('poltel:${d.id}')).length +
    pendingInspections(progress).length;

/// Evidence that has turned up and still needs a lab inspection.
List<Evidence> pendingInspections(StoryProgress progress) => [
  for (final e in StoryData.current.evidence)
    if (e.inspection != null &&
        progress.meets(e.requires) &&
        !progress.isInspected(e.id))
      e,
];

class Poltel extends StatelessWidget {
  const Poltel({super.key});

  String _subtitle(StoryDocument document) {
    final date = formatDate(
      GameClock.current.daysBeforeFirstOpen(document.daysBeforeFirstOpen),
    );
    return switch (document) {
      Statement(:final takenBy) => "Alan: $takenBy · $date",
      Report(:final authority) => "${authority.split('\n').last} · $date",
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Belgeler"),
              Tab(text: "Laboratuvar"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListenableBuilder(
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
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
                    for (final category in DocumentCategory.values)
                      if (documents.where((d) => d.category == category)
                          case final group when group.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                          child: Text(
                            category == DocumentCategory.case_
                                ? "BERAT YILMAZ DOSYASI"
                                : category.label.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.secondaryLabel,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        for (final document in group)
                          DocumentTile(
                            title: document.title,
                            subtitle: _subtitle(document),
                            icon: switch (document.category) {
                              DocumentCategory.personnel => Icons.badge_rounded,
                              DocumentCategory.internal => Icons.gavel_rounded,
                              DocumentCategory.case_ =>
                                document is Report
                                    ? Icons.medical_information_rounded
                                    : Icons.description_rounded,
                            },
                            isNew: !progress.hasSeen('poltel:${document.id}'),
                            onOpen: () {
                              progress.markSeen('poltel:${document.id}');
                              progress.discover(document.unlocksOnView);
                            },
                            page: switch (document) {
                              final Statement statement => StatementPage(
                                statement: statement,
                              ),
                              final Report report => ReportPage(report: report),
                            },
                          ),
                      ],
                  ],
                );
              },
            ),
            const _LabTab(),
          ],
        ),
      ),
    );
  }
}

class _LabTab extends StatelessWidget {
  const _LabTab();

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final evidence = [
          for (final e in StoryData.current.evidence)
            if (e.inspection != null && progress.meets(e.requires)) e,
        ];
        if (evidence.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 64,
                  color: AppColors.separator,
                ),
                SizedBox(height: 12),
                Text(
                  "İncelenecek delil yok",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  "Ekibin bulduğu deliller buraya gelir.",
                  style: TextStyle(color: AppColors.secondaryLabel),
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final e in evidence)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 44,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EDF7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(switch (e.inspection!) {
                        JigsawInspection() => Icons.extension_rounded,
                        FingerprintInspection() => Icons.fingerprint_rounded,
                        UvInspection() => Icons.flashlight_on_rounded,
                      }, color: poltelNavy),
                    ),
                    title: Text(
                      e.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      progress.isInspected(e.id)
                          ? "İnceleme tamamlandı"
                          : "İnceleme bekliyor",
                    ),
                    trailing: progress.isInspected(e.id)
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.green,
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => InspectionPage(evidence: e),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

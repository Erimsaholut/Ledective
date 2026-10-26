import 'package:flutter/material.dart';

import '../../data/game_clock.dart';
import '../../story/story_progress.dart';
import 'documents.dart';

const _bold = TextStyle(fontWeight: FontWeight.bold);

class _DocumentScaffold extends StatelessWidget {
  const _DocumentScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Colors.grey.shade400,
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: children,
        ),
      ),
    );
  }
}

class StatementPage extends StatelessWidget {
  const StatementPage({super.key, required this.statement});

  final Statement statement;

  Widget _qa(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: _bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = statement;
    final person = s.testimonyFrom;
    final records = person == null
        ? [
            for (var i = 0; i < s.questions.length; i++)
              (question: s.questions[i], answer: s.answers[i]),
          ]
        : StoryProgress.instance.testimonyFrom(person);
    final date = GameClock.current.daysBeforeFirstOpen(s.daysBeforeFirstOpen);
    return _DocumentScaffold(
      title: "${s.name} İfade Tutanağı",
      children: [
        const Text("İfade verenin kimliği :\n", style: _bold),
        for (final line in [
          "Adı ve soyadı: ${s.name}",
          "Kimlik numarası: ${s.number}",
          "İfadenin alındığı tarih: ${formatDate(date)}",
          "Öğrenim durumu: ${s.education}",
          "Medeni Hali - Cinsiyeti: ${s.isMarried} - ${s.gender}",
        ])
          Padding(padding: const EdgeInsets.only(left: 8), child: Text(line)),
        const Text("\nİfadesi :\n", style: _bold),
        for (final record in records) ...[
          _qa("Soruldu :", record.question),
          _qa("Cevap :", record.answer),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Text("İfadeyi alan", style: _bold),
                Text(s.takenBy),
              ],
            ),
            Column(
              children: [
                const Text("İfade veren", style: _bold),
                Text(s.name),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class AutopsyPage extends StatelessWidget {
  const AutopsyPage({super.key});

  // The body was found three days before the game starts.
  static String get _autopsyDate =>
      formatDate(GameClock.current.daysBeforeFirstOpen(2));

  Widget _line(ReportLine line) {
    return switch (line) {
      ReportHeading(:final text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 12),
        child: Text("$text :", style: _bold),
      ),
      ReportSubheading(:final text) => Padding(
        padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
        child: Text("$text :", style: _bold),
      ),
      ReportField(:final text) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(text.replaceAll("{autopsyDate}", _autopsyDate)),
      ),
      ReportParagraph(:final text) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(text),
      ),
      ReportConclusion(:final text) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return _DocumentScaffold(
      title: "$autopsySubject otopsi raporu",
      children: [for (final line in autopsyReport) _line(line)],
    );
  }
}

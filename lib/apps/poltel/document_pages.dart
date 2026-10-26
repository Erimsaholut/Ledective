import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/game_clock.dart';
import '../../story/story_progress.dart';
import '../../story/story_data.dart';

const _ink = Color(0xFF1A1A1A);
const _bold = TextStyle(fontWeight: FontWeight.w700, color: _ink);
const _body = TextStyle(fontSize: 14, height: 1.45, color: _ink);
const poltelNavy = Color(0xFF0B1F4D);

/// A document shown as a sheet of paper on a grey desk.
class _PaperScaffold extends StatelessWidget {
  const _PaperScaffold({
    required this.title,
    required this.authority,
    required this.heading,
    required this.children,
  });

  final String title;
  final String authority;
  final String heading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B6472),
      appBar: AppBar(
        backgroundColor: poltelNavy,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFCF8),
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.local_police_rounded,
                        size: 40,
                        color: poltelNavy,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        authority,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: _ink, thickness: 1),
                      const SizedBox(height: 14),
                      Text(
                        heading,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ...children,
                    ],
                  ),
                  const Positioned(top: 0, right: 0, child: _Stamp("GİZLİ")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A red rubber stamp.
class _Stamp extends StatelessWidget {
  const _Stamp(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -pi / 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xAAC62828), width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xAAC62828),
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

/// A "label: value" row of the identity table.
class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x33000000))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: _body.copyWith(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              style: _body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionTitle(String text) => Padding(
  padding: const EdgeInsets.only(top: 20, bottom: 8),
  child: Text(text.toUpperCase(), style: _bold.copyWith(letterSpacing: 1)),
);

class StatementPage extends StatelessWidget {
  const StatementPage({super.key, required this.statement});

  final Statement statement;

  @override
  Widget build(BuildContext context) {
    final s = statement;
    final person = s.testimonyFrom;
    final records = person == null
        ? s.qa
        : StoryProgress.instance.testimonyFrom(person);
    final date = GameClock.current.daysBeforeFirstOpen(s.daysBeforeFirstOpen);

    Widget signature(String role, String name) => Column(
      children: [
        Text(role, style: _bold.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Color(0xFF1F3A93),
          ),
        ),
        Text(name, style: _body.copyWith(fontSize: 12)),
      ],
    );

    return _PaperScaffold(
      title: "${s.name} İfade Tutanağı",
      authority:
          "T.C.\nİÇİŞLERİ BAKANLIĞI\nEMNİYET GENEL MÜDÜRLÜĞÜ\nCİNAYET BÜRO AMİRLİĞİ",
      heading: "İFADE TUTANAĞI",
      children: [
        _sectionTitle("İfade verenin kimliği"),
        _Field("Adı ve soyadı", s.name),
        _Field("Kimlik numarası", s.idNumber),
        _Field("İfade tarihi", formatDate(date)),
        _Field("Öğrenim durumu", s.education),
        _Field("Medeni hali", s.maritalStatus),
        _Field("Cinsiyeti", s.gender),
        _sectionTitle("İfadesi"),
        for (final record in records) ...[
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: "Soruldu: ", style: _bold),
                TextSpan(text: record.question),
              ],
            ),
            style: _body,
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: "Cevap: ", style: _bold),
                TextSpan(text: record.answer),
              ],
            ),
            style: _body,
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            signature("İfadeyi alan", s.takenBy),
            signature("İfade veren", s.name),
          ],
        ),
      ],
    );
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, required this.report});

  final Report report;

  String get _date => formatDate(
    GameClock.current.daysBeforeFirstOpen(report.daysBeforeFirstOpen),
  );

  Widget _line(ReportLine line) {
    final text = line.text.replaceAll("{tarih}", _date);
    return switch (line.kind) {
      ReportLineKind.heading => _sectionTitle(text),
      ReportLineKind.subheading => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(text, style: _bold.copyWith(fontStyle: FontStyle.italic)),
      ),
      ReportLineKind.field => _fieldFrom(text),
      ReportLineKind.paragraph => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(text, style: _body, textAlign: TextAlign.justify),
      ),
      ReportLineKind.conclusion => Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: _ink),
          color: const Color(0x0D000000),
        ),
        child: Text(
          text,
          style: _body.copyWith(
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    };
  }

  /// Splits "Label: value" into a table row.
  Widget _fieldFrom(String text) {
    final separator = text.indexOf(':');
    if (separator < 0) {
      final space = text.indexOf(' ');
      if (space < 0) return _Field(text, '');
      return _Field(text.substring(0, space), text.substring(space + 1));
    }
    return _Field(
      text.substring(0, separator),
      text.substring(separator + 1).trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PaperScaffold(
      title: report.title,
      authority: report.authority,
      heading: report.heading,
      children: [for (final line in report.lines) _line(line)],
    );
  }
}

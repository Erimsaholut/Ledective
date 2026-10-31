import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../story/demo_end.dart';
import '../story/story_data.dart';
import '../story/story_progress.dart';
import '../theme/turkish_text.dart';

/// The demo's last screen, after the epilogue: a few slides about the
/// player's run, the other endings and what's coming
/// (`assets/story/demo.json`).
class DemoEndPage extends StatefulWidget {
  const DemoEndPage({super.key});

  @override
  State<DemoEndPage> createState() => _DemoEndPageState();
}

class _DemoEndPageState extends State<DemoEndPage> {
  final PageController _pages = PageController();
  int _page = 0;
  late final Future<DemoEnd> _end = rootBundle
      .loadString(DemoEnd.path)
      .then(
        (text) => DemoEnd.fromJson(jsonDecode(text) as Map<String, Object?>),
      );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  List<Widget> _slides(DemoEnd end) {
    final progress = StoryProgress.instance;
    final story = StoryData.current;
    final stats = DemoStats.of(
      story,
      seen: progress.hasSeen,
      meets: progress.meets,
    );
    final caseSection = story.endings.sections
        .where((s) => s.id == end.endingSection)
        .firstOrNull;
    final yours = caseSection == null ? null : progress.ending(caseSection);
    final missed = end.missedBy(progress);
    return [
      _Slide(
        title: "Senin hikâyen",
        children: [
          _Stat("Oyun süresi", _duration(progress.playTime)),
          _Stat(
            "Bulunan deliller",
            "${stats.evidenceFound} / ${stats.evidence}",
          ),
          const SizedBox(height: 20),
          for (final (title, text) in end.decided(progress))
            _Item(title: title, text: text),
        ],
      ),
      _Slide(
        title: "Bunu da yapabilirdin",
        children: [
          if (missed.isEmpty)
            const _Item(text: "Gözünden kaçan bir şey olmadı.")
          else
            for (final text in missed.take(5)) _Item(text: text),
        ],
      ),
      _Slide(
        title: "Diğer sonlar",
        children: [
          for (final e in end.endings(story.endings, yours))
            _Item(
              title: e.yours ? "${e.title} · senin sonun" : e.title,
              text: e.summary,
              highlight: e.yours,
            ),
          if (end.secret.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                end.secret,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                ),
              ),
            ),
        ],
      ),
      _Slide(
        title: "Fark ettin mi?",
        children: [
          for (final text in end.noticed) _Item(text: text),
          const SizedBox(height: 12),
          _Stat(
            "Oyundaki mailler",
            "${stats.mails} · ${stats.mailsRead} okudun",
          ),
          _Stat(
            "Oyundaki haberler",
            "${stats.news} · ${stats.newsRead} okudun",
          ),
          _Stat("Sohbetler", "${stats.people} kişi · ${stats.lines} mesaj"),
        ],
      ),
      _Slide(
        title: "Geliştirme aşamasında",
        children: [
          _Item(text: end.about),
          const SizedBox(height: 8),
          for (final text in end.coming) _Item(text: "• $text"),
          const SizedBox(height: 24),
          Text(
            end.thanks,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
              fontSize: 22,
            ),
          ),
        ],
      ),
    ];
  }

  static String _duration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return hours > 0 ? "$hours sa $minutes dk" : "$minutes dk";
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: FutureBuilder<DemoEnd>(
            future: _end,
            builder: (context, snapshot) {
              final end = snapshot.data;
              if (end == null) return const SizedBox.shrink();
              final slides = _slides(end);
              final last = _page == slides.length - 1;
              return Column(
                children: [
                  const SizedBox(height: 28),
                  Text(
                    turkishUpper(end.title),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      onPageChanged: (i) => setState(() => _page = i),
                      children: slides,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page ? Colors.white : Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: last
                            ? () => Navigator.pop(context)
                            : () => _pages.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              ),
                        child: Text(last ? "Telefona dön" : "İleri"),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'serif',
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({this.title, required this.text, this.highlight = false});

  final String? title;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title case final title?)
            Text(
              turkishUpper(title),
              style: TextStyle(
                color: highlight ? Colors.white : Colors.white38,
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (title != null) const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: highlight ? Colors.white : Colors.white70,
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

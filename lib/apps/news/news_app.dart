import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/game_clock.dart';
import '../../story/news_feed.dart';
import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../theme/turkish_text.dart';

const _ink = Color(0xFF111111);

/// What the feed shows right now, newest first.
List<NewsItem> currentNews(StoryProgress progress) => progress.newsFeedAt();

/// News in the feed the player hasn't read.
int newArticleCount(StoryProgress progress) => currentNews(
  progress,
).where((item) => !progress.hasSeen('news:${item.key}')).length;

/// Archived articles and the ones in the feed that match [query] in their
/// title, text, author, outlet or tags.
List<NewsItem> searchArticles(String query, StoryProgress progress) {
  final key = searchKey(query.trim());
  if (key.length < 3) return const [];
  final news = StoryData.current.news;
  final firstOpen = GameClock.current.firstOpen;
  final items = [
    ...currentNews(progress),
    ...progress.archivedNews,
    for (final a in news.articles)
      if (a.archive && progress.meets(a.requires))
        NewsItem(
          a,
          DateTime(firstOpen.year, firstOpen.month, firstOpen.day - a.daysAgo),
        ),
  ];
  return [
    for (final item in items)
      if ([
        item.article.title,
        item.article.summary,
        item.article.author,
        news.outlet(item.article.outlet).name,
        ...item.article.body,
        ...item.article.tags,
      ].any((text) => searchKey(text).contains(key)))
        item,
  ]..sort((a, b) => b.published.compareTo(a.published));
}

/// "Bugün 14:05", "Dün 09:00" or the date.
String _dateOf(NewsItem item) {
  final fixed = item.article.date;
  if (fixed != null) return fixed;
  final t = item.published;
  final now = DateTime.now();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(t.year, t.month, t.day)).inDays;
  final clock =
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  if (item.article.archive) return formatDate(t);
  return switch (days) {
    0 => "Bugün $clock",
    1 => "Dün $clock",
    _ => formatDate(t),
  };
}

Color _colorOf(NewsOutlet outlet) => Color(outlet.color ?? 0xFF424242);

class NewsApp extends StatefulWidget {
  const NewsApp({super.key});

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  final StoryProgress _progress = StoryProgress.instance;
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _progress.lookedAt(mail: false);
  }

  @override
  void dispose() {
    // What came while the feed was open has been seen too.
    _progress.lookedAt(mail: false);
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          title: const Text(
            "News",
            style: TextStyle(
              color: _ink,
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: const TabBar(
            labelColor: _ink,
            unselectedLabelColor: AppColors.secondaryLabel,
            indicatorColor: _ink,
            tabs: [
              Tab(text: "Gündem"),
              Tab(text: "Arşiv"),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: _progress,
          builder: (context, _) => TabBarView(children: [_feed(), _archive()]),
        ),
      ),
    );
  }

  Widget _feed() {
    final articles = currentNews(_progress);
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          "Henüz haber yok",
          style: TextStyle(color: AppColors.secondaryLabel),
        ),
      );
    }
    // The case on top, so the everyday news doesn't bury it.
    final everyday = {
      for (final a in StoryData.current.news.filler.articles) a.id,
    };
    final story = [
      for (final item in articles)
        if (!everyday.contains(item.article.id)) item,
    ];
    final other = [
      for (final item in articles)
        if (everyday.contains(item.article.id)) item,
    ];
    List<Widget> section(String title, List<NewsItem> items) => [
      _SectionHeader(title),
      for (final (i, item) in items.indexed) ...[
        if (i > 0) const Divider(indent: 16, endIndent: 16),
        _ArticleTile(
          item: item,
          headline: i == 0 && identical(items, story),
          isNew: !_progress.hasSeen('news:${item.key}'),
        ),
      ],
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (story.isNotEmpty) ...section("Manşet", story),
        if (other.isNotEmpty) ...section("Diğer haberler", other),
      ],
    );
  }

  Widget _archive() {
    final results = searchArticles(_query.text, _progress);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _query,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: "İsim, yer, kurum ya da olay ara",
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppColors.background,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _query.text.trim().length < 3
              ? _oldNews()
              : results.isEmpty
              ? const Center(
                  child: Text(
                    "Sonuç bulunamadı",
                    style: TextStyle(color: AppColors.secondaryLabel),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: results.length,
                  separatorBuilder: (_, _) =>
                      const Divider(indent: 16, endIndent: 16),
                  itemBuilder: (context, i) => _ArticleTile(item: results[i]),
                ),
        ),
      ],
    );
  }
}

/// The archive tab before a search: what to search for, and the everyday
/// news that has left the feed.
Widget _oldNews() {
  final old = StoryProgress.instance.archivedNews;
  const hint = Padding(
    padding: EdgeInsets.all(32),
    child: Text(
      "Gazete arşivlerinde yıllar öncesine kadar arama yapabilirsin.",
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.secondaryLabel),
    ),
  );
  if (old.isEmpty) return const Center(child: hint);
  return ListView(
    padding: const EdgeInsets.only(bottom: 16),
    children: [
      hint,
      const _SectionHeader("Eski haberler"),
      for (final (i, item) in old.indexed) ...[
        if (i > 0) const Divider(indent: 16, endIndent: 16),
        _ArticleTile(item: item),
      ],
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Row(
        children: [
          Text(
            turkishUpper(title),
            style: const TextStyle(
              color: _ink,
              fontFamily: 'serif',
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: _ink, thickness: 2)),
        ],
      ),
    );
  }
}

class _OutletLabel extends StatelessWidget {
  const _OutletLabel(this.outlet, {this.size = 11});

  final NewsOutlet outlet;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      turkishUpper(outlet.name),
      style: TextStyle(
        color: _colorOf(outlet),
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({
    required this.item,
    this.headline = false,
    this.isNew = false,
  });

  final NewsItem item;
  Article get article => item.article;
  final bool headline;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final image = article.image;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => ArticlePage(item: item)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (headline && image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (!headline && image != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _text()),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      image,
                      width: 96,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              )
            else
              _text(),
          ],
        ),
      ),
    );
  }

  Widget _text() {
    final outlet = StoryData.current.news.outlet(article.outlet);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _OutletLabel(outlet),
            if (article.archive) ...[
              const SizedBox(width: 6),
              const Text(
                "· ARŞİV",
                style: TextStyle(
                  color: AppColors.secondaryLabel,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const Spacer(),
            if (isNew)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          article.title,
          style: TextStyle(
            color: _ink,
            fontFamily: 'serif',
            fontSize: headline ? 22 : 17,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        if (article.summary.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            article.summary,
            maxLines: headline ? 4 : 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF555555), height: 1.3),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          _dateOf(item),
          style: const TextStyle(color: AppColors.secondaryLabel, fontSize: 12),
        ),
      ],
    );
  }
}

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key, required this.item});

  final NewsItem item;

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = StoryProgress.instance;
      await progress.markSeen(
        'news:${widget.item.key}',
        widget.item.article.unlocksOnRead,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.item.article;
    final outlet = StoryData.current.news.outlet(a.outlet);
    final image = a.image;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: _OutletLabel(outlet, size: 14),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: _colorOf(outlet)),
        ),
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Text(
              a.title,
              style: const TextStyle(
                color: _ink,
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            if (a.summary.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                a.summary,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.4,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              [
                if (a.author.isNotEmpty) a.author,
                _dateOf(widget.item),
              ].join(" · "),
              style: const TextStyle(
                color: AppColors.secondaryLabel,
                fontSize: 13,
              ),
            ),
            const Divider(height: 28),
            if (image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image),
              ),
              const SizedBox(height: 16),
            ],
            for (final paragraph in a.body)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  paragraph,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    height: 1.55,
                    color: _ink,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

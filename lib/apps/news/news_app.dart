import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/game_clock.dart';
import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../theme/turkish_text.dart';

const _ink = Color(0xFF111111);

/// Current articles, newest first. Of those from the same day, the one
/// listed last in the file is the newest.
List<Article> currentArticles(StoryProgress progress) => [
  for (final a in StoryData.current.news.articles.reversed)
    if (!a.archive && progress.meets(a.requires)) a,
]..sort((a, b) => a.daysAgo.compareTo(b.daysAgo));

/// Current articles the player hasn't read.
int newArticleCount(StoryProgress progress) => currentArticles(
  progress,
).where((a) => !progress.hasSeen('news:${a.id}')).length;

/// Articles, current or archived, that match [query] in their title, text,
/// author, outlet or tags.
List<Article> searchArticles(String query, StoryProgress progress) {
  final key = searchKey(query.trim());
  if (key.length < 3) return const [];
  final news = StoryData.current.news;
  return [
    for (final a in news.articles)
      if (progress.meets(a.requires) &&
          [
            a.title,
            a.summary,
            a.author,
            news.outlet(a.outlet).name,
            ...a.body,
            ...a.tags,
          ].any((text) => searchKey(text).contains(key)))
        a,
  ]..sort((a, b) => a.daysAgo.compareTo(b.daysAgo));
}

String _dateOf(Article a) =>
    a.date ??
    (a.daysAgo == 0
        ? "Bugün"
        : formatDate(GameClock.current.daysBeforeFirstOpen(a.daysAgo)));

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
  void dispose() {
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
    final articles = currentArticles(_progress);
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          "Henüz haber yok",
          style: TextStyle(color: AppColors.secondaryLabel),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: articles.length,
      separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
      itemBuilder: (context, i) => _ArticleTile(
        article: articles[i],
        headline: i == 0,
        isNew: !_progress.hasSeen('news:${articles[i].id}'),
      ),
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
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      "Gazete arşivlerinde yıllar öncesine kadar arama "
                      "yapabilirsin.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.secondaryLabel),
                    ),
                  ),
                )
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
                  itemBuilder: (context, i) =>
                      _ArticleTile(article: results[i]),
                ),
        ),
      ],
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
      outlet.name.toUpperCase(),
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
    required this.article,
    this.headline = false,
    this.isNew = false,
  });

  final Article article;
  final bool headline;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final outlet = StoryData.current.news.outlet(article.outlet);
    final image = article.image;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => ArticlePage(article: article)),
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
              _dateOf(article),
              style: const TextStyle(
                color: AppColors.secondaryLabel,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key, required this.article});

  final Article article;

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = StoryProgress.instance;
      await progress.markSeen('news:${widget.article.id}');
      await progress.discover(widget.article.unlocksOnRead);
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
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
              [if (a.author.isNotEmpty) a.author, _dateOf(a)].join(" · "),
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

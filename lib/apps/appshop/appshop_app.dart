import 'package:flutter/material.dart';

import '../../data/installed_games.dart';
import '../../home/app_icon.dart';
import '../../theme/app_theme.dart';
import '../../theme/turkish_dates.dart';
import 'store_catalog.dart';

/// The app store, laid out like a phone's own: a Today page of editors'
/// picks, shelves of games and apps, search, and a page for each item
/// where it is downloaded, opened or deleted.
class AppShopApp extends StatefulWidget {
  const AppShopApp({super.key});

  @override
  State<AppShopApp> createState() => _AppShopAppState();
}

class _AppShopAppState extends State<AppShopApp> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (_tab) {
          0 => const _TodayTab(),
          1 => const _ShelfTab(kind: StoreKind.game),
          2 => const _ShelfTab(kind: StoreKind.app),
          _ => const _SearchTab(),
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (tab) => setState(() => _tab = tab),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: "Bugün",
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch_rounded),
            label: "Oyunlar",
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers_rounded),
            label: "Uygulamalar",
          ),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: "Ara"),
        ],
      ),
    );
  }
}

/// Opens the store page of [item].
void openStorePage(BuildContext context, StoreItem item) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => _ItemPage(item: item)));
}

/// "18,4 B" for 18400, the way stores count ratings.
String _count(int n) {
  if (n >= 1000000) return "${_oneDecimal(n / 1000000)} Mn";
  if (n >= 1000) return "${_oneDecimal(n / 1000)} B";
  return "$n";
}

String _oneDecimal(double x) {
  final text = x.toStringAsFixed(1).replaceAll('.', ',');
  return text.endsWith(',0') ? text.substring(0, text.length - 2) : text;
}

String _rating(double r) => r.toStringAsFixed(1).replaceAll('.', ',');

/// A page's big title with a small line over it, like a store's headers.
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, this.overline});

  final String title;
  final String? overline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overline case final overline?)
            Text(
              overline.toUpperCase(),
              style: const TextStyle(
                color: AppColors.secondaryLabel,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          Text(
            title,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          if (subtitle case final subtitle?)
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.secondaryLabel),
            ),
        ],
      ),
    );
  }
}

/// The editors' picks as big story cards, then the most downloaded.
class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    final picks = storeItems.where((item) => item.isFeatured).toList();
    final labels = ["EDİTÖRÜN SEÇİMİ", "GÜNÜN OYUNU", "GÜNÜN UYGULAMASI"];
    return ListView(
      key: const ValueKey('store-today'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _PageHeader(title: "Bugün", overline: longTurkishDate(DateTime.now())),
        for (var i = 0; i < picks.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: _StoryCard(
              item: picks[i],
              label: labels[i.clamp(0, labels.length - 1)],
            ),
          ),
        const _SectionHeader(
          "Bu hafta en çok indirilenler",
          subtitle: "Herkesin konuştuğu oyun ve uygulamalar",
        ),
        for (final (i, item)
            in storeItems.where((item) => item.isAvailable).take(5).indexed)
          _ItemRow(item: item, rank: i + 1),
      ],
    );
  }
}

/// An editors' pick: a tall card with the item's colours and art, what
/// the editors say, and the item along the bottom.
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.item, required this.label});

  final StoreItem item;
  final String label;

  @override
  Widget build(BuildContext context) {
    final art = item.previews.isEmpty ? '⭐' : item.previews.first.emoji;
    return GestureDetector(
      key: ValueKey('story-${item.id}'),
      onTap: () => openStorePage(context, item),
      child: Container(
        height: 380,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.colors,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // The item's main scene large in the corner, two more
                  // beside it.
                  for (final (i, preview) in item.previews.take(3).indexed)
                    Positioned(
                      right: i == 0 ? 14 : 124 + (i - 1) * 60,
                      bottom: i == 0 ? 10 : 22,
                      child: Opacity(
                        opacity: i == 0 ? 0.95 : 0.75,
                        child: Text(
                          preview.emoji,
                          style: TextStyle(fontSize: i == 0 ? 100 : 46),
                        ),
                      ),
                    ),
                  if (item.previews.isEmpty)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Text(art, style: const TextStyle(fontSize: 96)),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 220,
                          child: Text(
                            item.featured ?? item.tagline,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xE6FFFFFF),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  _Artwork(item: item, size: 44),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          item.tagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.secondaryLabel,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _GetButton(item: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The games or the apps: the recommended ones as wide banners, then
/// every one ranked.
class _ShelfTab extends StatelessWidget {
  const _ShelfTab({required this.kind});

  final StoreKind kind;

  @override
  Widget build(BuildContext context) {
    final items = storeItems.where((item) => item.kind == kind).toList();
    final picks = items.where((item) => item.isFeatured).toList();
    final games = kind == StoreKind.game;
    return ListView(
      key: ValueKey('store-${kind.name}s'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _PageHeader(title: games ? "Oyunlar" : "Uygulamalar"),
        if (picks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Text(
              games ? "Sizin için önerilenler" : "Öne çıkanlar",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: picks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _Banner(item: picks[i]),
            ),
          ),
        ],
        _SectionHeader(games ? "En popüler oyunlar" : "En popüler uygulamalar"),
        for (final (i, item) in items.indexed)
          _ItemRow(item: item, rank: i + 1),
      ],
    );
  }
}

/// A recommended item as a wide card: a label, its name and line, and
/// the item under it.
class _Banner extends StatelessWidget {
  const _Banner({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 56;
    return SizedBox(
      width: width,
      child: GestureDetector(
        key: ValueKey('banner-${item.id}'),
        onTap: () => openStorePage(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.kind == StoreKind.game ? "ÖNERİLEN" : "EDİTÖRLERİN SEÇİMİ",
              style: const TextStyle(
                color: AppColors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              item.tagline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.secondaryLabel),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.colors,
                  ),
                ),
                child: Stack(
                  children: [
                    for (final (i, preview) in item.previews.take(3).indexed)
                      Positioned(
                        left: 20.0 + i * 95,
                        top: 18.0 + (i % 2) * 34,
                        child: Text(
                          preview.emoji,
                          style: TextStyle(fontSize: i == 0 ? 64 : 44),
                        ),
                      ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 10,
                      child: Text(
                        item.featured ?? item.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(color: Color(0x66000000), blurRadius: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One item in a list: its icon, name and line, and its button.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, this.rank});

  final StoreItem item;

  /// Its place in a chart, if it is in one.
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final rank = this.rank;
    return InkWell(
      key: ValueKey('row-${item.id}'),
      onTap: () => openStorePage(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            _Artwork(item: item, size: 62),
            if (rank != null)
              SizedBox(
                width: 34,
                child: Text(
                  "$rank",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item.tagline.isEmpty ? item.category : item.tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryLabel,
                      fontSize: 13,
                    ),
                  ),
                  if (item.inDevelopment)
                    const Text(
                      "Geliştirme aşamasında",
                      style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (item.ratings > 0)
                    Text(
                      "★ ${_rating(item.rating)} · ${item.category}",
                      style: const TextStyle(
                        color: AppColors.secondaryLabel,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _GetButton(item: item),
          ],
        ),
      ),
    );
  }
}

/// Search over every name, line and category.
class _SearchTab extends StatefulWidget {
  const _SearchTab();

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<StoreItem> get _results {
    final words = _query.text.trim().toLowerCase();
    if (words.isEmpty) return const [];
    return [
      for (final item in storeItems)
        if ([
          item.title,
          item.tagline,
          item.category,
          item.developer,
        ].any((text) => text.toLowerCase().contains(words)))
          item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const _PageHeader(title: "Ara"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            key: const ValueKey('store-search'),
            controller: _query,
            decoration: InputDecoration(
              hintText: "Oyunlar, uygulamalar ve daha fazlası",
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFE9E9EE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (_query.text.trim().isEmpty) ...[
          const _SectionHeader("Keşfet"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final word in [
                  "strateji",
                  "çiftlik",
                  "bulmaca",
                  "araçlar",
                  "hesap",
                  "şifre",
                ])
                  ActionChip(
                    label: Text(word),
                    onPressed: () => setState(() => _query.text = word),
                  ),
              ],
            ),
          ),
        ] else if (results.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              "Sonuç bulunamadı",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryLabel),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          for (final item in results) _ItemRow(item: item),
        ],
      ],
    );
  }
}

/// An item's own store page: what it is, what players think of it, and
/// the button to get it.
class _ItemPage extends StatelessWidget {
  const _ItemPage({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    const grey = TextStyle(color: AppColors.secondaryLabel, fontSize: 13);
    final rated = item.ratings > 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: ListView(
        key: ValueKey('page-${item.id}'),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Artwork(item: item, size: 108),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(item.tagline, style: grey),
                      const SizedBox(height: 2),
                      Text(
                        item.developer,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _GetButton(item: item, large: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _Fact(
                  top: rated ? "${_count(item.ratings)} PUAN" : "YENİ",
                  middle: rated ? _rating(item.rating) : "—",
                  bottom: rated ? _stars(item.rating) : "Henüz yok",
                ),
                _Fact(top: "YAŞ", middle: item.age, bottom: "Yıl"),
                _Fact(top: "KATEGORİ", middle: '#', bottom: item.category),
                _Fact(
                  top: "BOYUT",
                  middle: item.sizeMb >= 1000
                      ? _oneDecimal(item.sizeMb / 1000)
                      : "${item.sizeMb}",
                  bottom: item.sizeMb >= 1000 ? "GB" : "MB",
                ),
                _Fact(top: "GELİŞTİRİCİ", middle: '👤', bottom: item.developer),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          if (item.previews.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: item.previews.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) =>
                    _Screenshot(item: item, preview: item.previews[i]),
              ),
            ),
          ],
          if (item.whatsNew.isNotEmpty) ...[
            const _PageSection("Yenilikler"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sürüm ${item.version}", style: grey),
                  const SizedBox(height: 6),
                  Text(item.whatsNew),
                ],
              ),
            ),
          ],
          const _PageSection("Açıklama"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(item.description, style: const TextStyle(height: 1.4)),
          ),
          if (rated) ...[
            const _PageSection("Değerlendirmeler ve Yorumlar"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _rating(item.rating),
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("5 üzerinden", style: grey),
                          Text(
                            "${_count(item.ratings)} değerlendirme",
                            style: grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (item.reviews.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: item.reviews.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) =>
                      _ReviewCard(review: item.reviews[i]),
                ),
              ),
            ],
          ],
          const _PageSection("Bilgiler"),
          for (final (label, value) in [
            ("Geliştirici", item.developer),
            ("Boyut", "${item.sizeMb} MB"),
            ("Kategori", item.category),
            ("Yaş sınırı", item.age),
            ("Sürüm", item.version),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: grey)),
                  Text(value),
                ],
              ),
            ),
          ValueListenableBuilder<List<String>>(
            valueListenable: InstalledGames.ids,
            builder: (context, ids, _) => !ids.contains(item.id)
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: OutlinedButton.icon(
                      key: const ValueKey('uninstall'),
                      onPressed: () => confirmUninstall(context, item),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(
                        item.kind == StoreKind.game
                            ? "Oyunu sil"
                            : "Uygulamayı sil",
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static String _stars(double rating) {
    final full = rating.round();
    return '★' * full + '☆' * (5 - full);
  }
}

class _PageSection extends StatelessWidget {
  const _PageSection(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
  );
}

/// One column of the facts strip under an item's name.
class _Fact extends StatelessWidget {
  const _Fact({required this.top, required this.middle, required this.bottom});

  final String top;
  final String middle;
  final String bottom;

  @override
  Widget build(BuildContext context) {
    const grey = TextStyle(color: AppColors.secondaryLabel, fontSize: 11);
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.separator)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(top, maxLines: 1, overflow: TextOverflow.ellipsis, style: grey),
          Text(
            middle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF636366),
            ),
          ),
          Text(
            bottom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: grey,
          ),
        ],
      ),
    );
  }
}

/// A store screenshot, drawn as a phone-shaped card with a scene.
class _Screenshot extends StatelessWidget {
  const _Screenshot({required this.item, required this.preview});

  final StoreItem item;
  final StorePreview preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.separator),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [item.colors.first, item.colors.last],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
            child: Text(
              preview.caption,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(preview.emoji, style: const TextStyle(fontSize: 72)),
            ),
          ),
          Container(
            height: 70,
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(item.icon, color: Colors.white70, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final StoreReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                review.author,
                style: const TextStyle(
                  color: AppColors.secondaryLabel,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '★' * review.stars + '☆' * (5 - review.stars),
            style: const TextStyle(color: AppColors.orange),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              review.text,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks before deleting [game] and its saved data.
Future<void> confirmUninstall(BuildContext context, StoreItem game) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("“${game.title}” silinsin mi?"),
      content: Text(
        "${game.kind == StoreKind.game ? "Oyun ve kayıtlı ilerlemesi" : "Uygulama ve kayıtlı verileri"} "
        "bu telefondan silinecek. AppShop'tan yeniden indirebilirsin.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Vazgeç"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.red),
          child: const Text("Sil"),
        ),
      ],
    ),
  );
  if (confirmed ?? false) {
    await InstalledGames.uninstall(game.id, data: game.dataKeys);
  }
}

/// A store game's home screen icon. A long press offers to delete it.
class InstalledAppIcon extends StatelessWidget {
  const InstalledAppIcon({super.key, required this.game});

  final StoreItem game;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => confirmUninstall(context, game),
      child: game.homeIcon,
    );
  }
}

/// A game still downloading, on the home screen: its icon greyed out
/// under the progress, as a phone shows it.
class DownloadingAppIcon extends StatefulWidget {
  const DownloadingAppIcon({super.key, required this.game});

  final StoreItem game;

  @override
  State<DownloadingAppIcon> createState() => _DownloadingAppIconState();
}

class _DownloadingAppIconState extends State<DownloadingAppIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: InstalledGames.downloadTime,
  );

  @override
  void initState() {
    super.initState();
    final started = InstalledGames.downloads.value[widget.game.id];
    final done = started == null
        ? 0.0
        : DateTime.now().difference(started).inMicroseconds /
              InstalledGames.downloadTime.inMicroseconds;
    _progress.forward(from: done.clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = AppIcon.size;
    return SizedBox(
      width: size + 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.45,
                child: _Artwork(item: widget.game, size: size),
              ),
              SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) => CircularProgressIndicator(
                    value: _progress.value,
                    strokeWidth: 4,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Yükleniyor…",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Color(0x80000000), blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

/// The button that gets an item: "İndir", then the download's progress
/// (a tap stops it), then "Aç". Items the store can't give say why.
class _GetButton extends StatefulWidget {
  const _GetButton({required this.item, this.large = false});

  final StoreItem item;

  /// The wide blue button of an item's own page.
  final bool large;

  @override
  State<_GetButton> createState() => _GetButtonState();
}

class _GetButtonState extends State<_GetButton>
    with SingleTickerProviderStateMixin {
  /// Draws the progress of the download, which runs in [InstalledGames]
  /// and so goes on when the store is closed.
  late final AnimationController _download = AnimationController(
    vsync: this,
    duration: InstalledGames.downloadTime,
  );

  StoreItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    InstalledGames.downloads.addListener(_showProgress);
    _showProgress();
  }

  @override
  void dispose() {
    InstalledGames.downloads.removeListener(_showProgress);
    _download.dispose();
    super.dispose();
  }

  /// Picks the progress up where the download is, e.g. when the store is
  /// opened again half way through.
  void _showProgress() {
    final started = InstalledGames.downloads.value[item.id];
    if (started == null) {
      _download.reset();
      return;
    }
    if (_download.isAnimating) return;
    final done =
        DateTime.now().difference(started).inMicroseconds /
        InstalledGames.downloadTime.inMicroseconds;
    _download.forward(from: done.clamp(0.0, 1.0));
  }

  void _get() {
    if (item.inDevelopment) {
      _tell(
        "Geliştirme aşamasında",
        "“${item.title}” henüz geliştiriliyor. Hazır olduğunda buradan "
            "indirebileceksin.",
      );
    } else if (!item.isAvailable) {
      _tell(
        "Ülkenizde kullanılamıyor",
        "“${item.title}” şu anda ülkenizde veya bölgenizde indirilemiyor.",
      );
    } else {
      InstalledGames.download(item.id);
    }
  }

  Future<void> _tell(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tamam"),
        ),
      ],
    ),
  );

  void _open() => Navigator.of(context).push(item.homeIcon.route());

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        InstalledGames.ids,
        InstalledGames.downloads,
        _download,
      ]),
      builder: (context, _) => _buildButton(),
    );
  }

  Widget _buildButton() {
    if (InstalledGames.isDownloading(item.id)) {
      return Semantics(
        label: "İndiriliyor",
        button: true,
        child: InkResponse(
          key: ValueKey('progress-${item.id}'),
          onTap: () => InstalledGames.cancelDownload(item.id),
          radius: 22,
          child: SizedBox(
            width: widget.large ? 40 : 34,
            height: widget.large ? 40 : 34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _download.value,
                  strokeWidth: 3,
                  backgroundColor: const Color(0xFFE3E3E8),
                ),
                Container(width: 10, height: 10, color: AppColors.blue),
              ],
            ),
          ),
        ),
      );
    }
    final (label, action) = item.inDevelopment
        ? ("Yakında", _get)
        : InstalledGames.isInstalled(item.id)
        ? ("Aç", _open)
        : ("İndir", _get);
    return _PillButton(
      key: ValueKey('get-${item.id}'),
      label: label,
      filled: widget.large,
      onPressed: action,
    );
  }
}

/// The grey rounded button of an app store, with a blue label.
class _PillButton extends StatelessWidget {
  const _PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback onPressed;

  /// Blue with a white label, as on an item's own page.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: filled ? AppColors.blue : const Color(0xFFE3E3E8),
        foregroundColor: filled ? Colors.white : AppColors.blue,
        minimumSize: const Size(76, 32),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

/// A store item's icon, as it looks on the home screen.
class _Artwork extends StatelessWidget {
  const _Artwork({required this.item, this.size = 60});

  final StoreItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.225),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: item.colors,
        ),
      ),
      child: Icon(item.icon, size: size * 0.56, color: item.glyphColor),
    );
  }
}

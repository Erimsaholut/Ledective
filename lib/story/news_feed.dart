import 'dart:math';

import 'dialogue.dart';
import 'story_data.dart';

/// An article as it appears in the News feed.
class NewsItem {
  const NewsItem(this.article, this.published, {this.run = 0});

  final Article article;
  final DateTime published;

  /// For everyday news: how many times the article ran before. Each run is
  /// a new item the player hasn't read.
  final int run;

  /// Identifies this appearance, for "read" marks and alerts.
  String get key => run == 0 ? article.id : '${article.id}#$run';
}

/// The News feed at [now], newest first: story articles whose condition
/// holds (published when they arrived, see [arrivedAt]), articles
/// scheduled for a day after [firstOpen], and the latest everyday news.
///
/// Everyday news follows a schedule fixed by [firstOpen], so it is the same
/// every time it is worked out and needs no saving.
List<NewsItem> newsFeed(
  NewsData news, {
  required DateTime firstOpen,
  required DateTime now,
  required bool Function(Condition condition) meets,
  DateTime? Function(String articleId)? arrivedAt,
}) {
  final day = DateTime(firstOpen.year, firstOpen.month, firstOpen.day);
  final items = <NewsItem>[];
  final waiting = <Article>[];
  for (final a in news.articles) {
    if (a.archive || !meets(a.requires)) continue;
    final offset = a.dayOffset;
    if (offset != null) {
      final time = DateTime(day.year, day.month, day.day + offset, a.hour);
      if (!time.isAfter(now)) items.add(NewsItem(a, time));
      continue;
    }
    final arrived = arrivedAt?.call(a.id);
    if (arrived != null) {
      items.add(NewsItem(a, arrived));
    } else {
      waiting.add(a);
    }
  }
  // Articles that were there from the start keep their own date, but come
  // before anything that arrived later.
  var earliest = now;
  for (final item in items) {
    if (item.published.isBefore(earliest)) earliest = item.published;
  }
  for (final a in waiting) {
    final time = DateTime(day.year, day.month, day.day - a.daysAgo, a.hour);
    final limit = earliest.subtract(const Duration(minutes: 1));
    items.add(NewsItem(a, time.isAfter(limit) ? limit : time));
  }
  items.addAll(_filler(news.filler, day, now, meets));
  // Same time: the article listed later in the file is the newer one.
  final order = {for (final (i, a) in news.articles.indexed) a.id: i};
  items.sort((a, b) {
    final byTime = b.published.compareTo(a.published);
    if (byTime != 0) return byTime;
    return (order[b.article.id] ?? 0).compareTo(order[a.article.id] ?? 0);
  });
  return items;
}

Iterable<NewsItem> _filler(
  FillerNews filler,
  DateTime day,
  DateTime now,
  bool Function(Condition condition) meets,
) {
  final pool = filler.articles;
  if (pool.isEmpty) return const [];
  final seed = day.year * 10000 + day.month * 100 + day.day;
  final low = max(1, filler.minHours);
  final high = max(low, filler.maxHours);

  // A different order each time the pool starts over, never running the
  // same article twice in a row.
  final orders = <int, List<int>>{};
  List<int> orderOf(int cycle) => orders[cycle] ??= () {
    final order = List.generate(pool.length, (i) => i)
      ..shuffle(Random(seed + cycle * 7919));
    final previous = cycle == 0 ? null : orderOf(cycle - 1).last;
    if (order.length > 1 && order.first == previous) {
      order.add(order.removeAt(0));
    }
    return order;
  }();

  // The first ones ran during the two days before the game started, so the
  // feed is never empty.
  var time = day
      .subtract(const Duration(days: 2))
      .add(const Duration(hours: 8));
  final items = <NewsItem>[];
  for (var slot = 0; !time.isAfter(now); slot++) {
    final cycle = slot ~/ pool.length;
    final article = pool[orderOf(cycle)[slot % pool.length]];
    if (meets(article.requires)) {
      items.add(NewsItem(article, time, run: cycle));
    }
    final gap = low + Random(seed * 31 + slot).nextInt(high - low + 1);
    time = time.add(Duration(hours: gap));
  }
  final keep = min(max(1, filler.keep), pool.length);
  return items.length <= keep ? items : items.sublist(items.length - keep);
}

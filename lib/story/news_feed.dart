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
/// holds (published when they arrived, see [arrivedAt]; [ready] holds back
/// the ones still on their way), articles scheduled for a day after
/// [firstOpen], and the latest of the everyday news in [filler].
List<NewsItem> newsFeed(
  NewsData news, {
  required DateTime firstOpen,
  required DateTime now,
  required bool Function(Condition condition) meets,
  bool Function(Article article)? ready,
  DateTime? Function(String articleId)? arrivedAt,
  Iterable<NewsItem> filler = const [],
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
    if (!(ready?.call(a) ?? true)) continue;
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
  final everyday = filler.toList()
    ..sort((a, b) => a.published.compareTo(b.published));
  final keep = max(1, news.filler.keep);
  items.addAll(
    everyday.length <= keep
        ? everyday
        : everyday.sublist(everyday.length - keep),
  );
  // Same time: the article listed later in the file is the newer one.
  final order = {for (final (i, a) in news.articles.indexed) a.id: i};
  items.sort((a, b) {
    final byTime = b.published.compareTo(a.published);
    if (byTime != 0) return byTime;
    return (order[b.article.id] ?? 0).compareTo(order[a.article.id] ?? 0);
  });
  return items;
}

import 'dart:math';

/// One item a [DripFeed] delivered.
class Drop {
  const Drop(this.id, this.run, this.at);

  final String id;

  /// How many times the item came before this one.
  final int run;
  final DateTime at;

  /// Identifies this delivery, for "read" marks and alerts.
  String get key => run == 0 ? id : '$id#$run';

  List<Object> toJson() => [id, run, at.millisecondsSinceEpoch];

  static Drop fromJson(List<dynamic> json) => Drop(
    json[0] as String,
    json[1] as int,
    DateTime.fromMillisecondsSinceEpoch(json[2] as int),
  );
}

/// Everyday items, such as spam mail or local news, that arrive one at a
/// time at random moments of play. The feed only remembers what came and
/// when the next one is due; the pool itself lives in the story files.
class DripFeed {
  final List<Drop> drops = [];

  /// Play time, in milliseconds, at which the next item is due. Null until
  /// the feed has started.
  int? dueAt;

  bool get started => dueAt != null;

  void clear() {
    drops.clear();
    dueAt = null;
  }

  /// The item of [ids] to deliver next, or null if none fits: one that
  /// [eligible] allows, that has come the fewest times (only items that
  /// never came if [recycle] is off), in an order shuffled by [seed] for
  /// each round, and never the same as the last one if there is a choice.
  Drop? next(
    List<String> ids, {
    required DateTime at,
    required int seed,
    bool Function(String id)? eligible,
    bool recycle = true,
  }) {
    final runs = {for (final id in ids) id: 0};
    for (final d in drops) {
      if (runs.containsKey(d.id)) runs[d.id] = runs[d.id]! + 1;
    }
    final candidates = [
      for (final id in ids)
        if ((recycle || runs[id] == 0) && (eligible?.call(id) ?? true)) id,
    ];
    if (candidates.isEmpty) return null;
    final orders = <int, Map<String, int>>{};
    int place(String id) {
      final round = runs[id]!;
      final order = orders[round] ??= {
        for (final (i, id) in (List.of(
          ids,
        )..shuffle(Random(seed + round * 7919))).indexed)
          id: i,
      };
      return round * ids.length + order[id]!;
    }

    candidates.sort((a, b) => place(a).compareTo(place(b)));
    final last = drops.lastOrNull?.id;
    final id = candidates.firstWhere(
      (id) => id != last,
      orElse: () => candidates.first,
    );
    return Drop(id, runs[id]!, at);
  }

  Map<String, Object?> toJson() => {
    'due': dueAt,
    'drops': [for (final d in drops) d.toJson()],
  };

  void load(Map<String, dynamic>? json) {
    clear();
    if (json == null) return;
    dueAt = json['due'] as int?;
    drops.addAll([
      for (final d in json['drops'] as List? ?? const [])
        Drop.fromJson(d as List),
    ]);
  }
}

/// One row of the weekly village league.
class LeagueEntry {
  const LeagueEntry({
    required this.name,
    required this.score,
    this.isPlayer = false,
  });

  final String name;
  final int score;
  final bool isPlayer;
}

/// A division of the league. Finishing a week near the top moves the
/// farm up a tier, near the bottom down one; higher tiers have faster
/// neighbours and bigger rewards.
enum LeagueTier {
  wood("Tahta", 0xFF8D6E63, pace: 1, reward: 1),
  copper("Bakır", 0xFFD4824A, pace: 1.3, reward: 1.5),
  iron("Demir", 0xFF78909C, pace: 1.7, reward: 2),
  silver("Gümüş", 0xFF9EAAB3, pace: 2.2, reward: 3),
  gold("Altın", 0xFFFFB300, pace: 2.8, reward: 4),
  diamond("Elmas", 0xFF29B6F6, pace: 3.5, reward: 6);

  const LeagueTier(
    this.title,
    this.color, {
    required this.pace,
    required this.reward,
  });

  final String title;

  /// ARGB colour of the tier's badge.
  final int color;

  /// How much faster than in [wood] the neighbours play on their own.
  final double pace;

  /// How much more the week's rewards pay than in [wood].
  final double reward;

  LeagueTier? get above => index + 1 < values.length ? values[index + 1] : null;
  LeagueTier? get below => index > 0 ? values[index - 1] : null;
}

/// The weekly village league: neighbours earn points through the week and
/// the best few are rewarded when it ends. There are no real players: each
/// neighbour plays in bursts through the day, sleeps at night, and earns at
/// a pace partly set by the player's own, so there is always someone close.
abstract final class FarmLeague {
  static const week = Duration(days: 7);

  /// How fast each neighbour's slot plays. An idle player falls to the
  /// bottom, a steady one sits in the middle, and only a hard-working week
  /// beats the fastest.
  static const paces = [1.45, 1.3, 1.18, 1.08, 1.0, 0.88, 0.75, 0.6, 0.45];

  /// The first and last this many places move up and down a tier.
  static const movers = 3;

  /// Villagers a week's neighbours are picked from.
  static const _names = [
    "Ayşe Teyze",
    "Hasan Dayı",
    "Zeynep",
    "Mehmet'in Çiftliği",
    "Elif",
    "Bekir Usta",
    "Kerem",
    "Fatma Hanım",
    "Ali Rıza",
    "Emine Nine",
    "Mustafa",
    "Selin",
    "Burak",
    "Hatice",
    "Osman Ağa",
    "Derya",
    "Cem",
    "Gülsüm",
    "Yusuf",
    "Nur",
    "Ramazan",
    "Esra",
    "Kadir",
    "Songül",
    "Tarık",
    "Melek",
    "İsmail Usta",
    "Pınar",
    "Halil",
    "Sevgi",
  ];

  /// The neighbours of the week starting [weekStart], one per pace slot.
  /// Every week brings a different set.
  static List<String> namesFor(DateTime weekStart) {
    final week = weekStart.millisecondsSinceEpoch;
    final shuffled = [..._names]
      ..sort((a, b) => _noise('$a|$week').compareTo(_noise('$b|$week')));
    return shuffled.take(paces.length).toList();
  }

  /// Monday midnight of the week [now] is in.
  static DateTime weekStartOf(DateTime now) =>
      DateTime(now.year, now.month, now.day - (now.weekday - 1));

  static DateTime weekEndOf(DateTime start) =>
      DateTime(start.year, start.month, start.day + 7);

  /// The least a farm of [level] is expected to earn in a week: about
  /// three levels' worth of experience. Neighbours never play slower.
  static int scale(int level) => 3 * (5 * level * level + 5 * level);

  /// Coins for finishing the week in [rank], counting from 1.
  static int reward(int rank, int level, [LeagueTier tier = LeagueTier.wood]) {
    const shares = [12, 8, 6, 4, 3, 2, 2, 1, 1, 1];
    final share = shares[(rank - 1).clamp(0, shares.length - 1)];
    return (share * 10 * level * tier.reward).round();
  }

  /// The tier a week finished in [rank] leads to.
  static LeagueTier tierAfter(LeagueTier tier, int rank) {
    if (rank <= movers) return tier.above ?? tier;
    if (rank > paces.length + 1 - movers) return tier.below ?? tier;
    return tier;
  }

  /// How much of a neighbour's pace is their own, and how much follows
  /// the player's.
  static const _steady = 0.5;
  static const _follow = 0.55;

  /// Points per hour the neighbour in slot [pace] earns while playing:
  /// partly a steady pace for a farm of [level] in [tier], partly keeping
  /// up with the player's [score] over the [hours] of the week gone.
  static double rate(
    double pace, {
    required int score,
    required double hours,
    required int level,
    LeagueTier tier = LeagueTier.wood,
  }) {
    // The first hours count as six, so an early burst doesn't send the
    // neighbours racing.
    final playerPace = score / (hours < 6 ? 6 : hours);
    final steadyPace = scale(level) / week.inHours;
    return pace * (_steady * tier.pace * steadyPace + _follow * playerPace);
  }

  /// Hours of play [name] fits between [from] and [to]: on average one per
  /// hour, but in uneven bursts and much less at night.
  static double playTime(
    String name,
    DateTime weekStart,
    DateTime from,
    DateTime to,
  ) {
    double hoursAt(DateTime time) => (time.difference(weekStart).inMinutes / 60)
        .clamp(0, week.inHours)
        .toDouble();
    final start = hoursAt(from);
    final end = hoursAt(to);
    var played = 0.0;
    for (var hour = start.floor(); hour < end; hour++) {
      final overlap =
          (end < hour + 1 ? end : hour + 1) - (start > hour ? start : hour);
      if (overlap <= 0) continue;
      final u = _noise('$name|${weekStart.millisecondsSinceEpoch}|$hour');
      final awake = weekStart.add(Duration(hours: hour)).hour < 7 ? 0.15 : 1;
      played += 3 * u * u * awake / _meanWakefulness * overlap;
    }
    return played;
  }

  static const double _meanWakefulness = (7 * 0.15 + 17) / 24;

  /// Sorts the player in among the neighbours called [names] with their
  /// [scores], best first. On a tie the neighbour stays ahead; the player
  /// has to pass them.
  static List<LeagueEntry> table(
    List<String> names,
    List<double> scores,
    int playerScore,
  ) {
    final entries = [
      LeagueEntry(name: "Sen", score: playerScore, isPlayer: true),
      for (var i = 0; i < names.length; i++)
        LeagueEntry(name: names[i], score: scores[i].floor()),
    ];
    entries.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return (a.isPlayer ? 1 : 0) - (b.isPlayer ? 1 : 0);
    });
    return entries;
  }

  static int rankOf(List<LeagueEntry> table) =>
      table.indexWhere((e) => e.isPlayer) + 1;

  /// A repeatable number in [0, 1) for [key]. Kept within 2^53 so it gives
  /// the same answer on the web.
  static double _noise(String key) {
    const m = 2147483647;
    var h = 17;
    for (final unit in key.codeUnits) {
      h = (h * 31 + unit) % m;
    }
    for (var i = 0; i < 3; i++) {
      h = h * 48271 % m;
    }
    return h / m;
  }
}

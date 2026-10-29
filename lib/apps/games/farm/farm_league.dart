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

/// A neighbour in the league. There are no real players: each neighbour
/// plays in bursts through the day, sleeps at night, and earns at a pace
/// set by the player's own, so there is always someone close by.
class LeagueRival {
  const LeagueRival(this.name, {required this.pace});

  final String name;

  /// How fast this neighbour plays compared with the player.
  final double pace;
}

/// The weekly village league: neighbours earn points through the week and
/// the best few are rewarded when it ends.
abstract final class FarmLeague {
  static const week = Duration(days: 7);

  /// An idle player falls to the bottom, a steady one sits in the middle,
  /// and only a hard-working week beats Ayşe Teyze.
  static const rivals = [
    LeagueRival("Ayşe Teyze", pace: 1.45),
    LeagueRival("Hasan Dayı", pace: 1.3),
    LeagueRival("Zeynep", pace: 1.18),
    LeagueRival("Mehmet'in Çiftliği", pace: 1.08),
    LeagueRival("Elif", pace: 1.0),
    LeagueRival("Bekir Usta", pace: 0.88),
    LeagueRival("Kerem", pace: 0.75),
    LeagueRival("Fatma Hanım", pace: 0.6),
    LeagueRival("Ali Rıza", pace: 0.45),
  ];

  /// Monday midnight of the week [now] is in.
  static DateTime weekStartOf(DateTime now) =>
      DateTime(now.year, now.month, now.day - (now.weekday - 1));

  static DateTime weekEndOf(DateTime start) =>
      DateTime(start.year, start.month, start.day + 7);

  /// The least a farm of [level] is expected to earn in a week: about
  /// three levels' worth of experience. Neighbours never play slower.
  static int scale(int level) => 3 * (5 * level * level + 5 * level);

  /// Coins for finishing the week in [rank], counting from 1.
  static int reward(int rank, int level) {
    const shares = [12, 8, 6, 4, 3, 2, 2, 1, 1, 1];
    return shares[(rank - 1).clamp(0, shares.length - 1)] * 10 * level;
  }

  /// How much of a neighbour's pace is their own, and how much follows
  /// the player's.
  static const _steady = 0.5;
  static const _follow = 0.55;

  /// Points per hour [rival] earns while playing: partly a steady pace for
  /// a farm of [level], partly keeping up with the player's [score] over
  /// the [hours] of the week gone.
  static double rate(
    LeagueRival rival, {
    required int score,
    required double hours,
    required int level,
  }) {
    // The first hours count as six, so an early burst doesn't send the
    // neighbours racing.
    final playerPace = score / (hours < 6 ? 6 : hours);
    final steadyPace = scale(level) / week.inHours;
    return rival.pace * (_steady * steadyPace + _follow * playerPace);
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

  /// Sorts the player in among the neighbours' [scores], best first. On a
  /// tie the neighbour stays ahead; the player has to pass them.
  static List<LeagueEntry> table(List<double> scores, int playerScore) {
    final entries = [
      LeagueEntry(name: "Sen", score: playerScore, isPlayer: true),
      for (var i = 0; i < rivals.length; i++)
        LeagueEntry(name: rivals[i].name, score: scores[i].floor()),
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

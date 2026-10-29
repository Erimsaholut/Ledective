import 'dart:math';

import 'farm_catalog.dart';
import 'farm_cosmetics.dart';
import 'farm_league.dart';
import 'farm_state.dart';

/// What the league shows about a farm when its row is tapped: how far it
/// has come, what it keeps and how it is dressed up.
class FarmProfile {
  const FarmProfile({
    required this.name,
    required this.level,
    required this.tier,
    required this.fields,
    required this.herd,
    required this.decorations,
    required this.theme,
    required this.trophies,
    this.hat,
    this.isPlayer = false,
  });

  /// The player's own farm.
  factory FarmProfile.of(FarmState farm) => FarmProfile(
    name: "Sen",
    level: farm.level,
    tier: farm.tier,
    fields: farm.plots.length,
    herd: {
      for (final kind in animals)
        if (farm.animalsOf(kind).isNotEmpty) kind: farm.animalsOf(kind).length,
    },
    decorations: farm.decorations,
    theme: farm.theme,
    trophies: farm.trophies,
    hat: farm.hat,
    isPlayer: true,
  );

  /// A neighbour's farm. There is no such farm: it is made up from the
  /// name, so it looks the same every time, and from how fast the
  /// neighbour plays, so the quicker ones have come further.
  factory FarmProfile.neighbour(
    String name, {
    required double pace,
    required int level,
    required LeagueTier tier,
  }) {
    double roll(String what) => FarmLeague.noise('$name|$what');
    final own = max(
      1,
      level + ((pace - 1) * 6 + (roll('level') - 0.5) * 3).round(),
    );

    final kept = <Animal, int>{
      for (final kind in animals)
        if (kind.level <= own)
          kind: (roll(kind.id) * (FarmState.maxAnimalsPerKind + 1)).floor(),
    }..removeWhere((_, count) => count == 0);

    // Cheap decorations come first; the dear ones only to the keen.
    final garden =
        cosmetics.where((c) => c.slot == CosmeticSlot.decoration).toList()
          ..sort(
            (a, b) => (a.price * (0.3 + roll(a.id))).compareTo(
              b.price * (0.3 + roll(b.id)),
            ),
          );
    final decorated = (own / 3 * (0.4 + roll('garden'))).round().clamp(
      0,
      garden.length,
    );

    final themes = cosmetics
        .where(
          (c) =>
              c.slot == CosmeticSlot.theme &&
              c.price > 0 &&
              c.price <= own * 1500,
        )
        .toList();
    final theme = themes.isEmpty || roll('theme') < 0.4
        ? springTheme
        : themes[(roll('which theme') * themes.length).floor()];

    final hats = cosmetics.where((c) => c.slot == CosmeticSlot.hat).toList();
    final hatChance = 0.35 + 0.1 * tier.index;
    final best = min(hats.length - 1, tier.index ~/ 2 + own ~/ 8);
    final hat = roll('hat') < hatChance
        ? hats[(roll('which hat') * (best + 1)).floor()]
        : null;

    return FarmProfile(
      name: name,
      level: own,
      tier: tier,
      fields: (FarmState.startPlots + own * (0.6 + 0.6 * roll('fields')))
          .round()
          .clamp(FarmState.startPlots, FarmState.maxPlots),
      herd: kept,
      decorations: garden.take(decorated).toList(),
      theme: theme,
      trophies: (roll('trophies') * (tier.index * 3 + own / 2)).floor(),
      hat: hat,
    );
  }

  final String name;
  final int level;
  final LeagueTier tier;
  final int fields;

  /// Animals kept, by kind.
  final Map<Animal, int> herd;
  final List<Cosmetic> decorations;
  final Cosmetic theme;
  final int trophies;
  final Cosmetic? hat;
  final bool isPlayer;

  int get animalCount => herd.values.fold(0, (a, b) => a + b);
}

/// The profile behind each row of [table], [farm]'s league table at [now].
List<FarmProfile> profilesFor(
  FarmState farm,
  List<LeagueEntry> table,
  DateTime now,
) {
  final names = FarmLeague.namesFor(
    farm.weekStart ?? FarmLeague.weekStartOf(now),
  );
  return [
    for (final entry in table)
      entry.isPlayer
          ? FarmProfile.of(farm)
          : FarmProfile.neighbour(
              entry.name,
              pace: FarmLeague.paces[names.indexOf(entry.name)],
              level: farm.weekLevel,
              tier: farm.tier,
            ),
  ];
}

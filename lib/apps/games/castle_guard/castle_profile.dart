import 'dart:math';

import 'castle_defense.dart';

/// Something to earn in Kale Muhafızı, shown on the achievements tab.
enum CastleAchievement {
  firstBlood("İlk Kan", '🗡️', "İlk düşmanını yere ser."),
  masterBuilder("Usta Mimar", '⭐', "Bir kuleyi en üst seviyeye çıkar."),
  treasury("Hazine Odası", '💰', "Aynı anda 500 altın biriktir."),
  dragonSlayer("Ejderha Avcısı", '🐉', "Bir ejderhayı alt et."),
  meadow("Vadinin Koruyucusu", '🌿', "Yeşil Vadi'yi kurtar."),
  swamp("Bataklık Fatihi", '🐸', "Sisli Bataklık'ı kurtar."),
  mountain("Dağların Efendisi", '🌋', "Ejderha Dağı'nı kurtar."),
  flawless(
    "Kusursuz Savunma",
    '🛡️',
    "Bir haritayı hiç can kaybetmeden kurtar.",
  ),
  archersOnly("Okçular Loncası", '🏹', "Bir haritayı yalnız okçularla kurtar."),
  thousand("Bin Düşman", '⚔️', "Toplam 1000 düşman öldür."),
  veteran("Emektar", '🎖️', "Toplam 100 dalgaya dayan.");

  const CastleAchievement(this.title, this.emoji, this.description);

  final String title;
  final String emoji;
  final String description;
}

/// The player's Kale Muhafızı record across games: the maps saved, the
/// best on each, totals for the statistics tab and the achievements.
class CastleProfile {
  CastleProfile({
    Set<String>? won,
    Map<String, int>? best,
    Map<String, int>? killsBy,
    Set<CastleAchievement>? achievements,
    this.games = 0,
    this.wins = 0,
    this.waves = 0,
    this.towers = 0,
    this.goldSpent = 0,
  }) : won = won ?? {},
       best = best ?? {},
       killsBy = killsBy ?? {},
       achievements = achievements ?? {};

  factory CastleProfile.fromJson(Map<String, dynamic> json) => CastleProfile(
    won: {...(json['won'] as List? ?? const []).cast<String>()},
    best: Map<String, int>.from(json['best'] as Map? ?? const {}),
    killsBy: Map<String, int>.from(json['killsBy'] as Map? ?? const {}),
    achievements: {
      for (final a in CastleAchievement.values)
        if ((json['achievements'] as List? ?? const []).contains(a.name)) a,
    },
    games: json['games'] as int? ?? 0,
    wins: json['wins'] as int? ?? 0,
    waves: json['waves'] as int? ?? 0,
    towers: json['towers'] as int? ?? 0,
    goldSpent: json['goldSpent'] as int? ?? 0,
  );

  /// Ids of the maps whose castle was saved.
  final Set<String> won;

  /// The most waves held on each map, by id.
  final Map<String, int> best;

  /// Enemies killed in finished games, by [EnemyKind.name].
  final Map<String, int> killsBy;
  final Set<CastleAchievement> achievements;

  /// Finished games, the ones won, and the waves held in all of them.
  int games;
  int wins;
  int waves;
  int towers;
  int goldSpent;

  int get losses => games - wins;
  int get kills => killsBy.values.fold(0, (a, b) => a + b);

  /// The first map is always open; each other opens once the one before
  /// is won.
  bool isUnlocked(CastleMap map) {
    final index = castleMaps.indexOf(map);
    return index <= 0 || won.contains(castleMaps[index - 1].id);
  }

  /// Waves [game] held out against so far.
  static int held(CastleDefense game) => game.isWon
      ? CastleDefense.waves
      : max(0, game.wave - (game.isLost || game.waveRunning ? 1 : 0));

  /// Whether [achievement] is earned, counting [game] as well as the
  /// finished ones.
  bool _earned(CastleAchievement achievement, CastleDefense game) {
    final won = game.isWon;
    return switch (achievement) {
      CastleAchievement.firstBlood => kills + game.kills >= 1,
      CastleAchievement.masterBuilder => game.topLevel >= Tower.maxLevel,
      CastleAchievement.treasury => game.richest >= 500,
      CastleAchievement.dragonSlayer =>
        (killsBy[EnemyKind.dragon.name] ?? 0) +
                (game.killsBy[EnemyKind.dragon] ?? 0) >=
            1,
      CastleAchievement.meadow => won && game.map.id == 'meadow',
      CastleAchievement.swamp => won && game.map.id == 'swamp',
      CastleAchievement.mountain => won && game.map.id == 'mountain',
      CastleAchievement.flawless =>
        won && game.lives == CastleDefense.startLives,
      CastleAchievement.archersOnly =>
        won && game.kindsBuilt.every((kind) => kind == TowerKind.archer),
      CastleAchievement.thousand => kills + game.kills >= 1000,
      CastleAchievement.veteran => waves + held(game) >= 100,
    };
  }

  /// Gives every achievement [game] has just earned and returns them.
  List<CastleAchievement> unlock(CastleDefense game) {
    final fresh = [
      for (final a in CastleAchievement.values)
        if (!achievements.contains(a) && _earned(a, game)) a,
    ];
    achievements.addAll(fresh);
    return fresh;
  }

  /// Adds a finished [game] to the record. Returns the achievements it
  /// earned and whether it beat the best on its map.
  ({List<CastleAchievement> earned, bool newBest}) record(CastleDefense game) {
    final earned = unlock(game);
    final held = CastleProfile.held(game);
    final newBest = held > (best[game.map.id] ?? 0);
    if (newBest) best[game.map.id] = held;
    if (game.isWon) {
      won.add(game.map.id);
      wins++;
    }
    games++;
    waves += held;
    towers += game.towersBuilt;
    goldSpent += game.goldSpent;
    game.killsBy.forEach(
      (kind, count) => killsBy[kind.name] = (killsBy[kind.name] ?? 0) + count,
    );
    return (earned: earned, newBest: newBest);
  }

  Map<String, Object> toJson() => {
    'won': won.toList(),
    'best': best,
    'killsBy': killsBy,
    'achievements': [for (final a in achievements) a.name],
    'games': games,
    'wins': wins,
    'waves': waves,
    'towers': towers,
    'goldSpent': goldSpent,
  };
}

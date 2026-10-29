import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/app_theme.dart';
import 'castle_defense.dart';
import 'castle_profile.dart';

/// Kale Muhafızı from AppShop: build towers beside the road and hold the
/// castle through twenty waves of goblins, orcs, giants and dragons, on
/// three maps that open one after another.
class CastleGuardApp extends StatefulWidget {
  const CastleGuardApp({super.key, this.initialGame});

  /// Where the record and the game in progress are saved.
  static const profileKey = 'castleGuard.profile';
  static const gameKey = 'castleGuard.game';

  /// Where the first version saved the most waves held; read once into the
  /// record.
  static const bestKey = 'castleGuard.best';

  /// A game to start in instead of the menu; tests pass one with a known
  /// state.
  final CastleDefense? initialGame;

  @override
  State<CastleGuardApp> createState() => _CastleGuardAppState();
}

class _CastleGuardAppState extends State<CastleGuardApp>
    with SingleTickerProviderStateMixin {
  static const _background = Color(0xFF33402B);

  /// Game seconds between saves while a wave runs.
  static const _saveEvery = 3.0;

  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;
  CastleProfile _profile = CastleProfile();

  /// The game on screen, or null while the menu is.
  CastleDefense? _game;

  /// A game left half way, offered on the menu.
  CastleDefense? _saved;
  bool _loaded = false;

  Tile? _selected;

  /// The tower shown on [_selected] before it is built.
  TowerKind? _preview;
  bool _fast = false;
  double _sinceSave = 0;
  ({List<CastleAchievement> earned, bool newBest})? _result;

  @override
  void initState() {
    super.initState();
    _game = widget.initialGame;
    _load();
    _runTicker();
  }

  /// Runs the frame ticker only while a game is being played.
  void _runTicker() {
    final playing = _game != null && !_game!.isOver;
    if (playing && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    } else if (!playing && _ticker.isActive) {
      _ticker.stop();
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    var profile = CastleProfile();
    final stored = prefs.getString(CastleGuardApp.profileKey);
    if (stored != null) {
      try {
        profile = CastleProfile.fromJson(
          json.decode(stored) as Map<String, dynamic>,
        );
      } on Object {
        // A record from an older version; start a new one.
      }
    } else if (prefs.getInt(CastleGuardApp.bestKey) case final best?) {
      profile.best[castleMaps.first.id] = best;
    }
    CastleDefense? saved;
    final game = prefs.getString(CastleGuardApp.gameKey);
    if (game != null) {
      try {
        saved = CastleDefense.fromJson(
          json.decode(game) as Map<String, dynamic>,
        );
      } on Object {
        // A game from an older version; it can't be continued.
      }
    }
    if (!mounted) return;
    setState(() {
      _profile = profile;
      if (widget.initialGame == null) _saved = saved;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _saveGame();
    super.dispose();
  }

  /// Saves the game on screen, or forgets it once it's over.
  Future<void> _saveGame() async {
    final game = _game ?? _saved;
    final prefs = await SharedPreferences.getInstance();
    if (game == null || game.isOver) {
      await prefs.remove(CastleGuardApp.gameKey);
    } else {
      await prefs.setString(CastleGuardApp.gameKey, json.encode(game.toJson()));
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      CastleGuardApp.profileKey,
      json.encode(_profile.toJson()),
    );
  }

  void _onTick(Duration elapsed) {
    // A long frame (or a tab in the background) shouldn't teleport enemies.
    final dt = min((elapsed - _lastTick).inMicroseconds / 1e6, 0.05);
    _lastTick = elapsed;
    final game = _game;
    if (game == null ||
        game.isOver ||
        (!game.waveRunning && game.shots.isEmpty)) {
      return;
    }
    final wasRunning = game.waveRunning;
    setState(() {
      for (var i = 0; i < (_fast ? 2 : 1); i++) {
        game.update(dt);
      }
    });
    if (game.isOver) {
      _finish(game);
    } else if (wasRunning && !game.waveRunning) {
      _waveBeaten(game);
    } else if ((_sinceSave += dt) >= _saveEvery) {
      _sinceSave = 0;
      _saveGame();
    }
  }

  void _waveBeaten(CastleDefense game) {
    _announce(_profile.unlock(game));
    _saveGame();
    _saveProfile();
  }

  void _finish(CastleDefense game) {
    if (_result != null) return;
    setState(() {
      _selected = null;
      _preview = null;
      _result = _profile.record(game);
    });
    _runTicker();
    _saveGame();
    _saveProfile();
  }

  void _announce(List<CastleAchievement> earned) {
    if (earned.isEmpty || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            [
              for (final a in earned) "🏆 Başarım: ${a.emoji} ${a.title}",
            ].join("\n"),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Starts a new game on [map], after asking if it would end one left
  /// half way.
  Future<void> _start(CastleMap map) async {
    final saved = _saved;
    if (saved != null) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Yeni oyun başlasın mı?"),
          content: Text(
            "${saved.map.title} haritasında ${saved.wave}. dalgada kalan "
            "oyunun silinir.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Vazgeç"),
            ),
            FilledButton(
              key: const ValueKey('confirm-new-game'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yeni oyun"),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }
    _play(CastleDefense(map: map));
  }

  void _play(CastleDefense game) {
    setState(() {
      _game = game;
      _saved = null;
      _selected = null;
      _preview = null;
      _result = null;
      _sinceSave = 0;
    });
    _runTicker();
    _saveGame();
  }

  /// Leaves the game for the menu; it waits there to be continued.
  void _toMenu() {
    final game = _game;
    setState(() {
      _saved = game == null || game.isOver ? null : game;
      _game = null;
      _selected = null;
      _preview = null;
      _result = null;
    });
    _runTicker();
    _saveGame();
  }

  void _tapBoard(CastleDefense game, Offset position, double tile) {
    if (game.isOver) return;
    final tapped = (
      col: (position.dx / tile).floor(),
      row: (position.dy / tile).floor(),
    );
    // Tapping the previewed tower's tile again builds it.
    if (tapped == _selected && _preview != null) {
      _confirmBuild(game);
      return;
    }
    final buildable = game.towerAt(tapped) != null || game.canBuildOn(tapped);
    setState(() {
      _selected = tapped == _selected || !buildable ? null : tapped;
      _preview = null;
    });
  }

  /// Shows [kind] on the chosen tile with its reach; choosing it again
  /// builds it.
  void _choose(CastleDefense game, TowerKind kind) {
    if (_preview == kind) {
      _confirmBuild(game);
    } else {
      setState(() => _preview = kind);
    }
  }

  void _confirmBuild(CastleDefense game) {
    final tile = _selected;
    final kind = _preview;
    if (tile == null || kind == null) return;
    setState(() {
      if (game.build(kind, tile) == null) _selected = null;
      _preview = null;
    });
    _announce(_profile.unlock(game));
    _saveGame();
  }

  void _upgrade(CastleDefense game, Tower tower) {
    setState(() => game.upgrade(tower));
    _announce(_profile.unlock(game));
    _saveGame();
  }

  void _sell(CastleDefense game, Tower tower) {
    setState(() {
      game.sell(tower);
      _selected = null;
    });
    _saveGame();
  }

  void _showGameStats(CastleDefense game) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _GameStatsSheet(game: game),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    if (game == null) {
      return Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          title: const Text("Kale Muhafızı"),
          backgroundColor: _background,
          foregroundColor: Colors.white,
        ),
        body: !_loaded
            ? const SizedBox()
            : _Menu(
                profile: _profile,
                saved: _saved,
                onContinue: () => _play(_saved!),
                onStart: _start,
              ),
      );
    }
    final result = _result;
    final next = castleMaps.indexOf(game.map) + 1;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text("${game.map.emoji} ${game.map.title}"),
        backgroundColor: _background,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const ValueKey('castle-game-stats'),
            tooltip: "Bu oyunun istatistikleri",
            onPressed: () => _showGameStats(game),
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          IconButton(
            key: const ValueKey('castle-menu'),
            tooltip: "Ana menü",
            onPressed: _toMenu,
            icon: const Icon(Icons.home_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Hud(game: game, best: _profile.best[game.map.id] ?? 0),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: CastleDefense.cols / CastleDefense.rows,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tile = constraints.maxWidth / CastleDefense.cols;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            key: const ValueKey('castle-board'),
                            onTapUp: (d) =>
                                _tapBoard(game, d.localPosition, tile),
                            child: CustomPaint(
                              painter: _BoardPainter(game, _selected, _preview),
                            ),
                          ),
                          if (game.isOver && result != null)
                            _EndOverlay(
                              game: game,
                              earned: result.earned,
                              newBest: result.newBest,
                              next: game.isWon && next < castleMaps.length
                                  ? castleMaps[next]
                                  : null,
                              onRestart: () =>
                                  _play(CastleDefense(map: game.map)),
                              onNext: (map) => _play(CastleDefense(map: map)),
                              onMenu: _toMenu,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 118, child: _buildPanel(game)),
          ],
        ),
      ),
    );
  }

  /// What can be done now: build on the chosen tile, upgrade or sell the
  /// chosen tower, or send the next wave.
  Widget _buildPanel(CastleDefense game) {
    final tile = _selected;
    final tower = tile == null ? null : game.towerAt(tile);
    if (tower != null) {
      final cost = tower.upgradeCost;
      return _Panel(
        title:
            "${tower.kind.emoji} ${tower.kind.title} · Seviye ${tower.level}",
        children: [
          Expanded(
            child: FilledButton(
              key: const ValueKey('upgrade'),
              onPressed: cost != null && game.gold >= cost
                  ? () => _upgrade(game, tower)
                  : null,
              child: Text(
                cost == null ? "En üst seviye" : "Geliştir · $cost 🪙",
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              key: const ValueKey('sell'),
              onPressed: () => _sell(game, tower),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              child: Text("Sat · +${tower.refund} 🪙"),
            ),
          ),
        ],
      );
    }
    if (tile != null) {
      final preview = _preview;
      return _Panel(
        title: preview == null
            ? "Kule seç, menzilini haritada gör"
            : "${preview.title}: kurmak için tekrar dokun",
        children: [
          for (final kind in TowerKind.values) ...[
            if (kind != TowerKind.values.first) const SizedBox(width: 8),
            Expanded(
              child: _BuildButton(
                kind: kind,
                affordable: game.gold >= kind.cost,
                chosen: preview == kind,
                onPressed: () => _choose(game, kind),
              ),
            ),
          ],
        ],
      );
    }
    final next = game.wave + 1;
    return _Panel(
      title: game.waveRunning
          ? "${game.wave}. dalga saldırıyor!"
          : game.wave == 0
          ? "Yolun yanındaki bir kareye dokunup kule kur."
          : "${game.wave}. dalga püskürtüldü. Kulelerini güçlendir.",
      children: [
        Expanded(
          child: FilledButton(
            key: const ValueKey('start-wave'),
            onPressed: game.waveRunning || game.isOver
                ? null
                : () => setState(game.startWave),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
            ),
            child: Text(
              game.waveRunning ? "Savaş sürüyor…" : "$next. dalgayı başlat",
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          key: const ValueKey('speed'),
          tooltip: _fast ? "Normal hız" : "İki kat hız",
          isSelected: _fast,
          onPressed: () => setState(() => _fast = !_fast),
          icon: const Icon(Icons.fast_forward_rounded),
        ),
      ],
    );
  }
}

/// The game's home: the game to continue, the maps with the locked ones
/// shown, and the ways to the achievements and statistics.
class _Menu extends StatelessWidget {
  const _Menu({
    required this.profile,
    required this.saved,
    required this.onContinue,
    required this.onStart,
  });

  final CastleProfile profile;
  final CastleDefense? saved;
  final VoidCallback onContinue;
  final void Function(CastleMap map) onStart;

  @override
  Widget build(BuildContext context) {
    final saved = this.saved;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const Center(child: Text('🏰', style: TextStyle(fontSize: 64))),
        const Center(
          child: Text(
            "Kaleni 20 dalga boyunca koru",
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        if (saved != null) ...[
          FilledButton(
            key: const ValueKey('castle-continue'),
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "▶ Devam et",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  "${saved.map.emoji} ${saved.map.title} · "
                  "Dalga ${saved.wave}/${CastleDefense.waves} · "
                  "❤️ ${saved.lives} · 🪙 ${saved.gold}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        const _MenuHeading("Haritalar"),
        for (final map in castleMaps)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MapCard(
              map: map,
              profile: profile,
              onTap: () {
                if (profile.isUnlocked(map)) {
                  onStart(map);
                  return;
                }
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text("🔒 ${_lockedHint(map)}")),
                  );
              },
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MenuButton(
                key: const ValueKey('castle-achievements'),
                emoji: '🏆',
                title: "Başarımlar",
                subtitle:
                    "${profile.achievements.length}/"
                    "${CastleAchievement.values.length}",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => _AchievementsPage(profile: profile),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MenuButton(
                key: const ValueKey('castle-stats'),
                emoji: '📊',
                title: "İstatistikler",
                subtitle: "${profile.games} oyun",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => _StatsPage(profile: profile),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// What opens [map]: saving the castle on the map before it.
String _lockedHint(CastleMap map) =>
    "Önce ${castleMaps[castleMaps.indexOf(map) - 1].title} haritasını kurtar.";

class _MenuHeading extends StatelessWidget {
  const _MenuHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.map,
    required this.profile,
    required this.onTap,
  });

  final CastleMap map;
  final CastleProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unlocked = profile.isUnlocked(map);
    final won = profile.won.contains(map.id);
    final best = profile.best[map.id] ?? 0;
    final level = castleMaps.indexOf(map) + 1;
    final status = !unlocked
        ? "🔒 ${_lockedHint(map)}"
        : won
        ? "✅ Kurtarıldı · Rekor $best/${CastleDefense.waves}"
        : best > 0
        ? "Rekor: $best/${CastleDefense.waves} dalga"
        : "Henüz oynanmadı";
    return GestureDetector(
      key: ValueKey('map-${map.id}'),
      onTap: onTap,
      child: Opacity(
        opacity: unlocked ? 1 : 0.6,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Darkened, so the white text reads on every map.
              colors: [
                for (final c in [map.grass.last, map.roadColor])
                  Color.lerp(Color(c), Colors.black, 0.45)!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: won ? AppColors.yellow : Colors.white24,
              width: won ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                unlocked ? map.emoji : '🔒',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$level. ${map.title}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Zorluk ${'★' * level}${'☆' * (castleMaps.length - level)}",
                      style: const TextStyle(color: AppColors.yellow),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      map.description,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsPage extends StatelessWidget {
  const _AchievementsPage({required this.profile});

  final CastleProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CastleGuardAppState._background,
      appBar: AppBar(
        title: Text(
          "Başarımlar · ${profile.achievements.length}/"
          "${CastleAchievement.values.length}",
        ),
        backgroundColor: _CastleGuardAppState._background,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final a in CastleAchievement.values)
            _AchievementRow(
              achievement: a,
              earned: profile.achievements.contains(a),
            ),
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement, required this.earned});

  final CastleAchievement achievement;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned ? const Color(0x33FFD54F) : Colors.white10,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: earned ? AppColors.yellow : Colors.white12),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: earned ? 1 : 0.35,
            child: Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: earned ? Colors.white : Colors.white60,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  achievement.description,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(earned ? '✅' : '🔒', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class _StatsPage extends StatelessWidget {
  const _StatsPage({required this.profile});

  final CastleProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CastleGuardAppState._background,
      appBar: AppBar(
        title: const Text("İstatistikler"),
        backgroundColor: _CastleGuardAppState._background,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatGrid(
            stats: [
              ('🎮', "Oyun", profile.games),
              ('🏰', "Zafer", profile.wins),
              ('🔥', "Yenilgi", profile.losses),
              ('🌊', "Dalga", profile.waves),
              ('⚔️', "Düşman", profile.kills),
              ('🗼', "Kule", profile.towers),
              ('🪙', "Harcanan", profile.goldSpent),
            ],
          ),
          const SizedBox(height: 16),
          const _MenuHeading("Haritalarda rekor"),
          for (final map in castleMaps)
            _StatLine(
              label: "${map.emoji} ${map.title}",
              value:
                  "${profile.best[map.id] ?? 0}/${CastleDefense.waves} dalga",
            ),
          const SizedBox(height: 16),
          const _MenuHeading("Alt edilen düşmanlar"),
          for (final kind in EnemyKind.values)
            _StatLine(
              label: "${kind.emoji} ${kind.title}",
              value: "${profile.killsBy[kind.name] ?? 0}",
            ),
        ],
      ),
    );
  }
}

/// Numbers in tiles, three to a row.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<(String, String, int)> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (emoji, label, value) in stats)
              Container(
                width: width,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    Text(
                      "$value",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

/// The game in progress in numbers.
class _GameStatsSheet extends StatelessWidget {
  const _GameStatsSheet({required this.game});

  final CastleDefense game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _CastleGuardAppState._background,
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _MenuHeading("${game.map.emoji} ${game.map.title} · bu oyun"),
            _StatGrid(
              stats: [
                ('🌊', "Dalga", game.wave),
                ('⚔️', "Düşman", game.kills),
                ('❤️', "Kalan can", game.lives),
                ('🗼', "Kurulan kule", game.towersBuilt),
                ('🪙', "Harcanan", game.goldSpent),
                ('💰', "En çok altın", game.richest),
              ],
            ),
            const SizedBox(height: 12),
            for (final kind in EnemyKind.values)
              if ((game.killsBy[kind] ?? 0) > 0)
                _StatLine(
                  label: "${kind.emoji} ${kind.title}",
                  value: "${game.killsBy[kind]}",
                ),
          ],
        ),
      ),
    );
  }
}

/// Lives, gold, the wave count and the record.
class _Hud extends StatelessWidget {
  const _Hud({required this.game, required this.best});

  final CastleDefense game;
  final int best;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text("❤️ ${game.lives}", style: style),
          const SizedBox(width: 16),
          Text("🪙 ${game.gold}", style: style),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Dalga ${game.wave}/${CastleDefense.waves}", style: style),
              Text(
                "Rekor: $best dalga",
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tower to choose; once chosen it is previewed on the board and this
/// button confirms it.
class _BuildButton extends StatelessWidget {
  const _BuildButton({
    required this.kind,
    required this.affordable,
    required this.chosen,
    required this.onPressed,
  });

  final TowerKind kind;
  final bool affordable;
  final bool chosen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      key: ValueKey('build-${kind.name}'),
      onPressed: affordable ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: chosen ? const Color(0xFF43A047) : null,
        foregroundColor: chosen ? Colors.white : null,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: chosen
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(kind.emoji, style: const TextStyle(fontSize: 22)),
          Text(
            chosen ? "Kur ✓" : "${kind.cost} 🪙",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: chosen ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndOverlay extends StatelessWidget {
  const _EndOverlay({
    required this.game,
    required this.earned,
    required this.newBest,
    required this.next,
    required this.onRestart,
    required this.onNext,
    required this.onMenu,
  });

  final CastleDefense game;
  final List<CastleAchievement> earned;
  final bool newBest;

  /// The map this win opened, if any.
  final CastleMap? next;
  final VoidCallback onRestart;
  final void Function(CastleMap map) onNext;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final won = game.isWon;
    final next = this.next;
    return ColoredBox(
      color: const Color(0xCC000000),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(won ? '🏰' : '🔥', style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(
                won ? "Kale kurtuldu!" : "Kale düştü!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${CastleProfile.held(game)} dalga dayandın · "
                "${game.kills} düşman",
                style: const TextStyle(color: Colors.white70),
              ),
              if (newBest)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    "Yeni rekor!",
                    style: TextStyle(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              for (final a in earned)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "🏆 ${a.emoji} ${a.title}",
                    style: const TextStyle(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (next != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Yeni harita açıldı: ${next.emoji} ${next.title}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 16),
              if (next != null) ...[
                FilledButton(
                  key: const ValueKey('next-map'),
                  onPressed: () => onNext(next),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                  ),
                  child: Text("${next.title} haritasına geç"),
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: onRestart,
                    child: const Text("Tekrar oyna"),
                  ),
                  OutlinedButton(
                    onPressed: onMenu,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Ana menü"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grass, the road, the castle, towers, enemies and shots. Everything is
/// placed in tiles and drawn at real pixel sizes, so emoji stay sharp.
class _BoardPainter extends CustomPainter {
  _BoardPainter(this.game, this.selected, this.preview);

  final CastleDefense game;
  final Tile? selected;

  /// A tower shown on [selected] before it is built.
  final TowerKind? preview;

  @override
  void paint(Canvas canvas, Size size) {
    final t = size.width / CastleDefense.cols;
    Offset at(double x, double y) => Offset(x * t, y * t);

    for (var c = 0; c < CastleDefense.cols; c++) {
      for (var r = 0; r < CastleDefense.rows; r++) {
        final rect = Rect.fromLTWH(c * t, r * t, t, t);
        final onRoad = game.road.contains((col: c, row: r));
        canvas.drawRect(
          rect,
          Paint()
            ..color = Color(
              onRoad ? game.map.roadColor : game.map.grass[(c + r) % 2],
            ),
        );
      }
    }

    final castle = game.castle;
    _emoji(canvas, '🏰', at(castle.col + 0.5, castle.row + 0.5), t * 0.85);

    final chosen = selected;
    if (chosen != null) {
      canvas.drawRect(
        Rect.fromLTWH(chosen.col * t, chosen.row * t, t, t).deflate(1.5),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final tower = game.towerAt(chosen);
      final ghost = preview;
      final range = tower?.range ?? ghost?.range.first;
      if (range != null) {
        final centre = at(chosen.col + 0.5, chosen.row + 0.5);
        canvas
          ..drawCircle(
            centre,
            range * t,
            Paint()..color = const Color(0x22FFFFFF),
          )
          ..drawCircle(
            centre,
            range * t,
            Paint()
              ..color = const Color(0x88FFFFFF)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
      }
      if (tower == null && ghost != null) {
        final centre = at(chosen.col + 0.5, chosen.row + 0.5);
        canvas.drawCircle(
          centre,
          t * 0.42,
          Paint()..color = const Color(0x888D8D8D),
        );
        _emoji(canvas, ghost.emoji, centre, t * 0.48, opacity: 0.75);
      }
    }

    for (final tower in game.towers) {
      final centre = at(tower.x, tower.y);
      canvas
        ..drawCircle(centre, t * 0.42, Paint()..color = const Color(0xFF8D8D8D))
        ..drawCircle(
          centre,
          t * 0.42,
          Paint()
            ..color = const Color(0xFF555555)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      _emoji(
        canvas,
        tower.kind.emoji,
        centre.translate(0, -t * 0.04),
        t * 0.48,
      );
      for (var i = 0; i < tower.level; i++) {
        canvas.drawCircle(
          centre.translate((i - (tower.level - 1) / 2) * t * 0.16, t * 0.3),
          t * 0.055,
          Paint()..color = const Color(0xFFFFD54F),
        );
      }
    }

    for (final enemy in game.enemies) {
      final p = game.map.positionAt(enemy.distance);
      final centre = at(p.x, p.y);
      if (enemy.slowFactor < 1) {
        canvas.drawCircle(
          centre,
          t * 0.34,
          Paint()..color = const Color(0x6680D8FF),
        );
      }
      final big =
          enemy.kind == EnemyKind.dragon || enemy.kind == EnemyKind.giant;
      _emoji(canvas, enemy.kind.emoji, centre, t * (big ? 0.7 : 0.52));
      final bar = Rect.fromCenter(
        center: centre.translate(0, -t * 0.42),
        width: t * 0.6,
        height: max(3, t * 0.07),
      );
      canvas
        ..drawRect(bar, Paint()..color = const Color(0xAA000000))
        ..drawRect(
          Rect.fromLTWH(
            bar.left,
            bar.top,
            bar.width * (enemy.hp / enemy.maxHp).clamp(0, 1),
            bar.height,
          ),
          Paint()..color = const Color(0xFFE53935),
        );
    }

    for (final shot in game.shots) {
      final fade = 1 - shot.age / Shot.life;
      final to = at(shot.to.x, shot.to.y);
      switch (shot.kind) {
        case TowerKind.cannon:
          canvas.drawCircle(
            to,
            TowerKind.cannon.splash * t * (0.4 + 0.6 * (1 - fade)),
            Paint()..color = Color.fromRGBO(255, 152, 0, 0.6 * fade),
          );
        case TowerKind.archer || TowerKind.frost:
          canvas.drawLine(
            at(shot.from.x, shot.from.y),
            to,
            Paint()
              ..color = shot.kind == TowerKind.frost
                  ? Color.fromRGBO(128, 216, 255, fade)
                  : Color.fromRGBO(93, 64, 55, fade)
              ..strokeWidth = 2.5,
          );
      }
    }
  }

  void _emoji(
    Canvas canvas,
    String emoji,
    Offset centre,
    double size, {
    double opacity = 1,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: size,
          color: Color.fromRGBO(0, 0, 0, opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      centre - Offset(painter.width / 2, painter.height / 2),
    );
    painter.dispose();
  }

  @override
  bool shouldRepaint(_BoardPainter old) => true;
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/app_theme.dart';
import 'castle_defense.dart';

/// Kale Muhafızı from AppShop: build towers beside the road and hold the
/// castle through twenty waves of goblins, orcs, giants and dragons.
class CastleGuardApp extends StatefulWidget {
  const CastleGuardApp({super.key, this.initialGame});

  /// Where the most waves held is saved.
  static const bestKey = 'castleGuard.best';

  /// A game to start from; tests pass one with a known state.
  final CastleDefense? initialGame;

  @override
  State<CastleGuardApp> createState() => _CastleGuardAppState();
}

class _CastleGuardAppState extends State<CastleGuardApp>
    with SingleTickerProviderStateMixin {
  static const _background = Color(0xFF33402B);

  late final Ticker _ticker = createTicker(_onTick);
  late CastleDefense _game = widget.initialGame ?? CastleDefense();
  Duration _lastTick = Duration.zero;
  Tile? _selected;
  bool _fast = false;
  int _best = 0;
  bool _newBest = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _loadBest();
    _ticker.start();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt(CastleGuardApp.bestKey) ?? 0;
    if (mounted) setState(() => _best = best);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    // A long frame (or a tab in the background) shouldn't teleport enemies.
    final dt = min((elapsed - _lastTick).inMicroseconds / 1e6, 0.05);
    _lastTick = elapsed;
    final game = _game;
    if (game.isOver || (!game.waveRunning && game.shots.isEmpty)) return;
    setState(() {
      for (var i = 0; i < (_fast ? 2 : 1); i++) {
        game.update(dt);
      }
    });
    if (game.isOver && !_finished) _finish(game);
  }

  /// Waves the castle held out against.
  static int _held(CastleDefense game) =>
      game.isWon ? CastleDefense.waves : max(0, game.wave - 1);

  Future<void> _finish(CastleDefense game) async {
    _finished = true;
    _selected = null;
    final held = _held(game);
    if (held <= _best) return;
    setState(() {
      _best = held;
      _newBest = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(CastleGuardApp.bestKey, held);
  }

  void _restart() {
    setState(() {
      _game = CastleDefense();
      _selected = null;
      _newBest = false;
      _finished = false;
    });
  }

  void _tapBoard(Offset position, double tile) {
    if (_game.isOver) return;
    final tapped = (
      col: (position.dx / tile).floor(),
      row: (position.dy / tile).floor(),
    );
    final buildable = _game.towerAt(tapped) != null || _game.canBuildOn(tapped);
    setState(() {
      _selected = tapped == _selected || !buildable ? null : tapped;
    });
  }

  void _build(TowerKind kind) {
    final tile = _selected;
    if (tile == null) return;
    setState(() {
      if (_game.build(kind, tile) == null) _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text("Kale Muhafızı"),
        backgroundColor: _background,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Hud(game: game, best: _best),
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
                            onTapUp: (d) => _tapBoard(d.localPosition, tile),
                            child: CustomPaint(
                              painter: _BoardPainter(game, _selected),
                            ),
                          ),
                          if (game.isOver)
                            _EndOverlay(
                              won: game.isWon,
                              held: _held(game),
                              kills: game.kills,
                              newBest: _newBest,
                              onRestart: _restart,
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
                  ? () => setState(() => game.upgrade(tower))
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
              onPressed: () => setState(() {
                game.sell(tower);
                _selected = null;
              }),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              child: Text("Sat · +${tower.refund} 🪙"),
            ),
          ),
        ],
      );
    }
    if (tile != null) {
      return _Panel(
        title: "Kule kur",
        children: [
          for (final kind in TowerKind.values) ...[
            if (kind != TowerKind.values.first) const SizedBox(width: 8),
            Expanded(
              child: _BuildButton(
                kind: kind,
                affordable: game.gold >= kind.cost,
                onPressed: () => _build(kind),
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

class _BuildButton extends StatelessWidget {
  const _BuildButton({
    required this.kind,
    required this.affordable,
    required this.onPressed,
  });

  final TowerKind kind;
  final bool affordable;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      key: ValueKey('build-${kind.name}'),
      onPressed: affordable ? onPressed : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(kind.emoji, style: const TextStyle(fontSize: 22)),
          Text(
            "${kind.cost} 🪙",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EndOverlay extends StatelessWidget {
  const _EndOverlay({
    required this.won,
    required this.held,
    required this.kills,
    required this.newBest,
    required this.onRestart,
  });

  final bool won;
  final int held;
  final int kills;
  final bool newBest;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xB3000000),
      child: Center(
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
              "$held dalga dayandın · $kills düşman",
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
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRestart,
              child: const Text("Tekrar oyna"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grass, the road, the castle, towers, enemies and shots. Everything is
/// placed in tiles and drawn at real pixel sizes, so emoji stay sharp.
class _BoardPainter extends CustomPainter {
  _BoardPainter(this.game, this.selected);

  final CastleDefense game;
  final Tile? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final t = size.width / CastleDefense.cols;
    Offset at(double x, double y) => Offset(x * t, y * t);

    for (var c = 0; c < CastleDefense.cols; c++) {
      for (var r = 0; r < CastleDefense.rows; r++) {
        final rect = Rect.fromLTWH(c * t, r * t, t, t);
        final onRoad = CastleDefense.road.contains((col: c, row: r));
        canvas.drawRect(
          rect,
          Paint()
            ..color = onRoad
                ? const Color(0xFFD9BC8C)
                : (c + r).isEven
                ? const Color(0xFF7CB342)
                : const Color(0xFF8BC34A),
        );
      }
    }

    final castle = CastleDefense.castle;
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
      if (tower != null) {
        final centre = at(tower.x, tower.y);
        canvas
          ..drawCircle(
            centre,
            tower.range * t,
            Paint()..color = const Color(0x22FFFFFF),
          )
          ..drawCircle(
            centre,
            tower.range * t,
            Paint()
              ..color = const Color(0x88FFFFFF)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
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
      final p = CastleDefense.positionAt(enemy.distance);
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

  void _emoji(Canvas canvas, String emoji, Offset centre, double size) {
    final painter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size),
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

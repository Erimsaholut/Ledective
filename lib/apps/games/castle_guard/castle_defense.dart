import 'dart:math';

/// A tile on the board, counted from the top left.
typedef Tile = ({int col, int row});

/// A kind of tower the player can build beside the road.
enum TowerKind {
  archer(
    title: "Okçu Kulesi",
    emoji: '🏹',
    cost: 50,
    damage: [5, 9, 14],
    rate: 1.6,
    range: [2.4, 2.7, 3.0],
  ),
  cannon(
    title: "Top Kulesi",
    emoji: '💣',
    cost: 80,
    damage: [16, 26, 42],
    rate: 0.55,
    range: [2.1, 2.3, 2.5],
    splash: 1.0,
  ),
  frost(
    title: "Buz Kulesi",
    emoji: '❄️',
    cost: 70,
    damage: [3, 5, 8],
    rate: 1.0,
    range: [2.1, 2.3, 2.5],
    slow: [0.4, 0.5, 0.6],
  );

  const TowerKind({
    required this.title,
    required this.emoji,
    required this.cost,
    required this.damage,
    required this.rate,
    required this.range,
    this.splash = 0,
    this.slow = const [0, 0, 0],
  });

  final String title;
  final String emoji;

  /// Gold to build it.
  final int cost;

  /// Damage per shot at each level.
  final List<int> damage;

  /// Shots per second.
  final double rate;

  /// Reach in tiles at each level.
  final List<double> range;

  /// Radius in tiles hit around the target, or 0 for one enemy only.
  final double splash;

  /// How much a hit slows its target at each level, e.g. 0.4 for 40%.
  final List<double> slow;
}

/// A built tower.
class Tower {
  Tower(this.kind, this.tile);

  final TowerKind kind;
  final Tile tile;

  /// From 1 to [maxLevel].
  int level = 1;

  /// Gold put into it so far, for the refund when sold.
  late int spent = kind.cost;
  double cooldown = 0;

  static const maxLevel = 3;

  int get damage => kind.damage[level - 1];
  double get range => kind.range[level - 1];
  double get slow => kind.slow[level - 1];

  /// Gold for the next level, or null at the top.
  int? get upgradeCost =>
      level >= maxLevel ? null : (kind.cost * (level == 1 ? 0.8 : 1.4)).round();

  int get refund => (spent * 0.6).round();

  double get x => tile.col + 0.5;
  double get y => tile.row + 0.5;
}

/// A kind of enemy marching on the castle.
enum EnemyKind {
  goblin(title: "Goblin", emoji: '👺', hp: 22, speed: 1.3, reward: 4),
  wolf(title: "Kurt", emoji: '🐺', hp: 26, speed: 2.1, reward: 5),
  orc(title: "Ork", emoji: '👹', hp: 60, speed: 0.95, reward: 8, damage: 2),
  giant(
    title: "Taş Dev",
    emoji: '🗿',
    hp: 200,
    speed: 0.6,
    reward: 18,
    damage: 5,
  ),
  dragon(
    title: "Ejderha",
    emoji: '🐉',
    hp: 450,
    speed: 0.55,
    reward: 70,
    damage: 8,
  );

  const EnemyKind({
    required this.title,
    required this.emoji,
    required this.hp,
    required this.speed,
    required this.reward,
    this.damage = 1,
  });

  final String title;
  final String emoji;
  final int hp;

  /// Tiles per second.
  final double speed;

  /// Gold for killing one.
  final int reward;

  /// Lives the castle loses when one gets in.
  final int damage;
}

class Enemy {
  Enemy(this.kind, {required this.maxHp}) : hp = maxHp;

  final EnemyKind kind;
  final double maxHp;
  double hp;

  /// Tiles walked along the road.
  double distance = 0;

  /// Speed factor from frost, and how long it lasts.
  double slowFactor = 1;
  double slowFor = 0;

  bool get isDead => hp <= 0;
}

/// A shot drawn briefly from a tower to where it hit.
class Shot {
  Shot({required this.from, required this.to, required this.kind});

  final ({double x, double y}) from;
  final ({double x, double y}) to;
  final TowerKind kind;
  double age = 0;

  static const life = 0.15;
}

/// One game of Kale Muhafızı. Enemies come down a winding road in waves;
/// towers built beside it shoot them for gold. The castle falls when its
/// lives run out, and is saved after the last wave.
class CastleDefense {
  CastleDefense({Random? random}) : _random = random ?? Random();

  static const cols = 8;
  static const rows = 12;
  static const waves = 20;
  static const startGold = 150;
  static const startLives = 20;

  /// Seconds between enemies in a wave.
  static const spawnGap = 0.8;

  /// The road's corners, from where enemies come in to the castle gate.
  static const List<Tile> waypoints = [
    (col: 1, row: -1),
    (col: 1, row: 2),
    (col: 6, row: 2),
    (col: 6, row: 5),
    (col: 1, row: 5),
    (col: 1, row: 8),
    (col: 6, row: 8),
    (col: 6, row: 11),
  ];

  /// The tile the castle stands on, at the end of the road.
  static Tile get castle => waypoints.last;

  /// Every tile the road covers.
  static final Set<Tile> road = {
    for (var i = 1; i < waypoints.length; i++)
      ..._between(waypoints[i - 1], waypoints[i]),
  };

  static Iterable<Tile> _between(Tile a, Tile b) sync* {
    final dc = (b.col - a.col).sign;
    final dr = (b.row - a.row).sign;
    var t = a;
    while (true) {
      if (t.row >= 0) yield t;
      if (t == b) return;
      t = (col: t.col + dc, row: t.row + dr);
    }
  }

  /// The road's length in tiles.
  static final double roadLength = [
    for (var i = 1; i < waypoints.length; i++)
      (waypoints[i].col - waypoints[i - 1].col).abs() +
          (waypoints[i].row - waypoints[i - 1].row).abs(),
  ].fold(0, (a, b) => a + b).toDouble();

  /// Where on the board an enemy [distance] tiles down the road is.
  static ({double x, double y}) positionAt(double distance) {
    var left = distance;
    for (var i = 1; i < waypoints.length; i++) {
      final a = waypoints[i - 1];
      final b = waypoints[i];
      final length = ((b.col - a.col).abs() + (b.row - a.row).abs()).toDouble();
      if (left <= length) {
        final t = left / length;
        return (
          x: a.col + 0.5 + (b.col - a.col) * t,
          y: a.row + 0.5 + (b.row - a.row) * t,
        );
      }
      left -= length;
    }
    return (x: castle.col + 0.5, y: castle.row + 0.5);
  }

  final Random _random;
  final List<Tower> towers = [];
  final List<Enemy> enemies = [];
  final List<Shot> shots = [];

  int gold = startGold;
  int lives = startLives;

  /// The wave being fought or last fought; 0 before the first.
  int wave = 0;
  int kills = 0;

  /// Enemies of this wave still to come in.
  final List<EnemyKind> _toSpawn = [];
  double _untilSpawn = 0;

  bool get isLost => lives <= 0;
  bool get isWon => wave >= waves && !waveRunning && !isLost;
  bool get isOver => isLost || isWon;

  bool get waveRunning => _toSpawn.isNotEmpty || enemies.isNotEmpty;

  bool canBuildOn(Tile tile) =>
      tile.col >= 0 &&
      tile.col < cols &&
      tile.row >= 0 &&
      tile.row < rows &&
      !road.contains(tile) &&
      towerAt(tile) == null;

  Tower? towerAt(Tile tile) {
    for (final tower in towers) {
      if (tower.tile == tile) return tower;
    }
    return null;
  }

  Tower? build(TowerKind kind, Tile tile) {
    if (isOver || !canBuildOn(tile) || gold < kind.cost) return null;
    gold -= kind.cost;
    final tower = Tower(kind, tile);
    towers.add(tower);
    return tower;
  }

  bool upgrade(Tower tower) {
    final cost = tower.upgradeCost;
    if (isOver || cost == null || gold < cost) return false;
    gold -= cost;
    tower
      ..level += 1
      ..spent += cost;
    return true;
  }

  void sell(Tower tower) {
    if (isOver || !towers.remove(tower)) return;
    gold += tower.refund;
  }

  /// The enemies of wave [n]: goblins at first, then faster, tougher and
  /// bigger ones, and a dragon every fifth wave from the tenth.
  static List<EnemyKind> waveEnemies(int n) => [
    for (var i = 0; i < 5 + 2 * n; i++)
      if (n >= 8 && i % 6 == 5)
        EnemyKind.giant
      else if (n >= 3 && i % 3 == 1)
        EnemyKind.orc
      else if (n >= 5 && i % 3 == 2)
        EnemyKind.wolf
      else
        EnemyKind.goblin,
    if (n >= 4 && n % 4 == 0) EnemyKind.giant,
    if (n >= 10 && n % 5 == 0) EnemyKind.dragon,
  ];

  /// Enemies grow stronger with every wave.
  static double toughness(int wave) =>
      1 + 0.18 * (wave - 1) + 0.009 * wave * wave;

  /// Gold for holding out against wave [n].
  static int waveBonus(int n) => 15 + 5 * n;

  /// Sends the next wave. Only one wave at a time.
  bool startWave() {
    if (isOver || waveRunning || wave >= waves) return false;
    wave++;
    _toSpawn.addAll(waveEnemies(wave));
    _untilSpawn = 0;
    return true;
  }

  /// Moves the game on by [dt] seconds.
  void update(double dt) {
    if (isOver) return;
    final wasRunning = waveRunning;

    _untilSpawn -= dt;
    if (_toSpawn.isNotEmpty && _untilSpawn <= 0) {
      final kind = _toSpawn.removeAt(0);
      enemies.add(Enemy(kind, maxHp: kind.hp * toughness(wave)));
      _untilSpawn = spawnGap * (0.85 + 0.3 * _random.nextDouble());
    }

    for (final enemy in enemies) {
      if (enemy.slowFor > 0) {
        enemy.slowFor -= dt;
        if (enemy.slowFor <= 0) enemy.slowFactor = 1;
      }
      enemy.distance += enemy.kind.speed * enemy.slowFactor * dt;
    }
    enemies.removeWhere((enemy) {
      if (enemy.distance < roadLength) return false;
      lives = max(0, lives - enemy.kind.damage);
      return true;
    });

    for (final tower in towers) {
      tower.cooldown -= dt;
      if (tower.cooldown > 0) continue;
      final target = _targetFor(tower);
      if (target == null) continue;
      tower.cooldown = 1 / tower.kind.rate;
      _fire(tower, target);
    }
    enemies.removeWhere((enemy) {
      if (!enemy.isDead) return false;
      gold += enemy.kind.reward;
      kills++;
      return true;
    });

    for (final shot in shots) {
      shot.age += dt;
    }
    shots.removeWhere((shot) => shot.age > Shot.life);

    if (wasRunning && !waveRunning && !isLost) gold += waveBonus(wave);
  }

  /// The enemy in reach that is furthest down the road.
  Enemy? _targetFor(Tower tower) {
    Enemy? best;
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final p = positionAt(enemy.distance);
      final dx = p.x - tower.x;
      final dy = p.y - tower.y;
      if (dx * dx + dy * dy > tower.range * tower.range) continue;
      if (best == null || enemy.distance > best.distance) best = enemy;
    }
    return best;
  }

  void _fire(Tower tower, Enemy target) {
    final at = positionAt(target.distance);
    shots.add(Shot(from: (x: tower.x, y: tower.y), to: at, kind: tower.kind));
    final hit = tower.kind.splash > 0
        ? enemies.where((enemy) {
            final p = positionAt(enemy.distance);
            final dx = p.x - at.x;
            final dy = p.y - at.y;
            return dx * dx + dy * dy <= tower.kind.splash * tower.kind.splash;
          }).toList()
        : [target];
    for (final enemy in hit) {
      enemy.hp -= tower.damage;
      if (tower.slow > 0) {
        enemy
          ..slowFactor = min(enemy.slowFactor, 1 - tower.slow)
          ..slowFor = 1.5;
      }
    }
  }
}

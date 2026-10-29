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
  ),

  /// Shoots nothing, but digs gold after every wave. It costs more than it
  /// brings at first and pays off the longer the game goes.
  mine(
    title: "Altın Madeni",
    emoji: '⛏️',
    cost: 120,
    damage: [0, 0, 0],
    rate: 0,
    range: [0, 0, 0],
    income: [6, 14, 30],
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
    this.income = const [0, 0, 0],
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

  /// Gold dug at each level after a wave, before it grows with the waves.
  final List<int> income;

  bool get shoots => rate > 0;
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

  /// Gold this tower digs after beating wave [wave]: a little at first,
  /// more and more as the waves go on.
  int incomeAfter(int wave) =>
      (kind.income[level - 1] * (1 + wave / 4)).round();

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

/// A battlefield: the road enemies take to the castle, how the ground
/// looks and how much tougher the enemies are than on the first.
class CastleMap {
  CastleMap({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.waypoints,
    required this.grass,
    required this.roadColor,
    this.hpScale = 1,
    this.startGold = CastleDefense.startGold,
  });

  /// Saved with the progress; never change it once released.
  final String id;
  final String title;
  final String emoji;
  final String description;

  /// The road's corners, from where enemies come in to the castle gate.
  final List<Tile> waypoints;

  /// The two shades of the grass checkerboard, and the road, as ARGB.
  final List<int> grass;
  final int roadColor;

  /// Enemy health compared with the first map.
  final double hpScale;
  final int startGold;

  /// The tile the castle stands on, at the end of the road.
  Tile get castle => waypoints.last;

  /// Every tile the road covers.
  late final Set<Tile> road = {
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
  late final double roadLength = [
    for (var i = 1; i < waypoints.length; i++)
      (waypoints[i].col - waypoints[i - 1].col).abs() +
          (waypoints[i].row - waypoints[i - 1].row).abs(),
  ].fold(0, (a, b) => a + b).toDouble();

  /// Where on the board an enemy [distance] tiles down the road is.
  ({double x, double y}) positionAt(double distance) {
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
}

/// The three maps, each opened by saving the castle on the one before.
/// On each the enemies are tougher than on the last.
final List<CastleMap> castleMaps = [
  CastleMap(
    id: 'meadow',
    title: "Yeşil Vadi",
    emoji: '🌿',
    description: "Uzun, kıvrımlı bir yol. Kuleleri öğrenmek için ideal.",
    waypoints: const [
      (col: 1, row: -1),
      (col: 1, row: 2),
      (col: 6, row: 2),
      (col: 6, row: 5),
      (col: 1, row: 5),
      (col: 1, row: 8),
      (col: 6, row: 8),
      (col: 6, row: 11),
    ],
    grass: const [0xFF7CB342, 0xFF8BC34A],
    roadColor: 0xFFD9BC8C,
  ),
  CastleMap(
    id: 'swamp',
    title: "Sisli Bataklık",
    emoji: '🐸',
    description: "Bataklığın düşmanları daha dayanıklı. Kulelerini iyi seç.",
    waypoints: const [
      (col: 1, row: -1),
      (col: 1, row: 8),
      (col: 4, row: 8),
      (col: 4, row: 2),
      (col: 6, row: 2),
      (col: 6, row: 11),
    ],
    grass: const [0xFF5D7A4A, 0xFF6B8A56],
    roadColor: 0xFF8D7B5A,
    hpScale: 1.25,
    startGold: 170,
  ),
  CastleMap(
    id: 'mountain',
    title: "Ejderha Dağı",
    emoji: '🌋',
    description: "En güçlü düşmanlar burada. Gerçek muhafızlar için.",
    waypoints: const [
      (col: 1, row: -1),
      (col: 1, row: 9),
      (col: 3, row: 9),
      (col: 3, row: 2),
      (col: 5, row: 2),
      (col: 5, row: 10),
      (col: 7, row: 10),
    ],
    grass: const [0xFF8A7F72, 0xFF978C7F],
    roadColor: 0xFF5A4A42,
    hpScale: 1.4,
    startGold: 190,
  ),
];

CastleMap castleMapById(String id) =>
    castleMaps.firstWhere((map) => map.id == id);

/// One game of Kale Muhafızı. Enemies come down a winding road in waves;
/// towers built beside it shoot them for gold. The castle falls when its
/// lives run out, and is saved after the last wave.
class CastleDefense {
  CastleDefense({CastleMap? map, this.endless = false, Random? random})
    : map = map ?? castleMaps.first,
      _random = random ?? Random() {
    gold = this.map.startGold;
    richest = gold;
  }

  /// Picks up a game saved with [toJson].
  factory CastleDefense.fromJson(Map<String, dynamic> json, {Random? random}) {
    final game = CastleDefense(
      map: castleMapById(json['map'] as String),
      endless: json['endless'] as bool? ?? false,
      random: random,
    );
    game
      ..gold = json['gold'] as int
      ..lives = json['lives'] as int
      ..wave = json['wave'] as int
      ..kills = json['kills'] as int
      ..towersBuilt = json['built'] as int? ?? 0
      ..goldSpent = json['spent'] as int? ?? 0
      ..mined = json['mined'] as int? ?? 0
      ..richest = json['richest'] as int? ?? game.gold
      .._untilSpawn = (json['untilSpawn'] as num? ?? 0).toDouble();
    (json['killsBy'] as Map? ?? const {}).forEach(
      (kind, count) =>
          game.killsBy[EnemyKind.values.byName(kind as String)] = count as int,
    );
    game.kindsBuilt.addAll([
      for (final kind in json['kinds'] as List? ?? const [])
        TowerKind.values.byName(kind as String),
    ]);
    for (final t in json['towers'] as List) {
      final tower = t as Map<String, dynamic>;
      game.towers.add(
        Tower(TowerKind.values.byName(tower['kind'] as String), (
            col: tower['col'] as int,
            row: tower['row'] as int,
          ))
          ..level = tower['level'] as int
          ..spent = tower['spent'] as int,
      );
    }
    for (final e in json['enemies'] as List) {
      final enemy = e as Map<String, dynamic>;
      game.enemies.add(
        Enemy(
            EnemyKind.values.byName(enemy['kind'] as String),
            maxHp: (enemy['maxHp'] as num).toDouble(),
          )
          ..hp = (enemy['hp'] as num).toDouble()
          ..distance = (enemy['distance'] as num).toDouble()
          ..slowFactor = (enemy['slowFactor'] as num).toDouble()
          ..slowFor = (enemy['slowFor'] as num).toDouble(),
      );
    }
    game._toSpawn.addAll([
      for (final kind in json['toSpawn'] as List)
        EnemyKind.values.byName(kind as String),
    ]);
    return game;
  }

  static const cols = 8;
  static const rows = 12;
  static const waves = 20;
  static const startGold = 150;
  static const startLives = 20;

  /// Seconds between enemies in a wave.
  static const spawnGap = 0.8;

  final CastleMap map;

  /// The sandbox: waves never stop coming, so the game only ends when the
  /// castle falls.
  final bool endless;

  Set<Tile> get road => map.road;
  Tile get castle => map.castle;

  final Random _random;
  final List<Tower> towers = [];
  final List<Enemy> enemies = [];
  final List<Shot> shots = [];

  late int gold;
  int lives = startLives;

  /// The wave being fought or last fought; 0 before the first.
  int wave = 0;
  int kills = 0;

  /// What this game has seen so far, for the statistics and achievements.
  final Map<EnemyKind, int> killsBy = {};
  final Set<TowerKind> kindsBuilt = {};
  int towersBuilt = 0;
  int goldSpent = 0;

  /// Gold the mines have dug.
  int mined = 0;

  /// The most gold held at once.
  late int richest;

  /// The highest level any tower has reached.
  int get topLevel => towers.fold(0, (top, t) => max(top, t.level));

  /// Enemies of this wave still to come in.
  final List<EnemyKind> _toSpawn = [];
  double _untilSpawn = 0;

  bool get isLost => lives <= 0;
  bool get isWon => !endless && wave >= waves && !waveRunning && !isLost;
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
    _spend(kind.cost);
    final tower = Tower(kind, tile);
    towers.add(tower);
    towersBuilt++;
    kindsBuilt.add(kind);
    return tower;
  }

  bool upgrade(Tower tower) {
    final cost = tower.upgradeCost;
    if (isOver || cost == null || gold < cost) return false;
    _spend(cost);
    tower
      ..level += 1
      ..spent += cost;
    return true;
  }

  void sell(Tower tower) {
    if (isOver || !towers.remove(tower)) return;
    _earn(tower.refund);
  }

  void _spend(int amount) {
    gold -= amount;
    goldSpent += amount;
  }

  void _earn(int amount) {
    gold += amount;
    richest = max(richest, gold);
  }

  /// The enemies of wave [n]: goblins at first, then faster, tougher and
  /// bigger ones, and a dragon every fifth wave from the tenth. Past the
  /// twentieth, in the sandbox, dragons come in growing flights.
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
    if (n > waves)
      for (var i = 0; i < (n - waves) ~/ 4; i++) EnemyKind.dragon,
  ];

  /// Enemies grow stronger with every wave.
  static double toughness(int wave) =>
      1 + 0.18 * (wave - 1) + 0.009 * wave * wave;

  /// Gold for holding out against wave [n].
  static int waveBonus(int n) => 15 + 5 * n;

  /// Sends the next wave. Only one wave at a time.
  bool startWave() {
    if (isOver || waveRunning || (!endless && wave >= waves)) return false;
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
      enemies.add(Enemy(kind, maxHp: kind.hp * toughness(wave) * map.hpScale));
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
      if (enemy.distance < map.roadLength) return false;
      lives = max(0, lives - enemy.kind.damage);
      return true;
    });

    for (final tower in towers) {
      if (!tower.kind.shoots) continue;
      tower.cooldown -= dt;
      if (tower.cooldown > 0) continue;
      final target = _targetFor(tower);
      if (target == null) continue;
      tower.cooldown = 1 / tower.kind.rate;
      _fire(tower, target);
    }
    enemies.removeWhere((enemy) {
      if (!enemy.isDead) return false;
      _earn(enemy.kind.reward);
      kills++;
      killsBy[enemy.kind] = (killsBy[enemy.kind] ?? 0) + 1;
      return true;
    });

    for (final shot in shots) {
      shot.age += dt;
    }
    shots.removeWhere((shot) => shot.age > Shot.life);

    if (wasRunning && !waveRunning && !isLost) {
      final dug = towers.fold(0, (sum, t) => sum + t.incomeAfter(wave));
      mined += dug;
      _earn(waveBonus(wave) + dug);
    }
  }

  /// The enemy in reach that is furthest down the road.
  Enemy? _targetFor(Tower tower) {
    Enemy? best;
    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final p = map.positionAt(enemy.distance);
      final dx = p.x - tower.x;
      final dy = p.y - tower.y;
      if (dx * dx + dy * dy > tower.range * tower.range) continue;
      if (best == null || enemy.distance > best.distance) best = enemy;
    }
    return best;
  }

  void _fire(Tower tower, Enemy target) {
    final at = map.positionAt(target.distance);
    shots.add(Shot(from: (x: tower.x, y: tower.y), to: at, kind: tower.kind));
    final hit = tower.kind.splash > 0
        ? enemies.where((enemy) {
            final p = map.positionAt(enemy.distance);
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

  Map<String, Object> toJson() => {
    'map': map.id,
    'endless': endless,
    'mined': mined,
    'gold': gold,
    'lives': lives,
    'wave': wave,
    'kills': kills,
    'built': towersBuilt,
    'spent': goldSpent,
    'richest': richest,
    'untilSpawn': _untilSpawn,
    'killsBy': {for (final e in killsBy.entries) e.key.name: e.value},
    'kinds': [for (final kind in kindsBuilt) kind.name],
    'towers': [
      for (final t in towers)
        {
          'kind': t.kind.name,
          'col': t.tile.col,
          'row': t.tile.row,
          'level': t.level,
          'spent': t.spent,
        },
    ],
    'enemies': [
      for (final e in enemies)
        {
          'kind': e.kind.name,
          'hp': e.hp,
          'maxHp': e.maxHp,
          'distance': e.distance,
          'slowFactor': e.slowFactor,
          'slowFor': e.slowFor,
        },
    ],
    'toSpawn': [for (final kind in _toSpawn) kind.name],
  };
}

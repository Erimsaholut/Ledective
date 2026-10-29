import 'dart:math';

import 'farm_catalog.dart';
import 'farm_league.dart';

/// One field of the farm, empty or growing a crop until [readyAt].
class Plot {
  Plot({this.cropId, this.plantedAt, this.readyAt});

  factory Plot.fromJson(Map<String, dynamic> json) {
    DateTime? time(String key) => json[key] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json[key] as int);
    return Plot(
      cropId: json['crop'] as String?,
      plantedAt: time('planted'),
      readyAt: time('ready'),
    );
  }

  String? cropId;
  DateTime? plantedAt;
  DateTime? readyAt;

  bool get isEmpty => cropId == null;

  Crop? get crop => cropId == null ? null : cropById(cropId!);

  bool isReady(DateTime now) => readyAt != null && !now.isBefore(readyAt!);

  /// How far the crop has grown, from 0 to 1.
  double progress(DateTime now) {
    if (plantedAt == null || readyAt == null) return 0;
    final total = readyAt!.difference(plantedAt!).inMilliseconds;
    if (total <= 0) return 1;
    final done = now.difference(plantedAt!).inMilliseconds;
    return (done / total).clamp(0.0, 1.0);
  }

  Map<String, Object?> toJson() => {
    'crop': cropId,
    'planted': plantedAt?.millisecondsSinceEpoch,
    'ready': readyAt?.millisecondsSinceEpoch,
  };
}

/// One animal on the farm: hungry, busy making its product until
/// [readyAt], or waiting for the product to be collected.
class FarmAnimal {
  FarmAnimal(this.kindId, {this.fedAt, this.readyAt});

  factory FarmAnimal.fromJson(Map<String, dynamic> json) {
    DateTime? time(String key) => json[key] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json[key] as int);
    return FarmAnimal(
      json['kind'] as String,
      fedAt: time('fed'),
      readyAt: time('ready'),
    );
  }

  final String kindId;
  DateTime? fedAt;
  DateTime? readyAt;

  Animal get kind => animalById(kindId);

  bool get isHungry => readyAt == null;

  bool isReady(DateTime now) => readyAt != null && !now.isBefore(readyAt!);

  /// How far the product is, from 0 to 1.
  double progress(DateTime now) {
    if (fedAt == null || readyAt == null) return 0;
    final total = readyAt!.difference(fedAt!).inMilliseconds;
    if (total <= 0) return 1;
    return (now.difference(fedAt!).inMilliseconds / total).clamp(0.0, 1.0);
  }

  Map<String, Object?> toJson() => {
    'kind': kindId,
    'fed': fedAt?.millisecondsSinceEpoch,
    'ready': readyAt?.millisecondsSinceEpoch,
  };
}

/// A neighbour asking for crops, paying more than the market does.
class FarmOrder {
  const FarmOrder({required this.items, required this.coins, required this.xp});

  factory FarmOrder.fromJson(Map<String, dynamic> json) => FarmOrder(
    items: Map<String, int>.from(json['items'] as Map),
    coins: json['coins'] as int,
    xp: json['xp'] as int,
  );

  /// Good ids and how many of each.
  final Map<String, int> items;
  final int coins;
  final int xp;

  Map<String, Object> toJson() => {'items': items, 'coins': coins, 'xp': xp};
}

/// Everything about the player's farm. Crops grow in real time: a field
/// planted before closing the game is ready when the player comes back.
class FarmState {
  FarmState({
    this.coins = startCoins,
    this.xp = 0,
    this.level = 1,
    List<Plot>? plots,
    Map<String, int>? barn,
    Set<String>? tools,
    List<FarmOrder>? orders,
    List<FarmAnimal>? animals,
    this.lastBonusDay,
    this.streak = 0,
    this.weekStart,
    this.weekScore = 0,
    int? weekLevel,
    this.trophies = 0,
    this.lastRank,
    List<double>? rivalScores,
    this.leagueUpdatedAt,
  }) : rivalScores = rivalScores ?? List.filled(FarmLeague.rivals.length, 0.0),
       plots = plots ?? [for (var i = 0; i < startPlots; i++) Plot()],
       barn = barn ?? {},
       tools = tools ?? {},
       orders = orders ?? [],
       animals = animals ?? [],
       weekLevel = weekLevel ?? level;

  factory FarmState.fromJson(Map<String, dynamic> json) => FarmState(
    coins: json['coins'] as int,
    xp: json['xp'] as int,
    level: json['level'] as int,
    plots: [
      for (final plot in json['plots'] as List)
        Plot.fromJson(plot as Map<String, dynamic>),
    ],
    barn: Map<String, int>.from(json['barn'] as Map),
    tools: {...(json['tools'] as List).cast<String>()},
    orders: [
      for (final order in json['orders'] as List)
        FarmOrder.fromJson(order as Map<String, dynamic>),
    ],
    animals: [
      for (final animal in json['animals'] as List? ?? const [])
        FarmAnimal.fromJson(animal as Map<String, dynamic>),
    ],
    lastBonusDay: json['bonusDay'] as String?,
    streak: json['streak'] as int? ?? 0,
    weekStart: json['weekStart'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['weekStart'] as int),
    weekScore: json['weekScore'] as int? ?? 0,
    weekLevel: json['weekLevel'] as int?,
    trophies: json['trophies'] as int? ?? 0,
    lastRank: json['lastRank'] as int?,
    rivalScores: json['rivals'] == null
        ? null
        : [
            for (final score in json['rivals'] as List)
              (score as num).toDouble(),
          ],
    leagueUpdatedAt: json['leagueUpdated'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['leagueUpdated'] as int),
  );

  static const startCoins = 20;
  static const startPlots = 4;
  static const maxPlots = 16;
  static const orderSlots = 3;
  static const maxAnimalsPerKind = 5;

  /// Chance that a harvest or an animal gives double.
  static const luckyChance = 0.1;

  /// Daily gift coins on each day of a seven-day streak, before the level
  /// bonus. The last day is worth coming back for.
  static const streakRewards = [20, 30, 40, 60, 80, 100, 250];

  int coins;
  int xp;
  int level;
  final List<Plot> plots;

  /// Harvested crops waiting to be sold or delivered, by crop id.
  final Map<String, int> barn;

  /// Ids of the tools bought.
  final Set<String> tools;
  final List<FarmOrder> orders;
  final List<FarmAnimal> animals;

  /// The day the daily bonus was last collected, as `yyyy-mm-dd`.
  String? lastBonusDay;

  /// Days in a row the daily bonus has been collected.
  int streak;

  /// When the current league week began, and the experience earned since.
  DateTime? weekStart;
  int weekScore;

  /// The level when the week began; it sets how fast neighbours play.
  int weekLevel;

  /// Weeks finished in the top three.
  int trophies;

  /// League rank when the player last looked, to tell who passed them.
  int? lastRank;

  /// The neighbours' league scores this week, in [FarmLeague.rivals] order,
  /// and when they were last brought up to date.
  final List<double> rivalScores;
  DateTime? leagueUpdatedAt;

  Iterable<FarmTool> _owned(ToolEffect effect) =>
      farmTools.where((t) => t.effect == effect && tools.contains(t.id));

  bool has(ToolEffect effect) => _owned(effect).isNotEmpty;

  /// Experience needed to go from this level to the next.
  int get xpToNextLevel => 5 * level * level + 5 * level;

  /// How long crops take compared with their [Crop.growTime].
  double get growthFactor =>
      _owned(ToolEffect.faster).fold(1.0, (f, tool) => f * (1 - tool.amount));

  int get harvestPerPlot =>
      2 +
      _owned(
        ToolEffect.biggerHarvest,
      ).fold(0, (sum, tool) => sum + tool.amount.round());

  int priceOf(FarmGood good) {
    final bonus = _owned(
      ToolEffect.betterPrices,
    ).fold(0.0, (sum, tool) => sum + tool.amount);
    return (good.price * (1 + bonus)).round();
  }

  /// Rolls for a lucky double. Without [random] luck never strikes.
  bool _lucky(Random? random) =>
      random != null && random.nextDouble() < luckyChance;

  Duration growTimeOf(Crop crop) => Duration(
    milliseconds: (crop.growTime.inMilliseconds * growthFactor).round(),
  );

  bool isUnlocked(Crop crop) => crop.level <= level;

  List<Crop> get unlockedCrops => crops.where(isUnlocked).toList();

  /// Price of the next field, or null once the farm is full.
  int? get nextPlotPrice {
    if (plots.length >= maxPlots) return null;
    final bought = plots.length - startPlots;
    return 25 * (bought + 1) * (bought + 2);
  }

  int readyCount(DateTime now) => plots.where((p) => p.isReady(now)).length;

  /// Sows [crop] in field [index]. Fails on a busy field, a locked crop or
  /// too few coins.
  bool plant(int index, Crop crop, DateTime now) {
    final plot = plots[index];
    if (!plot.isEmpty || !isUnlocked(crop) || coins < crop.seedCost) {
      return false;
    }
    coins -= crop.seedCost;
    plot
      ..cropId = crop.id
      ..plantedAt = now
      ..readyAt = now.add(growTimeOf(crop));
    return true;
  }

  /// Sows [crop] in every empty field there are coins for. Needs the
  /// tractor. Returns how many fields were planted.
  int plantAll(Crop crop, DateTime now) {
    if (!has(ToolEffect.plantAll)) return 0;
    var planted = 0;
    for (var i = 0; i < plots.length; i++) {
      if (plots[i].isEmpty && plant(i, crop, now)) planted++;
    }
    return planted;
  }

  /// Puts a ready field's crop in the barn. Returns how many were picked,
  /// or 0 if it isn't ready. With [random], a lucky harvest gives double.
  int harvest(int index, DateTime now, {Random? random}) {
    final plot = plots[index];
    final crop = plot.crop;
    if (crop == null || !plot.isReady(now)) return 0;
    final amount = harvestPerPlot * (_lucky(random) ? 2 : 1);
    _put(crop.id, amount);
    plot
      ..cropId = null
      ..plantedAt = null
      ..readyAt = null;
    addXp(crop.xp);
    return amount;
  }

  /// Harvests every ready field. Needs the harvester. Returns the crops
  /// picked, by id.
  Map<String, int> harvestAll(DateTime now, {Random? random}) {
    final picked = <String, int>{};
    if (!has(ToolEffect.harvestAll)) return picked;
    for (var i = 0; i < plots.length; i++) {
      final id = plots[i].cropId;
      final amount = harvest(i, now, random: random);
      if (amount > 0) picked[id!] = (picked[id] ?? 0) + amount;
    }
    return picked;
  }

  /// Adds experience, levelling up as often as it fills the bar. Every new
  /// level pays a reward.
  void addXp(int amount) {
    xp += amount;
    weekScore += amount;
    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level++;
      coins += levelReward(level);
    }
  }

  static int levelReward(int level) => 10 * level;

  /// Sells [count] of a crop from the barn at the market.
  bool sell(String cropId, int count) {
    final stock = barn[cropId] ?? 0;
    if (count <= 0 || stock < count) return false;
    coins += priceOf(goodById(cropId)) * count;
    _take(cropId, count);
    return true;
  }

  void _put(String id, int count) => barn[id] = (barn[id] ?? 0) + count;

  void _take(String cropId, int count) {
    final left = (barn[cropId] ?? 0) - count;
    if (left > 0) {
      barn[cropId] = left;
    } else {
      barn.remove(cropId);
    }
  }

  bool buyPlot() {
    final price = nextPlotPrice;
    if (price == null || coins < price) return false;
    coins -= price;
    plots.add(Plot());
    return true;
  }

  bool canBuy(FarmTool tool) =>
      !tools.contains(tool.id) && tool.level <= level && coins >= tool.price;

  bool buyTool(FarmTool tool) {
    if (!canBuy(tool)) return false;
    coins -= tool.price;
    tools.add(tool.id);
    return true;
  }

  bool isAnimalUnlocked(Animal kind) => kind.level <= level;

  List<FarmAnimal> animalsOf(Animal kind) =>
      animals.where((a) => a.kindId == kind.id).toList();

  /// Price of one more [kind], or null once the pen is full.
  int? animalPrice(Animal kind) {
    final owned = animalsOf(kind).length;
    if (owned >= maxAnimalsPerKind) return null;
    return kind.price * (owned + 1);
  }

  bool buyAnimal(Animal kind) {
    final price = animalPrice(kind);
    if (!isAnimalUnlocked(kind) || price == null || coins < price) {
      return false;
    }
    coins -= price;
    animals.add(FarmAnimal(kind.id));
    return true;
  }

  bool canFeed(FarmAnimal animal) =>
      animal.isHungry &&
      (barn[animal.kind.feedId] ?? 0) >= animal.kind.feedCount;

  /// Gives animal [index] its meal from the barn.
  bool feed(int index, DateTime now) {
    final animal = animals[index];
    if (!canFeed(animal)) return false;
    _take(animal.kind.feedId, animal.kind.feedCount);
    animal
      ..fedAt = now
      ..readyAt = now.add(animal.kind.time);
    return true;
  }

  /// Puts animal [index]'s product in the barn. Returns how many, or 0 if
  /// it isn't ready. With [random], a lucky animal gives double.
  int collect(int index, DateTime now, {Random? random}) {
    final animal = animals[index];
    if (!animal.isReady(now)) return 0;
    final amount = _lucky(random) ? 2 : 1;
    _put(animal.kind.product.id, amount);
    animal
      ..fedAt = null
      ..readyAt = null;
    addXp(animal.kind.xp * amount);
    return amount;
  }

  int animalsReady(DateTime now) => animals.where((a) => a.isReady(now)).length;

  /// Collects every ready product, then feeds every hungry animal the barn
  /// has food for. Needs the feeder. Returns the products collected, by id,
  /// and how many animals were fed.
  ({Map<String, int> collected, int fed}) tendAll(
    DateTime now, {
    Random? random,
  }) {
    final collected = <String, int>{};
    var fed = 0;
    if (!has(ToolEffect.tendAll)) return (collected: collected, fed: fed);
    for (var i = 0; i < animals.length; i++) {
      final id = animals[i].kind.product.id;
      final amount = collect(i, now, random: random);
      if (amount > 0) collected[id] = (collected[id] ?? 0) + amount;
      if (feed(i, now)) fed++;
    }
    return (collected: collected, fed: fed);
  }

  bool canDeliver(FarmOrder order) =>
      order.items.entries.every((e) => (barn[e.key] ?? 0) >= e.value);

  /// Hands over order [index] for its reward and takes a new one.
  bool deliver(int index, {Random? random}) {
    final order = orders[index];
    if (!canDeliver(order)) return false;
    order.items.forEach(_take);
    coins += order.coins;
    addXp(order.xp);
    orders[index] = newOrder(random: random);
    return true;
  }

  /// Turns down order [index] for a different one.
  void replaceOrder(int index, {Random? random}) {
    orders[index] = newOrder(random: random);
  }

  /// Fills the order board up to [orderSlots].
  void fillOrders({Random? random}) {
    while (orders.length < orderSlots) {
      orders.add(newOrder(random: random));
    }
  }

  /// An order for one to three of the newest unlocked crops and the
  /// products of animals the farm keeps, paying about half again what the
  /// market would.
  FarmOrder newOrder({Random? random}) {
    random ??= Random();
    final kept = {for (final animal in animals) animal.kind};
    final choices = <FarmGood>[
      ...unlockedCrops.reversed.take(4),
      for (final kind in kept) kind.product,
    ]..shuffle(random);
    final kinds = 1 + random.nextInt(min(3, choices.length));
    final items = <String, int>{};
    var value = 0;
    var xp = 2;
    for (final good in choices.take(kinds)) {
      final int count;
      final int goodXp;
      if (good is Crop) {
        count = 2 + random.nextInt(2 + level);
        goodXp = good.xp;
      } else {
        final kind = kept.firstWhere((k) => k.product == good);
        count = 1 + random.nextInt(2 + level ~/ 4);
        goodXp = kind.xp * 2;
      }
      items[good.id] = count;
      value += good.price * count;
      xp += (goodXp * count / 2).ceil();
    }
    return FarmOrder(items: items, coins: (value * 1.5).round() + 5, xp: xp);
  }

  static String _day(DateTime time) =>
      '${time.year}-${time.month.toString().padLeft(2, '0')}-'
      '${time.day.toString().padLeft(2, '0')}';

  /// Which day of the seven-day streak it is, from 1 to 7.
  int get streakDay => streak == 0 ? 1 : (streak - 1) % 7 + 1;

  static int dailyReward(int day, int level) =>
      streakRewards[day - 1] + 10 * level;

  /// Gives today's bonus if it hasn't been collected yet. Coming back the
  /// next day grows the streak and the gift; missing a day starts over.
  /// Returns the coins given, or null.
  int? claimDailyBonus(DateTime now) {
    final today = _day(now);
    if (lastBonusDay == today) return null;
    final yesterday = _day(DateTime(now.year, now.month, now.day - 1));
    streak = lastBonusDay == yesterday ? streak + 1 : 1;
    lastBonusDay = today;
    final bonus = dailyReward(streakDay, level);
    coins += bonus;
    return bonus;
  }

  /// Lets the neighbours play until [now] at a pace set by the player's
  /// own, then returns the league table, best first.
  List<LeagueEntry> standings(DateTime now) {
    final start = weekStart;
    if (start != null) {
      final end = FarmLeague.weekEndOf(start);
      final to = now.isAfter(end) ? end : now;
      final from = leagueUpdatedAt ?? start;
      if (to.isAfter(from)) {
        final hours = to.difference(start).inMinutes / 60;
        for (var i = 0; i < rivalScores.length; i++) {
          final rival = FarmLeague.rivals[i];
          final rate = FarmLeague.rate(
            rival,
            score: weekScore,
            hours: hours,
            level: weekLevel,
          );
          rivalScores[i] +=
              rate * FarmLeague.playTime(rival.name, start, from, to);
        }
        leagueUpdatedAt = to;
      }
    }
    return FarmLeague.table(rivalScores, weekScore);
  }

  int leagueRank(DateTime now) => FarmLeague.rankOf(standings(now));

  /// Starts the league week, or ends the last one when it is over and pays
  /// for the rank reached. Returns that rank and reward, or null if no week
  /// ended.
  ({int rank, int reward})? rollWeek(DateTime now) {
    final start = weekStart;
    if (start != null && now.isBefore(FarmLeague.weekEndOf(start))) {
      return null;
    }
    ({int rank, int reward})? result;
    if (start != null) {
      final rank = leagueRank(FarmLeague.weekEndOf(start));
      final reward = FarmLeague.reward(rank, weekLevel);
      coins += reward;
      if (rank <= 3) trophies++;
      result = (rank: rank, reward: reward);
    }
    weekStart = FarmLeague.weekStartOf(now);
    weekScore = 0;
    weekLevel = level;
    lastRank = null;
    rivalScores.fillRange(0, rivalScores.length, 0);
    leagueUpdatedAt = null;
    return result;
  }

  Map<String, Object?> toJson() => {
    'coins': coins,
    'xp': xp,
    'level': level,
    'plots': [for (final plot in plots) plot.toJson()],
    'barn': barn,
    'tools': tools.toList(),
    'orders': [for (final order in orders) order.toJson()],
    'animals': [for (final animal in animals) animal.toJson()],
    'bonusDay': lastBonusDay,
    'streak': streak,
    'weekStart': weekStart?.millisecondsSinceEpoch,
    'weekScore': weekScore,
    'weekLevel': weekLevel,
    'trophies': trophies,
    'lastRank': lastRank,
    'rivals': rivalScores,
    'leagueUpdated': leagueUpdatedAt?.millisecondsSinceEpoch,
  };
}

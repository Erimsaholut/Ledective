import 'dart:math';

import 'farm_catalog.dart';

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

/// A neighbour asking for crops, paying more than the market does.
class FarmOrder {
  const FarmOrder({required this.items, required this.coins, required this.xp});

  factory FarmOrder.fromJson(Map<String, dynamic> json) => FarmOrder(
    items: Map<String, int>.from(json['items'] as Map),
    coins: json['coins'] as int,
    xp: json['xp'] as int,
  );

  /// Crop ids and how many of each.
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
    this.lastBonusDay,
  }) : plots = plots ?? [for (var i = 0; i < startPlots; i++) Plot()],
       barn = barn ?? {},
       tools = tools ?? {},
       orders = orders ?? [];

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
    lastBonusDay: json['bonusDay'] as String?,
  );

  static const startCoins = 20;
  static const startPlots = 4;
  static const maxPlots = 16;
  static const orderSlots = 3;

  int coins;
  int xp;
  int level;
  final List<Plot> plots;

  /// Harvested crops waiting to be sold or delivered, by crop id.
  final Map<String, int> barn;

  /// Ids of the tools bought.
  final Set<String> tools;
  final List<FarmOrder> orders;

  /// The day the daily bonus was last collected, as `yyyy-mm-dd`.
  String? lastBonusDay;

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

  int priceOf(Crop crop) {
    final bonus = _owned(
      ToolEffect.betterPrices,
    ).fold(0.0, (sum, tool) => sum + tool.amount);
    return (crop.price * (1 + bonus)).round();
  }

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
  /// or 0 if it isn't ready.
  int harvest(int index, DateTime now) {
    final plot = plots[index];
    final crop = plot.crop;
    if (crop == null || !plot.isReady(now)) return 0;
    final amount = harvestPerPlot;
    barn[crop.id] = (barn[crop.id] ?? 0) + amount;
    plot
      ..cropId = null
      ..plantedAt = null
      ..readyAt = null;
    addXp(crop.xp);
    return amount;
  }

  /// Harvests every ready field. Needs the harvester. Returns the crops
  /// picked, by id.
  Map<String, int> harvestAll(DateTime now) {
    final picked = <String, int>{};
    if (!has(ToolEffect.harvestAll)) return picked;
    for (var i = 0; i < plots.length; i++) {
      final id = plots[i].cropId;
      final amount = harvest(i, now);
      if (amount > 0) picked[id!] = (picked[id] ?? 0) + amount;
    }
    return picked;
  }

  /// Adds experience, levelling up as often as it fills the bar. Every new
  /// level pays a reward.
  void addXp(int amount) {
    xp += amount;
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
    coins += priceOf(cropById(cropId)) * count;
    _take(cropId, count);
    return true;
  }

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

  /// An order for one to three of the newest unlocked crops, paying about
  /// half again what the market would.
  FarmOrder newOrder({Random? random}) {
    random ??= Random();
    final choices = unlockedCrops.reversed.take(4).toList()..shuffle(random);
    final kinds = 1 + random.nextInt(min(3, choices.length));
    final items = <String, int>{};
    var value = 0;
    var xp = 2;
    for (final crop in choices.take(kinds)) {
      final count = 2 + random.nextInt(2 + level);
      items[crop.id] = count;
      value += crop.price * count;
      xp += (crop.xp * count / 2).ceil();
    }
    return FarmOrder(items: items, coins: (value * 1.5).round() + 5, xp: xp);
  }

  /// Gives today's bonus if it hasn't been collected yet. Returns the
  /// coins given, or null.
  int? claimDailyBonus(DateTime now) {
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    if (lastBonusDay == today) return null;
    lastBonusDay = today;
    final bonus = 20 + 10 * level;
    coins += bonus;
    return bonus;
  }

  Map<String, Object?> toJson() => {
    'coins': coins,
    'xp': xp,
    'level': level,
    'plots': [for (final plot in plots) plot.toJson()],
    'barn': barn,
    'tools': tools.toList(),
    'orders': [for (final order in orders) order.toJson()],
    'bonusDay': lastBonusDay,
  };
}

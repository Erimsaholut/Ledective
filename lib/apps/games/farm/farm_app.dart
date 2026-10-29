import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/app_theme.dart';
import 'farm_catalog.dart';
import 'farm_league.dart';
import 'farm_state.dart';

/// Bereket Çiftliği from AppShop: grow crops in real time, sell them or
/// fill orders, and spend the coins on more fields and better tools.
class FarmApp extends StatefulWidget {
  const FarmApp({super.key, this.clock, this.random});

  /// Where the farm is saved.
  static const saveKey = 'farm.state';

  /// The current time; tests pass a fake one to make crops grow.
  final DateTime Function()? clock;
  final Random? random;

  @override
  State<FarmApp> createState() => _FarmAppState();
}

class _FarmAppState extends State<FarmApp> {
  static const _green = Color(0xFF2E7D32);
  static const _soil = Color(0xFF8D5A3B);

  FarmState? _farm;
  int _tab = 0;
  Timer? _timer;

  /// League rank the last action climbed to, told with its toast.
  int? _climbedTo;

  late final Random _random = widget.random ?? Random();

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _load();
    // Growing crops tick on screen, and neighbours keep playing.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      _watchLeague();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _save();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(FarmApp.saveKey);
    FarmState? farm;
    if (stored != null) {
      try {
        farm = FarmState.fromJson(json.decode(stored) as Map<String, dynamic>);
      } on Object {
        // A save from an older version; start a new farm.
      }
    }
    farm ??= FarmState();
    final now = _now;
    final week = farm.rollWeek(now);
    farm.fillOrders(random: widget.random);
    final bonus = farm.claimDailyBonus(now);
    // Neighbours keep playing while the farm is closed.
    final table = farm.standings(now);
    final rank = FarmLeague.rankOf(table);
    final passedBy = farm.lastRank != null && rank > farm.lastRank!
        ? table[rank - 2].name
        : null;
    farm.lastRank = rank;
    if (!mounted) return;
    setState(() => _farm = farm);
    await _save();
    if (week != null) await _showWeekResult(week.rank, week.reward);
    if (bonus != null && mounted) await _showDailyGift(farm, bonus);
    if (passedBy != null) {
      _toast("👀 $passedBy seni geçti! Ligde $rank. sıradasın.");
    }
  }

  /// Tells the player when a neighbour passes them in the league.
  void _watchLeague() {
    final farm = _farm;
    if (farm == null || farm.weekStart == null) return;
    final table = farm.standings(_now);
    final rank = FarmLeague.rankOf(table);
    final last = farm.lastRank;
    farm.lastRank = rank;
    if (last != null && rank > last) {
      _toast("👀 ${table[rank - 2].name} seni geçti! Ligde $rank. sıradasın.");
    }
  }

  Future<void> _save() async {
    final farm = _farm;
    if (farm == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(FarmApp.saveKey, json.encode(farm.toJson()));
  }

  /// Runs [action] on the farm, saves, shows [toast] and celebrates any
  /// new level or league rank.
  void _act(void Function(FarmState farm) action, {String Function()? toast}) {
    final farm = _farm!;
    final now = _now;
    final week = farm.rollWeek(now);
    final before = farm.level;
    final rankBefore = farm.leagueRank(now);
    setState(() => action(farm));
    final rank = farm.leagueRank(now);
    if (rank < rankBefore) _climbedTo = rank;
    farm.lastRank = rank;
    _save();
    final message = toast?.call();
    if (message != null || _climbedTo != null) _toast(message);
    if (week != null) _showWeekResult(week.rank, week.reward);
    if (farm.level > before) _showLevelUp(before + 1, farm.level);
  }

  void _toast(String? message) {
    if (!mounted) return;
    final lines = [
      ?message,
      if (_climbedTo != null) "🏆 Ligde $_climbedTo. sıraya yükseldin!",
    ];
    _climbedTo = null;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(lines.join("\n")),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }

  void _showLevelUp(int from, int to) {
    final reward = [
      for (var l = from; l <= to; l++) FarmState.levelReward(l),
    ].reduce((a, b) => a + b);
    bool isNew(int level) => level >= from && level <= to;
    final unlocks = [
      for (final crop in crops.where((c) => isNew(c.level)))
        "Yeni ürün: ${crop.emoji} ${crop.name}",
      for (final kind in animals.where((a) => isNew(a.level)))
        "Yeni hayvan: ${kind.emoji} ${kind.name}",
      for (final tool in farmTools.where((t) => isNew(t.level)))
        "Dükkânda yeni: ${tool.emoji} ${tool.name}",
    ];
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Text('🎉', style: TextStyle(fontSize: 48)),
        title: Text("Seviye $to!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ödül: +$reward 🪙", style: const TextStyle(fontSize: 16)),
            for (final unlock in unlocks)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(unlock),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: _green),
            child: const Text("Harika!"),
          ),
        ],
      ),
    );
  }

  /// The daily gift, with the streak so far and what tomorrow brings.
  Future<void> _showDailyGift(FarmState farm, int bonus) {
    final day = farm.streakDay;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Text('🎁', style: TextStyle(fontSize: 48)),
        title: const Text("Günlük hediye"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "+$bonus 🪙",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (var d = 1; d <= 7; d++)
                  _StreakDay(day: d, reached: d <= day),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              day < 7
                  ? "Seri: $day gün. Yarın gel, "
                        "+${FarmState.dailyReward(day + 1, farm.level)} 🪙 "
                        "seni bekliyor. Bir gün kaçırırsan seri sıfırlanır!"
                  : "7 günü tamamladın! Yarın seri baştan başlıyor.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryLabel),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: _green),
            child: const Text("Topla"),
          ),
        ],
      ),
    );
  }

  Future<void> _showWeekResult(int rank, int reward) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Text(
          rank <= 3 ? '🏆' : '🌾',
          style: const TextStyle(fontSize: 48),
        ),
        title: const Text("Hafta bitti"),
        content: Text(
          "Köy Liginde $rank. oldun.\nÖdül: +$reward 🪙"
          "${rank <= 3 ? "\nKupa dolabına bir kupa eklendi!" : ""}",
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: _green),
            child: const Text("Yeni hafta"),
          ),
        ],
      ),
    );
  }

  void _showLeague() {
    final farm = _farm!;
    final now = _now;
    final table = farm.standings(now);
    final rank = FarmLeague.rankOf(table);
    setState(() => farm.lastRank = rank);
    _save();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _LeagueSheet(
        table: table,
        rank: rank,
        timeLeft: FarmLeague.weekEndOf(farm.weekStart!).difference(now),
        trophies: farm.trophies,
        level: farm.weekLevel,
      ),
    );
  }

  Future<Crop?> _chooseCrop({required String title}) {
    final farm = _farm!;
    return showModalBottomSheet<Crop>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final crop in crops) _cropOption(context, farm, crop),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _cropOption(BuildContext context, FarmState farm, Crop crop) {
    final unlocked = farm.isUnlocked(crop);
    final affordable = farm.coins >= crop.seedCost;
    final seed = crop.seedCost == 0 ? "bedava" : "${crop.seedCost} 🪙";
    return ListTile(
      key: ValueKey('crop-${crop.id}'),
      tileColor: Colors.transparent,
      enabled: unlocked && affordable,
      leading: Text(
        unlocked ? crop.emoji : '🔒',
        style: const TextStyle(fontSize: 30),
      ),
      title: Text(crop.name),
      subtitle: Text(
        unlocked
            ? "${formatGrowTime(farm.growTimeOf(crop))} · tohum $seed · "
                  "tanesi ${farm.priceOf(crop)} 🪙"
            : "Seviye ${crop.level}'te açılır",
      ),
      onTap: () => Navigator.pop(context, crop),
    );
  }

  Future<void> _tapPlot(int index) async {
    final farm = _farm!;
    final plot = farm.plots[index];
    final now = _now;
    final crop = plot.crop;
    if (crop == null) {
      final choice = await _chooseCrop(title: "Ne ekelim?");
      if (choice != null) _act((f) => f.plant(index, choice, _now));
    } else if (plot.isReady(now)) {
      final usual = farm.harvestPerPlot;
      var amount = 0;
      _act(
        (f) => amount = f.harvest(index, now, random: _random),
        toast: () =>
            "${amount > usual ? "🍀 Bereketli hasat! " : ""}"
            "+$amount ${crop.emoji} ${crop.name} · +${crop.xp} XP",
      );
    } else {
      _toast(
        "${crop.emoji} ${crop.name}: "
        "${formatGrowTime(plot.readyAt!.difference(now))} sonra hazır",
      );
    }
  }

  Future<void> _plantAll() async {
    final crop = await _chooseCrop(title: "Boş tarlaların hepsine ek");
    if (crop == null) return;
    var planted = 0;
    _act(
      (f) => planted = f.plantAll(crop, _now),
      toast: () => "🚜 $planted tarlaya ${crop.name} ekildi",
    );
  }

  void _harvestAll() {
    var picked = <String, int>{};
    _act(
      (f) => picked = f.harvestAll(_now, random: _random),
      toast: () =>
          "⚙️ ${[for (final e in picked.entries) "+${e.value} ${goodById(e.key).emoji}"].join("  ")}",
    );
  }

  void _tapAnimal(int index) {
    final farm = _farm!;
    final animal = farm.animals[index];
    final kind = animal.kind;
    final product = kind.product;
    final now = _now;
    if (animal.isReady(now)) {
      var amount = 0;
      _act(
        (f) => amount = f.collect(index, now, random: _random),
        toast: () =>
            "${amount > 1 ? "🍀 Çifte ürün! " : ""}"
            "+$amount ${product.emoji} ${product.name} · "
            "+${kind.xp * amount} XP",
      );
    } else if (!animal.isHungry) {
      _toast(
        "${product.emoji} ${product.name}: "
        "${formatGrowTime(animal.readyAt!.difference(now))} sonra hazır",
      );
    } else if (farm.canFeed(animal)) {
      _act(
        (f) => f.feed(index, now),
        toast: () =>
            "${kind.emoji} ${kind.name} karnını doyurdu · "
            "${formatGrowTime(kind.time)} sonra ${product.emoji}",
      );
    } else {
      _toast(
        "${kind.name} için ambarda ${kind.feedCount} ${kind.feed.emoji} "
        "${kind.feed.name} olmalı",
      );
    }
  }

  void _tendAll() {
    var result = (collected: <String, int>{}, fed: 0);
    _act(
      (f) => result = f.tendAll(_now, random: _random),
      toast: () =>
          "🥣 ${[for (final e in result.collected.entries) "+${e.value} ${goodById(e.key).emoji}", if (result.fed > 0) "${result.fed} hayvan beslendi"].join("  ")}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = _farm;
    final now = _now;
    final deliverable =
        farm?.orders.where((o) => farm.canDeliver(o)).length ?? 0;
    final readyPlots = farm?.readyCount(now) ?? 0;
    final readyAnimals = farm?.animalsReady(now) ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5D6),
      appBar: AppBar(
        title: const Text("Bereket Çiftliği"),
        backgroundColor: const Color(0xFFE8F5D6),
        actions: [
          if (farm != null)
            _LeagueButton(rank: farm.leagueRank(now), onTap: _showLeague),
          const SizedBox(width: 10),
        ],
      ),
      body: farm == null
          ? const SizedBox()
          : Column(
              children: [
                _Header(farm: farm),
                Expanded(
                  child: switch (_tab) {
                    0 => _buildField(farm),
                    1 => _buildAnimals(farm),
                    2 => _buildBarn(farm),
                    3 => _buildOrders(farm),
                    _ => _buildShop(farm),
                  },
                ),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (tab) => setState(() => _tab = tab),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFC8E6A0),
        destinations: [
          NavigationDestination(
            icon: _CountBadge(
              count: readyPlots,
              child: const Icon(Icons.grass_rounded),
            ),
            label: "Tarla",
          ),
          NavigationDestination(
            icon: _CountBadge(
              count: readyAnimals,
              child: const Icon(Icons.pets_rounded),
            ),
            label: "Hayvanlar",
          ),
          const NavigationDestination(
            icon: Icon(Icons.warehouse_rounded),
            label: "Ambar",
          ),
          NavigationDestination(
            icon: _CountBadge(
              count: deliverable,
              child: const Icon(Icons.receipt_long_rounded),
            ),
            label: "Siparişler",
          ),
          const NavigationDestination(
            icon: Icon(Icons.storefront_rounded),
            label: "Dükkân",
          ),
        ],
      ),
    );
  }

  Widget _buildField(FarmState farm) {
    final now = _now;
    final empty = farm.plots.where((p) => p.isEmpty).length;
    final ready = farm.readyCount(now);
    final plotPrice = farm.nextPlotPrice;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
      children: [
        if (farm.has(ToolEffect.plantAll) || farm.has(ToolEffect.harvestAll))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                if (farm.has(ToolEffect.plantAll))
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: empty == 0 ? null : _plantAll,
                      child: const Text("🚜 Hepsine ek"),
                    ),
                  ),
                if (farm.has(ToolEffect.plantAll) &&
                    farm.has(ToolEffect.harvestAll))
                  const SizedBox(width: 10),
                if (farm.has(ToolEffect.harvestAll))
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: ready == 0 ? null : _harvestAll,
                      child: Text("⚙️ Hepsini topla ($ready)"),
                    ),
                  ),
              ],
            ),
          ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (var i = 0; i < farm.plots.length; i++)
              _PlotTile(
                key: ValueKey('plot-$i'),
                plot: farm.plots[i],
                now: now,
                onTap: () => _tapPlot(i),
              ),
            if (plotPrice != null)
              _LockedPlotTile(
                price: plotPrice,
                affordable: farm.coins >= plotPrice,
                onTap: () => _act((f) => f.buyPlot()),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Boş tarlaya dokunup tohum ek, olgunlaşan ürüne dokunup topla. "
          "Ürünler oyun kapalıyken de büyür.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryLabel, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildAnimals(FarmState farm) {
    final now = _now;
    final busy =
        farm.animalsReady(now) + farm.animals.where(farm.canFeed).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
      children: [
        if (farm.has(ToolEffect.tendAll))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FilledButton.tonal(
              onPressed: busy == 0 ? null : _tendAll,
              child: const Text("🥣 Hepsini topla ve besle"),
            ),
          ),
        for (final kind in animals)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AnimalPen(
              kind: kind,
              farm: farm,
              now: now,
              onTapAnimal: _tapAnimal,
              onBuy: () => _act(
                (f) => f.buyAnimal(kind),
                toast: () => "${kind.emoji} Yeni bir ${kind.name} aldın!",
              ),
            ),
          ),
        const Text(
          "Aç hayvana dokunup ambardaki ürünlerle besle, ürününü verince "
          "dokunup topla. Hayvan ürünleri pazarda ve siparişlerde para eder.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryLabel, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBarn(FarmState farm) {
    final stock = [
      for (final good in farmGoods)
        if ((farm.barn[good.id] ?? 0) > 0) good,
    ];
    if (stock.isEmpty) {
      return const _EmptyState(
        emoji: '🏚️',
        message: "Ambar boş. Tarlada ürün yetiştirip topla.",
      );
    }
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        for (final good in stock)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(good.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${good.name} × ${farm.barn[good.id]}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Tanesi ${farm.priceOf(good)} 🪙",
                            style: const TextStyle(
                              color: AppColors.secondaryLabel,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 6,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    _act((f) => f.sell(good.id, 1)),
                                child: const Text("1 sat"),
                              ),
                              FilledButton(
                                onPressed: () {
                                  final count = farm.barn[good.id]!;
                                  final total = farm.priceOf(good) * count;
                                  _act(
                                    (f) => f.sell(good.id, count),
                                    toast: () => "+$total 🪙",
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: _green,
                                ),
                                child: const Text("Hepsini sat"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrders(FarmState farm) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Komşuların ürün bekliyor. Siparişler pazardan çok daha iyi "
            "kazandırır.",
            style: TextStyle(color: AppColors.secondaryLabel),
          ),
        ),
        for (var i = 0; i < farm.orders.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrderCard(
              order: farm.orders[i],
              farm: farm,
              onDeliver: () {
                final order = farm.orders[i];
                _act(
                  (f) => f.deliver(i, random: widget.random),
                  toast: () =>
                      "Teslim edildi: +${order.coins} 🪙 · +${order.xp} XP",
                );
              },
              onReplace: () =>
                  _act((f) => f.replaceOrder(i, random: widget.random)),
            ),
          ),
      ],
    );
  }

  Widget _buildShop(FarmState farm) {
    final plotPrice = farm.nextPlotPrice;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.add_box_rounded, size: 34, color: _soil),
            title: const Text("Yeni tarla"),
            subtitle: Text(
              plotPrice == null
                  ? "Çiftliğin tamamen dolu"
                  : "${farm.plots.length} / ${FarmState.maxPlots} tarla",
            ),
            trailing: plotPrice == null
                ? null
                : FilledButton(
                    onPressed: farm.coins >= plotPrice
                        ? () => _act((f) => f.buyPlot())
                        : null,
                    style: FilledButton.styleFrom(backgroundColor: _green),
                    child: Text("$plotPrice 🪙"),
                  ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Text(
            "Tarım aletleri",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        for (final tool in farmTools)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ToolCard(
              tool: tool,
              farm: farm,
              onBuy: () => _act(
                (f) => f.buyTool(tool),
                toast: () => "${tool.emoji} ${tool.name} artık senin!",
              ),
            ),
          ),
      ],
    );
  }
}

/// "4:05", or "1:02:05" for crops that take hours.
String formatGrowTime(Duration time) {
  final seconds = max(0, (time.inMilliseconds / 1000).ceil());
  final h = seconds ~/ 3600;
  final m = seconds % 3600 ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

/// Coins, level, and the experience bar with what the next level brings.
class _Header extends StatelessWidget {
  const _Header({required this.farm});

  final FarmState farm;

  /// Emoji of everything the next level with something new unlocks.
  String? get _nextUnlock {
    final upcoming = [
      for (final crop in crops) (crop.level, crop.emoji),
      for (final kind in animals) (kind.level, kind.emoji),
      for (final tool in farmTools) (tool.level, tool.emoji),
    ].where((u) => u.$1 > farm.level).toList();
    if (upcoming.isEmpty) return null;
    final level = upcoming.map((u) => u.$1).reduce(min);
    final emoji = [
      for (final u in upcoming)
        if (u.$1 == level) u.$2,
    ];
    return "Sv. $level: ${emoji.join(" ")}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "🪙 ${farm.coins}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 14),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFFC94A),
            child: Text(
              '${farm.level}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B4400),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seviye ${farm.level}",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: farm.xp / farm.xpToNextLevel,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    color: const Color(0xFFFFB300),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "${farm.xp} / ${farm.xpToNextLevel} XP",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_nextUnlock case final next?)
                      Expanded(
                        child: Text(
                          next,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The player's league rank; opens the league table.
class _LeagueButton extends StatelessWidget {
  const _LeagueButton({required this.rank, required this.onTap});

  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const ValueKey('league'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            "🏆 $rank.",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

/// A count on a navigation icon when something waits there.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Badge(isLabelVisible: count > 0, label: Text('$count'), child: child);
}

/// One day of the daily gift streak.
class _StreakDay extends StatelessWidget {
  const _StreakDay({required this.day, required this.reached});

  final int day;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: reached ? const Color(0xFFFFC94A) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(8),
        border: day == 7
            ? Border.all(color: const Color(0xFFFF9500), width: 2)
            : null,
      ),
      child: Text(
        day == 7 ? '🎁' : '$day',
        style: TextStyle(
          fontSize: day == 7 ? 18 : 14,
          fontWeight: FontWeight.w800,
          color: reached ? const Color(0xFF6B4400) : AppColors.grey,
        ),
      ),
    );
  }
}

/// The weekly village league table.
class _LeagueSheet extends StatelessWidget {
  const _LeagueSheet({
    required this.table,
    required this.rank,
    required this.timeLeft,
    required this.trophies,
    required this.level,
  });

  final List<LeagueEntry> table;
  final int rank;
  final Duration timeLeft;
  final int trophies;
  final int level;

  String get _left {
    final days = timeLeft.inDays;
    final hours = timeLeft.inHours % 24;
    if (days > 0) return "$days gün $hours saat";
    return "$hours saat ${timeLeft.inMinutes % 60} dk";
  }

  /// How far the player is from the next place, or from the one behind.
  String get _gap {
    final me = table[rank - 1];
    if (rank == 1) {
      final next = table[1];
      return "Zirvedesin! ${next.name} ${me.score - next.score} puan "
          "arkanda.";
    }
    final ahead = table[rank - 2];
    return "${ahead.name} seni ${ahead.score - me.score + 1} puanla "
        "geçiyor.";
  }

  @override
  Widget build(BuildContext context) {
    const medals = ['🥇', '🥈', '🥉'];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Köy Ligi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            "Haftanın bitmesine $_left · Kupaların: $trophies 🏆",
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondaryLabel),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
            child: Text(
              _gap,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (var i = 0; i < table.length; i++)
                  ListTile(
                    dense: true,
                    tileColor: table[i].isPlayer
                        ? const Color(0xFFE8F5D6)
                        : Colors.transparent,
                    leading: SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          i < 3 ? medals[i] : '${i + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      table[i].name,
                      style: TextStyle(
                        fontWeight: table[i].isPlayer
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      "${table[i].score} puan",
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            // Clear of the phone's home bar.
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Text(
              "Kazandığın her XP lig puanıdır. Hafta sonunda birinciye "
              "+${FarmLeague.reward(1, level)} 🪙 ve kupa, ilk üçe kupa.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryLabel,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A pen of one kind of animal, with the next one for sale.
class _AnimalPen extends StatelessWidget {
  const _AnimalPen({
    required this.kind,
    required this.farm,
    required this.now,
    required this.onTapAnimal,
    required this.onBuy,
  });

  final Animal kind;
  final FarmState farm;
  final DateTime now;
  final void Function(int index) onTapAnimal;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final unlocked = farm.isAnimalUnlocked(kind);
    final owned = farm.animalsOf(kind);
    final price = farm.animalPrice(kind);
    final product = kind.product;
    return Card(
      child: Opacity(
        opacity: unlocked ? 1 : 0.55,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${unlocked ? kind.emoji : '🔒'} ${kind.home} · "
                "${owned.length}/${FarmState.maxAnimalsPerKind}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                unlocked
                    ? "${kind.feedCount} ${kind.feed.emoji} yer, "
                          "${formatGrowTime(kind.time)} sonra "
                          "${product.emoji} ${product.name} verir · "
                          "tanesi ${farm.priceOf(product)} 🪙"
                    : "Seviye ${kind.level}'te açılır: "
                          "${kind.name}, ${product.emoji} ${product.name} verir",
                style: const TextStyle(
                  color: AppColors.secondaryLabel,
                  fontSize: 13,
                ),
              ),
              if (unlocked) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final animal in owned)
                      _AnimalTile(
                        key: ValueKey('animal-${farm.animals.indexOf(animal)}'),
                        animal: animal,
                        canFeed: farm.canFeed(animal),
                        now: now,
                        onTap: () => onTapAnimal(farm.animals.indexOf(animal)),
                      ),
                    if (price != null)
                      _BuyAnimalTile(
                        key: ValueKey('buy-${kind.id}'),
                        price: price,
                        affordable: farm.coins >= price,
                        onTap: onBuy,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// An animal: hungry with what it eats, busy with time left, or with its
/// product waiting.
class _AnimalTile extends StatelessWidget {
  const _AnimalTile({
    super.key,
    required this.animal,
    required this.canFeed,
    required this.now,
    required this.onTap,
  });

  final FarmAnimal animal;
  final bool canFeed;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kind = animal.kind;
    final ready = animal.isReady(now);
    final hungry = animal.isHungry;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFFF4EBD0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ready ? const Color(0xFFFFD54F) : const Color(0xFFD7C7A0),
            width: ready ? 3 : 2,
          ),
          boxShadow: ready
              ? const [BoxShadow(color: Color(0x88FFD54F), blurRadius: 10)]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              ready ? kind.product.emoji : kind.emoji,
              style: TextStyle(fontSize: ready ? 34 : 30),
            ),
            if (hungry)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: canFeed ? Colors.white : const Color(0xFFFFE0DE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kind.feed.emoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            if (!hungry && !ready)
              Positioned(
                left: 5,
                right: 5,
                bottom: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: animal.progress(now),
                    minHeight: 4,
                    backgroundColor: Colors.black12,
                    color: _FarmAppState._green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BuyAnimalTile extends StatelessWidget {
  const _BuyAnimalTile({
    super.key,
    required this.price,
    required this.affordable,
    required this.onTap,
  });

  final int price;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: affordable ? onTap : null,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x66795548), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Color(0xFF795548)),
            Text(
              "$price 🪙",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: affordable ? _FarmAppState._green : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A field: bare soil, a growing crop with its time left, or a ripe crop
/// waiting to be picked.
class _PlotTile extends StatelessWidget {
  const _PlotTile({
    super.key,
    required this.plot,
    required this.now,
    required this.onTap,
  });

  final Plot plot;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final crop = plot.crop;
    final ready = plot.isReady(now);
    final progress = plot.progress(now);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _FarmAppState._soil,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ready ? const Color(0xFFFFD54F) : const Color(0xFF6D4429),
            width: ready ? 3 : 2,
          ),
          boxShadow: ready
              ? const [BoxShadow(color: Color(0x88FFD54F), blurRadius: 10)]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Furrows in the soil.
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: const Color(0x33000000),
                  ),
              ],
            ),
            if (crop == null)
              const Icon(Icons.add_rounded, color: Colors.white54, size: 28)
            else if (ready)
              Text(crop.emoji, style: const TextStyle(fontSize: 40))
            else
              Text(
                progress < 0.5 ? '🌱' : crop.emoji,
                style: TextStyle(fontSize: progress < 0.5 ? 24 : 30),
              ),
            if (crop != null && !ready)
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Column(
                  children: [
                    Text(
                      formatGrowTime(plot.readyAt!.difference(now)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: Colors.black26,
                        color: const Color(0xFF9CCC65),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The next field for sale.
class _LockedPlotTile extends StatelessWidget {
  const _LockedPlotTile({
    required this.price,
    required this.affordable,
    required this.onTap,
  });

  final int price;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: affordable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x228D5A3B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x668D5A3B), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(
              "$price 🪙",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: affordable ? _FarmAppState._green : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.farm,
    required this.onDeliver,
    required this.onReplace,
  });

  final FarmOrder order;
  final FarmState farm;
  final VoidCallback onDeliver;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final item in order.items.entries)
                  _OrderItem(
                    good: goodById(item.key),
                    have: farm.barn[item.key] ?? 0,
                    need: item.value,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Ödül: ${order.coins} 🪙 · ${order.xp} XP",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: onReplace,
                  tooltip: "Başka sipariş",
                  icon: const Icon(Icons.refresh_rounded),
                ),
                FilledButton(
                  onPressed: farm.canDeliver(order) ? onDeliver : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _FarmAppState._green,
                  ),
                  child: const Text("Teslim et"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  const _OrderItem({
    required this.good,
    required this.have,
    required this.need,
  });

  final FarmGood good;
  final int have;
  final int need;

  @override
  Widget build(BuildContext context) {
    final enough = have >= need;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(good.emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 4),
        Text(
          "${min(have, need)}/$need",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: enough ? _FarmAppState._green : AppColors.red,
          ),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.tool,
    required this.farm,
    required this.onBuy,
  });

  final FarmTool tool;
  final FarmState farm;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final owned = farm.tools.contains(tool.id);
    final locked = tool.level > farm.level;
    final Widget trailing;
    if (owned) {
      trailing = const Text(
        "Sende ✓",
        style: TextStyle(
          color: _FarmAppState._green,
          fontWeight: FontWeight.w700,
        ),
      );
    } else if (locked) {
      trailing = Text(
        "Seviye ${tool.level}",
        style: const TextStyle(color: AppColors.secondaryLabel),
      );
    } else {
      trailing = FilledButton(
        onPressed: farm.canBuy(tool) ? onBuy : null,
        style: FilledButton.styleFrom(backgroundColor: _FarmAppState._green),
        child: Text("${tool.price} 🪙"),
      );
    }
    return Card(
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: ListTile(
          leading: Text(
            locked ? '🔒' : tool.emoji,
            style: const TextStyle(fontSize: 30),
          ),
          title: Text(
            tool.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(tool.description),
          trailing: trailing,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.emoji, required this.message});

  final String emoji;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

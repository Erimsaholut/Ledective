import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/bank_account.dart';
import '../../../story/story_progress.dart';
import '../../../theme/app_theme.dart';
import '../../shopper/shopper_app.dart' show formatLira;
import 'farm_catalog.dart';
import 'farm_cosmetics.dart';
import 'farm_league.dart';
import 'farm_profile.dart';
import 'farm_reminder.dart';
import 'farm_state.dart';

/// Bereket Çiftliği from AppShop: grow crops in real time, sell them or
/// fill orders, and spend the coins on more fields and better tools.
class FarmApp extends StatefulWidget {
  const FarmApp({super.key, this.clock, this.random, this.pay});

  /// Where the farm is saved.
  static const saveKey = 'farm.state';

  /// The current time; tests pass a fake one to make crops grow.
  final DateTime Function()? clock;
  final Random? random;

  /// Takes [kurus] from the player's ZaferBank account for [detail];
  /// false if the balance is too low. Tests pass a fake bank.
  final Future<bool> Function(int kurus, String detail)? pay;

  @override
  State<FarmApp> createState() => _FarmAppState();
}

class _FarmAppState extends State<FarmApp> {
  static const _green = Color(0xFF2E7D32);
  static const _soil = Color(0xFF8D5A3B);

  FarmState? _farm;
  int _tab = 0;

  /// Whether the shop shows cosmetics rather than tools.
  bool _cosmeticShop = false;
  Timer? _timer;

  /// League rank the last action climbed to, told with its toast.
  int? _climbedTo;

  late final Random _random = widget.random ?? Random();

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    FarmReminder.farmOpen = true;
    StoryProgress.instance.alerts.clearApp(FarmReminder.app);
    _load();
    // Growing crops tick on screen, and neighbours keep playing.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      _watchLeague();
      _watchOrders();
      _watchOffer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    FarmReminder.farmOpen = false;
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
    farm.fillOrders(now, random: widget.random);
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
    if (week != null) await _showWeekResult(week);
    if (bonus != null && mounted) await _showDailyGift(farm, bonus);
    if (passedBy != null) {
      _toast("👀 $passedBy seni geçti! Ligde $rank. sıradasın.");
    }
    _watchOffer();
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

  /// Puts new orders on the board once the slots of turned-down ones are
  /// free again.
  void _watchOrders() {
    final farm = _farm;
    if (farm == null) return;
    if (farm.fillOrders(_now, random: widget.random) > 0) {
      _save();
      _toast("📋 Sipariş panosuna yeni sipariş geldi!");
    }
  }

  /// Now and then puts the ZaferBank chest on offer.
  void _watchOffer() {
    final farm = _farm;
    if (farm == null || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    if (farm.rollOffer(_now, random: _random)) {
      _save();
      _showOffer();
    }
  }

  Future<void> _showOffer() async {
    final farm = _farm!;
    final buy = await showDialog<bool>(
      context: context,
      builder: (context) => _OfferDialog(farm: farm, now: _now),
    );
    if (buy != true || !mounted) return;
    final pay =
        widget.pay ??
        (kurus, detail) =>
            BankAccount.instance.pay("Bereket Çiftliği", detail, kurus);
    final paid = await pay(
      FarmState.offerPrice,
      "Oyun içi satın alma · Bereket Sandığı",
    );
    if (!mounted) return;
    if (!paid) {
      _toast("ZaferBank: Yetersiz bakiye. Ödeme reddedildi.");
      return;
    }
    final coins = farm.offerCoins;
    _act(
      (f) => f.claimOffer(_now),
      toast: () =>
          "🎁 Bereket Sandığı açıldı! Her üründen ${FarmState.offerItems} "
          "tane ve +$coins 🪙 ambarında.",
    );
  }

  Future<void> _save() async {
    final farm = _farm;
    if (farm == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(FarmApp.saveKey, json.encode(farm.toJson()));
    await FarmReminder.schedule(farm, _now);
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
    if (week != null) _showWeekResult(week);
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

  Future<void> _showWeekResult(WeekResult week) {
    final up = week.to.index > week.from.index;
    final down = week.to.index < week.from.index;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Text(
          up
              ? '🚀'
              : week.rank <= 3
              ? '🏆'
              : '🌾',
          style: const TextStyle(fontSize: 48),
        ),
        title: const Text("Hafta bitti"),
        content: Text(
          "${week.from.title} Liginde ${week.rank}. oldun.\n"
          "Ödül: +${week.reward} 🪙"
          "${week.rank <= 3 ? "\nKupa dolabına bir kupa eklendi!" : ""}"
          "\n\n${up
              ? "${week.to.title} Ligine yükseldin!"
              : down
              ? "${week.to.title} Ligine düştün. Bu hafta geri al!"
              : "${week.to.title} Liginde kaldın."}",
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
        tier: farm.tier,
        profiles: profilesFor(farm, table, now),
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
    final cost = farm.seedCostOf(crop);
    final affordable = farm.coins >= cost;
    final seed = cost == 0 ? "bedava" : "$cost 🪙";
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
      final usual = farm.productsPerAnimal;
      var amount = 0;
      _act(
        (f) => amount = f.collect(index, now, random: _random),
        toast: () {
          final lucky = amount > usual;
          return "${lucky ? "🍀 Çifte ürün! " : ""}"
              "+$amount ${product.emoji} ${product.name} · "
              "+${kind.xp * (lucky ? 2 : 1)} XP";
        },
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
            "${formatGrowTime(farm.productTimeOf(kind))} sonra "
            "${product.emoji}",
      );
    } else {
      _toast(
        "${kind.name} için ambarda ${farm.feedCountOf(kind)} "
        "${kind.feed.emoji} "
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
    final background = Color(farm?.theme.background ?? springTheme.background!);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Bereket Çiftliği"),
        backgroundColor: background,
        actions: [
          if (farm != null)
            _LeagueButton(
              rank: farm.leagueRank(now),
              tier: farm.tier,
              onTap: _showLeague,
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: farm == null
          ? const SizedBox()
          : _ThemePattern(
              pattern: farm.theme.pattern,
              child: Column(
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
    final offerLeft = farm.hasOffer(now)
        ? farm.offerUntil!.difference(now)
        : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
      children: [
        if (offerLeft != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OfferBanner(timeLeft: offerLeft, onTap: _showOffer),
          ),
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
                      child: Text("⚙️ Topla ($ready)"),
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
                soil: Color(farm.theme.soil!),
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
        if (farm.showDecorations && farm.decorations.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
            decoration: BoxDecoration(
              color: const Color(0x66FFFFFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      for (final decoration in farm.decorations)
                        Tooltip(
                          message: decoration.name,
                          child: Text(
                            decoration.emoji,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('hide-decorations'),
                  tooltip: "Süsleri gizle",
                  onPressed: () => _act(
                    (f) => f.showDecorations = false,
                    toast: () =>
                        "Süsler gizlendi. Dükkân › Süsleme'den yeniden "
                        "açabilirsin.",
                  ),
                  icon: const Icon(
                    Icons.visibility_off_rounded,
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
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
    final now = _now;
    final slotPrice = farm.nextOrderSlotPrice;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _OrderBoardHeader(farm: farm),
        const SizedBox(height: 12),
        for (var i = 0; i < farm.orders.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrderCard(
              order: farm.orders[i],
              farm: farm,
              onDeliver: () {
                final order = farm.orders[i];
                final coins = farm.orderCoins(order);
                _act(
                  (f) => f.deliver(i, random: widget.random),
                  toast: () => "Teslim edildi: +$coins 🪙 · +${order.xp} XP",
                );
              },
              onCancel: () => _cancelOrder(i),
            ),
          ),
        for (final at in [...farm.orderWaits]..sort())
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrderSlot(
              emoji: '⏳',
              title: "Yeni sipariş bekleniyor",
              subtitle: "${formatGrowTime(at.difference(now))} sonra gelir",
            ),
          ),
        if (slotPrice != null)
          _OrderSlot(
            emoji: '🔒',
            title: "${farm.orderSlots + 1}. sipariş yeri",
            subtitle: "Aynı anda bir sipariş daha al",
            action: FilledButton(
              key: const ValueKey('buy-order-slot'),
              onPressed: farm.coins >= slotPrice
                  ? () => _act(
                      (f) => f.buyOrderSlot(_now, random: widget.random),
                      toast: () => "📋 Panoya yeni bir sipariş yeri açıldı!",
                    )
                  : null,
              style: FilledButton.styleFrom(backgroundColor: _green),
              child: Text("$slotPrice 🪙"),
            ),
          ),
      ],
    );
  }

  Future<void> _cancelOrder(int index) async {
    final minutes = FarmState.orderCooldown.inMinutes;
    final cancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sipariş iptal edilsin mi?"),
        content: Text(
          "Komşun başka birini bulur, ama bu yere $minutes dakika yeni "
          "sipariş gelmez.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Vazgeç"),
          ),
          FilledButton(
            key: const ValueKey('confirm-cancel-order'),
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text("İptal et"),
          ),
        ],
      ),
    );
    if (cancel != true || !mounted) return;
    _act(
      (f) => f.cancelOrder(index, _now),
      toast: () => "Sipariş iptal edildi. Yenisi $minutes dakika sonra gelir.",
    );
  }

  Widget _buildShop(FarmState farm) {
    final collected = cosmetics.where((c) => c.price > 0 && farm.owns(c));
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          children: [
            Expanded(
              child: _ShopSwitch(
                key: const ValueKey('shop-tools'),
                emoji: '🛠️',
                title: "Aletler",
                subtitle: "${farm.tools.length}/${farmTools.length} alındı",
                colors: const [Color(0xFF43A047), Color(0xFF1B5E20)],
                selected: !_cosmeticShop,
                onTap: () => setState(() => _cosmeticShop = false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ShopSwitch(
                key: const ValueKey('shop-cosmetics'),
                emoji: '🎨',
                title: "Süsleme",
                subtitle:
                    "${collected.length}/${cosmetics.length - 1} koleksiyon",
                colors: const [Color(0xFFE056FD), Color(0xFF7B1FA2)],
                selected: _cosmeticShop,
                onTap: () => setState(() => _cosmeticShop = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...(_cosmeticShop ? _cosmeticsShop(farm) : _toolShop(farm)),
      ],
    );
  }

  List<Widget> _toolShop(FarmState farm) {
    final plotPrice = farm.nextPlotPrice;
    const groups = {
      "Tarla aletleri": [
        ToolEffect.faster,
        ToolEffect.biggerHarvest,
        ToolEffect.plantAll,
        ToolEffect.harvestAll,
        ToolEffect.cheaperSeeds,
      ],
      "Hayvan aletleri": [
        ToolEffect.tendAll,
        ToolEffect.moreProducts,
        ToolEffect.fasterAnimals,
        ToolEffect.lessFeed,
      ],
      "Pazar ve şans": [
        ToolEffect.betterPrices,
        ToolEffect.betterOrders,
        ToolEffect.luckier,
      ],
    };
    return [
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
      for (final group in groups.entries) ...[
        _ShopHeading(group.key),
        for (final tool in farmTools)
          if (group.value.contains(tool.effect))
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
    ];
  }

  List<Widget> _cosmeticsShop(FarmState farm) {
    void buy(Cosmetic cosmetic) => _act(
      (f) => f.buyCosmetic(cosmetic),
      toast: () => "${cosmetic.emoji} ${cosmetic.name} artık senin!",
    );
    void use(Cosmetic cosmetic) => _act((f) => f.useCosmetic(cosmetic));
    List<Cosmetic> of(CosmeticSlot slot) =>
        cosmetics.where((c) => c.slot == slot).toList();
    return [
      _FarmShowcase(farm: farm),
      SwitchListTile(
        key: const ValueKey('show-decorations'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: const Text("Süsleri tarlada göster"),
        subtitle: const Text("Kapalıyken süslerin sadece burada görünür."),
        value: farm.showDecorations,
        activeThumbColor: _green,
        onChanged: (show) => _act((f) => f.showDecorations = show),
      ),
      const _ShopHeading("Temalar"),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final theme in of(CosmeticSlot.theme))
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _ThemeSwatch(
                  theme: theme,
                  farm: farm,
                  onBuy: () => buy(theme),
                  onUse: () => use(theme),
                ),
              ),
          ],
        ),
      ),
      const _ShopHeading("Bahçe süsleri"),
      _CosmeticGrid(
        items: of(CosmeticSlot.decoration),
        farm: farm,
        onBuy: buy,
        onUse: use,
      ),
      const _ShopHeading("Şapkalar · ligde adının yanında"),
      _CosmeticGrid(
        items: of(CosmeticSlot.hat),
        farm: farm,
        onBuy: buy,
        onUse: use,
      ),
      const SizedBox(height: 12),
    ];
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
  const _LeagueButton({
    required this.rank,
    required this.tier,
    required this.onTap,
  });

  final int rank;
  final LeagueTier tier;
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, size: 20, color: Color(tier.color)),
              const SizedBox(width: 4),
              Text(
                "$rank.",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ZaferBank chest while it is on offer.
class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.timeLeft, required this.onTap});

  final Duration timeLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFE08A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const ValueKey('offer-banner'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bereket Sandığı",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Nadir teklif · ${formatGrowTime(timeLeft)} kaldı",
                      style: const TextStyle(color: Color(0xFF7A5200)),
                    ),
                  ],
                ),
              ),
              Text(
                formatLira(FarmState.offerPrice),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ZaferBank chest: what is in it, what it is worth, and the price.
/// Pops true when the player chooses to pay.
class _OfferDialog extends StatelessWidget {
  const _OfferDialog({required this.farm, required this.now});

  final FarmState farm;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final left = farm.offerUntil!.difference(now);
    return AlertDialog(
      icon: const Text('🎁', style: TextStyle(fontSize: 52)),
      title: const Text("Bereket Sandığı"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Nadir teklif! ${formatGrowTime(left)} sonra kaybolur.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              for (final good in farmGoods)
                Text(
                  "${good.emoji}×${FarmState.offerItems}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "+ ${farm.offerCoins} 🪙",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            "Pazar değeri: ${farm.offerValue} 🪙",
            style: const TextStyle(
              color: _FarmAppState._green,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "ZaferBank hesabından ${formatLira(FarmState.offerPrice)} "
            "çekilecek.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Şimdi değil"),
        ),
        FilledButton(
          key: const ValueKey('buy-offer'),
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: _FarmAppState._green),
          child: Text("${formatLira(FarmState.offerPrice)} öde"),
        ),
      ],
    );
  }
}

/// A cosmetic in the shop: for sale, in use, or owned and ready to use.
/// One of the big buttons switching the shop between tools and
/// cosmetics.
class _ShopSwitch extends StatelessWidget {
  const _ShopSwitch({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? Colors.white : colors.last;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.first.withValues(alpha: selected ? 0 : 0.6),
            width: 2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: colors.last.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ink.withValues(alpha: 0.85),
                      fontSize: 12,
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

class _ShopHeading extends StatelessWidget {
  const _ShopHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  );
}

/// How rare a cosmetic is, by its price.
({String label, Color color}) _rarity(Cosmetic cosmetic) =>
    switch (cosmetic.price) {
      < 1000 => (label: "Sıradan", color: const Color(0xFF43A047)),
      < 5000 => (label: "Nadir", color: const Color(0xFF1E88E5)),
      < 20000 => (label: "Destansı", color: const Color(0xFF8E24AA)),
      _ => (label: "Efsanevi", color: const Color(0xFFF57C00)),
    };

/// The farm as the cosmetics make it look, and how much of the collection
/// is owned.
class _FarmShowcase extends StatelessWidget {
  const _FarmShowcase({required this.farm});

  final FarmState farm;

  @override
  Widget build(BuildContext context) {
    final theme = farm.theme;
    final decorations = farm.decorations;
    final forSale = cosmetics.where((c) => c.price > 0);
    final owned = forSale.where(farm.owns).length;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ColoredBox(
          color: Color(theme.background!),
          child: Column(
            children: [
              _ThemePattern(
                pattern: theme.pattern,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Text(
                            farm.hat?.emoji ?? ' ',
                            style: const TextStyle(fontSize: 22, height: 1),
                          ),
                          const Text('🧑‍🌾', style: TextStyle(fontSize: 40)),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: decorations.isEmpty
                            ? const Text(
                                "Bahçen boş duruyor. Bir süs al, komşular "
                                "görsün!",
                                style: TextStyle(
                                  color: AppColors.secondaryLabel,
                                ),
                              )
                            : Wrap(
                                spacing: 4,
                                children: [
                                  for (final d in decorations)
                                    Text(
                                      d.emoji,
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 14, color: Color(theme.soil!)),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(
                  children: [
                    Text(
                      "${theme.emoji} ${theme.name}",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: owned / forSale.length,
                          minHeight: 8,
                          color: const Color(0xFF8E24AA),
                          backgroundColor: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$owned/${forSale.length}",
                      style: const TextStyle(fontWeight: FontWeight.w700),
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

/// The buy, use or "in use" control of a cosmetic.
class _CosmeticAction extends StatelessWidget {
  const _CosmeticAction({
    required this.cosmetic,
    required this.farm,
    required this.onBuy,
    required this.onUse,
  });

  final Cosmetic cosmetic;
  final FarmState farm;
  final VoidCallback onBuy;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    const compact = EdgeInsets.symmetric(horizontal: 10);
    if (!farm.owns(cosmetic)) {
      return FilledButton(
        key: ValueKey('cosmetic-${cosmetic.id}'),
        onPressed: farm.coins >= cosmetic.price ? onBuy : null,
        style: FilledButton.styleFrom(
          backgroundColor: _rarity(cosmetic).color,
          padding: compact,
          visualDensity: VisualDensity.compact,
        ),
        child: Text("${cosmetic.price} 🪙"),
      );
    }
    final inUse = switch (cosmetic.slot) {
      CosmeticSlot.theme => farm.themeId == cosmetic.id,
      CosmeticSlot.hat => farm.hatId == cosmetic.id,
      CosmeticSlot.decoration => true,
    };
    if (cosmetic.slot == CosmeticSlot.hat) {
      return OutlinedButton(
        onPressed: onUse,
        style: OutlinedButton.styleFrom(
          padding: compact,
          visualDensity: VisualDensity.compact,
        ),
        child: Text(inUse ? "Çıkar" : "Tak"),
      );
    }
    if (inUse) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "Sende ✓",
          style: TextStyle(
            color: _FarmAppState._green,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return OutlinedButton(
      onPressed: onUse,
      style: OutlinedButton.styleFrom(
        padding: compact,
        visualDensity: VisualDensity.compact,
      ),
      child: const Text("Kullan"),
    );
  }
}

/// A theme with a preview of its colours.
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.farm,
    required this.onBuy,
    required this.onUse,
  });

  final Cosmetic theme;
  final FarmState farm;
  final VoidCallback onBuy;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final inUse = farm.themeId == theme.id;
    return Container(
      width: 126,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inUse ? _FarmAppState._green : const Color(0x1F000000),
          width: inUse ? 2.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 54,
            color: Color(theme.background!),
            alignment: Alignment.center,
            child: Text(theme.emoji, style: const TextStyle(fontSize: 26)),
          ),
          Container(height: 10, color: Color(theme.soil!)),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              children: [
                Text(
                  theme.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _CosmeticAction(
                  cosmetic: theme,
                  farm: farm,
                  onBuy: onBuy,
                  onUse: onUse,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorations or hats, three to a row.
class _CosmeticGrid extends StatelessWidget {
  const _CosmeticGrid({
    required this.items,
    required this.farm,
    required this.onBuy,
    required this.onUse,
  });

  final List<Cosmetic> items;
  final FarmState farm;
  final void Function(Cosmetic cosmetic) onBuy;
  final void Function(Cosmetic cosmetic) onUse;

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 2 * gap) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _CosmeticTile(
                  cosmetic: item,
                  farm: farm,
                  onBuy: () => onBuy(item),
                  onUse: () => onUse(item),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CosmeticTile extends StatelessWidget {
  const _CosmeticTile({
    required this.cosmetic,
    required this.farm,
    required this.onBuy,
    required this.onUse,
  });

  final Cosmetic cosmetic;
  final FarmState farm;
  final VoidCallback onBuy;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final rarity = _rarity(cosmetic);
    final owned = farm.owns(cosmetic);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [rarity.color.withValues(alpha: 0.16), Colors.white],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rarity.color.withValues(alpha: owned ? 0.9 : 0.45),
          width: owned ? 2 : 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(cosmetic.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(
            cosmetic.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          Text(
            rarity.label,
            style: TextStyle(
              fontSize: 11,
              color: rarity.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          _CosmeticAction(
            cosmetic: cosmetic,
            farm: farm,
            onBuy: onBuy,
            onUse: onUse,
          ),
        ],
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
    required this.tier,
    required this.profiles,
  });

  final List<LeagueEntry> table;
  final int rank;
  final Duration timeLeft;
  final int trophies;
  final int level;
  final LeagueTier tier;

  /// The farm behind each row of [table], shown when it is tapped.
  final List<FarmProfile> profiles;

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

  /// Whether finishing in [place] moves the farm up or down a tier.
  Widget? _zoneArrow(int place) {
    if (tier.above != null && place <= FarmLeague.movers) {
      return const Icon(
        Icons.arrow_drop_up_rounded,
        color: _FarmAppState._green,
      );
    }
    if (tier.below != null && place > table.length - FarmLeague.movers) {
      return const Icon(Icons.arrow_drop_down_rounded, color: AppColors.red);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const medals = ['🥇', '🥈', '🥉'];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, color: Color(tier.color), size: 26),
              const SizedBox(width: 6),
              Text(
                "${tier.title} Ligi",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
                    key: ValueKey('league-row-$i'),
                    dense: true,
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) =>
                          _FarmProfileDialog(profile: profiles[i]),
                    ),
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
                      [?profiles[i].hat?.emoji, table[i].name].join(" "),
                      style: TextStyle(
                        fontWeight: table[i].isPlayer
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${table[i].score} puan",
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        SizedBox(width: 22, child: _zoneArrow(i + 1)),
                      ],
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
              "+${FarmLeague.reward(1, level, tier)} 🪙, ilk üçe kupa. "
              "${[if (tier.above case final above?) "İlk ${FarmLeague.movers} ${above.title} Ligine yükselir", if (tier.below case final below?) "son ${FarmLeague.movers} ${below.title} Ligine düşer"].join(", ")}.",
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

/// A farm from the league table: its level, fields, animals and what it
/// has bought to look good.
class _FarmProfileDialog extends StatelessWidget {
  const _FarmProfileDialog({required this.profile});

  final FarmProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = profile.theme;
    final decorations = profile.decorations;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Color(theme.background!),
            child: _ThemePattern(
              pattern: theme.pattern,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  children: [
                    Text(
                      profile.hat?.emoji ?? ' ',
                      style: const TextStyle(fontSize: 26, height: 1),
                    ),
                    const Text('🧑‍🌾', style: TextStyle(fontSize: 48)),
                    Text(
                      profile.isPlayer ? "Senin çiftliğin" : profile.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 16,
                          color: Color(profile.tier.color),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "Seviye ${profile.level} · "
                            "${profile.tier.title} Ligi",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(height: 10, color: Color(theme.soil!)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _ProfileStat(
                      emoji: '🟫',
                      value: profile.fields,
                      label: "Tarla",
                    ),
                    _ProfileStat(
                      emoji: '🐾',
                      value: profile.animalCount,
                      label: "Hayvan",
                    ),
                    _ProfileStat(
                      emoji: '🌳',
                      value: decorations.length,
                      label: "Süs",
                    ),
                    _ProfileStat(
                      emoji: '🏆',
                      value: profile.trophies,
                      label: "Kupa",
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ProfileLine(
                  title: "Hayvanlar",
                  text: profile.herd.isEmpty
                      ? "Henüz hayvanı yok"
                      : [
                          for (final e in profile.herd.entries)
                            "${e.key.emoji} ×${e.value}",
                        ].join("   "),
                ),
                _ProfileLine(
                  title: "Süsler",
                  text: decorations.isEmpty
                      ? "Henüz süs almamış"
                      : decorations.map((d) => d.emoji).join(" "),
                ),
                _ProfileLine(
                  title: "Tema",
                  text: "${theme.emoji} ${theme.name}",
                ),
                if (profile.hat case final hat?)
                  _ProfileLine(
                    title: "Şapka",
                    text: "${hat.emoji} ${hat.name}",
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kapat"),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        Text(
          "$value",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.secondaryLabel, fontSize: 12),
        ),
      ],
    ),
  );
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            title,
            style: const TextStyle(color: AppColors.secondaryLabel),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

/// A theme's emoji scattered faintly over the background behind [child].
class _ThemePattern extends StatelessWidget {
  const _ThemePattern({required this.pattern, required this.child});

  final String? pattern;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pattern = this.pattern;
    if (pattern == null) return child;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: CustomPaint(painter: _PatternPainter(pattern)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.pattern);

  final String pattern;

  /// Distance between the emoji, in pixels.
  static const _gap = 58.0;

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(
        text: pattern,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Faint, so the farm in front stays easy to read.
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = const Color(0x38FFFFFF),
    );
    for (var row = 0; row * _gap < size.height + _gap; row++) {
      // Every other row sits half a step over, like wallpaper.
      final shift = row.isOdd ? _gap / 2 : 0.0;
      for (var x = -_gap + shift; x < size.width + _gap; x += _gap) {
        canvas
          ..save()
          ..translate(x + 10, row * _gap + 10)
          // A slight tilt that changes along the row, so it looks scattered.
          ..rotate(((row * 7 + x ~/ _gap) % 5 - 2) * 0.18);
        painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
        canvas.restore();
      }
    }
    canvas.restore();
    painter.dispose();
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.pattern != pattern;
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
                    ? "${farm.feedCountOf(kind)} ${kind.feed.emoji} yer, "
                          "${formatGrowTime(farm.productTimeOf(kind))} sonra "
                          "${farm.productsPerAnimal} ${product.emoji} "
                          "${product.name} verir · "
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
    required this.soil,
    required this.now,
    required this.onTap,
  });

  final Plot plot;
  final Color soil;
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
          color: soil,
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
    required this.onCancel,
  });

  final FarmOrder order;
  final FarmState farm;
  final VoidCallback onDeliver;
  final VoidCallback onCancel;

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
                    "Ödül: ${farm.orderCoins(order)} 🪙 · ${order.xp} XP",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: onCancel,
                  tooltip: "Siparişi iptal et",
                  icon: const Icon(Icons.close_rounded),
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

/// The top of the order board: how many slots are open and in use.
class _OrderBoardHeader extends StatelessWidget {
  const _OrderBoardHeader({required this.farm});

  final FarmState farm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB07A4A), Color(0xFF8A5A33)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('📋', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sipariş Panosu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Komşuların pazardan çok daha iyi öder.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < FarmState.maxOrderSlots; i++)
                      Container(
                        width: 22,
                        height: 8,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: i < farm.orders.length
                              ? const Color(0xFFFFD166)
                              : i < farm.orderSlots
                              ? Colors.white54
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      "${farm.orderSlots}/${FarmState.maxOrderSlots} yer",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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

/// An order board slot without an order: waiting for one, or still to
/// be bought.
class _OrderSlot extends StatelessWidget {
  const _OrderSlot({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33000000), width: 1.5),
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: action,
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

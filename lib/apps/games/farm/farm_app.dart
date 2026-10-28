import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/app_theme.dart';
import 'farm_catalog.dart';
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

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _load();
    // Growing crops tick on screen.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
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
    farm.fillOrders(random: widget.random);
    final bonus = farm.claimDailyBonus(_now);
    if (!mounted) return;
    setState(() => _farm = farm);
    await _save();
    if (bonus != null) _toast("Günlük hediye: +$bonus 🪙");
  }

  Future<void> _save() async {
    final farm = _farm;
    if (farm == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(FarmApp.saveKey, json.encode(farm.toJson()));
  }

  /// Runs [action] on the farm, saves, and celebrates any new level.
  void _act(void Function(FarmState farm) action) {
    final farm = _farm!;
    final before = farm.level;
    setState(() => action(farm));
    _save();
    if (farm.level > before) _showLevelUp(before + 1, farm.level);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }

  void _showLevelUp(int from, int to) {
    final reward = [
      for (var l = from; l <= to; l++) FarmState.levelReward(l),
    ].reduce((a, b) => a + b);
    final newCrops = crops.where((c) => c.level >= from && c.level <= to);
    final newTools = farmTools.where((t) => t.level >= from && t.level <= to);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Text('🎉', style: TextStyle(fontSize: 48)),
        title: Text("Seviye $to!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ödül: +$reward 🪙", style: const TextStyle(fontSize: 16)),
            for (final crop in newCrops)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("Yeni ürün: ${crop.emoji} ${crop.name}"),
              ),
            for (final tool in newTools)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("Dükkânda yeni: ${tool.emoji} ${tool.name}"),
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
      var amount = 0;
      _act((f) => amount = f.harvest(index, now));
      _toast("+$amount ${crop.emoji} ${crop.name} · +${crop.xp} XP");
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
    _act((f) => planted = f.plantAll(crop, _now));
    _toast("🚜 $planted tarlaya ${crop.name} ekildi");
  }

  void _harvestAll() {
    var picked = <String, int>{};
    _act((f) => picked = f.harvestAll(_now));
    _toast(
      "⚙️ ${[for (final e in picked.entries) "+${e.value} ${cropById(e.key).emoji}"].join("  ")}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = _farm;
    final deliverable =
        farm?.orders.where((o) => farm.canDeliver(o)).length ?? 0;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5D6),
      appBar: AppBar(
        title: const Text("Bereket Çiftliği"),
        backgroundColor: const Color(0xFFE8F5D6),
      ),
      body: farm == null
          ? const SizedBox()
          : Column(
              children: [
                _Header(farm: farm),
                Expanded(
                  child: switch (_tab) {
                    0 => _buildField(farm),
                    1 => _buildBarn(farm),
                    2 => _buildOrders(farm),
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
          const NavigationDestination(
            icon: Icon(Icons.grass_rounded),
            label: "Tarla",
          ),
          const NavigationDestination(
            icon: Icon(Icons.warehouse_rounded),
            label: "Ambar",
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: deliverable > 0,
              label: Text('$deliverable'),
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

  Widget _buildBarn(FarmState farm) {
    final stock = [
      for (final crop in crops)
        if ((farm.barn[crop.id] ?? 0) > 0) crop,
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
        for (final crop in stock)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(crop.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${crop.name} × ${farm.barn[crop.id]}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Tanesi ${farm.priceOf(crop)} 🪙",
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
                                    _act((f) => f.sell(crop.id, 1)),
                                child: const Text("1 sat"),
                              ),
                              FilledButton(
                                onPressed: () {
                                  final count = farm.barn[crop.id]!;
                                  final total = farm.priceOf(crop) * count;
                                  _act((f) => f.sell(crop.id, count));
                                  _toast("+$total 🪙");
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
                _act((f) => f.deliver(i, random: widget.random));
                _toast("Teslim edildi: +${order.coins} 🪙 · +${order.xp} XP");
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
              onBuy: () {
                _act((f) => f.buyTool(tool));
                _toast("${tool.emoji} ${tool.name} artık senin!");
              },
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

/// Coins, level and the experience bar.
class _Header extends StatelessWidget {
  const _Header({required this.farm});

  final FarmState farm;

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
                Text(
                  "${farm.xp} / ${farm.xpToNextLevel} XP",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                    crop: cropById(item.key),
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
    required this.crop,
    required this.have,
    required this.need,
  });

  final Crop crop;
  final int have;
  final int need;

  @override
  Widget build(BuildContext context) {
    final enough = have >= need;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(crop.emoji, style: const TextStyle(fontSize: 26)),
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

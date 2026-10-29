import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/games/castle_guard/castle_defense.dart';
import 'package:ledective/apps/games/castle_guard/castle_profile.dart';
import 'package:ledective/apps/games/farm/farm_catalog.dart';
import 'package:ledective/apps/games/farm/farm_cosmetics.dart';
import 'package:ledective/apps/games/farm/farm_league.dart';
import 'package:ledective/apps/games/farm/farm_reminder.dart';
import 'package:ledective/apps/games/farm/farm_state.dart';
import 'package:ledective/apps/games/space_runner/space_run.dart';
import 'package:ledective/story/story_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

FarmTool _tool(String id) => farmTools.firstWhere((t) => t.id == id);

/// Always rolls the lowest number, so every chance comes up.
class _Lucky implements Random {
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

/// Plays [game] like a sensible player: before every wave it builds
/// [mix] towers on the tiles that see the most road, then upgrades.
void _defend(CastleDefense game, List<TowerKind> mix) {
  int roadInReach(Tile t) => game.road
      .where((r) => pow(r.col - t.col, 2) + pow(r.row - t.row, 2) <= 6)
      .length;
  final spots =
      [
          for (var c = 0; c < CastleDefense.cols; c++)
            for (var r = 0; r < CastleDefense.rows; r++) (col: c, row: r),
        ].where(game.canBuildOn).toList()
        ..sort((a, b) => roadInReach(b).compareTo(roadInReach(a)));
  while (!game.isOver) {
    var spent = true;
    while (spent) {
      spent = false;
      final kind = mix[game.towers.length % mix.length];
      final upgrades = game.towers.where((t) => t.upgradeCost != null).toList()
        ..sort((a, b) => a.upgradeCost!.compareTo(b.upgradeCost!));
      if (game.towers.length >= 6 + game.wave &&
          upgrades.isNotEmpty &&
          game.gold >= upgrades.first.upgradeCost!) {
        spent = game.upgrade(upgrades.first);
      } else if (game.gold >= kind.cost) {
        final spot = spots.where(game.canBuildOn).firstOrNull;
        if (spot != null) spent = game.build(kind, spot) != null;
      }
    }
    game.startWave();
    while (game.waveRunning && !game.isOver) {
      game.update(0.05);
    }
  }
}

void main() {
  group('CastleDefense', () {
    test('every road runs unbroken from the edge to the castle', () {
      for (final map in castleMaps) {
        final start = map.positionAt(0);
        expect(start.y, lessThan(0), reason: 'enemies come in from outside');
        expect(map.positionAt(map.roadLength), (
          x: map.castle.col + 0.5,
          y: map.castle.row + 0.5,
        ));
        for (var d = 1.0; d < map.roadLength; d += 0.5) {
          final p = map.positionAt(d);
          expect(map.road, contains((col: p.x.floor(), row: p.y.floor())));
        }
        for (final tile in map.road) {
          expect(tile.col, inInclusiveRange(0, CastleDefense.cols - 1));
          expect(tile.row, inInclusiveRange(0, CastleDefense.rows - 1));
        }
      }
      expect(castleMaps.map((m) => m.id).toSet(), hasLength(3));
    });

    test('towers go on the grass, cost gold and refund part of it', () {
      final game = CastleDefense();
      expect(
        game.build(TowerKind.archer, (col: 1, row: 1)),
        isNull,
        reason: 'on the road',
      );
      final tower = game.build(TowerKind.archer, (col: 2, row: 1))!;
      expect(game.gold, CastleDefense.startGold - TowerKind.archer.cost);
      expect(
        game.build(TowerKind.frost, (col: 2, row: 1)),
        isNull,
        reason: 'taken',
      );
      expect(game.upgrade(tower), isTrue);
      expect(tower.damage, TowerKind.archer.damage[1]);
      final gold = game.gold;
      game.sell(tower);
      expect(game.towers, isEmpty);
      expect(game.gold, gold + tower.refund);
      expect(tower.refund, lessThan(tower.spent));
    });

    test('waves grow and bring dragons from the tenth', () {
      expect(CastleDefense.waveEnemies(1), everyElement(EnemyKind.goblin));
      expect(
        CastleDefense.waveEnemies(2).length,
        greaterThan(CastleDefense.waveEnemies(1).length),
      );
      expect(CastleDefense.waveEnemies(5), isNot(contains(EnemyKind.dragon)));
      expect(CastleDefense.waveEnemies(10), contains(EnemyKind.dragon));
      expect(CastleDefense.toughness(20), greaterThan(4));
    });

    test('only one wave at a time, paid for when it is beaten', () {
      final game = CastleDefense(random: Random(1))
        ..build(TowerKind.archer, (col: 2, row: 1))
        ..build(TowerKind.archer, (col: 0, row: 4));
      expect(game.startWave(), isTrue);
      expect(game.startWave(), isFalse);
      final gold = game.gold;
      while (game.waveRunning) {
        game.update(0.05);
      }
      final leaked = CastleDefense.waveEnemies(1).length - game.kills;
      expect(game.kills, greaterThan(0));
      expect(game.lives, CastleDefense.startLives - leaked);
      expect(
        game.gold,
        gold +
            game.kills * EnemyKind.goblin.reward +
            CastleDefense.waveBonus(1),
      );
    });

    test('an undefended castle falls within a few waves', () {
      final game = CastleDefense(random: Random(1));
      while (!game.isOver) {
        game
          ..startWave()
          ..update(0.05);
      }
      expect(game.isLost, isTrue);
      expect(game.wave, lessThanOrEqualTo(4));
      expect(game.startWave(), isFalse);
    });

    test('a sensible defence holds all twenty waves', () {
      for (final mix in [
        [TowerKind.archer],
        [TowerKind.archer, TowerKind.cannon, TowerKind.frost, TowerKind.archer],
      ]) {
        final game = CastleDefense(random: Random(2));
        _defend(game, mix);
        expect(game.isWon, isTrue, reason: '$mix');
      }
    });

    test('the later maps are harder but can be won', () {
      final lives = <int>[];
      for (final map in castleMaps) {
        final game = CastleDefense(map: map, random: Random(2));
        _defend(game, [TowerKind.archer]);
        lives.add(game.lives);
      }
      expect(lives, everyElement(greaterThan(0)));
      expect(lives.last, lessThan(lives.first));
    });

    test('a game is saved and picked up mid-wave', () {
      final game = CastleDefense(map: castleMaps[1], random: Random(3))
        ..build(TowerKind.archer, (col: 2, row: 1))
        ..build(TowerKind.frost, (col: 0, row: 4));
      game
        ..upgrade(game.towers.first)
        ..startWave();
      for (var i = 0; i < 80; i++) {
        game.update(0.05);
      }
      expect(game.enemies, isNotEmpty);
      final copy = CastleDefense.fromJson(game.toJson(), random: Random(3));
      expect(copy.toJson(), game.toJson());
      expect(copy.map, castleMaps[1]);
      expect(copy.waveRunning, isTrue);
      while (copy.waveRunning) {
        copy.update(0.05);
      }
      expect(copy.wave, 1);
      expect(copy.kills, greaterThan(game.kills));
    });
  });

  group('CastleProfile', () {
    test('a win opens the next map', () {
      final profile = CastleProfile();
      expect(profile.isUnlocked(castleMaps[0]), isTrue);
      expect(profile.isUnlocked(castleMaps[1]), isFalse);
      final game = CastleDefense(random: Random(2));
      _defend(game, [TowerKind.archer]);
      final result = profile.record(game);
      expect(result.newBest, isTrue);
      expect(profile.best['meadow'], CastleDefense.waves);
      expect(profile.isUnlocked(castleMaps[1]), isTrue);
      expect(profile.isUnlocked(castleMaps[2]), isFalse);
      expect(
        result.earned,
        containsAll([
          CastleAchievement.firstBlood,
          CastleAchievement.meadow,
          CastleAchievement.archersOnly,
          CastleAchievement.dragonSlayer,
        ]),
      );
      expect(
        profile.unlock(CastleDefense()),
        isEmpty,
        reason: 'each is earned once',
      );
    });

    test('a lost game counts in the statistics', () {
      final profile = CastleProfile();
      final game = CastleDefense(random: Random(1));
      while (!game.isOver) {
        game
          ..startWave()
          ..update(0.05);
      }
      final result = profile.record(game);
      expect(profile.games, 1);
      expect(profile.losses, 1);
      expect(profile.waves, CastleProfile.held(game));
      expect(profile.kills, 0);
      expect(result.earned, isEmpty);
      expect(profile.isUnlocked(castleMaps[1]), isFalse);
    });

    test('achievements come while playing, too', () {
      final profile = CastleProfile();
      final game = CastleDefense()..gold = 1000;
      final tower = game.build(TowerKind.cannon, (col: 2, row: 1))!;
      game
        ..upgrade(tower)
        ..upgrade(tower);
      expect(
        profile.unlock(game),
        containsAll([CastleAchievement.masterBuilder]),
      );
      expect(profile.achievements, contains(CastleAchievement.masterBuilder));
    });

    test('survives a JSON round trip', () {
      final profile = CastleProfile();
      final game = CastleDefense(random: Random(2));
      _defend(game, [TowerKind.archer]);
      profile.record(game);
      final copy = CastleProfile.fromJson(profile.toJson());
      expect(copy.toJson(), profile.toJson());
      expect(copy.achievements, profile.achievements);
      expect(copy.killsBy, profile.killsBy);
    });
  });

  group('SpaceRun', () {
    test('flying uses fuel until the tank is empty', () {
      final run = SpaceRun(random: Random(1));
      // No asteroids, so only the fuel can end the run.
      while (!run.isOver) {
        run.update(0.05);
        run.objects.clear();
      }
      expect(run.end, SpaceRunEnd.outOfFuel);
      expect(run.time, closeTo(SpaceRun.tankSeconds, 0.1));
      expect(run.metres, greaterThan(0));
    });

    test('an asteroid on the rocket ends the run', () {
      final run = SpaceRun(random: Random(1))
        ..objects.add(
          SpaceObject(x: 0.5, y: SpaceRun.rocketY - 0.01, radius: 0.05),
        );
      run.update(0.01);
      expect(run.end, SpaceRunEnd.crashed);
      run.update(1);
      expect(run.time, closeTo(0.01, 1e-9), reason: 'a finished run stops');
    });

    test('a caught fuel can refills the tank', () {
      final run = SpaceRun(random: Random(1))..fuel = 0.5;
      run.objects.add(
        SpaceObject(x: 0.5, y: SpaceRun.rocketY, radius: 0.035, isFuel: true),
      );
      run.update(0.01);
      expect(run.isOver, isFalse);
      expect(run.fuel, greaterThan(0.8));
      expect(run.fuelCollected, 1);
    });

    test('the rocket stays on the field and things speed up', () {
      final run = SpaceRun(random: Random(1))..moveTo(-3);
      expect(run.rocketX, SpaceRun.rocketRadius);
      run.moveTo(3);
      expect(run.rocketX, 1 - SpaceRun.rocketRadius);
      final start = run.speed;
      run.time = 60;
      expect(run.speed, greaterThan(start));
    });

    test('rocks keep coming', () {
      final run = SpaceRun(random: Random(2))..moveTo(0);
      for (var i = 0; i < 40 && !run.isOver; i++) {
        run.update(0.05);
      }
      expect(run.objects.where((o) => !o.isFuel), isNotEmpty);
    });
  });

  group('FarmState', () {
    final now = DateTime(2026, 10, 28, 12);
    final wheat = cropById('wheat');
    final carrot = cropById('carrot');

    test('a new farm has coins, four fields and free wheat', () {
      final farm = FarmState();
      expect(farm.coins, FarmState.startCoins);
      expect(farm.plots, hasLength(4));
      expect(farm.unlockedCrops, [wheat]);
      expect(wheat.seedCost, 0);
    });

    test('crops grow in real time and are harvested into the barn', () {
      final farm = FarmState();
      expect(farm.plant(0, wheat, now), isTrue);
      expect(farm.plant(0, wheat, now), isFalse, reason: 'field is busy');
      expect(farm.plots[0].progress(now.add(wheat.growTime ~/ 2)), 0.5);
      expect(farm.harvest(0, now.add(const Duration(seconds: 29))), 0);
      expect(farm.harvest(0, now.add(wheat.growTime)), 2);
      expect(farm.barn['wheat'], 2);
      expect(farm.xp, wheat.xp);
      expect(farm.plots[0].isEmpty, isTrue);
    });

    test('locked or unaffordable crops cannot be planted', () {
      final farm = FarmState();
      expect(farm.plant(0, carrot, now), isFalse, reason: 'level 2 crop');
      farm
        ..level = 2
        ..coins = 1;
      expect(farm.plant(0, carrot, now), isFalse, reason: 'seed costs 2');
      farm.coins = 2;
      expect(farm.plant(0, carrot, now), isTrue);
      expect(farm.coins, 0);
    });

    test('levelling up pays a reward and unlocks crops', () {
      final farm = FarmState()..addXp(11);
      expect(farm.level, 2);
      expect(farm.xp, 0);
      expect(farm.coins, FarmState.startCoins + FarmState.levelReward(2));
      expect(farm.unlockedCrops, contains(carrot));
      farm.addXp(1000);
      expect(farm.level, greaterThan(4));
      expect(farm.xp, lessThan(farm.xpToNextLevel));
    });

    test('later levels take much longer than the first ones', () {
      int need(int level) => FarmState(level: level).xpToNextLevel;
      expect(need(1), 11);
      expect(need(5), 275);
      expect(need(10), 1550);
      expect(need(10), greaterThan(2.5 * (5 * 10 * 10 + 5 * 10)));
    });

    test('selling and buying fields', () {
      final farm = FarmState()..barn['wheat'] = 5;
      expect(farm.sell('wheat', 6), isFalse);
      expect(farm.sell('wheat', 5), isTrue);
      expect(farm.barn, isEmpty);
      expect(farm.coins, FarmState.startCoins + 5 * wheat.price);

      expect(farm.nextPlotPrice, 50);
      expect(farm.buyPlot(), isFalse, reason: 'not enough coins yet');
      farm.coins = 1000;
      expect(farm.buyPlot(), isTrue);
      expect(farm.plots, hasLength(5));
      expect(farm.nextPlotPrice, 150);
      farm.coins = 1 << 30;
      while (farm.buyPlot()) {}
      expect(farm.plots, hasLength(FarmState.maxPlots));
      expect(farm.nextPlotPrice, isNull);
    });

    test('tools speed things up and do the work', () {
      final farm = FarmState(level: 20, coins: 100000);
      for (final tool in farmTools) {
        expect(farm.buyTool(tool), isTrue, reason: tool.id);
      }
      expect(farm.buyTool(farmTools.first), isFalse, reason: 'owned');
      expect(farm.growthFactor, closeTo(0.8 * 0.7, 1e-9));
      expect(farm.harvestPerPlot, 2 + 1 + 2);
      expect(farm.priceOf(carrot), (carrot.price * 1.25).round());

      expect(farm.plantAll(wheat, now), 4);
      final ready = now.add(farm.growTimeOf(wheat));
      expect(farm.readyCount(ready), 4);
      expect(farm.harvestAll(ready), {'wheat': 4 * 5});
    });

    test('tools need their level and the coins', () {
      final farm = FarmState(coins: 100000);
      expect(farm.buyTool(_tool('tractor')), isFalse);
      expect(farm.plantAll(wheat, now), 0, reason: 'no tractor');
      farm
        ..level = 4
        ..coins = 10;
      expect(farm.buyTool(_tool('tractor')), isFalse);
    });

    test('orders ask for unlocked crops and pay better than the market', () {
      final farm = FarmState(level: 6)..fillOrders(now, random: Random(1));
      expect(farm.orders, hasLength(FarmState.startOrderSlots));
      for (final order in farm.orders) {
        var market = 0;
        order.items.forEach((id, count) {
          expect(farm.isUnlocked(cropById(id)), isTrue);
          market += cropById(id).price * count;
        });
        expect(order.coins, greaterThan(market));
      }

      final order = farm.orders.first;
      expect(farm.deliver(0), isFalse);
      farm.barn.addAll(order.items);
      final coins = farm.coins;
      expect(farm.deliver(0, random: Random(2)), isTrue);
      expect(farm.coins, greaterThanOrEqualTo(coins + order.coins));
      expect(farm.barn, isEmpty);
      expect(farm.orders.first, isNot(same(order)));
    });

    test('a turned-down order leaves its slot empty for a while', () {
      final farm = FarmState(level: 3)..fillOrders(now, random: Random(1));
      farm.cancelOrder(0, now);
      expect(farm.orders, hasLength(FarmState.startOrderSlots - 1));
      expect(farm.fillOrders(now.add(const Duration(minutes: 9))), 0);
      expect(farm.orders, hasLength(FarmState.startOrderSlots - 1));
      expect(farm.fillOrders(now.add(FarmState.orderCooldown)), 1);
      expect(farm.orderWaits, isEmpty);
      expect(farm.orders, hasLength(FarmState.startOrderSlots));
    });

    test('more order slots are bought, up to five', () {
      final farm = FarmState(coins: 100000)..fillOrders(now);
      final paid = <int>[];
      for (int? price; (price = farm.nextOrderSlotPrice) != null;) {
        paid.add(price!);
        expect(farm.buyOrderSlot(now), isTrue);
        expect(farm.orders, hasLength(farm.orderSlots));
      }
      expect(paid, FarmState.orderSlotPrices);
      expect(farm.orderSlots, FarmState.maxOrderSlots);
      expect(farm.buyOrderSlot(now), isFalse);
      expect(farm.coins, 100000 - paid.fold(0, (a, b) => a + b));
    });

    test('the daily gift grows with the streak and resets on a missed day', () {
      final farm = FarmState();
      expect(farm.claimDailyBonus(now), 30);
      expect(farm.claimDailyBonus(now.add(const Duration(hours: 5))), isNull);
      expect(farm.claimDailyBonus(now.add(const Duration(days: 1))), 40);
      expect(farm.streakDay, 2);
      for (var day = 2; day < 7; day++) {
        farm.claimDailyBonus(now.add(Duration(days: day)));
      }
      expect(farm.streakDay, 7);
      expect(farm.coins, FarmState.startCoins + 580 + 7 * 10);
      // The streak goes round again after the big seventh day.
      expect(farm.claimDailyBonus(now.add(const Duration(days: 7))), 30);
      expect(farm.claimDailyBonus(now.add(const Duration(days: 9))), 30);
      expect(farm.streak, 1, reason: 'a day was missed');
    });

    test('a lucky harvest gives double', () {
      final farm = FarmState()..plant(0, wheat, now);
      final ready = now.add(wheat.growTime);
      expect(farm.harvest(0, ready, random: _Lucky()), 4);
      farm.plant(0, wheat, ready);
      expect(farm.harvest(0, ready.add(wheat.growTime), random: Random(1)), 2);
    });

    test('animals eat crops from the barn and give their product', () {
      final chicken = animalById('chicken');
      final farm = FarmState(coins: 1000);
      expect(farm.buyAnimal(chicken), isFalse, reason: 'level 2 animal');
      farm.level = 2;
      expect(farm.buyAnimal(chicken), isTrue);
      expect(farm.coins, 1000 - chicken.price);
      expect(farm.animalPrice(chicken), 2 * chicken.price);

      expect(farm.feed(0, now), isFalse, reason: 'no wheat in the barn');
      farm.barn['wheat'] = 1;
      expect(farm.feed(0, now), isTrue);
      expect(farm.barn, isEmpty);
      expect(farm.animals[0].progress(now.add(chicken.time ~/ 2)), 0.5);
      expect(farm.collect(0, now.add(const Duration(minutes: 1))), 0);
      final xp = farm.xp;
      expect(farm.collect(0, now.add(chicken.time)), 1);
      expect(farm.barn['egg'], 1);
      expect(farm.xp, xp + chicken.xp);
      expect(farm.animals[0].isHungry, isTrue);
      expect(farm.sell('egg', 1), isTrue);
    });

    test('a pen holds five animals', () {
      final cow = animalById('cow');
      final farm = FarmState(level: 4, coins: 1 << 20);
      while (farm.buyAnimal(cow)) {}
      expect(farm.animalsOf(cow), hasLength(FarmState.maxAnimalsPerKind));
      expect(farm.animalPrice(cow), isNull);
    });

    test('the feeder collects from and feeds every animal', () {
      final chicken = animalById('chicken');
      final farm = FarmState(level: 5, coins: 1 << 20)
        ..buyAnimal(chicken)
        ..buyAnimal(chicken)
        ..buyAnimal(chicken)
        ..barn['wheat'] = 3;
      expect(farm.tendAll(now).fed, 0, reason: 'no feeder yet');
      farm.buyTool(_tool('feeder'));
      expect(farm.tendAll(now).fed, 3);
      final later = now.add(chicken.time);
      expect(farm.animalsReady(later), 3);
      farm.barn['wheat'] = 2;
      final result = farm.tendAll(later);
      expect(result.collected, {'egg': 3});
      expect(result.fed, 2, reason: 'wheat for only two');
    });

    test('animal tools give more, quicker products for less feed', () {
      final cow = animalById('cow');
      final farm = FarmState(level: 15, coins: 1 << 20)
        ..buyAnimal(cow)
        ..barn['corn'] = 10;
      expect(farm.feedCountOf(cow), 2);
      expect(farm.productsPerAnimal, 1);
      farm
        ..buyTool(_tool('milking-kit'))
        ..buyTool(_tool('barn-radio'))
        ..buyTool(_tool('feed-silo'));
      expect(farm.feedCountOf(cow), 1);
      expect(farm.feedCountOf(animalById('chicken')), 1, reason: 'at least 1');
      expect(farm.feed(0, now), isTrue);
      expect(farm.barn['corn'], 9);
      final ready = now.add(cow.time * 0.75);
      final xp = farm.xp;
      expect(farm.collect(0, ready), 2);
      expect(farm.xp, xp + cow.xp, reason: 'tools add no experience');
      farm.buyTool(_tool('modern-barn'));
      expect(farm.productsPerAnimal, 3);
    });

    test('seed, order and luck tools', () {
      final farm = FarmState(level: 12, coins: 1 << 20)
        ..fillOrders(now, random: Random(3));
      final tomato = cropById('tomato');
      final order = farm.orders.first;
      expect(farm.seedCostOf(tomato), tomato.seedCost);
      expect(farm.orderCoins(order), order.coins);
      expect(farm.luckChance, FarmState.luckyChance);
      farm
        ..buyTool(_tool('seed-store'))
        ..buyTool(_tool('truck'))
        ..buyTool(_tool('clover'));
      expect(farm.seedCostOf(tomato), (tomato.seedCost / 2).round());
      expect(farm.orderCoins(order), (order.coins * 1.3).round());
      expect(farm.luckChance, closeTo(0.2, 1e-9));
      farm.barn.addAll(order.items);
      final coins = farm.coins;
      farm.deliver(0);
      expect(farm.coins, coins + (order.coins * 1.3).round());
    });

    test('tells when every growing field will be ready', () {
      final farm = FarmState(level: 2, coins: 100);
      expect(farm.allReadyAt(now), isNull);
      farm
        ..plant(0, wheat, now)
        ..plant(1, carrot, now);
      final last = now.add(carrot.growTime);
      expect(farm.allReadyAt(now), last);
      expect(farm.allReadyAt(last), isNull, reason: 'all ready already');
    });

    test('the phone is told once every field is ready', () async {
      SharedPreferences.setMockInitialValues({});
      final farm = FarmState(level: 2, coins: 100)
        ..plant(0, wheat, now)
        ..plant(1, carrot, now);
      await FarmReminder.schedule(farm, now);
      final alerts = AlertQueue();
      await FarmReminder.tick(alerts, now: now.add(wheat.growTime));
      expect(alerts.items, isEmpty, reason: 'the carrots still grow');

      FarmReminder.farmOpen = true;
      await FarmReminder.tick(alerts, now: now.add(carrot.growTime));
      expect(alerts.items, isEmpty, reason: 'the farm is on screen');
      FarmReminder.farmOpen = false;

      await FarmReminder.tick(alerts, now: now.add(carrot.growTime));
      expect(alerts.items.single.app, "Bereket Çiftliği");
      expect(alerts.items.single.body, contains('2 tarlanın hepsi hazır'));
      await FarmReminder.tick(alerts, now: now.add(const Duration(hours: 1)));
      expect(alerts.items, hasLength(1), reason: 'only once');
    });

    test('orders ask for the products of animals the farm keeps', () {
      final farm = FarmState(level: 4, coins: 1000)
        ..buyAnimal(animalById('cow'));
      final asked = <String>{};
      final random = Random(5);
      for (var i = 0; i < 40; i++) {
        asked.addAll(farm.newOrder(random: random).items.keys);
      }
      expect(asked, contains('milk'));
      expect(asked, isNot(contains('egg')), reason: 'no chickens');
    });

    test('survives a JSON round trip', () {
      final farm = FarmState(level: 4, coins: 5000)
        ..rollWeek(now)
        ..buyAnimal(animalById('chicken'))
        ..barn['wheat'] = 1
        ..feed(0, now)
        ..addXp(3)
        ..standings(now.add(const Duration(hours: 5)))
        ..plant(1, carrot, now)
        ..barn['corn'] = 3
        ..buyTool(_tool('watering-can'))
        ..fillOrders(now, random: Random(4))
        ..cancelOrder(0, now)
        ..buyOrderSlot(now, random: Random(4))
        ..claimDailyBonus(now)
        ..offerUntil = now.add(const Duration(hours: 1))
        ..offerCheckedAt = now
        ..tier = LeagueTier.silver
        ..buyCosmetic(cosmeticById('tree'))
        ..buyCosmetic(cosmeticById('straw-hat'));
      final copy = FarmState.fromJson(farm.toJson());
      expect(copy.toJson(), farm.toJson());
      expect(copy.plots[1].readyAt, farm.plots[1].readyAt);
      expect(copy.has(ToolEffect.faster), isTrue);
      copy.barn['corn'] = 4;
      expect(farm.barn['corn'], 3, reason: 'the copy has its own barn');
      expect(copy.animals.single.readyAt, farm.animals.single.readyAt);
      expect(copy.rivalScores, farm.rivalScores);
      expect(copy.tier, LeagueTier.silver);
      expect(copy.hat, cosmeticById('straw-hat'));
      expect(copy.decorations, farm.decorations);
      expect(copy.orderSlots, 3);
      expect(copy.orderWaits, farm.orderWaits);
    });

    test('the ZaferBank chest turns up rarely and holds five of all', () {
      final farm = FarmState(level: 2);
      expect(farm.rollOffer(now, random: _Lucky()), isFalse, reason: 'level');
      farm.level = 3;
      expect(farm.rollOffer(now, random: Random(1)), isFalse);
      expect(
        farm.rollOffer(now.add(const Duration(hours: 1)), random: _Lucky()),
        isFalse,
        reason: 'checked an hour ago',
      );
      final later = now.add(FarmState.offerCheckEvery);
      expect(farm.rollOffer(later, random: _Lucky()), isTrue);
      expect(farm.hasOffer(later), isTrue);
      expect(farm.hasOffer(later.add(FarmState.offerLength)), isFalse);

      expect(farm.offerValue, greaterThan(10 * farm.offerCoins));
      final coins = farm.coins;
      expect(farm.claimOffer(later), isTrue);
      for (final good in farmGoods) {
        expect(farm.barn[good.id], FarmState.offerItems, reason: good.id);
      }
      expect(farm.coins, coins + farm.offerCoins);
      expect(farm.claimOffer(later), isFalse, reason: 'already taken');
      expect(farm.rollOffer(later, random: _Lucky()), isFalse);
    });

    test('cosmetics are bought with coins and put to use', () {
      final tree = cosmeticById('tree');
      final winter = cosmeticById('winter');
      final crown = cosmeticById('crown');
      final farm = FarmState(coins: 5000);
      expect(farm.theme, springTheme);
      expect(farm.owns(springTheme), isTrue);
      expect(farm.buyCosmetic(crown), isFalse, reason: 'too dear');
      expect(farm.buyCosmetic(tree), isTrue);
      expect(farm.buyCosmetic(tree), isFalse, reason: 'owned');
      expect(farm.decorations, [tree]);
      expect(farm.buyCosmetic(winter), isTrue);
      expect(farm.theme, winter);
      farm.useCosmetic(springTheme);
      expect(farm.theme, springTheme);
      farm.coins = 1 << 20;
      farm.buyCosmetic(crown);
      expect(farm.hat, crown);
      farm.useCosmetic(crown);
      expect(farm.hat, isNull, reason: 'taken off');
      expect(farm.coins, (1 << 20) - crown.price);
    });

    test('a save from before animals and the league still loads', () {
      final old = FarmState(level: 3, coins: 70).toJson()
        ..removeWhere(
          (key, _) => !{
            'coins',
            'xp',
            'level',
            'plots',
            'barn',
            'tools',
            'orders',
            'bonusDay',
          }.contains(key),
        );
      final farm = FarmState.fromJson(old);
      expect(farm.animals, isEmpty);
      expect(farm.weekStart, isNull);
      expect(farm.rollWeek(now), isNull, reason: 'the first week starts');
      expect(farm.leagueRank(now), greaterThan(0));
    });
  });

  group('Village league', () {
    final monday = DateTime(2026, 10, 26);

    test('every week has nine different neighbours', () {
      final names = FarmLeague.namesFor(monday);
      expect(names.toSet(), hasLength(FarmLeague.paces.length));
      expect(names, FarmLeague.namesFor(monday), reason: 'same all week');
      expect(FarmLeague.namesFor(monday.add(FarmLeague.week)), isNot(names));
    });

    test('the top three go up a tier and the bottom three down', () {
      expect(FarmLeague.tierAfter(LeagueTier.wood, 1), LeagueTier.copper);
      expect(FarmLeague.tierAfter(LeagueTier.wood, 10), LeagueTier.wood);
      expect(FarmLeague.tierAfter(LeagueTier.iron, 5), LeagueTier.iron);
      expect(FarmLeague.tierAfter(LeagueTier.iron, 8), LeagueTier.copper);
      expect(FarmLeague.tierAfter(LeagueTier.diamond, 1), LeagueTier.diamond);
      expect(
        FarmLeague.reward(1, 5, LeagueTier.gold),
        4 * FarmLeague.reward(1, 5),
      );
    });

    test('neighbours keep playing while the player is away', () {
      final farm = FarmState(level: 5)
        ..rollWeek(monday.add(const Duration(hours: 9)));
      expect(farm.weekStart, monday);
      var last = List.of(farm.rivalScores);
      for (var hour = 1; hour <= 72; hour++) {
        farm.standings(monday.add(Duration(hours: hour)));
        for (var i = 0; i < last.length; i++) {
          expect(farm.rivalScores[i], greaterThanOrEqualTo(last[i]));
        }
        last = List.of(farm.rivalScores);
      }
      expect(farm.leagueRank(monday.add(const Duration(days: 3))), 10);
    });

    test('earning experience climbs the table', () {
      final farm = FarmState(level: 5)..rollWeek(monday);
      final noon = monday.add(const Duration(hours: 36));
      final rank = farm.leagueRank(noon);
      farm.addXp(400);
      expect(farm.leagueRank(noon), lessThan(rank));
      expect(farm.standings(noon).first.isPlayer, isTrue);
    });

    test('the end of the week pays for the rank and starts over', () {
      final farm = FarmState(level: 5)..rollWeek(monday);
      farm
        ..addXp(5000)
        ..level = 5;
      final coins = farm.coins;
      expect(farm.rollWeek(monday.add(const Duration(days: 6))), isNull);
      final result = farm.rollWeek(monday.add(const Duration(days: 8)));
      expect(result!.rank, 1);
      expect(result.reward, FarmLeague.reward(1, 5));
      expect(result.from, LeagueTier.wood);
      expect(result.to, LeagueTier.copper);
      expect(farm.tier, LeagueTier.copper);
      expect(farm.coins, coins + result.reward);
      expect(farm.trophies, 1);
      expect(farm.weekStart, monday.add(const Duration(days: 7)));
      expect(farm.weekScore, 0);
      expect(farm.rivalScores.every((s) => s == 0), isTrue);
    });

    test('a steady player can win only by playing a lot', () {
      int finish(int perHour) {
        final farm = FarmState(level: 5)..rollWeek(monday);
        for (var hour = 1; hour <= 7 * 24; hour++) {
          farm.standings(monday.add(Duration(hours: hour)));
          if (hour % 24 >= 9) farm.addXp(perHour);
        }
        return farm.leagueRank(monday.add(FarmLeague.week));
      }

      expect(finish(0), 10);
      expect(finish(6), inInclusiveRange(3, 7));
      expect(finish(20), 1);
    });
  });
}

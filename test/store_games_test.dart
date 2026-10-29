import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/games/farm/farm_catalog.dart';
import 'package:ledective/apps/games/farm/farm_league.dart';
import 'package:ledective/apps/games/farm/farm_state.dart';
import 'package:ledective/apps/games/space_runner/space_run.dart';

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

void main() {
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
      final farm = FarmState()..addXp(10);
      expect(farm.level, 2);
      expect(farm.xp, 0);
      expect(farm.coins, FarmState.startCoins + FarmState.levelReward(2));
      expect(farm.unlockedCrops, contains(carrot));
      farm.addXp(1000);
      expect(farm.level, greaterThan(5));
      expect(farm.xp, lessThan(farm.xpToNextLevel));
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
      final farm = FarmState(level: 6)..fillOrders(random: Random(1));
      expect(farm.orders, hasLength(FarmState.orderSlots));
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
      final farm = FarmState(level: 4, coins: 500)
        ..rollWeek(now)
        ..buyAnimal(animalById('chicken'))
        ..barn['wheat'] = 1
        ..feed(0, now)
        ..addXp(3)
        ..standings(now.add(const Duration(hours: 5)))
        ..plant(1, carrot, now)
        ..barn['corn'] = 3
        ..buyTool(_tool('watering-can'))
        ..fillOrders(random: Random(4))
        ..claimDailyBonus(now);
      final copy = FarmState.fromJson(farm.toJson());
      expect(copy.toJson(), farm.toJson());
      expect(copy.plots[1].readyAt, farm.plots[1].readyAt);
      expect(copy.has(ToolEffect.faster), isTrue);
      copy.barn['corn'] = 4;
      expect(farm.barn['corn'], 3, reason: 'the copy has its own barn');
      expect(copy.animals.single.readyAt, farm.animals.single.readyAt);
      expect(copy.rivalScores, farm.rivalScores);
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

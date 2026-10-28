import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/games/farm/farm_catalog.dart';
import 'package:ledective/apps/games/farm/farm_state.dart';
import 'package:ledective/apps/games/space_runner/space_run.dart';
import 'package:ledective/apps/games/word_hunt/word_hunt_round.dart';

FarmTool _tool(String id) => farmTools.firstWhere((t) => t.id == id);

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

  group('WordHuntRound', () {
    test('the word list is clean', () {
      expect(turkishWords.length, greaterThan(900));
      for (final word in turkishWords) {
        expect(
          word,
          matches(RegExp(r'^[abcçdefgğhıijklmnoöprsştuüvyz]{3,8}$')),
        );
      }
    });

    test('every root hides enough words, itself included', () {
      expect(WordHuntRound.roots.length, greaterThan(40));
      for (final root in WordHuntRound.roots) {
        final answers = WordHuntRound.answersFor(root);
        expect(answers, contains(root));
        expect(answers.length, greaterThanOrEqualTo(WordHuntRound.minAnswers));
      }
    });

    test('answers only use the root letters, each as often as it has them', () {
      final answers = WordHuntRound.answersFor('karton');
      expect(answers, containsAll(['karton', 'kart', 'kar', 'ortak']));
      expect(answers, isNot(contains('tarak')), reason: 'karton has one a');
      expect(answers, isNot(contains('kitap')));
    });

    test('submitting scores new words only', () {
      final round = WordHuntRound('karton', random: Random(1));
      expect(round.letters..sort(), 'karton'.split('')..sort());
      expect(round.submit('ka'), WordCheck.tooShort);
      expect(round.submit('kotna'), WordCheck.notAWord);
      expect(round.submit('kart'), WordCheck.accepted);
      expect(round.submit('kart'), WordCheck.alreadyFound);
      expect(round.submit('karton'), WordCheck.accepted);
      expect(round.score, 60 + 150);
      expect(round.longest, 'karton');
      expect(round.missed, isNot(contains('kart')));
    });

    test('random rounds use the roots', () {
      final round = WordHuntRound.random(random: Random(3));
      expect(WordHuntRound.roots, contains(round.root));
    });

    test('Turkish capitals keep the dots right', () {
      expect(turkishUpper('kılıç işi'), 'KILIÇ İŞİ');
      expect(turkishLower('KILIÇ İŞİ'), 'kılıç işi');
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

    test('the daily bonus comes once a day', () {
      final farm = FarmState();
      expect(farm.claimDailyBonus(now), 30);
      expect(farm.claimDailyBonus(now.add(const Duration(hours: 5))), isNull);
      expect(farm.claimDailyBonus(now.add(const Duration(days: 1))), 30);
    });

    test('survives a JSON round trip', () {
      final farm = FarmState(level: 4, coins: 500)
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
    });
  });
}

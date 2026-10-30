import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/appshop/store_catalog.dart';
import 'package:ledective/apps/store_apps/cipher/cipher_app.dart';
import 'package:ledective/apps/store_apps/cipher/ciphers.dart';
import 'package:ledective/apps/store_apps/pro_calculator/expression.dart';
import 'package:ledective/apps/store_apps/pro_calculator/pro_calculator_app.dart';
import 'package:ledective/apps/store_apps/unit_converter/unit_converter_app.dart';
import 'package:ledective/apps/store_apps/unit_converter/units.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Hesap Makinesi Pro', () {
    test('works out sums the way they are written', () {
      expect(evaluate('2+3×4'), 14);
      expect(evaluate('(2+3)×4'), 20);
      expect(evaluate('10÷4'), 2.5);
      expect(evaluate('2^3^2'), 512);
      expect(evaluate('−3^2'), -9);
      expect(evaluate('√16+1'), 5);
      expect(evaluate('50%'), 0.5);
      expect(evaluate('5!'), 120);
      expect(evaluate('3,5×2'), 7);
      expect(evaluate('2π'), closeTo(2 * pi, 1e-12));
      expect(evaluate('2(3+1'), 8, reason: 'an open bracket closes itself');
    });

    test('knows its functions, in degrees or radians', () {
      expect(evaluate('sin(30)'), closeTo(0.5, 1e-12));
      expect(evaluate('cos(180)'), -1);
      expect(evaluate('sin(π)', radians: true), 0);
      expect(evaluate('log(1000)'), closeTo(3, 1e-12));
      expect(evaluate('ln(e)'), 1);
    });

    test('says when something cannot be worked out', () {
      expect(() => evaluate('2+'), throwsFormatException);
      expect(() => evaluate('(−1)!'), throwsFormatException);
      expect(() => evaluate('3)'), throwsFormatException);
      expect(formatResult(1 / 0), "Hata");
    });

    test('shows results with a comma and no stray zeros', () {
      expect(formatResult(14), "14");
      expect(formatResult(2.5), "2,5");
      expect(formatResult(1 / 3), "0,3333333333");
      expect(formatResult(1e20), "1e+20");
    });
  });

  group('Birim Çevirici', () {
    double convert(Quantity q, String from, String to, double value) =>
        q.convert(
          value,
          q.units.firstWhere((u) => u.symbol == from),
          q.units.firstWhere((u) => u.symbol == to),
        );

    test('converts between units of a kind', () {
      expect(convert(Quantity.length, "km", "m", 2), 2000);
      expect(convert(Quantity.length, "in", "cm", 1), closeTo(2.54, 1e-9));
      expect(convert(Quantity.weight, "lb", "kg", 1), closeTo(0.4536, 1e-4));
      expect(convert(Quantity.speed, "km/sa", "m/s", 36), closeTo(10, 1e-9));
      expect(convert(Quantity.area, "dönüm", "m²", 3), 3000);
    });

    test('gets temperatures right, offsets and all', () {
      expect(
        convert(Quantity.temperature, "°C", "°F", 100),
        closeTo(212, 1e-9),
      );
      expect(convert(Quantity.temperature, "°F", "°C", 32), closeTo(0, 1e-9));
      expect(convert(Quantity.temperature, "°C", "K", 0), 273.15);
    });

    testWidgets('shows a value in another unit', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: UnitConverterApp()));
      await tester.enterText(find.byKey(const ValueKey('unit-input')), '3');
      await tester.pump();
      Text result() =>
          tester.widget<Text>(find.byKey(const ValueKey('unit-result')));
      expect(result().data, '3000 m');
      await tester.tap(find.byKey(const ValueKey('swap-units')));
      await tester.pump();
      expect(result().data, '0,003 km');
    });
  });

  group('Şifre Çözücü', () {
    test('Sezar moves letters along the Turkish alphabet and back', () {
      expect(caesar('abc', 1), 'BCÇ');
      expect(caesar('Zehir', 3), 'CĞJLT');
      expect(caesar(caesar('Gizli mesaj!', 7), -7), 'GİZLİ MESAJ!');
    });

    test('Atbaş and reversing undo themselves', () {
      expect(atbash('A'), 'Z');
      expect(atbash(atbash('Kasa şifresi')), 'KASA ŞİFRESİ');
      expect(reverse('ilac'), 'cali');
    });

    test('Morse is written and read', () {
      expect(toMorse('SOS'), '... --- ...');
      expect(toMorse('iz ara'), '.-..- --.. / .- .-. .-');
      expect(fromMorse('... --- ...'), 'SOS');
      expect(apply(Cipher.morse, '... --- ...'), 'SOS');
      expect(apply(Cipher.morse, 'Şüphe'), toMorse('ŞÜPHE'));
    });

    testWidgets('tries every shift of a Sezar message', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CipherApp()));
      await tester.enterText(
        find.byKey(const ValueKey('cipher-input')),
        caesar('KATİL', 5),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('all-shifts')));
      await tester.pumpAndSettle();
      expect(find.text('KATİL'), findsOneWidget);
    });
  });

  test('every store item can be found, and the best are put forward', () {
    final ids = storeItems.map((item) => item.id).toSet();
    expect(ids, hasLength(storeItems.length));
    final apps = storeItems.where((item) => item.kind == StoreKind.app);
    expect(apps, hasLength(3));
    expect(apps.every((app) => app.isAvailable), isTrue);
    final picks = storeItems.where((item) => item.isFeatured).map((i) => i.id);
    expect(picks, containsAll(['castle-guard', 'farm']));
  });

  testWidgets('the calculator keeps its history', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ProCalculatorApp()));
    for (final key in ['7', '×', '6', '=']) {
      await tester.tap(find.byKey(ValueKey('key-$key')));
      await tester.pump();
    }
    expect(find.text('42'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ProCalculatorApp.historyKey), contains('7×6 = 42'));
    // An operator carries on from the answer; a digit starts afresh.
    await tester.tap(find.byKey(const ValueKey('key-+')));
    await tester.tap(find.byKey(const ValueKey('key-1')));
    await tester.pump();
    expect(find.text('42+1'), findsOneWidget);
  });
}

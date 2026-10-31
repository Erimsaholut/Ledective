import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/appshop/store_catalog.dart';
import 'package:ledective/data/game_state.dart';
import 'package:ledective/home/app_icon.dart';
import 'package:ledective/home/start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On a real phone the system's own home bar sits over the game's, so every
/// app needs a button of its own to get back out.
void main() {
  final apps = <AppIcon>[
    ...homeIcons,
    for (final item in storeItems)
      if (item.isAvailable) item.homeIcon,
  ];
  for (final app in apps) {
    testWidgets('${app.title} has a way out', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      await tester.runAsync(loadGameState);
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const Scaffold()),
      );
      final opened = navigator.currentState!.push(app.route());
      // Let apps that load their saves get to their first screen.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // A welcome or daily-gift dialog closes first.
      while (find.byType(Dialog).evaluate().isNotEmpty) {
        navigator.currentState!.pop();
        await tester.pump(const Duration(seconds: 1));
      }
      final back = find.byWidgetPredicate(
        (w) =>
            w is BackButton ||
            w is CloseButton ||
            (w is Tooltip && const ['Back', 'Close'].contains(w.message)),
      );
      expect(back.hitTestable(), findsWidgets);
      await tester.tap(back.hitTestable().first);
      await tester.pump(const Duration(seconds: 1));
      await expectLater(opened, completes);
    });
  }
}

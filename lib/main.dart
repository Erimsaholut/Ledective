import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'apps/games/farm/farm_reminder.dart';
import 'data/game_state.dart';
import 'home/alert_banner.dart';
import 'home/epilogue_page.dart';
import 'home/home_indicator.dart';
import 'home/start_screen.dart';
import 'story/story_progress.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Draw edge to edge so the wallpaper runs under the status bar.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await loadGameState();
  StoryProgress.instance.paceMessages = true;
  // Officers come back, timers run and the farm calls whichever app is
  // open.
  Timer.periodic(const Duration(seconds: 2), (_) {
    StoryProgress.instance.tick();
    FarmReminder.tick(StoryProgress.instance.alerts);
  });
  runApp(const LedectiveApp());
}

class LedectiveApp extends StatefulWidget {
  const LedectiveApp({super.key});

  @override
  State<LedectiveApp> createState() => _LedectiveAppState();
}

class _LedectiveAppState extends State<LedectiveApp> {
  final RouteDepthObserver _routes = RouteDepthObserver();
  final GlobalKey<NavigatorState> _navigator = GlobalKey();
  final StoryProgress _progress = StoryProgress.instance;

  @override
  void initState() {
    super.initState();
    _progress.addListener(_showEnding);
  }

  @override
  void dispose() {
    _progress.removeListener(_showEnding);
    super.dispose();
  }

  /// Plays the epilogue once, as soon as the story is over.
  void _showEnding() {
    if (!_progress.isOver || _progress.hasSeen('ending')) return;
    _progress.markSeen('ending');
    _navigator.currentState?.push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const EpiloguePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledective',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Let a mouse swipe between pages too, as a finger would.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      navigatorKey: _navigator,
      navigatorObservers: [_routes],
      builder: (context, child) => Stack(
        children: [
          HomeIndicator(observer: _routes, child: child!),
          Positioned.fill(
            child: AlertBanner(
              alerts: StoryProgress.instance.alerts,
              onOpen: (alert) {
                final navigator = _navigator.currentState;
                if (navigator != null) openAlert(navigator, alert);
              },
            ),
          ),
        ],
      ),
      home: const StartScreen(),
    );
  }
}

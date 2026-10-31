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
  StoryProgress.instance.alerts.spacing = const Duration(milliseconds: 1800);
  // Officers come back, timers run and the farm calls whichever app is
  // open.
  Timer.periodic(const Duration(seconds: 2), (_) {
    StoryProgress.instance.tick();
    StoryProgress.instance.alerts.release();
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
    if (!_progress.isOver || _progress.hasSeen('ending') || _endingQueued) {
      return;
    }
    // The change may come in the middle of a build, where pushing a route
    // fails, so the epilogue waits for the end of the frame.
    _endingQueued = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        _endingQueued = false;
        final navigator = _navigator.currentState;
        if (navigator == null || _progress.hasSeen('ending')) return;
        _progress.markSeen('ending');
        navigator.push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => const EpiloguePage(),
          ),
        );
      })
      ..scheduleFrame();
  }

  bool _endingQueued = false;

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
          // A tap anywhere but on a text field puts the keyboard away.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: HomeIndicator(observer: _routes, child: child!),
          ),
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

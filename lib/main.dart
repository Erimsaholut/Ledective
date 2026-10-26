import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/game_state.dart';
import 'home/alert_banner.dart';
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
  // Officers come back from missions whichever app is open.
  Timer.periodic(
    const Duration(seconds: 2),
    (_) => StoryProgress.instance.completeDueMissions(),
  );
  runApp(const LedectiveApp());
}

class LedectiveApp extends StatefulWidget {
  const LedectiveApp({super.key});

  @override
  State<LedectiveApp> createState() => _LedectiveAppState();
}

class _LedectiveAppState extends State<LedectiveApp> {
  final RouteDepthObserver _routes = RouteDepthObserver();

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
      navigatorObservers: [_routes],
      builder: (context, child) => Stack(
        children: [
          HomeIndicator(observer: _routes, child: child!),
          Align(
            alignment: Alignment.topCenter,
            child: AlertBanner(alerts: StoryProgress.instance.alerts),
          ),
        ],
      ),
      home: const StartScreen(),
    );
  }
}

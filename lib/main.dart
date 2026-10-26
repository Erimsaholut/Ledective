import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/game_state.dart';
import 'home/start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await loadGameState();
  runApp(const LedectiveApp());
}

class LedectiveApp extends StatelessWidget {
  const LedectiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledective',
      debugShowCheckedModeBanner: false,
      // The game's screens were designed for Material 2.
      theme: ThemeData(useMaterial3: false),
      home: const StartScreen(),
    );
  }
}

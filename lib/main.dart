import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'StartScreen.dart';

void main() {
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  runApp(const StartScreen());
}

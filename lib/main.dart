import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ledective/apps/appShop_app/appShop.dart';
import 'package:ledective/apps/photos_app/photos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StartScreen.dart';
import 'apps/calendar_app/calendar.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appOpened();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  runApp(const  MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const StartScreen(),
      routes: {
        "/photosApp":(context) => const PhotosApp(),
        "/appShop":(context) => const AppShop(),
        "/calendarApp":(context) => const CalendarApp(),
      },
    );
  }
}





//todo uygulama çıkmadan önce bunu bi sıfırlaman lazım
Future<void> appOpened() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? firstOpen = prefs.getInt('isOpenedBefore');

  if (firstOpen == null) {
    print('first time open');
    await prefs.setInt('isOpenedBefore', 1);
    print(firstOpen);

    final DateTime now = DateTime.now();
    await prefs.setInt('firstOpenDay', now.day);
    await prefs.setInt('firstOpenMonth', now.month);
    await prefs.setInt('firstOpenYear', now.year);
    await prefs.setInt('section', 0);
  }
}
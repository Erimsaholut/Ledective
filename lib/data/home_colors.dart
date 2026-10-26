import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

/// Background colors of the two home screen pages, chosen in Settings.
class HomeColors {
  HomeColors._();

  static const _page1Key = 'homePage1Color';
  static const _page2Key = 'homePage2Color';

  static final page1 = ValueNotifier<Color>(kStartScreenPage1Color);
  static final page2 = ValueNotifier<Color>(kStartScreenPage2Color);

  static void load(SharedPreferences prefs) {
    final page1Value = prefs.getInt(_page1Key);
    final page2Value = prefs.getInt(_page2Key);
    page1.value = page1Value == null
        ? kStartScreenPage1Color
        : Color(page1Value);
    page2.value = page2Value == null
        ? kStartScreenPage2Color
        : Color(page2Value);
  }

  static Future<void> setPage1(Color color) async {
    page1.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_page1Key, color.toARGB32());
  }

  static Future<void> setPage2(Color color) async {
    page2.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_page2Key, color.toARGB32());
  }
}

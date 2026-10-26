import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Colours shared by the phone's apps, modelled on iOS system colours.
abstract final class AppColors {
  static const background = Color(0xFFF2F2F7);
  static const surface = Colors.white;
  static const label = Color(0xFF1C1C1E);
  static const secondaryLabel = Color(0xFF8E8E93);
  static const separator = Color(0xFFD1D1D6);

  static const blue = Color(0xFF0A84FF);
  static const green = Color(0xFF34C759);
  static const red = Color(0xFFFF3B30);
  static const orange = Color(0xFFFF9500);
  static const yellow = Color(0xFFFFCC00);
  static const purple = Color(0xFFAF52DE);
  static const pink = Color(0xFFFF2D55);
  static const teal = Color(0xFF30B0C7);
  static const indigo = Color(0xFF5856D6);
  static const grey = Color(0xFF8E8E93);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    primary: AppColors.blue,
    surface: AppColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    // App bar titles: small ones use titleLarge, the expanded large ones
    // (SliverAppBar.large) use headlineMedium, like iOS navigation bars.
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.label,
      ),
      headlineMedium: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.label,
        letterSpacing: -0.5,
      ),
    ),
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.label,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.separator,
      thickness: 0.5,
      space: 0.5,
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: AppColors.surface,
      iconColor: AppColors.secondaryLabel,
      subtitleTextStyle: TextStyle(
        color: AppColors.secondaryLabel,
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFE3E3E8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: AppColors.blue,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A home screen wallpaper: a soft gradient with two glows for depth.
class Wallpaper {
  const Wallpaper(this.name, this.colors, this.glow);

  final String name;

  /// Gradient from the top-left to the bottom-right corner.
  final List<Color> colors;
  final Color glow;
}

const List<Wallpaper> wallpapers = [
  Wallpaper('Gece', [
    Color(0xFF0B1A3A),
    Color(0xFF1F3B73),
    Color(0xFF3A2A6B),
  ], Color(0xFF4F8DFF)),
  Wallpaper('Okyanus', [
    Color(0xFF003B5C),
    Color(0xFF00708F),
    Color(0xFF14B8A6),
  ], Color(0xFF5EEAD4)),
  Wallpaper('Gün Batımı', [
    Color(0xFF3B0A45),
    Color(0xFFB2245A),
    Color(0xFFFF8A3D),
  ], Color(0xFFFFB86B)),
  Wallpaper('Orman', [
    Color(0xFF0B2B26),
    Color(0xFF1E5A43),
    Color(0xFF6FA86A),
  ], Color(0xFFB7E4A0)),
  Wallpaper('Grafit', [
    Color(0xFF16181D),
    Color(0xFF2B2F38),
    Color(0xFF4A505C),
  ], Color(0xFF9AA4B5)),
  Wallpaper('Lavanta', [
    Color(0xFF2E1A47),
    Color(0xFF6B4C9A),
    Color(0xFFC59BD6),
  ], Color(0xFFF0C6FF)),
];

/// The wallpaper chosen in Settings.
class WallpaperSetting {
  WallpaperSetting._();

  static const _prefsKey = 'wallpaper';

  static final current = ValueNotifier<Wallpaper>(wallpapers.first);

  static void load(SharedPreferences prefs) {
    final index = prefs.getInt(_prefsKey) ?? 0;
    current.value = wallpapers[index.clamp(0, wallpapers.length - 1)];
  }

  static Future<void> set(Wallpaper wallpaper) async {
    current.value = wallpaper;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, wallpapers.indexOf(wallpaper));
  }
}

/// Paints [wallpaper] to fill its parent.
class WallpaperView extends StatelessWidget {
  const WallpaperView({super.key, required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: wallpaper.colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _glow(const Alignment(-0.9, -0.55), 1.1, 0.45),
          _glow(const Alignment(1.0, 0.7), 0.9, 0.3),
        ],
      ),
    );
  }

  Widget _glow(Alignment center, double radius, double opacity) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [
            wallpaper.glow.withValues(alpha: opacity),
            wallpaper.glow.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

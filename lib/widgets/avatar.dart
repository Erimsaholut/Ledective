import 'package:flutter/material.dart';

/// A round avatar with the person's initials on a colour picked from their
/// name, so the same person always gets the same colour.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.name, this.radius = 22, this.icon});

  final String name;
  final double radius;

  /// Shown instead of initials, e.g. for companies.
  final IconData? icon;

  static const _palettes = [
    [Color(0xFF5AC8FA), Color(0xFF007AFF)],
    [Color(0xFFFF9F0A), Color(0xFFFF6B00)],
    [Color(0xFF30D158), Color(0xFF248A3D)],
    [Color(0xFFBF5AF2), Color(0xFF8944AB)],
    [Color(0xFFFF6482), Color(0xFFD70040)],
    [Color(0xFF64D2FF), Color(0xFF0071A4)],
    [Color(0xFFFFD60A), Color(0xFFC9A400)],
    [Color(0xFFAC8E68), Color(0xFF7F6545)],
  ];

  static String initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final hash = name.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    final colors = _palettes[hash % _palettes.length];
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: icon != null
          ? Icon(icon, color: Colors.white, size: radius)
          : Text(
              initials(name),
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

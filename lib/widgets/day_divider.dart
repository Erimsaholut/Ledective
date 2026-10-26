import 'package:flutter/material.dart';

import '../data/game_clock.dart';

class DayDivider extends StatelessWidget {
  const DayDivider({super.key, this.label, this.daysAgo = 0});

  final String? label;

  /// Days before the game was first opened.
  final int daysAgo;

  static String describe(int daysAgo, GameClock clock, [DateTime? now]) {
    final days = clock.daysSinceFirstOpen(now) + daysAgo;
    return days == 0 ? 'Bugün' : '$days gün önce';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: Text(
          label ?? describe(daysAgo, GameClock.current),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

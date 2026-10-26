import 'package:flutter/material.dart';

import '../data/game_clock.dart';

/// A date pill between chat messages.
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 1),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              label ?? describe(daysAgo, GameClock.current),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF54656F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

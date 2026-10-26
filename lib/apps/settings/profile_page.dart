import 'package:flutter/material.dart';

import '../../story/dialogue.dart';
import '../../story/story_progress.dart';

/// The detective's personality so far ("Gezici tablo"), built from the
/// player's choices in conversations.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _colors = {
    Trait.anger: Colors.red,
    Trait.mercy: Colors.lightBlue,
    Trait.curiosity: Colors.orange,
    Trait.courage: Colors.green,
    Trait.indifference: Colors.blueGrey,
    Trait.caution: Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    final points = {for (final t in Trait.values) t: progress.trait(t)};
    final max = points.values.fold(0, (a, b) => a > b ? a : b);
    final strongest = points.entries.where((e) => e.value == max && max > 0);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detective Profile"),
        backgroundColor: Colors.grey.shade700,
      ),
      backgroundColor: Colors.grey.shade300,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            strongest.isEmpty
                ? "Henüz bir karar vermedin."
                : "Öne çıkan yönün: ${strongest.map((e) => e.key.label).join(", ")}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          for (final trait in Trait.values) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trait.label, style: const TextStyle(fontSize: 16)),
                Text("${points[trait]}"),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: max == 0 ? 0 : points[trait]! / max,
              minHeight: 10,
              color: _colors[trait],
              backgroundColor: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

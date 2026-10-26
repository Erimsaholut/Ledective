import 'package:flutter/material.dart';

import '../../story/dialogue.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/grouped_list.dart';

/// The detective's personality so far ("Gezici tablo"), built from the
/// player's choices in conversations.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _colors = {
    Trait.anger: AppColors.red,
    Trait.mercy: AppColors.teal,
    Trait.curiosity: AppColors.orange,
    Trait.courage: AppColors.green,
    Trait.indifference: AppColors.grey,
    Trait.caution: AppColors.purple,
  };

  static const _icons = {
    Trait.anger: Icons.local_fire_department_rounded,
    Trait.mercy: Icons.favorite_rounded,
    Trait.curiosity: Icons.search_rounded,
    Trait.courage: Icons.shield_rounded,
    Trait.indifference: Icons.do_not_disturb_on_rounded,
    Trait.caution: Icons.visibility_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    final points = {for (final t in Trait.values) t: progress.trait(t)};
    final max = points.values.fold(0, (a, b) => a > b ? a : b);
    final strongest = [
      for (final e in points.entries)
        if (e.value == max && max > 0) e.key.label,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("Detective Profile")),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Center(child: Avatar(name: "Komiser", radius: 44)),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              "Komiser",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              strongest.isEmpty
                  ? "Henüz bir karar vermedin."
                  : "Öne çıkan yönün: ${strongest.join(", ")}",
              style: const TextStyle(color: AppColors.secondaryLabel),
            ),
          ),
          const SizedBox(height: 16),
          GroupedSection(
            header: "Kişilik",
            footer: "Sohbetlerdeki seçimlerin dedektifin kişiliğini belirler.",
            dividerIndent: 60,
            children: [
              for (final trait in Trait.values)
                ListTile(
                  leading: TileIcon(_icons[trait]!, color: _colors[trait]!),
                  title: Text(trait.label),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: max == 0 ? 0 : points[trait]! / max,
                      minHeight: 6,
                      color: _colors[trait],
                      backgroundColor: AppColors.background,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  trailing: Text(
                    "${points[trait]}",
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

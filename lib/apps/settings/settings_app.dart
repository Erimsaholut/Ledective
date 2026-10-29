import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/game_state.dart';
import '../../data/wallpaper.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/grouped_list.dart';
import 'profile_page.dart';
import 'story_state_page.dart';

class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _resetProgress(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Reset Game Progress"),
        content: const Text(
          "Messages, mails, photos, notes and contacts will start over.",
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await resetGameState();
    if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    const chevron = Icon(
      CupertinoIcons.chevron_forward,
      size: 18,
      color: AppColors.separator,
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text("Settings")),
          SliverList.list(
            children: [
              GroupedSection(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: const Avatar(name: "Komiser", radius: 28),
                    title: const Text(
                      "Komiser",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text("Ledective Kimliği, Dedektif Profili"),
                    trailing: chevron,
                    onTap: () => _push(context, const ProfilePage()),
                  ),
                ],
              ),
              GroupedSection(
                dividerIndent: 60,
                children: [
                  ListTile(
                    leading: const TileIcon(
                      Icons.wallpaper_rounded,
                      color: AppColors.teal,
                    ),
                    title: const Text("Wallpaper"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<Wallpaper>(
                          valueListenable: WallpaperSetting.current,
                          builder: (context, wallpaper, _) => Text(
                            wallpaper.name,
                            style: const TextStyle(
                              color: AppColors.secondaryLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        chevron,
                      ],
                    ),
                    onTap: () => _push(context, const _WallpaperPage()),
                  ),
                  ListTile(
                    leading: const TileIcon(
                      Icons.psychology_rounded,
                      color: AppColors.purple,
                    ),
                    title: const Text("Detective Profile"),
                    trailing: chevron,
                    onTap: () => _push(context, const ProfilePage()),
                  ),
                  ListenableBuilder(
                    listenable: StoryProgress.instance,
                    builder: (context, _) => SwitchListTile.adaptive(
                      secondary: const TileIcon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.orange,
                      ),
                      title: const Text("İpucu bildirimleri"),
                      value: StoryProgress.instance.hintsOn,
                      onChanged: StoryProgress.instance.setHints,
                    ),
                  ),
                  ListTile(
                    leading: const TileIcon(
                      Icons.info_outline_rounded,
                      color: AppColors.grey,
                    ),
                    title: const Text("About"),
                    trailing: chevron,
                    onTap: () => _push(context, const _AboutPage()),
                  ),
                ],
              ),
              GroupedSection(
                header: "Hikâye yazarı",
                footer:
                    "Hızlı görevler, harita görevlerini ve süreli olayları "
                    "30 kat hızlı bitirir.",
                children: [
                  ListenableBuilder(
                    listenable: StoryProgress.instance,
                    builder: (context, _) => SwitchListTile.adaptive(
                      title: const Text("Hızlı görevler"),
                      value: StoryProgress.instance.fastMissions,
                      onChanged: StoryProgress.instance.setFastMissions,
                    ),
                  ),
                  ListTile(
                    title: const Text("Hikâye durumu"),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _push(context, const StoryStatePage()),
                  ),
                ],
              ),
              GroupedSection(
                footer: "Starts the story from the beginning.",
                children: [
                  ListTile(
                    title: const Text(
                      "Reset Game Progress",
                      style: TextStyle(color: AppColors.red),
                    ),
                    onTap: () => _resetProgress(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WallpaperPage extends StatelessWidget {
  const _WallpaperPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wallpaper")),
      body: ValueListenableBuilder<Wallpaper>(
        valueListenable: WallpaperSetting.current,
        builder: (context, current, _) => GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.5,
          children: [
            for (final wallpaper in wallpapers)
              GestureDetector(
                onTap: () => WallpaperSetting.set(wallpaper),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: wallpaper == current
                                ? AppColors.blue
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: WallpaperView(wallpaper: wallpaper),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      wallpaper.name,
                      style: TextStyle(
                        fontWeight: wallpaper == current
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    Widget row(String title, String value) => ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(color: AppColors.secondaryLabel, fontSize: 16),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: ListView(
        children: [
          GroupedSection(
            children: [
              row("Name", "Komiserin Telefonu"),
              row("Software Version", "Ledective 1.0"),
              row("Model", "LDX Pro"),
              row("Carrier", "LedTel"),
            ],
          ),
        ],
      ),
    );
  }
}

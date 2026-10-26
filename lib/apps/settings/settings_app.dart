import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../data/home_colors.dart';
import '../../data/game_state.dart';
import 'profile_page.dart';

class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  Future<void> _pickColor(
    BuildContext context,
    ValueNotifier<Color> current,
    Future<void> Function(Color) save,
  ) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Choose a color"),
        contentPadding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final swatch in kHomeBackgroundSwatches)
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context, swatch),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: swatch,
                    child: swatch.toARGB32() == current.value.toARGB32()
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
    if (color != null) await save(color);
  }

  Future<void> _resetProgress(BuildContext context) async {
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("Reset Game Progress"),
        content: const Text(
          "Messages, mails, photos, notes and contacts will start over.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
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
    final themeColor = Colors.grey.shade500;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: themeColor,
      ),
      backgroundColor: themeColor,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        children: [
          _SettingsTile(
            name: "Main Screen Background Color",
            color: HomeColors.page1,
            onPressed: () =>
                _pickColor(context, HomeColors.page1, HomeColors.setPage1),
          ),
          _SettingsTile(
            name: "Second Screen Background Color",
            color: HomeColors.page2,
            onPressed: () =>
                _pickColor(context, HomeColors.page2, HomeColors.setPage2),
          ),
          _SettingsTile(
            name: "Detective Profile",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
            ),
          ),
          _SettingsTile(
            name: "Reset Game Progress",
            onPressed: () => _resetProgress(context),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.name, this.color, this.onPressed});

  final String name;
  final ValueNotifier<Color>? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 3.0),
          borderRadius: BorderRadius.circular(6.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (color != null)
                    ValueListenableBuilder<Color>(
                      valueListenable: color,
                      builder: (context, value, _) =>
                          CircleAvatar(radius: 16, backgroundColor: value),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

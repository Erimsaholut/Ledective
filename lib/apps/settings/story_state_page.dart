import 'package:flutter/material.dart';

import '../../home/epilogue_page.dart';
import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/grouped_list.dart';

/// For story writers: the numbers and flags behind the story, with
/// controls to change them while testing.
class StoryStatePage extends StatelessWidget {
  const StoryStatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    final state = StoryData.current.state;
    return Scaffold(
      appBar: AppBar(title: const Text("Hikâye durumu")),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final others =
              progress.flags.where((f) => !state.flags.containsKey(f)).toList()
                ..sort();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              GroupedSection(
                header: "Sayılar",
                footer: "Oyuncu bu değerleri hiçbir zaman görmez.",
                children: [
                  for (final stat in state.stats.values)
                    ListTile(
                      title: Text(stat.label.isEmpty ? stat.name : stat.label),
                      subtitle: Text(stat.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded),
                            onPressed: () =>
                                progress.discover(['${stat.name} -= 10']),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${progress.value(stat.name)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded),
                            onPressed: () =>
                                progress.discover(['${stat.name} += 10']),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              GroupedSection(
                header: "Planlanmış bayraklar",
                children: [
                  for (final MapEntry(key: flag, value: meaning)
                      in state.flags.entries)
                    SwitchListTile.adaptive(
                      title: Text(meaning),
                      subtitle: Text(flag),
                      value: progress.has(flag),
                      onChanged: (on) =>
                          progress.discover([on ? flag : '!$flag']),
                    ),
                ],
              ),
              if (progress.runningTimers.isNotEmpty)
                GroupedSection(
                  header: "Süreli olaylar",
                  children: [
                    for (final id in progress.runningTimers)
                      ListTile(
                        title: Text(id),
                        trailing: Text(
                          "${progress.timeLeft(id)?.inMinutes ?? 0} dk kaldı",
                        ),
                      ),
                  ],
                ),
              GroupedSection(
                header: "Açık bayraklar",
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: others.isEmpty
                        ? const Text(
                            "Henüz hiçbiri",
                            style: TextStyle(color: AppColors.secondaryLabel),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final flag in others)
                                Chip(
                                  label: Text(flag),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                  ),
                ],
              ),
              if (StoryData.current.endings.sections.isNotEmpty)
                GroupedSection(
                  footer:
                      "Finalin şu anki seçimlerle nasıl biteceğini gösterir.",
                  children: [
                    ListTile(
                      title: const Text("Finali önizle"),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          fullscreenDialog: true,
                          builder: (_) => const EpiloguePage(),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

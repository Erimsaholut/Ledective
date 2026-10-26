import 'dart:async';

import 'package:flutter/material.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';

/// Reports the player hasn't read yet, for the home screen badge.
int unreadReportCount(StoryProgress progress) => progress.unreadReports;

String _countdown(Duration left) {
  final seconds = left.inSeconds < 0 ? 0 : left.inSeconds;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

/// A city map. The player sends officers to locations; they report back
/// after a while, which can turn up evidence and new places.
class MapApp extends StatefulWidget {
  const MapApp({super.key});

  @override
  State<MapApp> createState() => _MapAppState();
}

class _MapAppState extends State<MapApp> {
  final StoryProgress _progress = StoryProgress.instance;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _progress.completeDueMissions();
    // Keeps countdowns moving and brings officers back on time.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _progress.completeDueMissions();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  void _openLocation(MapLocation location) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _LocationSheet(location: location),
    );
  }

  void _openReports() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ReportsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final map = StoryData.current.map;
    return Scaffold(
      body: ListenableBuilder(
        listenable: _progress,
        builder: (context, _) {
          final locations = [
            for (final l in map.locations)
              if (_progress.meets(l.requires)) l,
          ];
          return Stack(
            children: [
              InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                constrained: false,
                child: LayoutBuilder(
                  builder: (context, _) {
                    final width = MediaQuery.sizeOf(context).width * 1.6;
                    final height = width * 4 / 3;
                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(map.image, fit: BoxFit.fill),
                          ),
                          for (final location in locations)
                            Positioned(
                              left: location.x * width - 60,
                              top: location.y * height - 52,
                              width: 120,
                              child: _Pin(
                                location: location,
                                busy: location.tasks.any(
                                  (t) => _progress.activeMission(t.id) != null,
                                ),
                                onTap: () => _openLocation(location),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _GlassButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: "Back",
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _GlassBar(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.map_rounded,
                                color: AppColors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  locations.isEmpty
                                      ? "Henüz bilinen konum yok"
                                      : "${locations.length} konum",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Badge(
                        isLabelVisible: _progress.unreadReports > 0,
                        label: Text('${_progress.unreadReports}'),
                        child: _GlassButton(
                          icon: Icons.assignment_rounded,
                          tooltip: "Reports",
                          onTap: _openReports,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    child: _OfficersBar(officers: map.officers),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlassBar extends StatelessWidget {
  const _GlassBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(14),
      elevation: 3,
      shadowColor: const Color(0x40000000),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.blue),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.location, required this.busy, required this.onTap});

  final MapLocation location;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 4),
              ],
            ),
            child: Text(
              location.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            busy ? Icons.local_police_rounded : Icons.location_on_rounded,
            size: 36,
            color: busy ? AppColors.blue : AppColors.red,
            shadows: const [Shadow(color: Color(0x66000000), blurRadius: 6)],
          ),
        ],
      ),
    );
  }
}

/// Who is free and who is out on a mission.
class _OfficersBar extends StatelessWidget {
  const _OfficersBar({required this.officers});

  final List<String> officers;

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return _GlassBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final officer in officers)
            Builder(
              builder: (context) {
                final mission = progress.missionOf(officer);
                return Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Opacity(
                          opacity: mission == null ? 1 : 0.45,
                          child: Avatar(name: officer, radius: 13),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mission == null
                              ? officer
                              : _countdown(
                                  mission.endsAt.difference(DateTime.now()),
                                ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mission == null
                                ? AppColors.label
                                : AppColors.blue,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet({required this.location});

  final MapLocation location;

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final StoryProgress _progress = StoryProgress.instance;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _send(MissionTask task) async {
    final officers = StoryData.current.map.officers;
    final officer = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                "Kimi göndereceksin?\n${task.label}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final officer in officers)
              Builder(
                builder: (context) {
                  final busy = _progress.missionOf(officer) != null;
                  return ListTile(
                    enabled: !busy,
                    leading: Opacity(
                      opacity: busy ? 0.4 : 1,
                      child: Avatar(name: officer),
                    ),
                    title: Text(officer),
                    subtitle: Text(busy ? "Görevde" : "Müsait"),
                    onTap: () => Navigator.pop(context, officer),
                  );
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (officer == null) return;
    await _progress.startMission(task, officer);
  }

  Widget _task(MissionTask task) {
    final active = _progress.activeMission(task.id);
    final done = _progress.finishedMission(task.id);
    final Widget trailing;
    final String subtitle;
    if (done != null) {
      subtitle = "${done.officer} raporladı";
      trailing = const Icon(Icons.check_circle_rounded, color: AppColors.green);
    } else if (active != null) {
      subtitle =
          "${active.officer} yolda · ${_countdown(active.endsAt.difference(DateTime.now()))}";
      trailing = const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    } else {
      final seconds = _progress.durationOf(task).inSeconds;
      subtitle = seconds < 60
          ? "Tahmini süre: $seconds sn"
          : "Tahmini süre: ${(seconds / 60).toStringAsFixed(seconds % 60 == 0 ? 0 : 1)} dk";
      trailing = FilledButton(
        onPressed: () => _send(task),
        child: const Text("Gönder"),
      );
    }
    return ListTile(
      title: Text(
        task.label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: done == null
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ReportPage(mission: done),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    return ListenableBuilder(
      listenable: _progress,
      builder: (context, _) {
        final tasks = [
          for (final t in location.tasks)
            if (_progress.meets(t.requires)) t,
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    location.description,
                    style: const TextStyle(color: AppColors.secondaryLabel),
                  ),
                ),
                const Divider(),
                for (final task in tasks) _task(task),
                if (tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Şimdilik burada yapılacak bir şey yok.",
                      style: TextStyle(color: AppColors.secondaryLabel),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Finished missions, newest first.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    final map = StoryData.current.map;
    return Scaffold(
      appBar: AppBar(title: const Text("Görev Raporları")),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final reports = progress.reports;
          final active = progress.activeMissions;
          if (reports.isEmpty && active.isEmpty) {
            return const Center(
              child: Text(
                "Henüz kimseyi göreve göndermedin.",
                style: TextStyle(color: AppColors.secondaryLabel),
              ),
            );
          }
          return ListView(
            children: [
              for (final mission in active)
                ListTile(
                  leading: Avatar(name: mission.officer),
                  title: Text(map.task(mission.taskId)?.label ?? ''),
                  subtitle: Text(
                    "${map.locationOf(mission.taskId)?.name ?? ''} · görevde",
                  ),
                  trailing: const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              for (final mission in reports)
                ListTile(
                  leading: Avatar(name: mission.officer),
                  title: Text(
                    map.task(mission.taskId)?.label ?? '',
                    style: TextStyle(
                      fontWeight: progress.hasSeen('report:${mission.taskId}')
                          ? FontWeight.normal
                          : FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    "${map.locationOf(mission.taskId)?.name ?? ''} · ${mission.officer}",
                  ),
                  trailing: progress.hasSeen('report:${mission.taskId}')
                      ? const Icon(Icons.chevron_right_rounded)
                      : const Icon(
                          Icons.circle,
                          size: 10,
                          color: AppColors.blue,
                        ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ReportPage(mission: mission),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.mission});

  final Mission mission;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Mission get mission => widget.mission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => StoryProgress.instance.markSeen('report:${mission.taskId}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final map = StoryData.current.map;
    final task = map.task(mission.taskId);
    final location = map.locationOf(mission.taskId);
    return Scaffold(
      appBar: AppBar(title: Text(location?.name ?? "Rapor")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Avatar(name: mission.officer, radius: 26),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.officer,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    task?.label ?? '',
                    style: const TextStyle(color: AppColors.secondaryLabel),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                task?.report ?? '',
                style: const TextStyle(fontSize: 16.5, height: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

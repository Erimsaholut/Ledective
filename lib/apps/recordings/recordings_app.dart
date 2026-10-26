import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';

/// Recordings the player hasn't listened to yet.
int unheardRecordingCount(StoryProgress progress) => [
  for (final r in StoryData.current.recordings)
    if (progress.meets(r.requires) && !progress.hasSeen('rec:${r.id}')) r,
].length;

String _duration(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

/// Voicemail and the detective's own voice memos. Recordings without an
/// audio file play their transcript word by word.
class RecordingsApp extends StatefulWidget {
  const RecordingsApp({super.key});

  @override
  State<RecordingsApp> createState() => _RecordingsAppState();
}

class _RecordingsAppState extends State<RecordingsApp> {
  final StoryProgress _progress = StoryProgress.instance;
  AudioPlayer? _player;
  Timer? _ticker;
  String? _playing;
  double _position = 0;

  @override
  void dispose() {
    _ticker?.cancel();
    _player?.dispose();
    super.dispose();
  }

  void _stop() {
    _ticker?.cancel();
    _player?.stop();
    setState(() {
      _playing = null;
      _position = 0;
    });
  }

  Future<void> _play(Recording recording) async {
    if (_playing == recording.id) {
      _stop();
      return;
    }
    _stop();
    setState(() => _playing = recording.id);
    unawaited(_progress.markSeen('rec:${recording.id}'));
    unawaited(_progress.discover(recording.unlocksOnListen));
    final audio = recording.audio;
    if (audio != null) {
      try {
        final player = _player ??= AudioPlayer();
        await player.setAsset(audio);
        unawaited(player.play());
      } on Exception catch (error) {
        debugPrint('Could not play $audio: $error');
      }
    }
    final start = DateTime.now();
    final total = recording.seconds * 1000;
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      if (!mounted) return timer.cancel();
      if (elapsed >= total) {
        timer.cancel();
        setState(() => _position = 1);
        return;
      }
      setState(() => _position = elapsed / total);
    });
  }

  Widget _list(RecordingKind kind) {
    final recordings = [
      for (final r in StoryData.current.recordings.reversed)
        if (r.kind == kind && _progress.meets(r.requires)) r,
    ];
    if (recordings.isEmpty) {
      return Center(
        child: Text(
          kind == RecordingKind.voicemail ? "Sesli mesaj yok" : "Kayıt yok",
          style: const TextStyle(color: AppColors.secondaryLabel),
        ),
      );
    }
    return ListView.separated(
      itemCount: recordings.length,
      separatorBuilder: (_, _) => const Divider(indent: 72),
      itemBuilder: (context, index) {
        final r = recordings[index];
        final playing = _playing == r.id;
        final unheard = !_progress.hasSeen('rec:${r.id}');
        final words = r.transcript.split(' ');
        final shown = playing
            ? words.take((words.length * _position).ceil()).join(' ')
            : r.transcript;
        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => _play(r),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (unheard)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: AppColors.blue,
                          ),
                        ),
                      Avatar(
                        name: r.from,
                        radius: 20,
                        icon: kind == RecordingKind.memo
                            ? Icons.mic_rounded
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.from,
                              style: TextStyle(
                                fontWeight: unheard
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            Text(
                              r.daysAgo == 0
                                  ? "Bugün"
                                  : "${r.daysAgo} gün önce",
                              style: const TextStyle(
                                color: AppColors.secondaryLabel,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _duration(r.seconds),
                        style: const TextStyle(color: AppColors.secondaryLabel),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        playing
                            ? Icons.stop_circle_rounded
                            : Icons.play_circle_fill_rounded,
                        color: AppColors.blue,
                        size: 34,
                      ),
                    ],
                  ),
                  if (playing) ...[
                    const SizedBox(height: 10),
                    _Waveform(progress: _position, seed: r.id.hashCode),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    shown,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: playing
                          ? AppColors.label
                          : AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Kayıtlar"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Sesli Mesaj"),
              Tab(text: "Kayıtlarım"),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: _progress,
          builder: (context, _) => TabBarView(
            children: [
              _list(RecordingKind.voicemail),
              _list(RecordingKind.memo),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bars that light up as the recording plays.
class _Waveform extends StatelessWidget {
  const _Waveform({required this.progress, required this.seed});

  final double progress;
  final int seed;

  @override
  Widget build(BuildContext context) {
    const bars = 48;
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          for (var i = 0; i < bars; i++)
            Expanded(
              child: Center(
                child: Container(
                  width: 3,
                  height: 6 + ((seed ~/ (i + 1) + i * 7) % 24).toDouble(),
                  decoration: BoxDecoration(
                    color: i / bars <= progress
                        ? AppColors.blue
                        : AppColors.separator,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

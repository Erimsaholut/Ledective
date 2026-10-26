import 'dart:async';

import 'package:flutter/material.dart';

import '../pian/note_player.dart';
import 'songs.dart';

/// A music player whose songs are played on the Pian app's notes.
class MusicApp extends StatefulWidget {
  const MusicApp({super.key});

  @override
  State<MusicApp> createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  NotePlayer? _notes;
  Timer? _timer;

  int _songIndex = 0;
  int _step = 0;
  bool _playing = false;

  Song get _song => songs[_songIndex];

  @override
  void dispose() {
    _timer?.cancel();
    _notes?.dispose();
    super.dispose();
  }

  void _playStep() {
    final steps = _song.steps;
    if (_step >= steps.length) {
      // Move on to the next song, like a playlist.
      _select((_songIndex + 1) % songs.length, autoplay: true);
      return;
    }
    final step = steps[_step];
    final note = step.note;
    if (note != null) (_notes ??= NotePlayer()).play(note);
    _timer = Timer(_song.durationOf(step), () {
      if (!mounted) return;
      setState(() => _step++);
      _playStep();
    });
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _playStep();
    } else {
      _timer?.cancel();
    }
  }

  void _select(int index, {bool autoplay = false}) {
    _timer?.cancel();
    setState(() {
      _songIndex = index;
      _step = 0;
      _playing = autoplay || _playing;
    });
    if (_playing) _playStep();
  }

  String _format(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  static const _artworks = [
    [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
    [Color(0xFFFF512F), Color(0xFFDD2476)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  ];

  Widget _artwork(int index, double size) {
    final colors = _artworks[index % _artworks.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.08),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          if (size > 100)
            BoxShadow(
              color: colors.first.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
        ],
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white.withValues(alpha: 0.85),
        size: size * 0.45,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFA233B);
    final steps = _song.steps;
    final elapsed = steps
        .take(_step)
        .map(_song.durationOf)
        .fold(Duration.zero, (a, b) => a + b);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Listen Now",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: AnimatedScale(
              scale: _playing ? 1 : 0.85,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: _artwork(_songIndex, 260),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            _song.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          Text(
            _song.artist,
            style: const TextStyle(fontSize: 18, color: accent),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: steps.isEmpty ? 0 : _step / steps.length,
              minHeight: 5,
              backgroundColor: const Color(0xFFE5E5EA),
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(elapsed),
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
              ),
              Text(
                "-${_format(_song.duration - elapsed)}",
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 44,
                tooltip: "Previous",
                onPressed: () => _select((_songIndex - 1) % songs.length),
                icon: const Icon(Icons.fast_rewind_rounded),
              ),
              IconButton(
                iconSize: 64,
                tooltip: _playing ? "Pause" : "Play",
                onPressed: _togglePlay,
                icon: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
              ),
              IconButton(
                iconSize: 44,
                tooltip: "Next",
                onPressed: () => _select((_songIndex + 1) % songs.length),
                icon: const Icon(Icons.fast_forward_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Çalma Listesi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < songs.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _artwork(i, 48),
              ),
              title: Text(
                songs[i].title,
                style: TextStyle(
                  fontWeight: i == _songIndex ? FontWeight.w700 : null,
                  color: i == _songIndex ? accent : null,
                ),
              ),
              subtitle: Text(songs[i].artist),
              trailing: i == _songIndex && _playing
                  ? const Icon(Icons.graphic_eq_rounded, color: accent)
                  : Text(_format(songs[i].duration)),
              onTap: () => _select(i, autoplay: true),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

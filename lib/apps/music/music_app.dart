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

  @override
  Widget build(BuildContext context) {
    final steps = _song.steps;
    final elapsed = steps
        .take(_step)
        .map(_song.durationOf)
        .fold(Duration.zero, (a, b) => a + b);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple.shade50,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < songs.length; i++)
                  ListTile(
                    leading: Icon(
                      i == _songIndex && _playing
                          ? Icons.graphic_eq
                          : Icons.music_note,
                      color: Colors.deepPurple,
                    ),
                    title: Text(
                      songs[i].title,
                      style: TextStyle(
                        fontWeight: i == _songIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(songs[i].artist),
                    trailing: Text(_format(songs[i].duration)),
                    onTap: () => _select(i, autoplay: true),
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Text(
                    _song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _song.artist,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: steps.isEmpty ? 0 : _step / steps.length,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _format(elapsed),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _format(_song.duration),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 40,
                        color: Colors.white,
                        tooltip: "Previous",
                        onPressed: () =>
                            _select((_songIndex - 1) % songs.length),
                        icon: const Icon(Icons.skip_previous),
                      ),
                      IconButton(
                        iconSize: 56,
                        color: Colors.white,
                        tooltip: _playing ? "Pause" : "Play",
                        onPressed: _togglePlay,
                        icon: Icon(
                          _playing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                        ),
                      ),
                      IconButton(
                        iconSize: 40,
                        color: Colors.white,
                        tooltip: "Next",
                        onPressed: () =>
                            _select((_songIndex + 1) % songs.length),
                        icon: const Icon(Icons.skip_next),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

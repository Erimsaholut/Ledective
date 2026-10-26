import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PianApp extends StatefulWidget {
  const PianApp({super.key});

  @override
  State<PianApp> createState() => _PianAppState();
}

class _PianAppState extends State<PianApp> {
  static const _keys = [
    (note: 1, color: Colors.red),
    (note: 2, color: Colors.orange),
    (note: 3, color: Colors.yellow),
    (note: 4, color: Colors.green),
    (note: 5, color: Colors.teal),
    (note: 7, color: Colors.blue),
    (note: 6, color: Colors.purple),
  ];

  // One preloaded player per note, so taps play instantly and players are
  // released when the app closes.
  final Map<int, AudioPlayer> _players = {};

  @override
  void initState() {
    super.initState();
    for (final key in _keys) {
      final player = AudioPlayer();
      _players[key.note] = player;
      player
          .setAsset('assets/apps/pian/pian_notes/note${key.note}.wav')
          .catchError((Object error) {
            debugPrint('Could not load note ${key.note}: $error');
            return null;
          });
    }
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }

  Future<void> _play(int note) async {
    final player = _players[note]!;
    await player.seek(Duration.zero);
    // play() only completes when the note has finished, so don't wait on it.
    unawaited(player.play());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pian"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            for (final key in _keys)
              Expanded(
                child: Material(
                  color: key.color,
                  child: InkWell(
                    onTap: () => _play(key.note),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

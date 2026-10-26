import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// The seven piano samples, note1.wav (C6) to note7.wav (B6).
enum Note {
  c(1, 'Do'),
  d(2, 'Re'),
  e(3, 'Mi'),
  f(4, 'Fa'),
  g(5, 'Sol'),
  a(6, 'La'),
  b(7, 'Si');

  const Note(this.sample, this.solfege);

  final int sample;
  final String solfege;

  String get asset => 'assets/apps/pian/pian_notes/note$sample.wav';
}

/// Plays piano notes from one preloaded player per note, so playback starts
/// instantly. Call [dispose] to release the players.
class NotePlayer {
  NotePlayer() {
    for (final note in Note.values) {
      final player = AudioPlayer();
      _players[note] = player;
      player.setAsset(note.asset).catchError((Object error) {
        debugPrint('Could not load ${note.asset}: $error');
        return null;
      });
    }
  }

  final Map<Note, AudioPlayer> _players = {};

  Future<void> play(Note note) async {
    final player = _players[note]!;
    await player.seek(Duration.zero);
    // play() only completes when the note has finished, so don't wait on it.
    unawaited(player.play());
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
  }
}

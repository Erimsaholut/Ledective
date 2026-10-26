import 'package:flutter/material.dart';

import 'note_player.dart';

class PianApp extends StatefulWidget {
  const PianApp({super.key});

  @override
  State<PianApp> createState() => _PianAppState();
}

class _PianAppState extends State<PianApp> {
  static const _colors = {
    Note.c: Colors.red,
    Note.d: Colors.orange,
    Note.e: Colors.yellow,
    Note.f: Colors.green,
    Note.g: Colors.teal,
    Note.a: Colors.blue,
    Note.b: Colors.purple,
  };

  final NotePlayer _player = NotePlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pian"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            for (final MapEntry(key: note, value: color) in _colors.entries)
              Expanded(
                child: Material(
                  color: color,
                  child: InkWell(
                    onTap: () => _player.play(note),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          note.solfege,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

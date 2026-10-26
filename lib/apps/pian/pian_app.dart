import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'note_player.dart';

/// A piano keyboard turned sideways to fit a phone held upright. The black
/// keys are decorative; the samples only cover the white keys.
class PianApp extends StatefulWidget {
  const PianApp({super.key});

  @override
  State<PianApp> createState() => _PianAppState();
}

class _PianAppState extends State<PianApp> {
  final NotePlayer _player = NotePlayer();
  Note? _pressed;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _play(Note note) {
    _player.play(note);
    setState(() => _pressed = note);
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (mounted && _pressed == note) setState(() => _pressed = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Black keys sit between these white keys (none after E and B).
    const blackAfter = {Note.c, Note.d, Note.f, Note.g, Note.a};
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1C1E),
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text("Pian", style: TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final keyHeight = constraints.maxHeight / Note.values.length;
                return Stack(
                  children: [
                    Column(
                      children: [
                        for (final note in Note.values)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: GestureDetector(
                                onTapDown: (_) => _play(note),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 80),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(8),
                                    ),
                                    gradient: LinearGradient(
                                      colors: _pressed == note
                                          ? const [
                                              Color(0xFFD9D9DE),
                                              Color(0xFFEDEDF0),
                                            ]
                                          : const [
                                              Color(0xFFF2F2F5),
                                              Colors.white,
                                            ],
                                    ),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Text(
                                    note.solfege,
                                    style: const TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (final note in Note.values)
                      if (blackAfter.contains(note))
                        Positioned(
                          left: 0,
                          top: keyHeight * (note.index + 1) - keyHeight * 0.3,
                          height: keyHeight * 0.6,
                          width: constraints.maxWidth * 0.58,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(6),
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF000000),
                                    Color(0xFF3A3A3C),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x66000000),
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

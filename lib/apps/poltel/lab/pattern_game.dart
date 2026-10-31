import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Unlocks a phone by drawing its pattern through a 3×3 grid of dots. The
/// smudges the owner's finger left on the screen show the way, and grow
/// clearer after each wrong try.
class PatternGame extends StatefulWidget {
  const PatternGame({super.key, required this.pattern, required this.onSolved});

  /// Dots 0–8, row by row, in the order they are drawn.
  final List<int> pattern;
  final VoidCallback onSolved;

  @override
  State<PatternGame> createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  final List<int> _drawn = [];
  Offset? _finger;
  int _tries = 0;
  bool _wrong = false;

  static Offset _dot(int i, Size size) =>
      Offset((i % 3 + 0.5) * size.width / 3, (i ~/ 3 + 0.5) * size.height / 3);

  void _touch(Offset at, Size size) {
    setState(() => _finger = at);
    for (var i = 0; i < 9; i++) {
      if (!_drawn.contains(i) && (at - _dot(i, size)).distance < 30) {
        setState(() {
          _drawn.add(i);
          _wrong = false;
        });
      }
    }
  }

  void _lift() {
    if (_drawn.isEmpty) return;
    final right =
        _drawn.length == widget.pattern.length &&
        [for (var i = 0; i < _drawn.length; i++) _drawn[i] == widget.pattern[i]]
            .every((same) => same);
    if (right) {
      setState(() => _finger = null);
      widget.onSolved();
      return;
    }
    setState(() {
      _tries++;
      _wrong = true;
      _drawn.clear();
      _finger = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF12141A),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              const Text(
                "Desen çizin",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return GestureDetector(
                      key: const ValueKey('pattern-pad'),
                      // The first dot counts from where the finger lands.
                      dragStartBehavior: DragStartBehavior.down,
                      onPanStart: (d) => _touch(d.localPosition, size),
                      onPanUpdate: (d) => _touch(d.localPosition, size),
                      onPanEnd: (_) => _lift(),
                      child: CustomPaint(
                        size: size,
                        painter: _PadPainter(
                          pattern: widget.pattern,
                          drawn: _drawn,
                          finger: _finger,
                          // Smudges show more with every miss.
                          smudge: (0.10 + _tries * 0.07).clamp(0, 0.4),
                          wrong: _wrong,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _wrong
              ? "Yanlış desen. Ekrandaki lekelere bak."
              : "Ekranı ışığa tut: parmak izinin lekeleri desenin yolunu gösteriyor.",
          textAlign: TextAlign.center,
          style: TextStyle(color: _wrong ? const Color(0xFFC62828) : null),
        ),
      ],
    );
  }
}

class _PadPainter extends CustomPainter {
  _PadPainter({
    required this.pattern,
    required this.drawn,
    required this.finger,
    required this.smudge,
    required this.wrong,
  });

  final List<int> pattern;
  final List<int> drawn;
  final Offset? finger;
  final double smudge;
  final bool wrong;

  @override
  void paint(Canvas canvas, Size size) {
    Offset dot(int i) => _PatternGameState._dot(i, size);
    final grease = Paint()
      ..color = Colors.white.withValues(alpha: smudge)
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    for (var i = 1; i < pattern.length; i++) {
      canvas.drawLine(dot(pattern[i - 1]), dot(pattern[i]), grease);
    }
    final line = Paint()
      ..color = wrong ? const Color(0xFFE53935) : const Color(0xFF4FC3F7)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < drawn.length; i++) {
      canvas.drawLine(dot(drawn[i - 1]), dot(drawn[i]), line);
    }
    if (drawn.isNotEmpty && finger != null) {
      canvas.drawLine(dot(drawn.last), finger!, line);
    }
    for (var i = 0; i < 9; i++) {
      final on = drawn.contains(i);
      canvas.drawCircle(
        dot(i),
        on ? 14 : 9,
        Paint()..color = on ? const Color(0xFF4FC3F7) : Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_PadPainter old) => true;
}

import 'dart:math';

import 'package:flutter/material.dart';

/// Turns a tyre's tread over a print from the scene until the grooves
/// line up, then compares them.
class TreadGame extends StatefulWidget {
  const TreadGame({super.key, required this.angle, required this.onSolved});

  /// Where the print lies, in degrees.
  final double angle;
  final VoidCallback onSolved;

  @override
  State<TreadGame> createState() => _TreadGameState();
}

class _TreadGameState extends State<TreadGame> {
  static const _close = 4.0;

  late double _turn = (widget.angle + 90) % 180;
  String? _message;

  double get _off {
    final d = (_turn - widget.angle).abs() % 180;
    return min(d, 180 - d);
  }

  void _compare() {
    if (_off <= _close) {
      widget.onSolved();
      return;
    }
    setState(() => _message = "Oluklar örtüşmüyor (${_off.round()}° fark).");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _TreadPainter(
                    angle: widget.angle,
                    color: const Color(0xFF5D4037),
                    background: const Color(0xFFBCAAA4),
                  ),
                ),
                Opacity(
                  opacity: 0.55,
                  child: CustomPaint(
                    painter: _TreadPainter(
                      angle: _turn,
                      color: const Color(0xFF0D47A1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Slider(
          key: const ValueKey('tread-turn'),
          value: _turn,
          max: 180,
          onChanged: (v) => setState(() {
            _turn = v;
            _message = null;
          }),
        ),
        Text("Açı: ${_turn.round()}°", textAlign: TextAlign.center),
        if (_message case final message?)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFC62828)),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const ValueKey('tread-compare'),
          onPressed: _compare,
          icon: const Icon(Icons.compare_rounded),
          label: const Text("Karşılaştır"),
        ),
      ],
    );
  }
}

/// A tyre tread: zigzag grooves across a band, turned by [angle].
class _TreadPainter extends CustomPainter {
  _TreadPainter({required this.angle, required this.color, this.background});

  final double angle;
  final Color color;
  final Color? background;

  @override
  void paint(Canvas canvas, Size size) {
    if (background case final b?) {
      canvas.drawRect(Offset.zero & size, Paint()..color = b);
    }
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(angle * pi / 180);
    final band = size.width * 0.42;
    final groove = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.03
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final step = size.width * 0.09;
    for (var y = -size.height; y < size.height; y += step) {
      final path = Path()..moveTo(-band, y);
      path
        ..lineTo(-band / 2, y + step * 0.4)
        ..lineTo(0, y)
        ..lineTo(band / 2, y + step * 0.4)
        ..lineTo(band, y);
      canvas.drawPath(path, groove);
    }
    canvas
      ..drawLine(
        Offset(-band, -size.height),
        Offset(-band, size.height),
        groove,
      )
      ..drawLine(Offset(band, -size.height), Offset(band, size.height), groove)
      ..restore();
  }

  @override
  bool shouldRepaint(_TreadPainter old) => true;
}

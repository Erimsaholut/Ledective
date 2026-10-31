import 'dart:math';

import 'package:flutter/material.dart';

/// Lines up the voice print of a recording with a suspect's: slide the
/// recording until the peaks match, then compare. The match meter climbs
/// as they come together.
class VoiceGame extends StatefulWidget {
  const VoiceGame({
    super.key,
    required this.offset,
    required this.suspect,
    required this.onSolved,
  });

  /// Where the recording lines up, 0–1.
  final double offset;
  final String suspect;
  final VoidCallback onSolved;

  @override
  State<VoiceGame> createState() => _VoiceGameState();
}

class _VoiceGameState extends State<VoiceGame> {
  static const _bars = 64;

  /// The suspect's voice print, louder in a few syllables.
  late final List<double> _print = () {
    final random = Random(widget.suspect.hashCode);
    return [
      for (var i = 0; i < _bars * 2; i++)
        (0.15 + random.nextDouble() * 0.35) *
            (i % 9 < 3 ? 1.8 : 1) *
            (0.6 + 0.4 * sin(i / 5)),
    ];
  }();

  late double _slide = widget.offset > 0.5 ? 0.05 : 0.95;
  String? _message;

  /// 0–100, how well the two prints line up now.
  int get _match =>
      (100 * (1 - ((_slide - widget.offset).abs() / 0.25).clamp(0, 1))).round();

  void _compare() {
    if (_match >= 92) {
      widget.onSolved();
      return;
    }
    setState(
      () => _message = "Eşleşme %$_match. Tepeler örtüşene kadar kaydır.",
    );
  }

  @override
  Widget build(BuildContext context) {
    // The recording is the same voice, shifted by where the slider is.
    final shift = ((_slide - widget.offset) * _bars).round();
    final recording = [
      for (var i = 0; i < _bars; i++)
        _print[(i + shift + _bars ~/ 2).clamp(0, _print.length - 1)],
    ];
    final reference = _print.sublist(_bars ~/ 2, _bars ~/ 2 + _bars);
    final match = _match;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Track(label: "Kayıt", bars: recording, color: const Color(0xFFFFB74D)),
        const SizedBox(height: 6),
        _Track(
          label: widget.suspect.isEmpty ? "Şüpheli" : widget.suspect,
          bars: reference,
          color: const Color(0xFF4FC3F7),
        ),
        const SizedBox(height: 8),
        Slider(
          key: const ValueKey('voice-slide'),
          value: _slide,
          onChanged: (v) => setState(() {
            _slide = v;
            _message = null;
          }),
        ),
        LinearProgressIndicator(
          value: match / 100,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          color: match >= 92
              ? const Color(0xFF43A047)
              : const Color(0xFFFFA000),
        ),
        const SizedBox(height: 4),
        Text("Eşleşme: %$match", textAlign: TextAlign.center),
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
          key: const ValueKey('voice-compare'),
          onPressed: _compare,
          icon: const Icon(Icons.graphic_eq_rounded),
          label: const Text("Karşılaştır"),
        ),
      ],
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.label, required this.bars, required this.color});

  final String label;
  final List<double> bars;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarsPainter(bars, color),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.bars, this.color);

  final List<double> bars;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / bars.length;
    final paint = Paint()..color = color;
    for (final (i, b) in bars.indexed) {
      final h = (b.clamp(0, 1)) * size.height;
      canvas.drawRect(
        Rect.fromLTWH(i * w + w * 0.15, (size.height - h) / 2, w * 0.7, h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => true;
}

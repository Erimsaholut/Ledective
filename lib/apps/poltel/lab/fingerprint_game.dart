import 'dart:math';

import 'package:flutter/material.dart';

/// Draws a fingerprint whose ridge pattern depends only on [seed], so the
/// same person always leaves the same print.
class FingerprintPainter extends CustomPainter {
  const FingerprintPainter(this.seed, {this.partial = false, this.color});

  final int seed;

  /// A smudged, incomplete print, as found at a scene.
  final bool partial;
  final Color? color;

  static int seedFor(String name) =>
      name.codeUnits.fold(17, (a, b) => (a * 31 + b) & 0x7fffffff);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final center = Offset(
      size.width * (0.42 + rng.nextDouble() * 0.16),
      size.height * (0.4 + rng.nextDouble() * 0.2),
    );
    final lobes = 2 + rng.nextInt(3);
    final phase = rng.nextDouble() * pi * 2;
    final skew = 0.15 + rng.nextDouble() * 0.25;
    final stretch = 1.15 + rng.nextDouble() * 0.35;
    final ridges = 16;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.018
      ..strokeCap = StrokeCap.round
      ..color = color ?? const Color(0xFF2B2B2B);
    // Gaps in the ridges are part of the pattern too.
    final breakRng = Random(seed * 3 + 1);
    final smudge = Random(seed * 7 + 3);

    for (var i = 1; i <= ridges; i++) {
      final base = size.shortestSide * 0.028 * i;
      const segments = 72;
      Path? path;
      for (var s = 0; s <= segments; s++) {
        final t = s / segments * 2 * pi;
        final r = base * (1 + skew * sin(lobes * t + phase + i * 0.15));
        final point = center + Offset(cos(t) * r, sin(t) * r * stretch);
        final gap = breakRng.nextDouble() < 0.06;
        final hidden =
            partial &&
            (point.dx > size.width * 0.72 || smudge.nextDouble() < 0.12);
        if (gap || hidden || !(Offset.zero & size).contains(point)) {
          if (path != null) canvas.drawPath(path, paint);
          path = null;
          continue;
        }
        if (path == null) {
          path = Path()..moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      if (path != null) canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(FingerprintPainter old) =>
      old.seed != seed || old.partial != partial;
}

/// Compare the print from the scene with prints on file.
class FingerprintGame extends StatefulWidget {
  const FingerprintGame({
    super.key,
    required this.options,
    required this.answer,
    required this.onSolved,
  });

  final List<String> options;
  final String answer;
  final VoidCallback onSolved;

  @override
  State<FingerprintGame> createState() => _FingerprintGameState();
}

class _FingerprintGameState extends State<FingerprintGame> {
  final Set<String> _rejected = {};
  bool _solved = false;

  void _pick(String name) {
    if (_solved) return;
    if (name == widget.answer) {
      setState(() => _solved = true);
      widget.onSolved();
    } else {
      setState(() => _rejected.add(name));
    }
  }

  Widget _print(int seed, {bool partial = false}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomPaint(
        painter: FingerprintPainter(seed, partial: partial),
        size: Size.infinite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "OLAY YERİ İZİ",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        SizedBox.square(
          dimension: 170,
          child: _print(
            FingerprintPainter.seedFor(widget.answer),
            partial: !_solved,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "KAYITLI İZLER",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            for (final name in widget.options)
              Opacity(
                opacity: _rejected.contains(name) ? 0.35 : 1,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _rejected.contains(name) ? null : () => _pick(name),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Expanded(
                            child: _print(FingerprintPainter.seedFor(name)),
                          ),
                          const SizedBox(height: 6),
                          if (_rejected.contains(name))
                            const Text(
                              "Eşleşme yok",
                              style: TextStyle(
                                color: Color(0xFFC62828),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _solved && name == widget.answer
                                  ? const Color(0xFF248A3D)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

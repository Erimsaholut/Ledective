import 'dart:math';

import 'package:flutter/material.dart';

/// Sprays luminol over a darkened scene. Each spray lights up the stains
/// under it and glows faintly when one is near; find them all before the
/// bottle runs out, or start again.
class LuminolGame extends StatefulWidget {
  const LuminolGame({
    super.key,
    required this.image,
    required this.spots,
    required this.sprays,
    required this.onSolved,
  });

  final String image;

  /// The hidden stains, as fractions of the image.
  final List<(double, double)> spots;
  final int sprays;
  final VoidCallback onSolved;

  @override
  State<LuminolGame> createState() => _LuminolGameState();
}

class _LuminolGameState extends State<LuminolGame> {
  /// How far one spray reaches, as a fraction of the width.
  static const _reach = 0.11;

  final List<Offset> _sprayed = [];
  final Set<int> _found = {};

  int get _left => widget.sprays - _sprayed.length;

  void _spray(Offset at, Size size) {
    if (_left <= 0 || _found.length == widget.spots.length) return;
    final point = Offset(at.dx / size.width, at.dy / size.height);
    setState(() {
      _sprayed.add(point);
      for (final (i, spot) in widget.spots.indexed) {
        if (_distance(point, spot) <= _reach) _found.add(i);
      }
    });
    if (_found.length == widget.spots.length) widget.onSolved();
  }

  /// Distance in widths, with the image's 4:3 height taken into account.
  static double _distance(Offset p, (double, double) spot) {
    final dx = p.dx - spot.$1;
    final dy = (p.dy - spot.$2) * 0.75;
    return sqrt(dx * dx + dy * dy);
  }

  /// How strongly the nearest hidden stain shows through a spray at [p]:
  /// 1 on it, fading to nothing three reaches away.
  double _warmth(Offset p) {
    var best = 0.0;
    for (final (i, spot) in widget.spots.indexed) {
      if (_found.contains(i)) continue;
      final d = _distance(p, spot);
      best = max(best, (1 - d / (_reach * 3)).clamp(0, 1));
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final out = _left <= 0 && _found.length < widget.spots.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              return GestureDetector(
                key: const ValueKey('luminol-scene'),
                onTapUp: (d) => _spray(d.localPosition, size),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColorFiltered(
                        // The lights are off for luminol.
                        colorFilter: const ColorFilter.mode(
                          Color(0xE6050A1A),
                          BlendMode.srcATop,
                        ),
                        child: Image.asset(widget.image, fit: BoxFit.cover),
                      ),
                      CustomPaint(
                        painter: _GlowPainter(
                          sprays: [for (final s in _sprayed) (s, _warmth(s))],
                          stains: [
                            for (final i in _found)
                              Offset(widget.spots[i].$1, widget.spots[i].$2),
                          ],
                          reach: _reach,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.water_drop_rounded, color: Color(0xFF3D7BFF)),
                const SizedBox(width: 6),
                Text("Kalan: $_left"),
              ],
            ),
            Text("Bulunan iz: ${_found.length} / ${widget.spots.length}"),
          ],
        ),
        if (out) ...[
          const SizedBox(height: 8),
          const Text(
            "Luminol bitti. Parlayan yerlerin yakınına sıkmayı dene.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFC62828)),
          ),
          TextButton.icon(
            key: const ValueKey('luminol-again'),
            onPressed: () => setState(() {
              _sprayed.clear();
              _found.clear();
            }),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Yeni şişe"),
          ),
        ],
      ],
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.sprays,
    required this.stains,
    required this.reach,
  });

  /// Each spray with how warm it is (0–1).
  final List<(Offset, double)> sprays;
  final List<Offset> stains;
  final double reach;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset p) => Offset(p.dx * size.width, p.dy * size.height);
    final r = reach * size.width;
    for (final (p, warmth) in sprays) {
      canvas.drawCircle(
        at(p),
        r,
        Paint()
          ..color = Color.lerp(
            const Color(0x1A3D7BFF),
            const Color(0x803DDCFF),
            warmth,
          )!
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }
    for (final s in stains) {
      canvas
        ..drawCircle(
          at(s),
          r * 0.55,
          Paint()
            ..color = const Color(0xCC66E0FF)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        )
        ..drawCircle(at(s), r * 0.2, Paint()..color = const Color(0xFFB8F4FF));
    }
  }

  @override
  bool shouldRepaint(_GlowPainter old) => true;
}

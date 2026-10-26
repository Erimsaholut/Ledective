import 'package:flutter/material.dart';

/// Sweep a UV lamp over an image; hidden ink shows inside its beam. Solved
/// once most of the writing has been lit up.
class UvGame extends StatefulWidget {
  const UvGame({
    super.key,
    required this.image,
    required this.hiddenText,
    required this.onSolved,
  });

  final String image;
  final String hiddenText;
  final VoidCallback onSolved;

  @override
  State<UvGame> createState() => _UvGameState();
}

class _UvGameState extends State<UvGame> {
  static const _grid = 8;

  /// The part of the page the hidden writing covers, in grid cells.
  static const _textRows = (2, 6);

  Offset? _lamp;
  final Set<int> _lit = {};
  bool _solved = false;

  int get _textCells => (_textRows.$2 - _textRows.$1) * _grid;

  void _move(Offset position, Size size) {
    setState(() => _lamp = position);
    if (_solved) return;
    final col = (position.dx / size.width * _grid).floor();
    final row = (position.dy / size.height * _grid).floor();
    if (row >= _textRows.$1 && row < _textRows.$2 && col >= 0 && col < _grid) {
      _lit.add(row * _grid + col);
    }
    if (_lit.length >= _textCells * 0.6) {
      setState(() => _solved = true);
      widget.onSolved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final radius = size.width * 0.2;
          final hidden = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.hiddenText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB6FF6B),
                  fontSize: 26,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Color(0xFF7CFF3A), blurRadius: 12)],
                ),
              ),
            ),
          );
          final lamp = _lamp;
          return GestureDetector(
            onPanStart: (d) => _move(d.localPosition, size),
            onPanUpdate: (d) => _move(d.localPosition, size),
            onTapDown: (d) => _move(d.localPosition, size),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.image, fit: BoxFit.cover),
                  // A dark room: only the lamp lights the page.
                  ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
                  if (_solved)
                    ColoredBox(color: const Color(0x553A0CA3), child: hidden)
                  else if (lamp != null)
                    ClipPath(
                      clipper: _BeamClipper(lamp, radius),
                      child: ColoredBox(
                        color: const Color(0xAA3A0CA3),
                        child: hidden,
                      ),
                    ),
                  if (lamp != null && !_solved)
                    Positioned(
                      left: lamp.dx - radius,
                      top: lamp.dy - radius,
                      width: radius * 2,
                      height: radius * 2,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF9D7BFF),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x889D7BFF),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (lamp == null)
                    const Center(
                      child: Text(
                        "Parmağını sayfada gezdir",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BeamClipper extends CustomClipper<Path> {
  const _BeamClipper(this.center, this.radius);

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(_BeamClipper old) =>
      old.center != center || old.radius != radius;
}

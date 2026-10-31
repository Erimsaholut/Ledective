import 'package:flutter/material.dart';

/// Compares the photo on file with the one found, which someone has
/// touched up: tap the touched-up places on the lower one.
class DifferencesGame extends StatefulWidget {
  const DifferencesGame({
    super.key,
    required this.image,
    required this.spots,
    required this.onSolved,
  });

  final String image;

  /// What was changed, as fractions of the image.
  final List<(double, double)> spots;
  final VoidCallback onSolved;

  @override
  State<DifferencesGame> createState() => _DifferencesGameState();
}

class _DifferencesGameState extends State<DifferencesGame> {
  static const _reach = 0.08;

  final Set<int> _found = {};
  int _misses = 0;

  void _tap(Offset at, Size size) {
    final x = at.dx / size.width;
    final y = at.dy / size.height;
    for (final (i, (sx, sy)) in widget.spots.indexed) {
      if ((x - sx).abs() < _reach && (y - sy).abs() < _reach * 1.33) {
        if (_found.add(i)) {
          setState(() {});
          if (_found.length == widget.spots.length) widget.onSolved();
        }
        return;
      }
    }
    setState(() => _misses++);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Kayıttaki fotoğraf", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        _Photo(image: widget.image, spots: const [], found: const {}),
        const SizedBox(height: 10),
        const Text("Bulunan fotoğraf", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            key: const ValueKey('differences-found'),
            onTapUp: (d) => _tap(
              d.localPosition,
              Size(constraints.maxWidth, constraints.maxWidth * 3 / 4),
            ),
            child: _Photo(
              image: widget.image,
              spots: widget.spots,
              found: _found,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Fark: ${_found.length} / ${widget.spots.length}"
          "${_misses > 0 ? " · Boşa dokunuş: $_misses" : ""}",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.image, required this.spots, required this.found});

  final String image;
  final List<(double, double)> spots;
  final Set<int> found;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            CustomPaint(painter: _ChangesPainter(spots, found)),
          ],
        ),
      ),
    );
  }
}

/// The touch-ups: small patches that don't belong, each a little
/// different. Found ones get a ring.
class _ChangesPainter extends CustomPainter {
  _ChangesPainter(this.spots, this.found);

  final List<(double, double)> spots;
  final Set<int> found;

  static const _patches = [
    Color(0xFF3E2723),
    Color(0xFFD7CCC8),
    Color(0xFF263238),
    Color(0xFF8D6E63),
    Color(0xFFECEFF1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (i, (x, y)) in spots.indexed) {
      final c = Offset(x * size.width, y * size.height);
      final r = size.width * 0.022;
      final patch = Paint()..color = _patches[i % _patches.length];
      switch (i % 3) {
        case 0:
          canvas.drawCircle(c, r, patch);
        case 1:
          canvas.drawRect(
            Rect.fromCenter(center: c, width: r * 2, height: r * 1.4),
            patch,
          );
        default:
          canvas.drawLine(
            c.translate(-r, -r),
            c.translate(r, r),
            patch..strokeWidth = r * 0.7,
          );
      }
      if (found.contains(i)) {
        canvas.drawCircle(
          c,
          r * 2.4,
          Paint()
            ..color = const Color(0xFF43A047)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ChangesPainter old) => true;
}

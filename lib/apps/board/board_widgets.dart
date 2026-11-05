import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../theme/turkish_text.dart';

/// Typewritten text on the board's cards.
const typewriter = TextStyle(
  fontFamily: 'Courier',
  fontFamilyFallback: ['Menlo', 'monospace'],
  color: Color(0xFF2B2B2B),
);

/// How wide each kind of card hangs on the board.
double cardWidth(PinKind? kind) => switch (kind) {
  null || PinKind.person => 150,
  PinKind.note => 170,
  PinKind.time => 180,
};

/// A pinned photo or note with the evidence on it.
class EvidenceCard extends StatelessWidget {
  const EvidenceCard({
    super.key,
    required this.evidence,
    required this.tilt,
    required this.isNew,
    required this.onTap,
  });

  final Evidence evidence;
  final double tilt;
  final bool isNew;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = evidence.image;
    final progress = StoryProgress.instance;
    final pending =
        evidence.inspection != null && !progress.isInspected(evidence.id);
    return _Hanging(
      tilt: tilt,
      isNew: isNew,
      onTap: onTap,
      child: _Paper(
        color: image == null
            ? const Color(0xFFFFF59D)
            : const Color(0xFFFAFAF5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (image != null)
              AspectRatio(
                aspectRatio: 1,
                // Torn pieces stay a jumble until the lab puts them back
                // together.
                child: pending && evidence.inspection is JigsawInspection
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                            child: _aged(image),
                          ),
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ],
                      )
                    : _aged(image),
              ),
            const SizedBox(height: 6),
            Text(
              evidence.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF2B2B2B),
              ),
            ),
            if (image == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  evidence.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ),
            if (pending)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "LAB BEKLİYOR",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFC62828),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A photo pinned up for a while: a little yellowed. The tint is painted
/// with the image rather than through a layer, which a board full of photos
/// can't afford.
Widget _aged(
  String image, {
  Alignment alignment = Alignment.center,
  double? width,
  double? height,
}) => Image.asset(
  image,
  fit: BoxFit.cover,
  alignment: alignment,
  width: width,
  height: height,
  color: const Color(0x33704214),
  colorBlendMode: BlendMode.multiply,
);

/// A person's card: a mugshot or a question mark, their name, their place
/// in the case and the latest rubber stamp.
class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key,
    required this.pin,
    required this.known,
    required this.stamp,
    required this.tilt,
    required this.isNew,
    required this.onTap,
  });

  final BoardPin pin;
  final bool known;
  final String? stamp;
  final double tilt;
  final bool isNew;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final role = known ? pin.role : pin.unknownRole;
    return _Hanging(
      tilt: tilt,
      isNew: isNew,
      onTap: onTap,
      child: _Paper(
        color: const Color(0xFFF7F3E8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (pin.tag.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  color: tagColor(pin.tag),
                  child: Text(
                    pin.tag,
                    style: typewriter.copyWith(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Mugshot(pin: pin, known: known),
                  if (stamp case final stamp?)
                    Align(
                      alignment: const Alignment(0, 0.72),
                      child: Stamp(stamp),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              known ? turkishUpper(pin.name) : pin.unknownName,
              textAlign: TextAlign.center,
              style: typewriter.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (role.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  role,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.25,
                    color: const Color(0xFF555555),
                    fontStyle: known ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Color tagColor(String tag) => switch (tag) {
  'ŞÜPHELİ' => const Color(0xFFB71C1C),
  'MAKTUL' || 'ÖLÜ' => const Color(0xFF212121),
  'KAYIP' => const Color(0xFFE65100),
  'TANIK' => const Color(0xFF1565C0),
  'AĞ' => const Color(0xFF4A148C),
  _ => const Color(0xFF455A64),
};

/// A handwritten sticky note, or a card on the night's timeline.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.pin,
    required this.known,
    required this.stamp,
    required this.tilt,
    required this.isNew,
    required this.onTap,
  });

  final BoardPin pin;
  final bool known;
  final String? stamp;
  final double tilt;
  final bool isNew;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = known ? pin.role : pin.unknownRole;
    final time = pin.kind == PinKind.time;
    return _Hanging(
      tilt: tilt,
      isNew: isNew,
      onTap: onTap,
      child: _Paper(
        color: time ? const Color(0xFFFDFDF8) : const Color(0xFFFFF59D),
        top: time ? const Color(0xFFD32F2F) : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (time)
                  Text(
                    pin.time,
                    style: typewriter.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB71C1C),
                    ),
                  ),
                if (pin.name.isNotEmpty)
                  Text(
                    pin.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                Text(
                  text,
                  style: time
                      ? typewriter.copyWith(fontSize: 11.5, height: 1.3)
                      : TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: const Color(0xFF3A2E00),
                          fontStyle: known
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                ),
              ],
            ),
            if (stamp case final stamp?)
              Positioned(right: -4, bottom: -6, child: Stamp(stamp, size: 11)),
          ],
        ),
      ),
    );
  }
}

/// A card hanging from a pin, tilted a little, with a red dot while new.
class _Hanging extends StatelessWidget {
  const _Hanging({
    required this.tilt,
    required this.isNew,
    required this.onTap,
    required this.child,
  });

  final double tilt;
  final bool isNew;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: tilt,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(padding: const EdgeInsets.only(top: 8), child: child),
            const BoardPinHead(),
            if (isNew)
              const Positioned(
                right: -6,
                top: 0,
                child: CircleAvatar(radius: 6, backgroundColor: AppColors.red),
              ),
          ],
        ),
      ),
    );
  }
}

class _Paper extends StatelessWidget {
  const _Paper({required this.color, required this.child, this.top});

  final Color color;
  final Widget child;

  /// A coloured rule along the top, like an index card.
  final Color? top;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: color,
        border: top == null
            ? null
            : Border(top: BorderSide(color: top!, width: 3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class BoardPinHead extends StatelessWidget {
  const BoardPinHead({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.4),
          colors: [Color(0xFFFF8A80), Color(0xFFC62828)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 3,
            offset: Offset(1, 2),
          ),
        ],
      ),
    );
  }
}

/// A red rubber stamp, such as "ARANIYOR".
class Stamp extends StatelessWidget {
  const Stamp(this.text, {super.key, this.size = 13});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.18,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x22FFFFFF),
          border: Border.all(color: const Color(0xDDC62828), width: 2),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          text,
          style: typewriter.copyWith(
            color: const Color(0xDDC62828),
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

/// A person's photo, cropped to their face, or a silhouette with height
/// lines behind it: a question mark while nobody knows who they are.
class Mugshot extends StatelessWidget {
  const Mugshot({super.key, required this.pin, required this.known});

  final BoardPin pin;
  final bool known;

  @override
  Widget build(BuildContext context) {
    final image = known ? pin.image : pin.unknownImage;
    if (image == null) {
      return CustomPaint(
        painter: _SilhouettePainter(),
        child: Center(
          child: known
              ? Align(
                  alignment: const Alignment(0, 0.95),
                  child: Text(
                    "FOTOĞRAF YOK",
                    style: typewriter.copyWith(
                      color: Colors.white54,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                )
              : const Text(
                  "?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      );
    }
    final (fx, fy) = pin.focus;
    final align = Alignment(fx * 2 - 1, fy * 2 - 1);
    return LayoutBuilder(
      builder: (context, box) => ClipRect(
        child: OverflowBox(
          maxWidth: box.maxWidth * pin.zoom,
          maxHeight: box.maxHeight * pin.zoom,
          alignment: align,
          child: _aged(
            image,
            alignment: align,
            width: box.maxWidth * pin.zoom,
            height: box.maxHeight * pin.zoom,
          ),
        ),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5A5F66), Color(0xFF34383D)],
        ).createShader(rect),
    );
    // Height chart lines, as in a mugshot.
    final line = Paint()
      ..color = const Color(0x40FFFFFF)
      ..strokeWidth = 1;
    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
      final label = TextPainter(
        text: TextSpan(
          text: '${200 - i * 10}',
          style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(3, y - label.height));
    }
    final body = Paint()..color = const Color(0xFF1F2226);
    final w = size.width;
    final h = size.height;
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w / 2, h * 0.42),
          width: w * 0.34,
          height: h * 0.4,
        ),
        body,
      )
      ..drawPath(
        Path()
          ..moveTo(w * 0.12, h)
          ..quadraticBezierTo(w * 0.15, h * 0.66, w / 2, h * 0.64)
          ..quadraticBezierTo(w * 0.85, h * 0.66, w * 0.88, h)
          ..close(),
        body,
      );
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) => false;
}

/// A label tied onto a red string.
class StringTag extends StatelessWidget {
  const StringTag(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0E1),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: typewriter.copyWith(fontSize: 9.5, height: 1.2),
      ),
    );
  }
}

/// A strip of black tape with a stencilled label, such as "ŞÜPHELİLER".
class ZoneLabel extends StatelessWidget {
  const ZoneLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.02,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        color: const Color(0xE6202020),
        child: Text(
          text,
          style: typewriter.copyWith(
            color: const Color(0xFFF5F0E1),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}

class CorkPainter extends CustomPainter {
  const CorkPainter({this.origin = Offset.zero});

  /// Where this piece of cork sits on the whole board, so the specks stay
  /// put when the board grows.
  final Offset origin;

  static const _tile = 200.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB78A5C), Color(0xFFA2764A)],
        ).createShader(Offset.zero & size),
    );
    final dark = Paint()..color = const Color(0x33402510);
    final light = Paint()..color = const Color(0x22FFF3E0);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final area = origin & size;
    for (var ty = (area.top / _tile).floor(); ty * _tile < area.bottom; ty++) {
      for (
        var tx = (area.left / _tile).floor();
        tx * _tile < area.right;
        tx++
      ) {
        final rng = Random(tx * 7919 + ty * 104729);
        final corner = Offset(tx * _tile, ty * _tile) - origin;
        for (var i = 0; i < _tile * _tile / 400; i++) {
          canvas.drawCircle(
            corner.translate(
              rng.nextDouble() * _tile,
              rng.nextDouble() * _tile,
            ),
            rng.nextDouble() * 1.8 + 0.4,
            i.isEven ? dark : light,
          );
        }
      }
    }
    canvas.restore();
    // A wooden frame around the cork.
    canvas.drawRect(
      (Offset.zero & size).deflate(6),
      Paint()
        ..color = const Color(0xFF5D3F25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
  }

  @override
  bool shouldRepaint(CorkPainter old) => old.origin != origin;
}

/// Where the string between two pins sags to, and where its label hangs.
({Offset control, Offset middle}) sag(Offset a, Offset b) {
  final drop = 20 + (b - a).distance * 0.06;
  final control = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + drop);
  return (control: control, middle: (a + b) / 2 * 0.5 + control * 0.5);
}

/// Red string between pins, and the black thread of the timeline.
class StringPainter extends CustomPainter {
  const StringPainter(this.links, {this.timeline = const []});

  final List<(Offset, Offset)> links;

  /// Pins along the night's timeline, left to right.
  final List<Offset> timeline;

  @override
  void paint(Canvas canvas, Size size) {
    if (timeline.length > 1) {
      final thread = Paint()
        ..color = const Color(0xFF1B1B1B)
        ..strokeWidth = 2.5;
      canvas.drawLine(timeline.first, timeline.last, thread);
      for (final t in timeline) {
        canvas.drawLine(t.translate(0, -9), t.translate(0, 9), thread);
      }
    }
    final paint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final shadow = Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final (a, b) in links) {
      final (:control, middle: _) = sag(a, b);
      Path curve(Offset shift) => Path()
        ..moveTo(a.dx + shift.dx, a.dy + shift.dy)
        ..quadraticBezierTo(
          control.dx + shift.dx,
          control.dy + shift.dy,
          b.dx + shift.dx,
          b.dy + shift.dy,
        );
      canvas
        ..drawPath(curve(const Offset(2, 3)), shadow)
        ..drawPath(curve(Offset.zero), paint);
    }
  }

  @override
  bool shouldRepaint(StringPainter old) => true;
}

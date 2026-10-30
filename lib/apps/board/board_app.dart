import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../poltel/lab/inspection_page.dart';

/// Evidence the player hasn't looked at yet, for the home screen badge.
int newEvidenceCount(StoryProgress progress) => _visible(
  progress,
).where((e) => !progress.hasSeen('evidence:${e.id}')).length;

List<Evidence> _visible(StoryProgress progress) => [
  for (final e in StoryData.current.evidence)
    if (progress.meets(e.requires)) e,
];

/// A cork board with every piece of evidence pinned to it and red string
/// between related pieces. Inspections happen in Poltel's lab.
class BoardApp extends StatelessWidget {
  const BoardApp({super.key});

  static const _cardWidth = 150.0;
  static const _rowHeight = 230.0;

  /// Where card [index] hangs on a board [width] wide.
  static Offset _position(int index, double width) {
    final rng = Random(index * 131 + 7);
    final col = index % 2;
    final row = index ~/ 2;
    final x =
        (col == 0 ? width * 0.27 : width * 0.73) +
        (rng.nextDouble() - 0.5) * 24;
    final y = 120 + row * _rowHeight + col * 70 + rng.nextDouble() * 20;
    return Offset(x, y);
  }

  void _open(BuildContext context, Evidence evidence) {
    StoryProgress.instance.markSeen('evidence:${evidence.id}');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EvidenceSheet(evidence: evidence),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF4A3424),
        body: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            final evidence = _visible(progress);
            final ids = {for (final e in evidence) e.id};
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final positions = {
                  for (var i = 0; i < evidence.length; i++)
                    evidence[i].id: _position(i, width),
                };
                final height = max(
                  constraints.maxHeight,
                  200 + (evidence.length / 2).ceil() * _rowHeight + 120,
                );
                return SingleChildScrollView(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: CustomPaint(painter: _CorkPainter()),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StringPainter([
                              for (final e in evidence)
                                for (final link in e.links)
                                  if (ids.contains(link))
                                    (positions[e.id]!, positions[link]!),
                            ]),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: "Back",
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    heightFactor: 1,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Transform.rotate(
                                        angle: -0.03,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          color: const Color(0xFFF5F0E1),
                                          child: const Text(
                                            "BERAT YILMAZ — DELİLLER",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.5,
                                              color: Color(0xFF2B2B2B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                          ),
                        ),
                        if (evidence.isEmpty)
                          Center(
                            child: Transform.rotate(
                              angle: 0.04,
                              child: Container(
                                width: 220,
                                padding: const EdgeInsets.all(18),
                                color: const Color(0xFFFFF59D),
                                child: const Text(
                                  "Pano boş.\nEkibi sahaya gönder, deliller buraya asılır.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, height: 1.4),
                                ),
                              ),
                            ),
                          ),
                        for (var i = 0; i < evidence.length; i++)
                          Positioned(
                            left:
                                positions[evidence[i].id]!.dx - _cardWidth / 2,
                            top: positions[evidence[i].id]!.dy - 8,
                            width: _cardWidth,
                            child: _EvidenceCard(
                              evidence: evidence[i],
                              tilt:
                                  (Random(i * 17 + 3).nextDouble() - 0.5) *
                                  0.12,
                              isNew: !progress.hasSeen(
                                'evidence:${evidence[i].id}',
                              ),
                              onTap: () => _open(context, evidence[i]),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({
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
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: tilt,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              decoration: BoxDecoration(
                color: image == null
                    ? const Color(0xFFFFF59D)
                    : const Color(0xFFFAFAF5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x80000000),
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (image != null)
                    AspectRatio(
                      aspectRatio: 1,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Color(0x33704214),
                          BlendMode.multiply,
                        ),
                        // Torn pieces stay a jumble until the lab puts
                        // them back together.
                        child:
                            pending && evidence.inspection is JigsawInspection
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: 7,
                                      sigmaY: 7,
                                    ),
                                    child: Image.asset(
                                      image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ],
                              )
                            : Image.asset(image, fit: BoxFit.cover),
                      ),
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
            const _Pin(),
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

class _Pin extends StatelessWidget {
  const _Pin();

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

class _CorkPainter extends CustomPainter {
  const _CorkPainter();

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
    final rng = Random(42);
    final dark = Paint()..color = const Color(0x33402510);
    final light = Paint()..color = const Color(0x22FFF3E0);
    final count = (size.width * size.height / 260).round();
    for (var i = 0; i < count; i++) {
      final point = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      );
      canvas.drawCircle(
        point,
        rng.nextDouble() * 1.8 + 0.4,
        i.isEven ? dark : light,
      );
    }
  }

  @override
  bool shouldRepaint(_CorkPainter old) => false;
}

/// Red string that sags a little between two pins.
class _StringPainter extends CustomPainter {
  const _StringPainter(this.links);

  final List<(Offset, Offset)> links;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final shadow = Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final (a, b) in links) {
      final middle = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + 30);
      Path curve(Offset shift) => Path()
        ..moveTo(a.dx + shift.dx, a.dy + shift.dy)
        ..quadraticBezierTo(
          middle.dx + shift.dx,
          middle.dy + shift.dy,
          b.dx + shift.dx,
          b.dy + shift.dy,
        );
      canvas
        ..drawPath(curve(const Offset(2, 3)), shadow)
        ..drawPath(curve(Offset.zero), paint);
    }
  }

  @override
  bool shouldRepaint(_StringPainter old) => true;
}

class _EvidenceSheet extends StatelessWidget {
  const _EvidenceSheet({required this.evidence});

  final Evidence evidence;

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    final inspection = evidence.inspection;
    final done = progress.isInspected(evidence.id);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              evidence.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            // Selectable, so a hidden line can be copied into Şifre Çözücü.
            SelectableText(evidence.description),
            if (evidence.image case final image?
                when inspection == null || done) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image),
              ),
            ],
            if (inspection != null) ...[
              const SizedBox(height: 16),
              if (done)
                Card(
                  color: AppColors.background,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(inspection.result),
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => InspectionPage(evidence: evidence),
                      ),
                    );
                  },
                  icon: const Icon(Icons.science_rounded),
                  // Pending inspections go on from here while a suspension
                  // locks Poltel, so the case can't get stuck.
                  label: Text(
                    progress.lockOf('Poltel') == null
                        ? "Poltel Laboratuvarı'nda incele"
                        : "Laboratuvar talebini sürdür",
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../story/story_data.dart';
import '../../../story/story_progress.dart';
import '../../../theme/app_theme.dart';
import '../document_pages.dart' show poltelNavy;
import 'fingerprint_game.dart';
import 'jigsaw_game.dart';
import 'uv_game.dart';

/// Poltel's forensic lab: the minigame for one piece of evidence and, once
/// it's solved, the lab's findings.
class InspectionPage extends StatefulWidget {
  const InspectionPage({super.key, required this.evidence});

  final Evidence evidence;

  @override
  State<InspectionPage> createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  final StoryProgress _progress = StoryProgress.instance;

  Evidence get _evidence => widget.evidence;

  Future<void> _solved() async {
    await _progress.completeInspection(_evidence);
    if (mounted) setState(() {});
  }

  Widget _game(Inspection inspection) {
    final image = _evidence.image ?? '';
    return switch (inspection) {
      JigsawInspection(:final rows, :final cols) => JigsawGame(
        image: image,
        rows: rows,
        cols: cols,
        onSolved: _solved,
      ),
      FingerprintInspection(:final options, :final answer) => FingerprintGame(
        options: options,
        answer: answer,
        onSolved: _solved,
      ),
      UvInspection(:final hiddenText) => UvGame(
        image: image,
        hiddenText: hiddenText,
        onSolved: _solved,
      ),
    };
  }

  /// What the evidence looks like once the lab is done with it.
  Widget _solvedView(Inspection inspection) {
    final image = _evidence.image;
    return switch (inspection) {
      FingerprintInspection(:final answer) => Row(
        children: [
          SizedBox.square(
            dimension: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomPaint(
                painter: FingerprintPainter(FingerprintPainter.seedFor(answer)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Eşleşme: $answer",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      UvInspection(:final hiddenText) when image != null => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(image),
            const Positioned.fill(child: ColoredBox(color: Color(0x993A0CA3))),
            Text(
              hiddenText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB6FF6B),
                fontSize: 24,
                height: 1.5,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Color(0xFF7CFF3A), blurRadius: 12)],
              ),
            ),
          ],
        ),
      ),
      _ when image != null => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(image),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final inspection = _evidence.inspection;
    final done = _progress.isInspected(_evidence.id);
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECF2),
      appBar: AppBar(
        backgroundColor: poltelNavy,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          "POLTEL · LABORATUVAR",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _evidence.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            _evidence.description,
            style: const TextStyle(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: 16),
          if (inspection == null)
            const Text("Bu delil için laboratuvar incelemesi gerekmiyor.")
          else ...[
            if (!done)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.science_rounded, color: poltelNavy),
                    const SizedBox(width: 8),
                    Expanded(child: Text(inspection.instructions)),
                  ],
                ),
              ),
            if (done) _solvedView(inspection) else _game(inspection),
            if (done) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_rounded, color: AppColors.green),
                          SizedBox(width: 8),
                          Text(
                            "LABORATUVAR SONUCU",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        inspection.result,
                        style: const TextStyle(fontSize: 16, height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

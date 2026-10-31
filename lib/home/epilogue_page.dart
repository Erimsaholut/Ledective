import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../story/story_data.dart';
import '../story/story_progress.dart';
import '../theme/turkish_text.dart';

/// The end of the game: how the case, the detective and everyone around
/// them turned out, one part at a time.
class EpiloguePage extends StatefulWidget {
  const EpiloguePage({super.key});

  @override
  State<EpiloguePage> createState() => _EpiloguePageState();
}

class _EpiloguePageState extends State<EpiloguePage>
    with SingleTickerProviderStateMixin {
  late final List<(EndingSection, EndingVariant)> _parts = _partsNow();

  /// The parts of the ending; the hidden ending takes the place of all.
  static List<(EndingSection, EndingVariant)> _partsNow() {
    final endings = StoryData.current.endings;
    final secret = endings.secret;
    if (secret != null && StoryProgress.instance.breakingDown) {
      return [
        (
          const EndingSection(id: 'secret', title: 'Gerçek', variants: []),
          EndingVariant(
            title: secret.title,
            text: secret.paragraphs.join('\n\n'),
          ),
        ),
      ];
    }
    return [
      for (final section in endings.sections)
        if (StoryProgress.instance.ending(section) case final variant?)
          (section, variant),
    ];
  }

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 900 * (_parts.length + 1)),
  )..forward();

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  Widget _fadeIn(int index, Widget child) {
    final step = 1 / (_parts.length + 1);
    final start = (index * step).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _reveal,
        curve: Interval(start, (start + step).clamp(0.0, 1.0)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = StoryData.current.endings.title;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
            children: [
              _fadeIn(
                0,
                Text(
                  turkishUpper(title.isEmpty ? "Son" : title),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontSize: 28,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              for (final (i, (section, variant)) in _parts.indexed)
                _fadeIn(
                  i + 1,
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turkishUpper(section.title),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (variant.title.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            variant.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'serif',
                              fontSize: 22,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          variant.text,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Telefona dön",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

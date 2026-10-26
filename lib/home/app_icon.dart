import 'dart:math';

import 'package:flutter/material.dart';

import '../story/story_progress.dart';
import '../theme/turkish_dates.dart';

/// A home screen icon: a rounded square with a gradient and a glyph, like a
/// real phone's app icons. Tapping it zooms [app] open from the icon.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.title,
    required this.app,
    this.iconData,
    this.colors = const [Color(0xFF8E8E93), Color(0xFF636366)],
    this.glyphColor = Colors.white,
    this.artwork,
    this.badgeCount,
    this.showLabel = true,
  });

  static const double size = 60;

  final String title;
  final Widget app;
  final IconData? iconData;

  /// Background gradient, top to bottom.
  final List<Color> colors;
  final Color glyphColor;

  /// Draws the whole icon instead of [iconData] on [colors], for icons with
  /// live content such as the calendar's date.
  final Widget Function(double size)? artwork;

  /// Number shown in a red badge, recomputed when the story progresses.
  final int Function(StoryProgress progress)? badgeCount;
  final bool showLabel;

  void _open(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final screen = MediaQuery.sizeOf(context);
    var origin = Alignment.center;
    if (box != null && box.hasSize) {
      final center = box.localToGlobal(box.size.center(Offset.zero));
      origin = Alignment(
        center.dx / screen.width * 2 - 1,
        center.dy / screen.height * 2 - 1,
      );
    }
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        settings: RouteSettings(name: title),
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => app,
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0, 0.5),
            ),
            child: ScaleTransition(
              alignment: origin,
              scale: Tween(begin: 0.1, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile() {
    final art = artwork;
    final tile = art != null
        ? art(size)
        : DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
            child: Center(
              child: Icon(iconData, size: size * 0.56, color: glyphColor),
            ),
          );
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size * 0.225)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.225),
        child: tile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = _buildTile();
    final count = badgeCount;
    if (count != null) {
      icon = ListenableBuilder(
        listenable: StoryProgress.instance,
        builder: (context, child) {
          final value = count(StoryProgress.instance);
          return Badge(
            isLabelVisible: value > 0,
            label: Text('$value'),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            largeSize: 22,
            backgroundColor: const Color(0xFFFF3B30),
            offset: const Offset(4, -4),
            child: child,
          );
        },
        child: icon,
      );
    }
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _open(context),
        child: SizedBox(
          width: size + 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PressableScale(child: icon),
              if (showLabel) ...[
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(color: Color(0x80000000), blurRadius: 4)],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dims and shrinks its child slightly while pressed.
class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child});

  final Widget child;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (mounted && pressed != _pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.7 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}

/// The calendar icon shows today's weekday and date.
Widget calendarArtwork(double size) {
  final now = DateTime.now();
  return ColoredBox(
    color: Colors.white,
    child: Column(
      children: [
        SizedBox(height: size * 0.1),
        Text(
          turkishWeekdayAbbreviations[now.weekday - 1].toUpperCase(),
          style: TextStyle(
            color: const Color(0xFFFF3B30),
            fontSize: size * 0.17,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              '${now.day}',
              style: TextStyle(
                color: const Color(0xFF1C1C1E),
                fontSize: size * 0.5,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// The clock icon is a small live analog clock.
Widget clockArtwork(double size) => const _LiveClockArtwork();

class _LiveClockArtwork extends StatefulWidget {
  const _LiveClockArtwork();

  @override
  State<_LiveClockArtwork> createState() => _LiveClockArtworkState();
}

class _LiveClockArtworkState extends State<_LiveClockArtwork> {
  late DateTime _now = DateTime.now();
  late final Stream<DateTime> _ticks = Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: StreamBuilder<DateTime>(
          stream: _ticks,
          initialData: _now,
          builder: (context, snapshot) {
            _now = snapshot.data ?? _now;
            return CustomPaint(
              painter: ClockFacePainter(_now),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

/// A white analog clock face with an orange second hand.
class ClockFacePainter extends CustomPainter {
  ClockFacePainter(this.time, {this.dark = false});

  final DateTime time;

  /// Dark face with white hands, for the Clock app.
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final face = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final ink = dark ? Colors.white : const Color(0xFF1C1C1E);
    canvas.drawCircle(center, radius, Paint()..color = face);

    for (var i = 0; i < 60; i++) {
      final major = i % 5 == 0;
      if (!major && radius < 60) continue;
      final angle = i * pi / 30;
      final direction = Offset(sin(angle), -cos(angle));
      canvas.drawLine(
        center + direction * radius * (major ? 0.8 : 0.86),
        center + direction * radius * 0.92,
        Paint()
          ..color = major ? ink : ink.withValues(alpha: 0.4)
          ..strokeWidth = radius * (major ? 0.04 : 0.015),
      );
    }

    void hand(double turns, double length, double width, Color color) {
      final angle = turns * 2 * pi;
      canvas.drawLine(
        center,
        center + Offset(sin(angle), -cos(angle)) * radius * length,
        Paint()
          ..color = color
          ..strokeWidth = radius * width
          ..strokeCap = StrokeCap.round,
      );
    }

    final minutes = time.minute + time.second / 60;
    hand((time.hour % 12 + minutes / 60) / 12, 0.5, 0.08, ink);
    hand(minutes / 60, 0.75, 0.055, ink);
    hand(time.second / 60, 0.82, 0.02, const Color(0xFFFF9500));
    canvas.drawCircle(
      center,
      radius * 0.05,
      Paint()..color = const Color(0xFFFF9500),
    );
  }

  @override
  bool shouldRepaint(ClockFacePainter old) => old.time.second != time.second;
}

/// The Pian icon shows piano keys.
Widget pianoArtwork(double size) {
  return ColoredBox(
    color: const Color(0xFF1C1C1E),
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        size * 0.12,
        size * 0.2,
        size * 0.12,
        size * 0.16,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(size * 0.04),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FractionalTranslation(
                      translation: const Offset(0.5, 0),
                      child: i == 2 || i == 4
                          ? const SizedBox.shrink()
                          : Container(
                              width: size * 0.08,
                              height: size * 0.36,
                              color: const Color(0xFF1C1C1E),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// The Photos icon is a colourful flower of petals.
Widget photosArtwork(double size) {
  return const ColoredBox(
    color: Colors.white,
    child: CustomPaint(painter: _FlowerPainter(), size: Size.infinite),
  );
}

class _FlowerPainter extends CustomPainter {
  const _FlowerPainter();

  static const _petals = [
    Color(0xFFFFCC00),
    Color(0xFFFF9500),
    Color(0xFFFF3B30),
    Color(0xFFFF2D55),
    Color(0xFFAF52DE),
    Color(0xFF5856D6),
    Color(0xFF007AFF),
    Color(0xFF34C759),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final petal = size.width * 0.17;
    for (var i = 0; i < _petals.length; i++) {
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(i * 2 * pi / _petals.length)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-petal / 2, -petal * 2.1, petal, petal * 1.8),
            Radius.circular(petal / 2),
          ),
          Paint()..color = _petals[i].withValues(alpha: 0.85),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_FlowerPainter old) => false;
}

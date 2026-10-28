import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'space_run.dart';

/// Uzay Kaçağı from AppShop: steer a rocket through falling asteroids and
/// catch fuel cans before the tank runs dry.
class SpaceRunnerApp extends StatefulWidget {
  const SpaceRunnerApp({super.key, this.random});

  /// Where the longest run is saved.
  static const bestKey = 'spaceRunner.best';

  /// Makes runs repeatable in tests.
  final Random? random;

  @override
  State<SpaceRunnerApp> createState() => _SpaceRunnerAppState();
}

class _SpaceRunnerAppState extends State<SpaceRunnerApp>
    with SingleTickerProviderStateMixin {
  static const _background = Color(0xFF0B0A24);

  late final Ticker _ticker = createTicker(_onTick);
  SpaceRun? _run;
  Duration _lastTick = Duration.zero;
  int _best = 0;
  bool _newBest = false;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt(SpaceRunnerApp.bestKey) ?? 0;
    if (mounted) setState(() => _best = best);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _run = SpaceRun(random: widget.random);
      _newBest = false;
    });
    _lastTick = Duration.zero;
    _ticker
      ..stop()
      ..start();
  }

  void _onTick(Duration elapsed) {
    final run = _run;
    if (run == null) return;
    // A long frame (or a tab in the background) shouldn't teleport rocks.
    final dt = min((elapsed - _lastTick).inMicroseconds / 1e6, 0.05);
    _lastTick = elapsed;
    setState(() => run.update(dt));
    if (run.isOver) {
      _ticker.stop();
      _finish(run);
    }
  }

  Future<void> _finish(SpaceRun run) async {
    if (run.metres <= _best) return;
    setState(() {
      _best = run.metres;
      _newBest = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SpaceRunnerApp.bestKey, run.metres);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final run = _run;
    final key = event.logicalKey;
    final direction = key == LogicalKeyboardKey.arrowLeft
        ? -1
        : key == LogicalKeyboardKey.arrowRight
        ? 1
        : 0;
    if (direction != 0 && run != null) {
      if (event is KeyUpEvent) {
        if (run.steer == direction) run.steer = 0;
      } else {
        run.steer = direction;
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.space && event is KeyDownEvent) {
      if (run == null || run.isOver) _start();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final run = _run;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text("Uzay Kaçağı"),
        backgroundColor: _background,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1 / SpaceRun.height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  void steer(Offset position) =>
                      run?.moveTo(position.dx / width);
                  return ClipRect(
                    child: GestureDetector(
                      onPanDown: (d) => steer(d.localPosition),
                      onPanUpdate: (d) => steer(d.localPosition),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(painter: _SpacePainter(run, _stars)),
                          if (run != null) _Hud(run: run),
                          if (run == null)
                            _Overlay(
                              title: "Uzay Kaçağı",
                              message:
                                  "Parmağınla roketi sağa sola kaydır. "
                                  "Asteroitlerden kaç, yakıt bidonlarını "
                                  "topla.",
                              best: _best,
                              button: "Başla",
                              onPressed: _start,
                            )
                          else if (run.isOver)
                            _Overlay(
                              title: run.end == SpaceRunEnd.crashed
                                  ? "Asteroide çarptın!"
                                  : "Yakıtın bitti!",
                              message:
                                  "${run.metres} m yol aldın, "
                                  "${run.fuelCollected} bidon topladın.",
                              highlight: _newBest ? "Yeni rekor!" : null,
                              best: _best,
                              button: "Tekrar dene",
                              onPressed: _start,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  static final List<_Star> _stars = () {
    final random = Random(42);
    return [
      for (var i = 0; i < 70; i++)
        _Star(
          random.nextDouble(),
          random.nextDouble() * SpaceRun.height,
          0.2 + random.nextDouble() * 0.6,
        ),
    ];
  }();
}

class _Star {
  const _Star(this.x, this.y, this.depth);

  final double x;
  final double y;

  /// From far (small, slow) to near (big, fast).
  final double depth;
}

/// Fuel gauge and distance along the top of the field.
class _Hud extends StatelessWidget {
  const _Hud({required this.run});

  final SpaceRun run;

  @override
  Widget build(BuildContext context) {
    final low = run.fuel < 0.25;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.local_gas_station_rounded,
              color: low ? const Color(0xFFFF5C5C) : const Color(0xFFFFB347),
              size: 20,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: run.fuel,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  color: low
                      ? const Color(0xFFFF5C5C)
                      : const Color(0xFFFFB347),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              "${run.metres} m",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card shown before a run and after it ends.
class _Overlay extends StatelessWidget {
  const _Overlay({
    required this.title,
    required this.message,
    required this.best,
    required this.button,
    required this.onPressed,
    this.highlight,
  });

  final String title;
  final String message;
  final String? highlight;
  final int best;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black38,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1A45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                color: Color(0xFFB69CFF),
                size: 48,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (highlight != null) ...[
                const SizedBox(height: 4),
                Text(
                  highlight!,
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, height: 1.35),
              ),
              const SizedBox(height: 8),
              Text(
                "Rekor: $best m",
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7F5AF0),
                  minimumSize: const Size(160, 44),
                ),
                child: Text(button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stars, falling objects and the rocket, scaled so the field is 1 wide.
class _SpacePainter extends CustomPainter {
  _SpacePainter(this.run, this.stars);

  final SpaceRun? run;
  final List<_Star> stars;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B0A24), Color(0xFF231A4F)],
        ).createShader(Offset.zero & size),
    );
    final scale = size.width;
    canvas.save();
    canvas.scale(scale);
    final run = this.run;
    final travelled = run?.distance ?? 0;
    final time = run?.time ?? 0;

    final star = Paint()..color = Colors.white;
    for (final s in stars) {
      final y = (s.y + travelled * s.depth * 0.5) % SpaceRun.height;
      star.color = Colors.white.withValues(alpha: 0.3 + s.depth * 0.6);
      canvas.drawCircle(Offset(s.x, y), 0.002 + s.depth * 0.004, star);
    }

    if (run != null) {
      for (final object in run.objects) {
        if (object.isFuel) {
          _paintFuel(canvas, object);
        } else {
          _paintAsteroid(canvas, object, time);
        }
      }
      _paintRocket(
        canvas,
        run.rocketX,
        time,
        crashed: run.end == SpaceRunEnd.crashed,
      );
    } else {
      _paintRocket(canvas, 0.5, 0);
    }
    canvas.restore();
  }

  void _paintAsteroid(Canvas canvas, SpaceObject rock, double time) {
    canvas
      ..save()
      ..translate(rock.x, rock.y)
      ..rotate(time * rock.spin * 2 * pi);
    final r = rock.radius;
    final outline = Path();
    for (var i = 0; i < 9; i++) {
      final angle = i * 2 * pi / 9;
      // A lumpy outline, the same for a rock throughout its fall.
      final bump = 0.82 + 0.18 * sin(i * 2.7 + r * 97);
      final point = Offset(cos(angle), sin(angle)) * r * bump;
      i == 0
          ? outline.moveTo(point.dx, point.dy)
          : outline.lineTo(point.dx, point.dy);
    }
    outline.close();
    canvas.drawPath(outline, Paint()..color = const Color(0xFF8C7B6B));
    final crater = Paint()..color = const Color(0xFF6B5B4D);
    canvas
      ..drawCircle(Offset(-r * 0.3, -r * 0.2), r * 0.22, crater)
      ..drawCircle(Offset(r * 0.35, r * 0.25), r * 0.16, crater)
      ..drawCircle(Offset(r * 0.1, -r * 0.45), r * 0.1, crater)
      ..restore();
  }

  void _paintFuel(Canvas canvas, SpaceObject can) {
    final r = can.radius;
    canvas.drawCircle(
      Offset(can.x, can.y),
      r * 1.5,
      Paint()..color = const Color(0x33FFB347),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: Offset(can.x, can.y), radius: r),
        Radius.circular(r * 0.35),
      ),
      Paint()..color = const Color(0xFFFF9F1C),
    );
    // A white fuel drop on the can.
    final drop = Path()
      ..moveTo(can.x, can.y - r * 0.6)
      ..quadraticBezierTo(
        can.x + r * 0.5,
        can.y,
        can.x + r * 0.4,
        can.y + r * 0.2,
      )
      ..arcToPoint(
        Offset(can.x - r * 0.4, can.y + r * 0.2),
        radius: Radius.circular(r * 0.42),
      )
      ..quadraticBezierTo(can.x - r * 0.5, can.y, can.x, can.y - r * 0.6)
      ..close();
    canvas.drawPath(drop, Paint()..color = Colors.white);
  }

  void _paintRocket(
    Canvas canvas,
    double x,
    double time, {
    bool crashed = false,
  }) {
    const r = SpaceRun.rocketRadius;
    canvas
      ..save()
      ..translate(x, SpaceRun.rocketY);
    if (!crashed) {
      final flicker = 0.8 + 0.2 * sin(time * 40);
      final flame = Path()
        ..moveTo(-r * 0.4, r * 0.9)
        ..lineTo(0, r * (1.6 + flicker))
        ..lineTo(r * 0.4, r * 0.9)
        ..close();
      canvas.drawPath(flame, Paint()..color = const Color(0xFFFFB347));
    }
    final fins = Path()
      ..moveTo(-r * 0.45, r * 0.1)
      ..lineTo(-r * 0.95, r * 1.0)
      ..lineTo(r * 0.95, r * 1.0)
      ..lineTo(r * 0.45, r * 0.1)
      ..close();
    canvas.drawPath(fins, Paint()..color = const Color(0xFFE63946));
    final body = Path()
      ..moveTo(0, -r * 1.4)
      ..quadraticBezierTo(r * 0.6, -r * 0.6, r * 0.5, r * 0.95)
      ..lineTo(-r * 0.5, r * 0.95)
      ..quadraticBezierTo(-r * 0.6, -r * 0.6, 0, -r * 1.4)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..color = crashed ? const Color(0xFF777777) : const Color(0xFFF1F1F6),
    );
    canvas
      ..drawCircle(
        Offset(0, -r * 0.3),
        r * 0.24,
        Paint()..color = const Color(0xFF4CC9F0),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_SpacePainter old) => true;
}

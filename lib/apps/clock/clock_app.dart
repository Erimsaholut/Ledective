import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../home/app_icon.dart' show ClockFacePainter;
import '../../theme/turkish_dates.dart';

const _orange = Color(0xFFFF9F0A);
const _green = Color(0xFF30D158);
const _red = Color(0xFFFF453A);
const _grey = Color(0xFF333333);

String _twoDigits(int n) => n.toString().padLeft(2, '0');

class ClockApp extends StatefulWidget {
  const ClockApp({super.key});

  @override
  State<ClockApp> createState() => _ClockAppState();
}

class _ClockAppState extends State<ClockApp> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: _orange,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            const ['World Clock', 'Digital', 'Stopwatch', 'Timer'][_tab],
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: IndexedStack(
          index: _tab,
          children: const [
            _WorldClockPage(),
            _DigitalClockPage(),
            _StopwatchPage(),
            _TimerPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF121212),
          indicatorColor: Colors.transparent,
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.public_rounded),
              selectedIcon: Icon(Icons.public_rounded, color: _orange),
              label: 'World Clock',
            ),
            NavigationDestination(
              icon: Icon(Icons.schedule_rounded),
              selectedIcon: Icon(Icons.schedule_rounded, color: _orange),
              label: 'Digital',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer_rounded, color: _orange),
              label: 'Stopwatch',
            ),
            NavigationDestination(
              icon: Icon(Icons.hourglass_empty_rounded),
              selectedIcon: Icon(
                Icons.hourglass_bottom_rounded,
                color: _orange,
              ),
              label: 'Timer',
            ),
          ],
        ),
      ),
    );
  }
}

/// Rebuilds [builder] with the current time every second.
class _Ticking extends StatefulWidget {
  const _Ticking({required this.builder});

  final Widget Function(DateTime now) builder;

  @override
  State<_Ticking> createState() => _TickingState();
}

class _TickingState extends State<_Ticking> {
  late DateTime _now = DateTime.now();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_now);
}

class _WorldClockPage extends StatelessWidget {
  const _WorldClockPage();

  /// "Bugün", "Yarın" or "Dün" for [other] seen from [now]'s calendar day.
  static String _dayLabel(DateTime now, DateTime other) {
    final a = DateTime.utc(now.year, now.month, now.day);
    final b = DateTime.utc(other.year, other.month, other.day);
    return switch (b.difference(a).inDays) {
      0 => 'Bugün',
      > 0 => 'Yarın',
      _ => 'Dün',
    };
  }

  static const _cities = [
    (name: 'İstanbul', offset: 3),
    (name: 'Londra', offset: 0),
    (name: 'New York', offset: -5),
    (name: 'Tokyo', offset: 9),
  ];

  @override
  Widget build(BuildContext context) {
    return _Ticking(
      builder: (now) {
        final utc = now.toUtc();
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),
            Center(
              child: SizedBox.square(
                dimension: 240,
                child: CustomPaint(painter: ClockFacePainter(now, dark: true)),
              ),
            ),
            const SizedBox(height: 16),
            for (final city in _cities) ...[
              const Divider(color: _grey),
              Builder(
                builder: (context) {
                  final local = utc.add(Duration(hours: city.offset));
                  final diff = city.offset - now.timeZoneOffset.inHours;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_dayLabel(now, local)}, '
                                '${diff >= 0 ? '+' : ''}$diff SA',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                city.name,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          clockTime(local),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w200,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DigitalClockPage extends StatelessWidget {
  const _DigitalClockPage();

  @override
  Widget build(BuildContext context) {
    return _Ticking(
      builder: (now) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: Text(
                '${clockTime(now)}:${_twoDigits(now.second)}',
                style: const TextStyle(
                  fontSize: 88,
                  fontWeight: FontWeight.w200,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Text(
              longTurkishDate(now),
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/// A round button in the style of the system clock app.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
      ),
      child: Material(
        color: color.withValues(alpha: onPressed == null ? 0.15 : 0.3),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 78,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: color == _grey ? Colors.white : color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Counts up from zero, with laps.
class _StopwatchPage extends StatefulWidget {
  const _StopwatchPage();

  @override
  State<_StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<_StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _laps = [];
  Timer? _ticker;

  void _toggle() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _ticker?.cancel();
      } else {
        _stopwatch.start();
        _ticker = Timer.periodic(
          const Duration(milliseconds: 30),
          (_) => setState(() {}),
        );
      }
    });
  }

  void _lapOrReset() {
    setState(() {
      if (_stopwatch.isRunning) {
        _laps.insert(0, _stopwatch.elapsed);
      } else {
        _stopwatch.reset();
        _laps.clear();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  static String _format(Duration d) {
    final centiseconds = (d.inMilliseconds % 1000) ~/ 10;
    return '${_twoDigits(d.inMinutes)}:${_twoDigits(d.inSeconds % 60)},'
        '${_twoDigits(centiseconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final running = _stopwatch.isRunning;
    final idle = !running && _stopwatch.elapsed == Duration.zero;
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: FittedBox(
              child: Text(
                _format(_stopwatch.elapsed),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w200,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundButton(
                label: running ? 'Lap' : 'Reset',
                color: _grey,
                onPressed: idle ? null : _lapOrReset,
              ),
              _RoundButton(
                label: running ? 'Stop' : 'Start',
                color: running ? _red : _green,
                onPressed: _toggle,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              for (var i = 0; i < _laps.length; i++) ...[
                const Divider(color: _grey),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tur ${_laps.length - i}'),
                      Text(
                        _format(
                          _laps[i] -
                              (i + 1 < _laps.length
                                  ? _laps[i + 1]
                                  : Duration.zero),
                        ),
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Counts down from a chosen duration, with a progress ring.
class _TimerPage extends StatefulWidget {
  const _TimerPage();

  @override
  State<_TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<_TimerPage> {
  static const _durations = [1, 5, 10, 30, 60];

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  int _minutes = 5;

  Duration get _total => Duration(minutes: _minutes);

  Duration get _remaining {
    final remaining = _total - _stopwatch.elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get _idle =>
      !_stopwatch.isRunning && _stopwatch.elapsed == Duration.zero;

  void _tick() {
    if (_remaining == Duration.zero) {
      _stopwatch.stop();
      _ticker?.cancel();
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(const SnackBar(content: Text("Time's up!")));
    }
    setState(() {});
  }

  void _toggle() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _ticker?.cancel();
      } else {
        if (_remaining == Duration.zero) _stopwatch.reset();
        _stopwatch.start();
        _ticker = Timer.periodic(
          const Duration(milliseconds: 200),
          (_) => _tick(),
        );
      }
    });
  }

  void _cancel() {
    setState(() {
      _stopwatch
        ..stop()
        ..reset();
      _ticker?.cancel();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Round up so the display only reaches 00:00 when time is really up.
    final seconds = (_remaining.inMilliseconds / 1000).ceil();
    final text = seconds >= 3600
        ? '${seconds ~/ 3600}:${_twoDigits(seconds ~/ 60 % 60)}:${_twoDigits(seconds % 60)}'
        : '${_twoDigits(seconds ~/ 60)}:${_twoDigits(seconds % 60)}';
    final progress = _remaining.inMilliseconds / _total.inMilliseconds;
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox.square(
          dimension: 280,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _RingPainter(progress)),
              Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final minutes in _durations)
              ChoiceChip(
                label: Text('$minutes dk'),
                selected: minutes == _minutes,
                selectedColor: _orange.withValues(alpha: 0.3),
                onSelected: _idle
                    ? (_) => setState(() => _minutes = minutes)
                    : null,
              ),
          ],
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundButton(
                label: 'Cancel',
                color: _grey,
                onPressed: _idle ? null : _cancel,
              ),
              _RoundButton(
                label: _stopwatch.isRunning ? 'Pause' : 'Start',
                color: _stopwatch.isRunning ? _orange : _green,
                onPressed: _toggle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(8);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, paint..color = _grey);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      paint..color = _orange,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

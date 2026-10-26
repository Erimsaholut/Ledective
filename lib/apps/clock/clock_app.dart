import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_clock/one_clock.dart';

class ClockApp extends StatefulWidget {
  const ClockApp({super.key});

  @override
  State<ClockApp> createState() => _ClockAppState();
}

class _ClockAppState extends State<ClockApp> {
  static const _tabs = [
    (icon: Icons.access_time_filled, tooltip: 'Analog'),
    (icon: Icons.watch_later_outlined, tooltip: 'Digital'),
    (icon: Icons.timer, tooltip: 'Stopwatch'),
    (icon: Icons.hourglass_bottom, tooltip: 'Timer'),
  ];

  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clock"),
        backgroundColor: Colors.grey.shade600,
      ),
      backgroundColor: Colors.grey,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _page = index),
        children: const [
          _AnalogClockPage(),
          _DigitalClockPage(),
          _StopwatchPage(),
          _TimerPage(),
        ],
      ),
      bottomNavigationBar: ColoredBox(
        color: Colors.grey.shade600,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                IconButton(
                  icon: Icon(_tabs[i].icon),
                  tooltip: _tabs[i].tooltip,
                  color: _page == i ? Colors.white : Colors.grey.shade400,
                  onPressed: () => _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');

class _AnalogClockPage extends StatelessWidget {
  const _AnalogClockPage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: AnalogClock(
        decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        secondHandColor: Colors.red,
        hourHandColor: Colors.white,
        minuteHandColor: Colors.white,
        numberColor: Colors.white,
        digitalClockColor: Colors.white,
        showAllNumbers: true,
        textScaleFactor: 1.4,
      ),
    );
  }
}

class _DigitalClockPage extends StatelessWidget {
  const _DigitalClockPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DigitalClock(
        textScaleFactor: 3.0,
        isLive: true,
        digitalClockTextColor: Colors.black,
      ),
    );
  }
}

class _ClockButton extends StatelessWidget {
  const _ClockButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: Colors.black, fontSize: 30),
      ),
    );
  }
}

/// Counts up from zero.
class _StopwatchPage extends StatefulWidget {
  const _StopwatchPage();

  @override
  State<_StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<_StopwatchPage>
    with AutomaticKeepAliveClientMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  bool get wantKeepAlive => true;

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

  void _reset() {
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
    super.build(context);
    final elapsed = _stopwatch.elapsed;
    final centiseconds = (elapsed.inMilliseconds % 1000) ~/ 10;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_twoDigits(elapsed.inMinutes)}:'
          '${_twoDigits(elapsed.inSeconds % 60)}.'
          '${_twoDigits(centiseconds)}',
          style: const TextStyle(
            fontSize: 64,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 80),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ClockButton(
              label: _stopwatch.isRunning ? 'Stop' : 'Start',
              onPressed: _toggle,
            ),
            const SizedBox(width: 60),
            _ClockButton(label: 'Reset', onPressed: _reset),
          ],
        ),
      ],
    );
  }
}

/// Counts down from a chosen duration.
class _TimerPage extends StatefulWidget {
  const _TimerPage();

  @override
  State<_TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<_TimerPage>
    with AutomaticKeepAliveClientMixin {
  static const _durations = [5, 10, 30, 60];

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  int _minutes = 30;

  @override
  bool get wantKeepAlive => true;

  Duration get _total => Duration(minutes: _minutes);

  Duration get _remaining {
    final remaining = _total - _stopwatch.elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

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

  void _reset() {
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
    super.build(context);
    // Round up so the display only reaches 00:00 when time is really up.
    final seconds = (_remaining.inMilliseconds / 1000).ceil();
    final isIdle = !_stopwatch.isRunning && _stopwatch.elapsed == Duration.zero;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          seconds >= 3600
              ? '${seconds ~/ 3600}:${_twoDigits(seconds ~/ 60 % 60)}:${_twoDigits(seconds % 60)}'
              : '${_twoDigits(seconds ~/ 60)}:${_twoDigits(seconds % 60)}',
          style: const TextStyle(
            fontSize: 64,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 20),
        DropdownButton<int>(
          value: _minutes,
          onChanged: isIdle
              ? (value) => setState(() => _minutes = value ?? _minutes)
              : null,
          items: [
            for (final minutes in _durations)
              DropdownMenuItem(value: minutes, child: Text('$minutes minutes')),
          ],
        ),
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ClockButton(
              label: _stopwatch.isRunning ? 'Pause' : 'Start',
              onPressed: _toggle,
            ),
            const SizedBox(width: 60),
            _ClockButton(label: 'Reset', onPressed: _reset),
          ],
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_clock/one_clock.dart';

class Clock extends StatefulWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  int pageNow = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {});
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopwatch.reset();
    setState(() {});
  }

  Widget _buildScreen() {
    switch (pageNow) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: AnalogClock(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            isLive: true,
            secondHandColor: Colors.red,
            hourHandColor: Colors.white,
            minuteHandColor: Colors.white,
            numberColor: Colors.white,
            showNumbers: true,
            showAllNumbers: true,
            textScaleFactor: 1.4,
            showTicks: true,
            showDigitalClock: true,
            datetime: DateTime.now(),
          ),
        );
      case 1:
        return SizedBox(
          width: double.infinity,
          child: DigitalClock(
            textScaleFactor: 3.0,
            showSeconds: true,
            isLive: true,
            digitalClockTextColor: Colors.black,
            decoration: const BoxDecoration(
              color: Colors.grey,
            ),
            datetime: DateTime.now(),
          ),
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    if (_stopwatch.isRunning) {
                      _stopwatch.stop();
                      _stopTimer();
                    } else {
                      _stopwatch.start();
                      _startTimer();
                    }
                  },
                  child: Text(
                    _stopwatch.isRunning ? 'Stop' : 'Start',
                    style: const TextStyle(color: Colors.black, fontSize: 30),
                  ),
                ),
                const SizedBox(width: 60),
                TextButton(
                  onPressed: () {
                    _stopwatch.reset();
                    _resetTimer();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.black, fontSize: 30),
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clock"),
        backgroundColor: Colors.grey.shade600,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade400),
                  child: _buildScreen(),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey.shade600,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.access_time_filled),
                        color: pageNow == 0 ? Colors.white : Colors.grey,
                        onPressed: () {
                          setState(() {
                            pageNow = 0;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.watch_later_outlined),
                        color: pageNow == 1 ? Colors.white : Colors.grey,
                        onPressed: () {
                          setState(() {
                            pageNow = 1;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.timer),
                        color: pageNow == 2 ? Colors.white : Colors.grey,
                        onPressed: () {
                          setState(() {
                            pageNow = 2;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

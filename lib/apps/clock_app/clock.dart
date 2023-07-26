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
  int _selectedDuration = 30;

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

  void _startStopwatch() {
    int durationInMilliseconds = _selectedDuration * 60000;
    int initialMilliseconds = _stopwatch.elapsed.inMilliseconds;

    if (initialMilliseconds >= durationInMilliseconds) {
      _stopwatch.reset();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      int elapsedMilliseconds = _stopwatch.elapsed.inMilliseconds;
      int remainingMilliseconds = durationInMilliseconds - elapsedMilliseconds;

      if (remainingMilliseconds <= 0) {
        _stopwatch.stop();
        timer.cancel();
      } else {
        setState(() {});
      }
    });

    _stopwatch.start();
    setState(() {});
  }


  Widget _buildAnalogClock() {
    return Container(
      color: Colors.grey,
      child: Padding(
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
      ),
    );
  }

  Widget _buildDigitalClock() {
    return const SizedBox(
      width: double.infinity,
      child: DigitalClock(
        textScaleFactor: 3.0,
        showSeconds: true,
        isLive: true,
        digitalClockTextColor: Colors.black,
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
      ),);
  }

  Widget _buildTimerClock() {
    return Container(
      color: Colors.grey,
      child: Column(
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
                  if (_stopwatch.isRunning) {
                    _stopwatch.stop();
                    _stopTimer();
                  }
                },
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStopwatchClock() {
    return Container(
      color: Colors.grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_stopwatch.elapsed.inHours.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _startStopwatch();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600, // Set button color
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  _stopwatch.stop();
                  _timer?.cancel();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600, // Set button color
                ),
                child: const Text(
                  'Stop',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  _stopwatch.reset();
                  _timer?.cancel();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600, // Set button color
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButton<int>(
              value: _selectedDuration,
              onChanged: (newValue) {
                setState(() {
                  _selectedDuration = newValue!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 5,
                  child: Text('5 minutes'),
                ),
                DropdownMenuItem(
                  value: 10,
                  child: Text('10 minutes'),
                ),
                DropdownMenuItem(
                  value: 30,
                  child: Text('30 minutes'),
                ),
                DropdownMenuItem(
                  value: 60,
                  child: Text('60 minutes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildAnalogClock(),
      _buildDigitalClock(),
      _buildTimerClock(),
      _buildStopwatchClock(), // Dördüncü sayfayı ekledik
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clock"),
        backgroundColor: Colors.grey.shade600,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 10,
            child: PageView(
              children: pages,
              onPageChanged: (index) {
                setState(() {
                  pageNow = index;
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade600,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < pages.length; i++)
                    IconButton(
                      icon: Icon(
                        i == 0
                            ? Icons.access_time_filled
                            : i == 1
                            ? Icons.watch_later_outlined
                            : i == 2
                            ? Icons.timer
                            : Icons.watch, // Stopwatch icon ekledik
                      ),
                      color: pageNow == i ? Colors.white : Colors.grey,
                      onPressed: () {
                        setState(() {
                          pageNow = i;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
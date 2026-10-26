import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../data/recent_calls.dart';
import '../../widgets/round_icon_button.dart';

/// A fake outgoing call that nobody answers. Hangs up by itself after
/// [ringDuration].
class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.number,
    this.person,
    this.ringDuration = const Duration(seconds: 15),
  });

  final String number;
  final String? person;
  final Duration ringDuration;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();
  late final Animation<int> _dotCount = StepTween(
    begin: 0,
    end: 3,
  ).animate(_dots);
  late final Timer _hangUpTimer;

  bool _videoOn = true;
  bool _micOn = true;
  bool _speakerOn = true;

  String get _displayName {
    final person = widget.person;
    return person == null || person.isEmpty ? widget.number : person;
  }

  @override
  void initState() {
    super.initState();
    _hangUpTimer = Timer(widget.ringDuration, _hangUp);
    RecentCalls.add(Contact(name: _displayName, number: widget.number));
  }

  @override
  void dispose() {
    _hangUpTimer.cancel();
    _dots.dispose();
    super.dispose();
  }

  void _hangUp() {
    if (mounted) Navigator.pop(context);
  }

  Widget _toggle(
    bool on,
    IconData onIcon,
    IconData offIcon,
    ValueChanged<bool> setValue,
  ) {
    return RoundIconButton(
      myIcon: on ? onIcon : offIcon,
      backGroundColor: on ? null : Colors.white54,
      onPressed: () => setState(() => setValue(!on)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade200,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(color: Colors.black, fontSize: 28),
                ),
                const SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _dotCount,
                  builder: (context, _) => Text(
                    'Calling.${'.' * _dotCount.value}',
                    style: const TextStyle(color: Colors.grey, fontSize: 23),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toggle(
                  _videoOn,
                  Icons.videocam,
                  Icons.videocam_off,
                  (v) => _videoOn = v,
                ),
                _toggle(_micOn, Icons.mic, Icons.mic_off, (v) => _micOn = v),
                _toggle(
                  _speakerOn,
                  Icons.volume_up_rounded,
                  Icons.volume_off,
                  (v) => _speakerOn = v,
                ),
              ],
            ),
            RoundIconButton(
              myIcon: Icons.call_end,
              iconColor: Colors.red,
              onPressed: _hangUp,
            ),
          ],
        ),
      ),
    );
  }
}

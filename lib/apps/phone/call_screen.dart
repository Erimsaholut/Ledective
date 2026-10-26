import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/contacts_repository.dart';
import '../../data/recent_calls.dart';
import '../../widgets/avatar.dart';

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

  bool _muted = false;
  bool _speaker = false;
  bool _video = false;

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

  Widget _button(
    IconData icon,
    String label, {
    bool active = false,
    VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.18),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 74,
              child: Icon(
                icon,
                size: 32,
                color: active ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3A4A5C),
                    Color(0xFF1B232E),
                    Color(0xFF0D1117),
                  ],
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox.expand(),
            ),
            SafeArea(
              // Scrolls on short screens; Spacers spread it out on tall ones.
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Avatar(name: _displayName, radius: 46),
                          const SizedBox(height: 16),
                          Text(
                            _displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedBuilder(
                            animation: _dotCount,
                            builder: (context, _) => Text(
                              'aranıyor${'.' * _dotCount.value}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _button(
                                      _muted
                                          ? Icons.mic_off_rounded
                                          : Icons.mic_rounded,
                                      "sessiz",
                                      active: _muted,
                                      onTap: () =>
                                          setState(() => _muted = !_muted),
                                    ),
                                    _button(
                                      Icons.dialpad_rounded,
                                      "tuş takımı",
                                    ),
                                    _button(
                                      Icons.volume_up_rounded,
                                      "hoparlör",
                                      active: _speaker,
                                      onTap: () =>
                                          setState(() => _speaker = !_speaker),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _button(Icons.add_rounded, "arama ekle"),
                                    _button(
                                      _video
                                          ? Icons.videocam_rounded
                                          : Icons.videocam_off_rounded,
                                      "görüntülü",
                                      active: _video,
                                      onTap: () =>
                                          setState(() => _video = !_video),
                                    ),
                                    _button(Icons.person_rounded, "kişiler"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          Material(
                            color: const Color(0xFFFF3B30),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _hangUp,
                              child: const SizedBox.square(
                                dimension: 76,
                                child: Icon(
                                  Icons.call_end_rounded,
                                  color: Colors.white,
                                  size: 36,
                                  semanticLabel: "Kapat",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

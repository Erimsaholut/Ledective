import 'package:flutter/material.dart';

/// A soft, breathing halo behind [child] that draws the eye: a new place on
/// the map, a piece of evidence waiting for the lab. Off when [on] is false.
class Glow extends StatefulWidget {
  const Glow({
    super.key,
    required this.child,
    this.on = true,
    this.color = const Color(0xFFFFC107),
    this.radius = 26,
  });

  final Widget child;
  final bool on;
  final Color color;

  /// How far the halo reaches past the child's centre at its widest.
  final double radius;

  @override
  State<Glow> createState() => _GlowState();
}

class _GlowState extends State<Glow> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.on) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(Glow old) {
    super.didUpdateWidget(old);
    if (widget.on && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.on && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.on) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulse.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35 + 0.4 * t),
                blurRadius: widget.radius * (0.6 + 0.4 * t),
                spreadRadius: widget.radius * 0.15 * t,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

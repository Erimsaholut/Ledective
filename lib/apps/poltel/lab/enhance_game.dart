import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Brings a blurred camera still into focus with two dials, focus and
/// light. The picture sharpens as both come near their right place;
/// "Kaydet" only takes it once both are close enough.
class EnhanceGame extends StatefulWidget {
  const EnhanceGame({
    super.key,
    required this.image,
    required this.focus,
    required this.light,
    required this.onSolved,
  });

  final String image;

  /// Where each dial has to be, 0–1.
  final double focus;
  final double light;
  final VoidCallback onSolved;

  @override
  State<EnhanceGame> createState() => _EnhanceGameState();
}

class _EnhanceGameState extends State<EnhanceGame> {
  static const _close = 0.05;

  // Both start well away from the answer.
  late double _focus = widget.focus > 0.5 ? 0.1 : 0.9;
  late double _light = widget.light > 0.5 ? 0.1 : 0.9;
  String? _message;

  double get _focusOff => (_focus - widget.focus).abs();
  double get _lightOff => (_light - widget.light).abs();

  void _save() {
    if (_focusOff <= _close && _lightOff <= _close) {
      widget.onSolved();
      return;
    }
    setState(() {
      _message = _focusOff > _close
          ? "Görüntü hâlâ bulanık. Netliği ayarla."
          : "Ayrıntılar karanlıkta kalıyor. Işığı ayarla.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final blur = _focusOff * 28;
    // Too dark below the right light, washed out above it.
    final shift = (_light - widget.light) * 220;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.matrix([
                  1, 0, 0, 0, shift, //
                  0, 1, 0, 0, shift,
                  0, 0, 1, 0, shift,
                  0, 0, 0, 1, 0,
                ]),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Image.asset(widget.image, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: Text(
                  "CAM-02  23:41:07",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Dial(
          key: const ValueKey('enhance-focus'),
          icon: Icons.center_focus_strong_rounded,
          label: "Netlik",
          value: _focus,
          onChanged: (v) => setState(() {
            _focus = v;
            _message = null;
          }),
        ),
        _Dial(
          key: const ValueKey('enhance-light'),
          icon: Icons.wb_sunny_rounded,
          label: "Işık",
          value: _light,
          onChanged: (v) => setState(() {
            _light = v;
            _message = null;
          }),
        ),
        if (_message case final message?)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFC62828)),
            ),
          ),
        FilledButton.icon(
          key: const ValueKey('enhance-save'),
          onPressed: _save,
          icon: const Icon(Icons.save_alt_rounded),
          label: const Text("Kaydet"),
        ),
      ],
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 6),
        SizedBox(width: 48, child: Text(label)),
        Expanded(
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

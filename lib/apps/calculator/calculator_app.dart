import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calculator.dart';

const _orange = Color(0xFFFF9F0A);
const _dark = Color(0xFF333333);
const _light = Color(0xFFA5A5A5);

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  final Calculator _calculator = Calculator();

  void _press(void Function(Calculator calculator) action) {
    HapticFeedback.selectionClick();
    setState(() => action(_calculator));
  }

  @override
  Widget build(BuildContext context) {
    final c = _calculator;
    _Key digit(int d) =>
        _Key(label: '$d', color: _dark, onTap: () => _press((c) => c.digit(d)));
    _Key op(Operation o) => _Key(
      label: o.symbol,
      color: _orange,
      selected: c.pending == o,
      onTap: () => _press((c) => c.operation(o)),
    );
    final rows = [
      [
        _Key(
          label: c.clearsEntry ? 'C' : 'AC',
          color: _light,
          dark: true,
          onTap: () =>
              _press((c) => c.clearsEntry ? c.clearEntry() : c.clearAll()),
        ),
        _Key(
          label: '±',
          color: _light,
          dark: true,
          onTap: () => _press((c) => c.toggleSign()),
        ),
        _Key(
          label: '%',
          color: _light,
          dark: true,
          onTap: () => _press((c) => c.percent()),
        ),
        op(Operation.divide),
      ],
      [digit(7), digit(8), digit(9), op(Operation.multiply)],
      [digit(4), digit(5), digit(6), op(Operation.subtract)],
      [digit(1), digit(2), digit(3), op(Operation.add)],
      [
        _Key(
          label: '0',
          color: _dark,
          wide: true,
          onTap: () => _press((c) => c.digit(0)),
        ),
        _Key(
          label: ',',
          color: _dark,
          onTap: () => _press((c) => c.decimalPoint()),
        ),
        _Key(
          label: '=',
          color: _orange,
          onTap: () => _press((c) => c.equals()),
        ),
      ],
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.black,
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 14.0;
                  final byWidth = (constraints.maxWidth - 32 - gap * 3) / 4;
                  // Five rows of keys and a display at least as tall as one.
                  final byHeight = (constraints.maxHeight - 24 - gap * 5) / 6.4;
                  final size = byWidth < byHeight ? byWidth : byHeight;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: _Display(
                            text: c.display,
                            onSwipe: () => _press((c) => c.backspace()),
                          ),
                        ),
                        for (final row in rows) ...[
                          const SizedBox(height: gap),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (final (i, key) in row.indexed) ...[
                                if (i > 0) const SizedBox(width: gap),
                                SizedBox(
                                  width: key.wide ? size * 2 + gap : size,
                                  height: size,
                                  child: key,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
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
}

/// The number, right-aligned and shrinking to fit. Swiping it removes the
/// last digit.
class _Display extends StatelessWidget {
  const _Display({required this.text, required this.onSwipe});

  final String text;
  final VoidCallback onSwipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (_) => onSwipe(),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomRight,
            child: Text(
              text,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 88,
                fontWeight: FontWeight.w300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.color,
    required this.onTap,
    this.dark = false,
    this.wide = false,
    this.selected = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  /// Black text, for the light grey keys.
  final bool dark;

  /// Twice as wide, for 0.
  final bool wide;

  /// An operation waiting for its second number shows inverted.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final background = selected ? Colors.white : color;
    final foreground = selected
        ? color
        : dark
        ? Colors.black
        : Colors.white;
    return Material(
      color: background,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Align(
          alignment: wide ? const Alignment(-0.6, 0) : Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 34,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

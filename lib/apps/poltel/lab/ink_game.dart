import 'package:flutter/material.dart';

/// Under the lab lamp old ink has faded browner than new: tap a
/// document's lines from the oldest to the newest. A wrong pick starts the
/// order over.
class InkGame extends StatefulWidget {
  const InkGame({
    super.key,
    required this.lines,
    required this.order,
    required this.onSolved,
  });

  /// In the order they are on the page.
  final List<String> lines;

  /// Indexes of [lines], oldest first.
  final List<int> order;
  final VoidCallback onSolved;

  @override
  State<InkGame> createState() => _InkGameState();
}

class _InkGameState extends State<InkGame> {
  final List<int> _picked = [];
  bool _wrong = false;

  /// The ink colour of line [i]: brown for the oldest, blue-black for the
  /// newest.
  Color _ink(int i) {
    final age = widget.order.indexOf(i) / (widget.order.length - 1);
    return Color.lerp(const Color(0xFF8D6E63), const Color(0xFF1A237E), age)!;
  }

  void _pick(int i) {
    if (_picked.contains(i)) return;
    if (widget.order[_picked.length] != i) {
      setState(() {
        _picked.clear();
        _wrong = true;
      });
      return;
    }
    setState(() {
      _picked.add(i);
      _wrong = false;
    });
    if (_picked.length == widget.order.length) widget.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F1E1),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 6),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, line) in widget.lines.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    key: ValueKey('ink-$i'),
                    onTap: () => _pick(i),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _picked.contains(i)
                              ? const Color(0xFF43A047)
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 26,
                            child: _picked.contains(i)
                                ? Text(
                                    "${_picked.indexOf(i) + 1}.",
                                    style: const TextStyle(
                                      color: Color(0xFF43A047),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : null,
                          ),
                          Expanded(
                            child: Text(
                              line,
                              style: TextStyle(
                                color: _ink(i),
                                fontFamily: 'serif',
                                fontSize: 15,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _wrong
              ? "Sıra tutmadı. En soluk, en kahverengi mürekkepten başla."
              : "En eski satırdan en yeniye doğru dokun.",
          textAlign: TextAlign.center,
          style: TextStyle(color: _wrong ? const Color(0xFFC62828) : null),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// A chat message bubble. Consecutive messages from the same side can drop
/// the [tail] so a run of bubbles reads as one group.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.outgoing,
    this.outgoingColor = const Color(0xFFD9FDD3),
    this.incomingColor = Colors.white,
    this.outgoingTextColor = const Color(0xFF111B21),
    this.incomingTextColor = const Color(0xFF111B21),
    this.tail = true,
  });

  final String text;

  /// True for messages the player sent.
  final bool outgoing;
  final Color outgoingColor;
  final Color incomingColor;
  final Color outgoingTextColor;
  final Color incomingTextColor;
  final bool tail;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(18);
    const tailRadius = Radius.circular(4);
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    return Align(
      alignment: outgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: tail ? 6 : 2),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: outgoing ? outgoingColor : incomingColor,
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
                bottomLeft: !outgoing && tail ? tailRadius : radius,
                bottomRight: outgoing && tail ? tailRadius : radius,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.3,
                  color: outgoing ? outgoingTextColor : incomingTextColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

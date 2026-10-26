import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.text, required this.outgoing});

  final String text;

  /// True for messages the player sent.
  final bool outgoing;

  @override
  Widget build(BuildContext context) {
    const corner = Radius.circular(32);
    return Padding(
      padding: EdgeInsets.only(
        bottom: 20,
        left: outgoing ? 80 : 0,
        right: outgoing ? 0 : 80,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: outgoing ? Colors.white : CupertinoColors.systemBlue,
          borderRadius: BorderRadius.only(
            topLeft: corner,
            topRight: corner,
            bottomLeft: outgoing ? corner : Radius.zero,
            bottomRight: outgoing ? Radius.zero : corner,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

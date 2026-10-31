import 'package:flutter/material.dart';

/// MatesApp's colours, in the spirit of familiar messaging apps.
abstract final class MatesColors {
  static const header = Color(0xFF008069);
  static const accent = Color(0xFF25D366);
  static const chatBackground = Color(0xFFEFE7DE);
  static const outgoing = Color(0xFFD9FDD3);
  static const text = Color(0xFF111B21);
  static const secondaryText = Color(0xFF667781);

  /// One of the story's big decisions.
  static const decision = Color(0xFFD32F2F);
}

/// The text field-like bar at the bottom of a chat.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    this.controller,
    this.hint = "Mesaj",
    this.onSend,
    this.enabled = true,
  });

  /// When null the bar is display-only.
  final TextEditingController? controller;
  final String hint;
  final VoidCallback? onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 1),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.emoji_emotions_outlined,
                      color: MatesColors.secondaryText,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: enabled && controller != null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend?.call(),
                      decoration: InputDecoration(
                        hintText: hint,
                        filled: false,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: MatesColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: MatesColors.header,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSend,
              child: SizedBox.square(
                dimension: 48,
                child: Icon(
                  controller == null ? Icons.mic_rounded : Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

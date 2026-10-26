import 'package:flutter/material.dart';

/// The bordered "avatar | label" row used by Contacts, Phone and MatesApp.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.avatar,
    required this.label,
    this.onTap,
    this.onLongPress,
  });

  final Widget avatar;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static const _border = BorderSide(color: Colors.black, width: 3.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _border.color,
                        width: _border.width,
                      ),
                    ),
                    child: avatar,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: _border,
                        bottom: _border,
                        right: _border,
                      ),
                    ),
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, this.child});

  /// Shown inside the avatar. Defaults to a person icon.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.teal,
      child: child ?? const Icon(Icons.person, size: 50, color: Colors.black),
    );
  }
}

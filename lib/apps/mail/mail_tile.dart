import 'package:flutter/material.dart';

import '../../data/game_data.dart';

/// A mail that expands to show its full text when tapped.
class MailTile extends StatefulWidget {
  const MailTile({super.key, required this.mail});

  final Mail mail;

  @override
  State<MailTile> createState() => _MailTileState();
}

class _MailTileState extends State<MailTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.black38,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 2.0),
          borderRadius: BorderRadius.circular(6.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(3, 3, 3, 15),
              child: Column(
                children: [
                  Text(
                    widget.mail.sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.mail.body,
                    maxLines: _expanded ? null : 1,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

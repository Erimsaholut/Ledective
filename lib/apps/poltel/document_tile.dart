import 'package:flutter/material.dart';

/// A Poltel inbox entry that opens [page] when tapped.
class DocumentTile extends StatelessWidget {
  const DocumentTile({
    super.key,
    required this.title,
    required this.page,
    this.isNew = false,
    this.onOpen,
  });

  final String title;
  final Widget page;
  final bool isNew;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Material(
        color: Colors.grey,
        shape: const Border.fromBorderSide(
          BorderSide(color: Colors.black, width: 3.0),
        ),
        child: InkWell(
          onTap: () {
            onOpen?.call();
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => page),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "YENİ",
                      style: TextStyle(color: Colors.white, fontSize: 12),
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

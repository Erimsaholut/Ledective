import 'package:flutter/material.dart';

class OutgoingMessage extends StatelessWidget {
  final String message;
  const OutgoingMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minHeight = 60.0;
        final maxHeight = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 80,),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: minHeight,
                  maxHeight: maxHeight,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                    bottomLeft: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

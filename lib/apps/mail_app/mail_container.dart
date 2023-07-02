import 'package:flutter/material.dart';

Color containerColor = Colors.black38;

class MailContainer extends StatelessWidget {
  final String title;
  final String message;

  const MailContainer({Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String shortMessage =
        message.length > 31 ? "${message.substring(0, 31)}..." : message;

    String shortTitle =
    title.length > 16 ? "${title.substring(0, 13)}..." : title;

    return Column(
      children: [
        Container(
          width: 500,
          decoration: BoxDecoration(
            color: containerColor,
            border: Border.all(
              color: Colors.black,
              width: 2.0,

            ),
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Column(
            children: [
              Text(
                shortTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                shortMessage,
                style: const TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

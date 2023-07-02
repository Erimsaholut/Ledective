import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final Color colour;
  final double buttonSize;

  const BackButtonWidget({
    Key? key,
    this.colour = Colors.black,
    this.buttonSize = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: buttonSize,
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back, color: colour),
    );
  }
}

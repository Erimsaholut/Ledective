import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({
    super.key,
    this.colour = Colors.black,
    this.buttonSize = 80,
  });

  final Color colour;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: buttonSize,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back, color: colour),
    );
  }
}

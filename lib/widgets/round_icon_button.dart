import 'package:flutter/material.dart';

/// A circular button showing either [myIcon] or, when given, [buttonText].
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    this.size = 85.0,
    this.myIcon,
    this.buttonText = '',
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
    this.borderColor = Colors.black,
    this.backGroundColor,
    this.onPressed,
    this.onLongPressed,
  });

  final double size;
  final IconData? myIcon;
  final String buttonText;
  final Color iconColor;
  final Color textColor;
  final Color borderColor;
  final Color? backGroundColor;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backGroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3.0),
      ),
      child: TextButton(
        onPressed: onPressed,
        onLongPress: onLongPressed,
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.all(size * 0.2),
          overlayColor: Colors.white,
        ),
        child: buttonText.isEmpty
            ? Icon(myIcon, size: 40, color: iconColor)
            : Text(
                buttonText,
                style: TextStyle(fontSize: 40, color: textColor),
              ),
      ),
    );
  }
}

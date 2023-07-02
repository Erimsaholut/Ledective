import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final double size;
  final IconData? myIcon;
  final String buttonText;
  final Color? iconColor;
  final Color? textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final Color? backGroundColor;


  const RoundIconButton({
    Key? key,
    this.size = 85.0,
    this.myIcon,
    this.buttonText = '',
    this.iconColor,
    this.textColor,
    this.borderColor,
    this.backGroundColor,
    this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIconButton = buttonText.isEmpty;
    final defaultIconColor = iconColor ?? Colors.black;
    final defaultTextColor = textColor ?? Colors.black;
    final defaultBorderColor = borderColor ?? Colors.black;
    return isIconButton
        ? Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backGroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: defaultBorderColor,
          width: 3.0,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        onLongPress: onLongPressed, // onLongPressed kullanıldı
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.all(size * 0.2),
          ),
          overlayColor: MaterialStateProperty.all(
            Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          myIcon,
          size: 40,
          color: defaultIconColor,
        ),
      ),
    )
        : Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: backGroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: defaultBorderColor,
          width: 3.0,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        onLongPress: onLongPressed, // onLongPressed kullanıldı
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.all(size * 0.2),
          ),
          overlayColor: MaterialStateProperty.all(
            Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 40, color: defaultTextColor),
        ),
      ),
    );
  }
}

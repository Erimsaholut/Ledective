import 'package:flutter/material.dart';

/// A home screen icon that zooms [app] open when tapped.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.title,
    required this.iconData,
    required this.app,
  });

  static const double size = 110;

  final String title;
  final IconData iconData;
  final Widget app;

  void _open(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => app,
        transitionsBuilder: (_, animation, _, child) =>
            ScaleTransition(scale: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: TextButton(
        onPressed: () => _open(context),
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 50, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

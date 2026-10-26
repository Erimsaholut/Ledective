import 'package:flutter/material.dart';

/// Tracks how many routes are on the navigator, so the home indicator only
/// shows while an app is open.
class RouteDepthObserver extends NavigatorObserver {
  final depth = ValueNotifier<int>(0);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    depth.value++;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    depth.value--;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    depth.value--;
  }
}

/// The thin bar at the bottom of the screen. Tapping it or swiping it up
/// closes every open app and returns to the home screen.
class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key, required this.observer, required this.child});

  final RouteDepthObserver observer;
  final Widget child;

  void _goHome() => observer.navigator?.popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder<int>(
          valueListenable: observer.depth,
          builder: (context, depth, _) {
            if (depth <= 1) return const SizedBox.shrink();
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Semantics(
                  button: true,
                  label: 'Ana ekran',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _goHome,
                    onVerticalDragEnd: (details) {
                      if ((details.primaryVelocity ?? 0) < -100) _goHome();
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 6, 40, 6),
                      child: Container(
                        width: 134,
                        height: 5,
                        decoration: BoxDecoration(
                          // Mid grey reads on light and dark apps alike.
                          color: const Color(0xFF8A8A8E),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../story/story_progress.dart';
import '../theme/app_theme.dart';

/// Shows story alerts as notification banners that slide in from the top,
/// one after another.
class AlertBanner extends StatefulWidget {
  const AlertBanner({super.key, required this.alerts});

  final AlertQueue alerts;

  @override
  State<AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<AlertBanner> {
  StoryAlert? _shown;
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.alerts.addListener(_update);
    _update();
  }

  @override
  void dispose() {
    widget.alerts.removeListener(_update);
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    final next = widget.alerts.current;
    if (next == null || identical(next, _shown)) return;
    setState(() {
      _shown = next;
      _visible = true;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), _hide);
  }

  void _hide() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _visible = false);
    // Let the banner slide away before the next one comes in.
    _timer = Timer(const Duration(milliseconds: 350), widget.alerts.dismiss);
  }

  @override
  Widget build(BuildContext context) {
    final alert = _shown;
    if (alert == null) return const SizedBox.shrink();
    const small = TextStyle(fontSize: 11.5, color: AppColors.secondaryLabel);
    final card = DecoratedBox(
      // No backdrop blur here: inside the sliding transform it can blur the
      // whole screen on some renderers.
      decoration: BoxDecoration(
        color: const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 18)],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(alert.app.toUpperCase(), style: small),
                      ),
                      const Text("şimdi", style: small),
                    ],
                  ),
                  Text(
                    alert.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.label,
                    ),
                  ),
                  Text(
                    alert.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.label,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, -1.6),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: GestureDetector(
              onTap: _hide,
              onVerticalDragEnd: (_) => _hide(),
              child: card,
            ),
          ),
        ),
      ),
    );
  }
}

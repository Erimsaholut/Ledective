import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../story/story_progress.dart';

/// Shows [child], or a locked screen while `state.json` closes [app], e.g.
/// Poltel for a suspended detective.
class AccessGate extends StatelessWidget {
  const AccessGate({super.key, required this.app, required this.child});

  final String app;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, child) {
        final lock = progress.lockOf(app);
        if (lock == null) return child!;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFF111418),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Spacer(),
                    const Icon(
                      Icons.lock_rounded,
                      size: 64,
                      color: Color(0xFFFF453A),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      lock.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lock.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Ana ekrana dön"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Shown for apps that are not part of the game (yet).
class UnavailableApp extends StatelessWidget {
  const UnavailableApp({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 60,
                  color: AppColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Sorry, $title is currently not available",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Bakım çalışması nedeniyle hizmet veremiyoruz. Lütfen daha sonra tekrar deneyin.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

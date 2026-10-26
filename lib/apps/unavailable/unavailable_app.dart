import 'package:flutter/material.dart';

/// Shown for apps that are not part of the game (yet).
class UnavailableApp extends StatelessWidget {
  const UnavailableApp({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.red),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Flexible(
                child: FittedBox(
                  child: Icon(
                    Icons.error_outline,
                    size: 300,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Sorry\n$title is currently not available",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

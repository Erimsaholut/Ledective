import 'package:flutter/material.dart';

class Sinstagram extends StatelessWidget {
  const Sinstagram({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Sinstagram gönderileri eklenecek.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sinstagram"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ColoredBox(
        color: Colors.blue.shade100,
        child: const Center(
          child: Text(
            "No posts yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

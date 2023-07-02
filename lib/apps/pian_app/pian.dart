import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';


class PianApp extends StatelessWidget {
  const PianApp({Key? key}) : super(key: key);

  Future<void> playSound(int num) async {
    final player = AudioPlayer();
    await player.setAsset('note7.wav');
    player.play();
  }

  Expanded buildTitle({required int sound, required Color color}) {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: color,
        child: TextButton(
          onPressed: () {
            playSound(sound);
          },
          child: const SizedBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Pian"),
          backgroundColor: Colors.black,
          leading: const BackButton(),
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            verticalDirection: VerticalDirection.down,
            children: [
              buildTitle(sound: 1, color: Colors.red),
              buildTitle(sound: 2, color: Colors.orange),
              buildTitle(sound: 3, color: Colors.yellow),
              buildTitle(sound: 4, color: Colors.green),
              buildTitle(sound: 5, color: Colors.teal),
              buildTitle(sound: 7, color: Colors.blue),
              buildTitle(sound: 6, color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }
}

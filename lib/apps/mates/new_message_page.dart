import 'package:flutter/material.dart';

// TODO: Rehbere eklenen kişiler için yeni mesaj yazma yeri ekle. Hikâyedeki
// kişilere yeni mesaj yazılamasın (buton silik olsun), kullanıcının kendi
// eklediği numaralara yazılabilsin.
class NewMessagePage extends StatelessWidget {
  const NewMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Message"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.green.shade100,
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "You can't start a new conversation right now.",
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

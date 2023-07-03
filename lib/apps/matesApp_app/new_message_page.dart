import 'package:flutter/material.dart';

class NewMessagePage extends StatelessWidget {
  const NewMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Message"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.green.shade100,
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Kanka rehberi ekleyince yeni mesaj"
              " yazma yeri ekle buraya ama yeni mesah yazılamsın butonu"
              " silik yap kullanıcının kendi eklediği numaralar için yazılabilir belki",
              style: TextStyle(fontSize: 24,),textAlign: TextAlign.center,
            ),
          ],
        )),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ledective/data_base/datas.dart';

class Sinstagram extends StatefulWidget {
  const Sinstagram({Key? key}) : super(key: key);

  @override
  State<Sinstagram> createState() => _SinstagramState();

}

class _SinstagramState extends State<Sinstagram> {
  DataDepo db = DataDepo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sinstagram"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(
            children: const [
              //db.insta_postları
            ],
          ),
        ),
      ),
    );
  }
}

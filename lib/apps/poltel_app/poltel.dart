import 'package:flutter/material.dart';
import 'package:ledective/apps/poltel_app/document_widget.dart';

class Poltel extends StatefulWidget {
  const Poltel({Key? key}) : super(key: key);

  @override
  State<Poltel> createState() => _PoltelState();
}

class _PoltelState extends State<Poltel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text("Poltel"),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.blue.shade100,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: const [
              Column(
                children: [
                  PolDocument(
                    name: "Furkan Kasap",
                  ),
                  PolDocument(
                    name: "Deniz Yılmaz",
                  ),
                  PolDocument(
                    name: "Orhan Kasap",
                  ),
                  PolDocument(
                    name: "Berat Yılmaz",
                    isAutopsy: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

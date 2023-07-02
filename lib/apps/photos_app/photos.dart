import 'package:flutter/material.dart';
import 'package:ledective/data_base/datas.dart';

class Photos extends StatefulWidget {
  const Photos({Key? key}) : super(key: key);

  @override
  State<Photos> createState() => _PhotosState();

}

class _PhotosState extends State<Photos> {
  DataDepo db = DataDepo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photos"),
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
            children: [
              ...(db.galleryImages)

            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ledective/data_base/datas.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotosApp extends StatefulWidget {
  const PhotosApp({Key? key}) : super(key: key);

  @override
  State<PhotosApp> createState() => _PhotosAppState();
}

class _PhotosAppState extends State<PhotosApp> {
  List<Widget> photos = DataDepo().galleryImages;
  List<Widget> myPhotos = [];
  int photoCount = 3; // Başlangıçta görüntülenecek fotoğraf sayısı

  @override
  void initState() {
    super.initState();
    myPhotos = photos.take(photoCount).toList();
    _getPhotoCountFromSharedPreferences();
  }

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
              ...myPhotos,
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _addPhoto(); // Daha fazla fotoğraf yükleme
                  });
                },
                child: const Text('Load More Photos'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPhoto() {
    if (photoCount < photos.length) {
      photoCount += 1;
      myPhotos = photos.take(photoCount).toList();
      _savePhotoCountToSharedPreferences(photoCount);
    }
  }

  Future<void> _savePhotoCountToSharedPreferences(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('photoCount', count);
  }

  Future<void> _getPhotoCountFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? count = prefs.getInt('photoCount');
    if (count != null) {
      setState(() {
        photoCount = count;
        myPhotos = photos.take(photoCount).toList();
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/game_data.dart';

class PhotosApp extends StatefulWidget {
  const PhotosApp({super.key});

  @override
  State<PhotosApp> createState() => _PhotosAppState();
}

class _PhotosAppState extends State<PhotosApp> {
  static const _prefsKey = 'photoCount';
  static const _initialPhotoCount = 3;

  int _photoCount = _initialPhotoCount;

  @override
  void initState() {
    super.initState();
    _loadPhotoCount();
  }

  Future<void> _loadPhotoCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_prefsKey);
    if (count != null && mounted) {
      setState(() => _photoCount = count.clamp(0, galleryImages.length));
    }
  }

  Future<void> _loadMorePhotos() async {
    setState(() => _photoCount++);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, _photoCount);
  }

  void _openPhoto(String path) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => _PhotoViewer(path: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photos"),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.blue.shade100,
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          for (final path in galleryImages.take(_photoCount))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _openPhoto(path),
                child: Hero(
                  tag: path,
                  child: Image.asset(path, fit: BoxFit.fitWidth),
                ),
              ),
            ),
          if (_photoCount < galleryImages.length)
            ElevatedButton(
              onPressed: _loadMorePhotos,
              child: const Text('Load More Photos'),
            ),
        ],
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: Hero(tag: path, child: Image.asset(path)),
        ),
      ),
    );
  }
}

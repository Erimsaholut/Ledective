import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/camera_roll.dart';

/// Takes photos with the device camera and keeps them in the camera roll,
/// which the Photos app shows above the gallery.
class CameraApp extends StatefulWidget {
  const CameraApp({super.key, this.picker});

  /// Tests pass a fake picker.
  final ImagePicker? picker;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  bool _busy = false;

  Future<void> _takePhoto() async {
    setState(() => _busy = true);
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (photo != null) {
        await CameraRoll.instance.add(await photo.readAsBytes());
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Kamera açılamadı: $error")));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openPhoto(int index) {
    final photo = CameraRoll.instance.photos[index];
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: InteractiveViewer(
            maxScale: 5,
            child: Center(child: Image.memory(photo)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Camera"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: CameraRoll.instance,
                builder: (context, _) {
                  final photos = CameraRoll.instance.photos;
                  if (photos.isEmpty) {
                    return const Center(
                      child: Text(
                        "Henüz fotoğraf çekmediniz",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _openPhoto(index),
                      child: Image.memory(photos[index], fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SizedBox.square(
                dimension: 80,
                child: ElevatedButton(
                  onPressed: _busy ? null : _takePhoto,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(
                      side: BorderSide(color: Colors.white54, width: 4),
                    ),
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: _busy
                      ? const CircularProgressIndicator()
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 36,
                          semanticLabel: "Fotoğraf çek",
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

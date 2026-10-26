import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Photos the player took with the Camera app, newest first. Saved in the
/// app's documents folder; on the web they only last for the session.
class CameraRoll extends ChangeNotifier {
  CameraRoll._();

  static final CameraRoll instance = CameraRoll._();

  final List<Uint8List> _photos = [];

  List<Uint8List> get photos => List.unmodifiable(_photos);

  Future<Directory?> _folder() async {
    if (kIsWeb) return null;
    try {
      final documents = await getApplicationDocumentsDirectory();
      return Directory('${documents.path}/camera');
    } on Exception catch (error) {
      debugPrint('Camera roll is not available: $error');
      return null;
    }
  }

  Future<void> load() async {
    _photos.clear();
    final folder = await _folder();
    if (folder != null && folder.existsSync()) {
      final files = folder.listSync().whereType<File>().toList()
        ..sort((a, b) => b.path.compareTo(a.path));
      for (final file in files) {
        _photos.add(await file.readAsBytes());
      }
    }
    notifyListeners();
  }

  Future<void> add(Uint8List photo) async {
    _photos.insert(0, photo);
    notifyListeners();
    final folder = await _folder();
    if (folder == null) return;
    await folder.create(recursive: true);
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    await File('${folder.path}/$name.jpg').writeAsBytes(photo);
  }

  Future<void> clear() async {
    _photos.clear();
    notifyListeners();
    final folder = await _folder();
    if (folder != null && folder.existsSync()) {
      await folder.delete(recursive: true);
    }
  }
}

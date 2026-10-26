import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/camera_roll.dart';
import '../../data/game_data.dart';
import '../../theme/app_theme.dart';

/// A photo from the camera roll (bytes) or the bundled gallery (asset).
typedef Photo = ({String? asset, Uint8List? bytes});

ImageProvider photoImage(Photo photo) => photo.bytes != null
    ? MemoryImage(photo.bytes!)
    : AssetImage(photo.asset!) as ImageProvider;

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

  void _openPhoto(List<Photo> photos, int index) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PhotoViewer(photos: photos, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: CameraRoll.instance,
        builder: (context, _) {
          final photos = <Photo>[
            for (final bytes in CameraRoll.instance.photos)
              (asset: null, bytes: bytes),
            for (final asset in galleryImages.take(_photoCount))
              (asset: asset, bytes: null),
          ];
          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(
                backgroundColor: Colors.white,
                title: Text("Library"),
              ),
              SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _openPhoto(photos, index),
                  child: Hero(
                    tag: photos[index],
                    child: Image(
                      image: photoImage(photos[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "${photos.length} Fotoğraf",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (_photoCount < galleryImages.length)
                        TextButton(
                          onPressed: _loadMorePhotos,
                          child: const Text('Load More Photos'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-screen photos you can swipe between and zoom into.
class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.photos, this.initialIndex = 0});

  final List<Photo> photos;
  final int initialIndex;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          "${_index + 1} / ${widget.photos.length}",
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photos.length,
        onPageChanged: (index) => setState(() => _index = index),
        itemBuilder: (context, index) => InteractiveViewer(
          maxScale: 5,
          child: Center(
            child: Hero(
              tag: widget.photos[index],
              child: Image(image: photoImage(widget.photos[index])),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.ios_share_rounded, color: AppColors.blue),
              Icon(Icons.favorite_border_rounded, color: AppColors.blue),
              Icon(Icons.info_outline_rounded, color: AppColors.blue),
              Icon(Icons.delete_outline_rounded, color: AppColors.blue),
            ],
          ),
        ),
      ),
    );
  }
}

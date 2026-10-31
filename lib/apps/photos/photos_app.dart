import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/camera_roll.dart';
import '../../data/game_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';

/// A photo from the camera roll (bytes) or the bundled gallery (asset).
typedef Photo = ({String? asset, Uint8List? bytes});

ImageProvider photoImage(Photo photo) => photo.bytes != null
    ? MemoryImage(photo.bytes!)
    : AssetImage(photo.asset!) as ImageProvider;

class PhotosApp extends StatelessWidget {
  const PhotosApp({super.key});

  void _openPhoto(BuildContext context, List<Photo> photos, int index) {
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
        listenable: Listenable.merge([
          CameraRoll.instance,
          StoryProgress.instance,
        ]),
        builder: (context, _) {
          // In the hidden ending the photos turn into what was really there.
          final gallery =
              StoryProgress.instance.breakdown?.gallery(galleryImages) ??
              galleryImages;
          // Photos people sent in chats are saved here too, newest first.
          final received = StoryProgress.instance.receivedPhotos.reversed
              .toSet();
          final photos = <Photo>[
            for (final bytes in CameraRoll.instance.photos)
              (asset: null, bytes: bytes),
            for (final asset in received) (asset: asset, bytes: null),
            for (final asset in gallery)
              if (!received.contains(asset)) (asset: asset, bytes: null),
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
                  onTap: () => _openPhoto(context, photos, index),
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
                  child: Text(
                    "${photos.length} Fotoğraf",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
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

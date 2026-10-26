import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/camera_roll.dart';
import '../photos/photos_app.dart';

/// A camera app. The shutter opens the device camera; photos land in the
/// camera roll, which the Photos app shows too.
class CameraApp extends StatefulWidget {
  const CameraApp({super.key, this.picker});

  /// Tests pass a fake picker.
  final ImagePicker? picker;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  static const _modes = ['SİNEMA', 'VİDEO', 'FOTOĞRAF', 'PORTRE', 'PANO'];

  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  bool _busy = false;
  bool _flash = false;

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

  void _openLastPhoto() {
    final photos = CameraRoll.instance.photos;
    if (photos.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PhotoViewer(
          photos: [for (final bytes in photos) (asset: null, bytes: bytes)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: "Close",
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: "Flash",
                      onPressed: () => setState(() => _flash = !_flash),
                      icon: Icon(
                        _flash
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: _flash ? const Color(0xFFFFD60A) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Color(0xFF2C2C2E), Color(0xFF0A0A0A)],
                          radius: 0.9,
                        ),
                      ),
                    ),
                    const CustomPaint(painter: _GridPainter()),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.center_focus_weak_rounded,
                            size: 72,
                            color: const Color(
                              0xFFFFD60A,
                            ).withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Çekmek için deklanşöre dokun",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final mode in _modes)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          mode,
                          style: TextStyle(
                            color: mode == 'FOTOĞRAF'
                                ? const Color(0xFFFFD60A)
                                : Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListenableBuilder(
                      listenable: CameraRoll.instance,
                      builder: (context, _) {
                        final photos = CameraRoll.instance.photos;
                        return GestureDetector(
                          onTap: _openLastPhoto,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24),
                              image: photos.isEmpty
                                  ? null
                                  : DecorationImage(
                                      image: MemoryImage(photos.first),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: _busy ? null : _takePhoto,
                      child: Semantics(
                        button: true,
                        label: "Fotoğraf çek",
                        child: Container(
                          width: 78,
                          height: 78,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _busy ? Colors.white54 : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2C2C2E),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rule-of-thirds lines over the viewfinder.
class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 0.7;
    for (var i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      final y = size.height * i / 3;
      canvas
        ..drawLine(Offset(x, 0), Offset(x, size.height), paint)
        ..drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

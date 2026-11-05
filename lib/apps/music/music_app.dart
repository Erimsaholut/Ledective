import 'package:flutter/material.dart';

import 'music_player.dart';
import 'tracks.dart';

const _accent = Color(0xFFFA233B);
const _grey = Color(0xFF8E8E93);

/// A music player for the bundled tracks. Playback lives in [MusicPlayer],
/// so it carries on after this screen is closed.
class MusicApp extends StatelessWidget {
  const MusicApp({super.key, this.player});

  /// Defaults to [MusicPlayer.instance].
  final MusicPlayer? player;

  static String _format(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  static const _artworks = [
    [Color(0xFF1D2B64), Color(0xFFF8CDDA)],
    [Color(0xFF232526), Color(0xFF8E0E00)],
    [Color(0xFF0F2027), Color(0xFF2C5364)],
    [Color(0xFF3A1C71), Color(0xFFD76D77)],
    [Color(0xFF141E30), Color(0xFF6B7A8F)],
  ];

  Widget _artwork(int index, double size) {
    final colors = _artworks[index % _artworks.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.08),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          if (size > 100)
            BoxShadow(
              color: colors.first.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
        ],
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white.withValues(alpha: 0.85),
        size: size * 0.45,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final music = player ?? MusicPlayer.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Listen Now",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: "Hakkında",
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MusicCredits()),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: music,
        builder: (context, _) {
          final track = music.track;
          final elapsed = music.position > track.duration
              ? track.duration
              : music.position;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 8),
              Center(
                child: AnimatedScale(
                  scale: music.playing ? 1 : 0.85,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: _artwork(music.index, 260),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                track.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                track.artist,
                style: const TextStyle(fontSize: 18, color: _accent),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value:
                      elapsed.inMilliseconds / track.duration.inMilliseconds,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFE5E5EA),
                  color: _grey,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _format(elapsed),
                    style: const TextStyle(color: _grey, fontSize: 12),
                  ),
                  Text(
                    "-${_format(track.duration - elapsed)}",
                    style: const TextStyle(color: _grey, fontSize: 12),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 44,
                    tooltip: "Previous",
                    onPressed: music.previous,
                    icon: const Icon(Icons.fast_rewind_rounded),
                  ),
                  IconButton(
                    iconSize: 64,
                    tooltip: music.playing ? "Pause" : "Play",
                    onPressed: music.toggle,
                    icon: Icon(
                      music.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                  IconButton(
                    iconSize: 44,
                    tooltip: "Next",
                    onPressed: music.next,
                    icon: const Icon(Icons.fast_forward_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Çalma Listesi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              for (var i = 0; i < tracks.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _artwork(i, 48),
                  ),
                  title: Text(
                    tracks[i].title,
                    style: TextStyle(
                      fontWeight: i == music.index ? FontWeight.w700 : null,
                      color: i == music.index ? _accent : null,
                    ),
                  ),
                  subtitle: Text("${tracks[i].artist} · ${tracks[i].style}"),
                  trailing: i == music.index && music.playing
                      ? const Icon(Icons.graphic_eq_rounded, color: _accent)
                      : Text(_format(tracks[i].duration)),
                  onTap: () => music.select(i, autoplay: true),
                ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

/// Music › Hakkında: the credits CC BY 4.0 asks for.
class MusicCredits extends StatelessWidget {
  const MusicCredits({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Hakkında"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          const Text(
            "Bu uygulamadaki müziklerin hepsi Kevin MacLeod'a ait ve "
            "Creative Commons Atıf 4.0 (CC BY 4.0) lisansıyla kullanılıyor.",
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 20),
          for (final track in tracks) ...[
            SelectableText(
              track.credit,
              style: const TextStyle(fontSize: 13, height: 1.4, color: _grey),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

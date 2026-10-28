import 'package:flutter/material.dart';

import '../../data/installed_games.dart';
import '../../theme/app_theme.dart';
import 'store_catalog.dart';

/// The app store: games from [storeGames] to download, open and delete.
class AppShopApp extends StatelessWidget {
  const AppShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text("AppShop")),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Oyunlar",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: storeGames.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _GameRow(game: storeGames[index]),
            ),
          ),
          const SliverToBoxAdapter(
            child: Text(
              "Daha fazla oyun yakında",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryLabel),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

/// Asks before deleting [game] and its saved data.
Future<void> confirmUninstall(BuildContext context, StoreGame game) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("“${game.title}” silinsin mi?"),
      content: const Text(
        "Oyun ve kayıtlı ilerlemesi bu telefondan silinecek. AppShop'tan "
        "yeniden indirebilirsin.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Vazgeç"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.red),
          child: const Text("Sil"),
        ),
      ],
    ),
  );
  if (confirmed ?? false) {
    await InstalledGames.uninstall(game.id, data: game.dataKeys);
  }
}

/// A store game's home screen icon. A long press offers to delete it.
class InstalledGameIcon extends StatelessWidget {
  const InstalledGameIcon({super.key, required this.game});

  final StoreGame game;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => confirmUninstall(context, game),
      child: game.homeIcon,
    );
  }
}

/// One game in the store, with its "İndir" or "Aç" button.
class _GameRow extends StatefulWidget {
  const _GameRow({required this.game});

  final StoreGame game;

  @override
  State<_GameRow> createState() => _GameRowState();
}

class _GameRowState extends State<_GameRow>
    with SingleTickerProviderStateMixin {
  static const downloadTime = Duration(milliseconds: 1600);

  late final AnimationController _download = AnimationController(
    vsync: this,
    duration: downloadTime,
  );

  @override
  void dispose() {
    _download.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    if (!widget.game.isAvailable) return _showUnavailable();
    try {
      await _download.forward(from: 0).orCancel;
    } on TickerCanceled {
      return; // Cancelled, or the store was closed.
    }
    await InstalledGames.install(widget.game.id);
    if (mounted) _download.reset();
  }

  /// What a store says about an app it can't sell in your country.
  Future<void> _showUnavailable() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Ülkenizde kullanılamıyor"),
      content: Text(
        "“${widget.game.title}” şu anda ülkenizde veya bölgenizde "
        "indirilemiyor.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tamam"),
        ),
      ],
    ),
  );

  void _cancelDownload() {
    _download.stop();
    _download.reset();
  }

  void _open() => Navigator.of(context).push(widget.game.homeIcon.route());

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _GameArtwork(game: game, size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.secondaryLabel,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<List<String>>(
              valueListenable: InstalledGames.ids,
              builder: (context, ids, _) => AnimatedBuilder(
                animation: _download,
                builder: (context, _) => _buildAction(ids.contains(game.id)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(bool installed) {
    if (_download.isAnimating) {
      return Semantics(
        label: "İndiriliyor",
        button: true,
        child: InkResponse(
          onTap: _cancelDownload,
          radius: 22,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _download.value,
                  strokeWidth: 3,
                  backgroundColor: const Color(0xFFE3E3E8),
                ),
                Container(width: 10, height: 10, color: AppColors.blue),
              ],
            ),
          ),
        ),
      );
    }
    if (!installed) {
      return _PillButton(label: "İndir", onPressed: _startDownload);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillButton(label: "Aç", onPressed: _open),
        TextButton(
          onPressed: () => confirmUninstall(context, widget.game),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.red,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text("Sil"),
        ),
      ],
    );
  }
}

/// The grey rounded button of an app store, with a blue label.
class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFE3E3E8),
        foregroundColor: AppColors.blue,
        minimumSize: const Size(76, 32),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

/// A store game's icon, as it looks on the home screen.
class _GameArtwork extends StatelessWidget {
  const _GameArtwork({required this.game, this.size = 60});

  final StoreGame game;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.225),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: game.colors,
        ),
      ),
      child: Icon(game.icon, size: size * 0.56, color: game.glyphColor),
    );
  }
}

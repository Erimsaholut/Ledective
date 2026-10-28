import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/app_theme.dart';
import 'sudoku_game.dart';
import 'sudoku_puzzle.dart';

/// Sudoku from AppShop. An unfinished game is saved and picked up again the
/// next time the app opens.
class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key, this.initialGame});

  /// Where the unfinished game is saved.
  static const saveKey = 'sudoku.game';

  /// Game to start with instead of the saved one.
  final SudokuGame? initialGame;

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  SudokuGame? _game;
  bool _loading = true;
  int? _selected;
  bool _notesMode = false;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGame;
    if (initial != null) {
      _start(initial);
    } else {
      _load();
    }
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _clock?.cancel();
    _save();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(SudokuApp.saveKey);
    SudokuGame? game;
    if (stored != null) {
      try {
        game = SudokuGame.fromJson(json.decode(stored) as Map<String, dynamic>);
      } on Object {
        // A save from an older version; start over.
      }
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (game != null) _start(game);
    });
  }

  void _start(SudokuGame game) {
    _loading = false;
    _game = game;
    _selected = null;
    _notesMode = false;
  }

  void _tick() {
    final game = _game;
    if (game == null || game.isSolved) return;
    setState(() => game.elapsed += const Duration(seconds: 1));
    if (game.elapsed.inSeconds % 10 == 0) _save();
  }

  /// Saves the game in progress, or forgets it once it's solved.
  Future<void> _save() async {
    final game = _game;
    if (game == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (game.isSolved) {
      await prefs.remove(SudokuApp.saveKey);
    } else {
      await prefs.setString(SudokuApp.saveKey, json.encode(game.toJson()));
    }
  }

  void _newGame(SudokuDifficulty difficulty) {
    setState(() => _start(SudokuGame.generate(difficulty)));
    _save();
  }

  Future<void> _chooseNewGame() async {
    final difficulty = await showModalBottomSheet<SudokuDifficulty>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Yeni oyun",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            if (_game?.isSolved == false)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Şu anki oyunun silinecek.",
                  style: TextStyle(color: AppColors.secondaryLabel),
                ),
              ),
            const SizedBox(height: 8),
            for (final difficulty in SudokuDifficulty.values)
              ListTile(
                tileColor: Colors.transparent,
                title: Text(difficulty.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context, difficulty),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (difficulty != null) _newGame(difficulty);
  }

  /// Applies a change to the game and celebrates if it solved the puzzle.
  void _play(bool Function(SudokuGame game) move) {
    final game = _game;
    if (game == null || !move(game)) return;
    setState(() {});
    _save();
    if (game.isSolved) _celebrate(game);
  }

  void _enter(int digit) {
    final cell = _selected;
    if (cell == null) return;
    _play(
      (game) =>
          _notesMode ? game.toggleNote(cell, digit) : game.enter(cell, digit),
    );
  }

  void _erase() {
    final cell = _selected;
    if (cell != null) _play((game) => game.erase(cell));
  }

  void _hint() {
    _play((game) {
      final cell = game.hint(preferred: _selected);
      if (cell != null) _selected = cell;
      return cell != null;
    });
  }

  void _celebrate(SudokuGame game) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.emoji_events_rounded,
          size: 56,
          color: AppColors.orange,
        ),
        title: const Text("Tebrikler!"),
        content: Text(
          "${game.difficulty.label} bulmacayı ${_formatTime(game.elapsed)} "
          "sürede çözdün.\n"
          "Hata: ${game.mistakes} · İpucu: ${game.hinted.length}",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _chooseNewGame();
            },
            child: const Text("Yeni oyun"),
          ),
        ],
      ),
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _game == null) return KeyEventResult.ignored;
    final digit = int.tryParse(event.character ?? '');
    if (digit != null && digit >= 1) {
      _enter(digit);
      return KeyEventResult.handled;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _erase();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyN) {
      setState(() => _notesMode = !_notesMode);
      return KeyEventResult.handled;
    }
    final (dRow, dCol) = switch (key) {
      LogicalKeyboardKey.arrowLeft => (0, -1),
      LogicalKeyboardKey.arrowRight => (0, 1),
      LogicalKeyboardKey.arrowUp => (-1, 0),
      LogicalKeyboardKey.arrowDown => (1, 0),
      _ => (0, 0),
    };
    if (dRow == 0 && dCol == 0) return KeyEventResult.ignored;
    final cell = _selected ?? 40;
    final row = (cell ~/ 9 + dRow).clamp(0, 8);
    final col = (cell % 9 + dCol).clamp(0, 8);
    setState(() => _selected = row * 9 + col);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sudoku"),
        actions: [
          if (game != null)
            IconButton(
              onPressed: _chooseNewGame,
              tooltip: "Yeni oyun",
              icon: const Icon(Icons.add_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const SizedBox()
            : game == null
            ? _DifficultyPicker(onPick: _newGame)
            : Focus(
                autofocus: true,
                onKeyEvent: _onKey,
                child: _buildGame(game),
              ),
      ),
    );
  }

  Widget _buildGame(SudokuGame game) {
    const infoStyle = TextStyle(
      color: AppColors.secondaryLabel,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Text(game.difficulty.label, style: infoStyle),
                    const Spacer(),
                    Text(
                      "Hata: ${game.mistakes}",
                      style: infoStyle.copyWith(
                        color: game.mistakes > 0 ? AppColors.red : null,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.timer_outlined,
                      size: 17,
                      color: AppColors.secondaryLabel,
                    ),
                    const SizedBox(width: 4),
                    Text(_formatTime(game.elapsed), style: infoStyle),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _Board(
                game: game,
                selected: _selected,
                onSelect: (cell) => setState(() => _selected = cell),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ToolButton(
                    icon: Icons.backspace_outlined,
                    label: "Sil",
                    onPressed: game.isSolved ? null : _erase,
                  ),
                  _ToolButton(
                    icon: Icons.edit_outlined,
                    label: "Not",
                    active: _notesMode,
                    badge: _notesMode ? "AÇIK" : "KAPALI",
                    onPressed: game.isSolved
                        ? null
                        : () => setState(() => _notesMode = !_notesMode),
                  ),
                  _ToolButton(
                    icon: Icons.lightbulb_outline_rounded,
                    label: "İpucu",
                    badge: "${game.hintsLeft}",
                    onPressed: game.isSolved || game.hintsLeft == 0
                        ? null
                        : _hint,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var digit = 1; digit <= 9; digit++)
                    Expanded(
                      child: _DigitButton(
                        key: ValueKey('sudoku-digit-$digit'),
                        digit: digit,
                        notesMode: _notesMode,
                        onPressed: game.isSolved || game.remaining(digit) == 0
                            ? null
                            : () => _enter(digit),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Takes its space all along so the board doesn't jump.
              Visibility.maintain(
                visible: game.isSolved,
                child: FilledButton.icon(
                  onPressed: _chooseNewGame,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text("Yeni oyun"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTime(Duration time) {
  String two(int n) => n.toString().padLeft(2, '0');
  final minutes = two(time.inMinutes.remainder(60));
  final seconds = two(time.inSeconds.remainder(60));
  return time.inHours > 0
      ? '${time.inHours}:$minutes:$seconds'
      : '$minutes:$seconds';
}

/// The first screen when there is no game to continue.
class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({required this.onPick});

  final ValueChanged<SudokuDifficulty> onPick;

  static const _blurbs = {
    SudokuDifficulty.easy: "Isınmak için",
    SudokuDifficulty.medium: "Biraz düşündürür",
    SudokuDifficulty.hard: "Sabır ister",
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            children: [
              const Icon(
                Icons.grid_3x3_rounded,
                size: 72,
                color: AppColors.blue,
              ),
              const SizedBox(height: 12),
              const Text(
                "Zorluk seç",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                "Her satır, sütun ve 3×3 kutuda 1'den 9'a her rakam bir kez "
                "bulunmalı.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: 24),
              for (final difficulty in SudokuDifficulty.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Text(
                        difficulty.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(_blurbs[difficulty]!),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => onPick(difficulty),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 9×9 grid. The selected cell, its row, column and box, and cells with
/// the same digit are highlighted.
class _Board extends StatelessWidget {
  const _Board({
    required this.game,
    required this.selected,
    required this.onSelect,
  });

  final SudokuGame game;
  final int? selected;
  final ValueChanged<int> onSelect;

  static const _peerColor = Color(0xFFE6EDF8);
  static const _sameDigitColor = Color(0xFFC7D9F5);
  static const _selectedColor = Color(0xFFA9C9F7);
  static const _wrongColor = Color(0xFFFFE3E1);

  @override
  Widget build(BuildContext context) {
    final selected = this.selected;
    final peers = selected == null
        ? const <int>{}
        : SudokuGame.peersOf(selected).toSet();
    final selectedDigit = selected == null ? 0 : game.values[selected];
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / 9;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomPaint(
              foregroundPainter: const _GridPainter(),
              child: Column(
                children: [
                  for (var row = 0; row < 9; row++)
                    Expanded(
                      child: Row(
                        children: [
                          for (var col = 0; col < 9; col++)
                            Expanded(
                              child: _buildCell(
                                row * 9 + col,
                                cellSize,
                                peers,
                                selectedDigit,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCell(int i, double size, Set<int> peers, int selectedDigit) {
    final digit = game.values[i];
    final wrong = game.isWrong(i);
    final Color background;
    if (i == selected) {
      background = _selectedColor;
    } else if (wrong) {
      background = _wrongColor;
    } else if (digit != 0 && digit == selectedDigit) {
      background = _sameDigitColor;
    } else if (peers.contains(i)) {
      background = _peerColor;
    } else {
      background = Colors.transparent;
    }
    final Widget content;
    if (digit != 0) {
      content = Text(
        '$digit',
        style: TextStyle(
          fontSize: size * 0.56,
          height: 1,
          fontWeight: game.puzzle.givens[i] != 0
              ? FontWeight.w600
              : FontWeight.w400,
          color: wrong
              ? AppColors.red
              : game.puzzle.givens[i] != 0
              ? AppColors.label
              : AppColors.blue,
        ),
      );
    } else if (game.notes[i] != 0) {
      content = _Notes(game: game, cell: i, size: size);
    } else {
      content = const SizedBox.expand();
    }
    return GestureDetector(
      key: ValueKey('sudoku-cell-$i'),
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelect(i),
      child: ColoredBox(
        color: background,
        child: Center(child: content),
      ),
    );
  }
}

/// Pencil notes, each digit in its own spot of a 3×3 grid.
class _Notes extends StatelessWidget {
  const _Notes({required this.game, required this.cell, required this.size});

  final SudokuGame game;
  final int cell;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size * 0.06),
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  for (var col = 0; col < 3; col++)
                    Expanded(
                      child: Center(
                        child: Text(
                          game.hasNote(cell, row * 3 + col + 1)
                              ? '${row * 3 + col + 1}'
                              : '',
                          style: TextStyle(
                            fontSize: size * 0.24,
                            height: 1,
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Thin lines between cells, thick ones around the boxes.
class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = AppColors.separator
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = AppColors.label
      ..strokeWidth = 2;
    final cell = size.width / 9;
    for (var i = 1; i < 9; i++) {
      final paint = i % 3 == 0 ? thick : thin;
      canvas
        ..drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), paint)
        ..drawLine(Offset(0, i * cell), Offset(size.width, i * cell), paint);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(6),
      ).deflate(1),
      thick..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

/// An icon with a label below, such as "Not".
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool active;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? AppColors.separator
        : active
        ? AppColors.blue
        : AppColors.label;
    return InkResponse(
      onTap: onPressed,
      radius: 36,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: badge != null,
              label: Text(badge ?? ''),
              backgroundColor: active ? AppColors.blue : AppColors.grey,
              offset: const Offset(14, -6),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// A digit on the number pad. In notes mode it writes pencil notes.
class _DigitButton extends StatelessWidget {
  const _DigitButton({
    super.key,
    required this.digit,
    required this.notesMode,
    required this.onPressed,
  });

  final int digit;
  final bool notesMode;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: onPressed == null ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 56,
            child: Center(
              child: Text(
                '$digit',
                style: TextStyle(
                  fontSize: notesMode ? 22 : 28,
                  fontWeight: FontWeight.w400,
                  color: onPressed == null
                      ? Colors.transparent
                      : notesMode
                      ? AppColors.secondaryLabel
                      : AppColors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

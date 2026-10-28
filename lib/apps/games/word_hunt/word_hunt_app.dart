import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/app_theme.dart';
import 'word_hunt_round.dart';

/// Kelime Avı from AppShop: make words from shuffled letters against the
/// clock.
class WordHuntApp extends StatefulWidget {
  const WordHuntApp({super.key, this.initialRound});

  /// Where the best score is saved.
  static const bestKey = 'wordHunt.best';

  /// Round to start right away instead of the start screen.
  final WordHuntRound? initialRound;

  @override
  State<WordHuntApp> createState() => _WordHuntAppState();
}

class _WordHuntAppState extends State<WordHuntApp> {
  static const _accent = Color(0xFFF77F00);

  WordHuntRound? _round;
  Duration _left = WordHuntRound.duration;
  bool _over = false;

  /// Indices into the round's letters, in the order they were tapped.
  final List<int> _picked = [];
  String? _feedback;
  bool _feedbackGood = false;
  int _best = 0;
  bool _newBest = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadBest();
    final initial = widget.initialRound;
    if (initial != null) _start(initial);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt(WordHuntApp.bestKey) ?? 0;
    if (mounted) setState(() => _best = best);
  }

  void _start([WordHuntRound? round]) {
    _timer?.cancel();
    setState(() {
      _round = round ?? WordHuntRound.random();
      _left = WordHuntRound.duration;
      _over = false;
      _picked.clear();
      _feedback = null;
      _newBest = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    setState(() => _left -= const Duration(seconds: 1));
    if (_left <= Duration.zero) _finish();
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final score = _round!.score;
    setState(() {
      _over = true;
      _newBest = score > _best;
      if (_newBest) _best = score;
    });
    if (_newBest) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(WordHuntApp.bestKey, score);
    }
  }

  String get _word => [for (final i in _picked) _round!.letters[i]].join();

  void _pick(int index) {
    if (_over || _picked.contains(index)) return;
    setState(() {
      _picked.add(index);
      _feedback = null;
    });
  }

  void _backspace() {
    if (_picked.isNotEmpty) setState(_picked.removeLast);
  }

  void _shuffle() {
    setState(() {
      _picked.clear();
      _round!.shuffle();
    });
  }

  void _submit() {
    final round = _round!;
    final word = _word;
    final result = round.submit(word);
    setState(() {
      _feedbackGood = result == WordCheck.accepted;
      _feedback = switch (result) {
        WordCheck.accepted =>
          "+${WordHuntRound.pointsFor(word)} · ${turkishUpper(word)}",
        WordCheck.tooShort => "En az ${WordHuntRound.minLength} harf olmalı",
        WordCheck.notAWord => "Böyle bir kelime bilmiyorum",
        WordCheck.alreadyFound => "Bunu zaten buldun",
      };
      _picked.clear();
    });
    if (round.found.length == round.answers.length) _finish();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final round = _round;
    if (round == null || _over || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter) {
      _submit();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }
    final typed = turkishLower(event.character ?? '');
    if (typed.length != 1) return KeyEventResult.ignored;
    for (var i = 0; i < round.letters.length; i++) {
      if (round.letters[i] == typed && !_picked.contains(i)) {
        _pick(i);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final round = _round;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E9),
      appBar: AppBar(
        title: const Text("Kelime Avı"),
        backgroundColor: const Color(0xFFFFF6E9),
      ),
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: round == null
              ? _StartView(best: _best, onStart: _start)
              : _over
              ? _ResultView(
                  round: round,
                  best: _best,
                  newBest: _newBest,
                  onAgain: _start,
                )
              : _buildRound(round),
        ),
      ),
    );
  }

  Widget _buildRound(WordHuntRound round) {
    final seconds = _left.inSeconds;
    final time =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: seconds <= 10 ? AppColors.red : AppColors.label,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: seconds <= 10 ? AppColors.red : AppColors.label,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              Text(
                "${round.score} puan",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _accent,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "${round.found.length} / ${round.answers.length} kelime",
              style: const TextStyle(color: AppColors.secondaryLabel),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final word in round.found)
                  Chip(
                    label: Text(turkishUpper(word)),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                  ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 24,
          child: Text(
            _feedback ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _feedbackGood ? AppColors.green : AppColors.red,
            ),
          ),
        ),
        Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            turkishUpper(_word),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < round.letters.length; i++)
                _LetterTile(
                  key: ValueKey('letter-$i'),
                  letter: turkishUpper(round.letters[i]),
                  used: _picked.contains(i),
                  onTap: () => _pick(i),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              IconButton.filledTonal(
                onPressed: _shuffle,
                tooltip: "Karıştır",
                icon: const Icon(Icons.shuffle_rounded),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _picked.isEmpty ? null : _backspace,
                tooltip: "Sil",
                icon: const Icon(Icons.backspace_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _picked.isEmpty ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    "Gönder",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    super.key,
    required this.letter,
    required this.used,
    required this.onTap,
  });

  final String letter;
  final bool used;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: used ? 0.3 : 1,
      child: Material(
        color: const Color(0xFFFFD166),
        borderRadius: BorderRadius.circular(14),
        elevation: used ? 0 : 2,
        child: InkWell(
          onTap: used ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 50,
            height: 56,
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5C3300),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartView extends StatelessWidget {
  const _StartView({required this.best, required this.onStart});

  final int best;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.abc_rounded, size: 96, color: Color(0xFFF77F00)),
            const Text(
              "Kelime Avı",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              "Karışık harflerden ${WordHuntRound.duration.inMinutes} dakikada "
              "bulabildiğin kadar kelime türet. Kelime uzadıkça puanı katlanır.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryLabel,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Rekor: $best puan",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF77F00),
                minimumSize: const Size(180, 48),
              ),
              child: const Text("Başla", style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.round,
    required this.best,
    required this.newBest,
    required this.onAgain,
  });

  final WordHuntRound round;
  final int best;
  final bool newBest;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final longest = round.longest;
    final missed = round.missed;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(
          Icons.emoji_events_rounded,
          size: 64,
          color: Color(0xFFF77F00),
        ),
        Text(
          round.found.length == round.answers.length
              ? "Hepsini buldun!"
              : "Süre doldu!",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        if (newBest)
          const Text(
            "Yeni rekor!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFF77F00),
              fontWeight: FontWeight.w700,
            ),
          ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text("Puan"),
                trailing: Text(
                  "${round.score}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                title: const Text("Bulunan kelime"),
                trailing: Text(
                  "${round.found.length} / ${round.answers.length}",
                ),
              ),
              ListTile(
                title: const Text("En uzun kelime"),
                trailing: Text(longest == null ? "—" : turkishUpper(longest)),
              ),
              ListTile(title: const Text("Rekor"), trailing: Text("$best")),
            ],
          ),
        ),
        if (missed.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            "Bulamadıkların",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final word in missed)
                Chip(
                  label: Text(turkishUpper(word)),
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onAgain,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF77F00),
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text("Tekrar oyna", style: TextStyle(fontSize: 17)),
        ),
      ],
    );
  }
}

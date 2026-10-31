import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/poltel/lab/differences_game.dart';
import 'package:ledective/apps/poltel/lab/enhance_game.dart';
import 'package:ledective/apps/poltel/lab/ink_game.dart';
import 'package:ledective/apps/poltel/lab/luminol_game.dart';
import 'package:ledective/apps/poltel/lab/pattern_game.dart';
import 'package:ledective/apps/poltel/lab/tread_game.dart';
import 'package:ledective/apps/poltel/lab/voice_game.dart';

const _image = 'assets/story/images/olay_yeri.jpg';

/// Shows [game] on a phone-sized screen.
Future<void> _show(WidgetTester tester, Widget game) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(16), children: [game]),
      ),
    ),
  );
}

void _slide(WidgetTester tester, String key, double value) => tester
    .widget<Slider>(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(Slider),
        matchRoot: true,
      ),
    )
    .onChanged!(value);

/// The point at fractions ([x], [y]) of the widget [finder] finds.
Offset _at(WidgetTester tester, Finder finder, double x, double y) {
  final rect = tester.getRect(finder);
  return Offset(rect.left + rect.width * x, rect.top + rect.height * y);
}

void main() {
  testWidgets('enhance: saving only works once both dials are right', (
    tester,
  ) async {
    var solved = false;
    await _show(
      tester,
      EnhanceGame(
        image: _image,
        focus: 0.7,
        light: 0.3,
        onSolved: () => solved = true,
      ),
    );
    _slide(tester, 'enhance-focus', 0.7);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('enhance-save')));
    await tester.pump();
    expect(solved, isFalse);
    expect(find.textContaining('Işığı ayarla'), findsOneWidget);
    _slide(tester, 'enhance-light', 0.32);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('enhance-save')));
    expect(solved, isTrue);
  });

  testWidgets('luminol: spraying every stain solves it', (tester) async {
    var solved = false;
    const spots = [(0.2, 0.5), (0.7, 0.4)];
    await _show(
      tester,
      LuminolGame(
        image: _image,
        spots: spots,
        sprays: 5,
        onSolved: () => solved = true,
      ),
    );
    final scene = find.byKey(const ValueKey('luminol-scene'));
    await tester.tapAt(_at(tester, scene, 0.9, 0.9));
    await tester.pump();
    expect(find.text('Bulunan iz: 0 / 2'), findsOneWidget);
    for (final (x, y) in spots) {
      await tester.tapAt(_at(tester, scene, x, y));
      await tester.pump();
    }
    expect(solved, isTrue);
  });

  testWidgets('pattern: only the smudged pattern unlocks', (tester) async {
    var solved = false;
    await _show(
      tester,
      PatternGame(pattern: const [0, 1, 2, 5], onSolved: () => solved = true),
    );
    final pad = find.byKey(const ValueKey('pattern-pad'));
    Offset dot(int i) =>
        _at(tester, pad, (i % 3 + 0.5) / 3, (i ~/ 3 + 0.5) / 3);
    Future<void> draw(List<int> dots) async {
      final finger = await tester.startGesture(dot(dots.first));
      for (final d in dots.skip(1)) {
        await finger.moveTo(dot(d));
        await tester.pump();
      }
      await finger.up();
      await tester.pump();
    }

    await draw([0, 3, 6, 7]);
    expect(solved, isFalse);
    expect(find.textContaining('Yanlış desen'), findsOneWidget);
    await draw([0, 1, 2, 5]);
    expect(solved, isTrue);
  });

  testWidgets('voice: the prints have to line up', (tester) async {
    var solved = false;
    await _show(
      tester,
      VoiceGame(offset: 0.4, suspect: 'H.Y.', onSolved: () => solved = true),
    );
    await tester.tap(find.byKey(const ValueKey('voice-compare')));
    await tester.pump();
    expect(solved, isFalse);
    _slide(tester, 'voice-slide', 0.41);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('voice-compare')));
    expect(solved, isTrue);
  });

  testWidgets('differences: every touch-up has to be found', (tester) async {
    var solved = false;
    const spots = [(0.2, 0.3), (0.6, 0.7)];
    await _show(
      tester,
      DifferencesGame(
        image: _image,
        spots: spots,
        onSolved: () => solved = true,
      ),
    );
    final photo = find.byKey(const ValueKey('differences-found'));
    await tester.tapAt(_at(tester, photo, 0.9, 0.1));
    await tester.pump();
    expect(find.textContaining('Boşa dokunuş: 1'), findsOneWidget);
    for (final (x, y) in spots) {
      await tester.tapAt(_at(tester, photo, x, y));
      await tester.pump();
    }
    expect(solved, isTrue);
  });

  testWidgets('ink: a wrong pick starts the order over', (tester) async {
    var solved = false;
    await _show(
      tester,
      InkGame(
        lines: const ['A', 'B', 'C'],
        order: const [2, 0, 1],
        onSolved: () => solved = true,
      ),
    );
    Future<void> pick(int i) async {
      await tester.tap(find.byKey(ValueKey('ink-$i')));
      await tester.pump();
    }

    await pick(2);
    await pick(1);
    expect(find.textContaining('Sıra tutmadı'), findsOneWidget);
    for (final i in [2, 0, 1]) {
      await pick(i);
    }
    expect(solved, isTrue);
  });

  testWidgets('tread: the grooves have to line up', (tester) async {
    var solved = false;
    await _show(tester, TreadGame(angle: 37, onSolved: () => solved = true));
    await tester.tap(find.byKey(const ValueKey('tread-compare')));
    await tester.pump();
    expect(solved, isFalse);
    _slide(tester, 'tread-turn', 39);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tread-compare')));
    expect(solved, isTrue);
  });
}

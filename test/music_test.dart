import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/music/music_app.dart';
import 'package:ledective/apps/music/music_player.dart';
import 'package:ledective/apps/music/tracks.dart';

/// Stands in for just_audio and records what the player asked of it.
class _FakeOutput implements MusicOutput {
  final List<String> calls = [];
  final positionController = StreamController<Duration>.broadcast();
  final completionController = StreamController<void>.broadcast();

  @override
  Stream<Duration> get positions => positionController.stream;

  @override
  Stream<void> get completions => completionController.stream;

  @override
  Future<void> load(String asset) async => calls.add('load $asset');

  @override
  Future<void> play() async => calls.add('play');

  @override
  Future<void> pause() async => calls.add('pause');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeOutput output;
  late MusicPlayer music;

  setUp(() {
    output = _FakeOutput();
    music = MusicPlayer(output: () => output);
  });

  test('every track is bundled and credited', () {
    expect(tracks, isNotEmpty);
    for (final track in tracks) {
      expect(track.asset, startsWith('assets/apps/music/'));
      expect(track.duration, greaterThan(Duration.zero));
      expect(track.credit, contains(track.title));
      expect(track.credit, contains('By Attribution 4.0'));
    }
  });

  test('plays, pauses and loads a track only once', () async {
    music.toggle();
    await pumpEventQueue();
    expect(music.playing, isTrue);
    music.toggle();
    music.toggle();
    await pumpEventQueue();
    expect(output.calls, ['load ${tracks[0].asset}', 'play', 'pause', 'play']);
  });

  test('wraps around the playlist and moves on when a track ends', () async {
    music.previous();
    expect(music.track, tracks.last);
    music.next();
    expect(music.index, 0);
    expect(output.calls, isEmpty, reason: 'nothing plays until asked');

    music.select(0, autoplay: true);
    await pumpEventQueue();
    output.positionController.add(const Duration(seconds: 42));
    await pumpEventQueue();
    expect(music.position, const Duration(seconds: 42));

    output.completionController.add(null);
    await pumpEventQueue();
    expect(music.index, 1);
    expect(music.position, Duration.zero);
    expect(output.calls.last, 'play');
    expect(output.calls, contains('load ${tracks[1].asset}'));
  });

  test('pauses in the background and resumes on return', () async {
    music.toggle();
    await pumpEventQueue();
    music.didChangeAppLifecycleState(AppLifecycleState.inactive);
    expect(music.playing, isTrue);
    music.didChangeAppLifecycleState(AppLifecycleState.hidden);
    music.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(music.playing, isFalse);
    music.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(music.playing, isTrue);
    expect(output.calls.skip(1), ['play', 'pause', 'play']);

    // Music the player paused stays paused.
    music.toggle();
    music.didChangeAppLifecycleState(AppLifecycleState.paused);
    music.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(music.playing, isFalse);
  });

  testWidgets('keeps playing after the Music app closes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => MusicApp(player: music)),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text(tracks[2].title), 200);
    await tester.tap(find.text(tracks[2].title));
    await tester.pump();
    expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byType(MusicApp), findsNothing);
    expect(music.playing, isTrue);
    expect(music.track, tracks[2]);
    expect(output.calls, ['load ${tracks[2].asset}', 'play']);

    // Opening it again shows what is playing.
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Pause'), findsOneWidget);
  });

  testWidgets('Hakkında lists every credit', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MusicApp(player: music)));
    await tester.tap(find.byTooltip('Hakkında'));
    await tester.pumpAndSettle();
    for (final track in tracks) {
      expect(find.text(track.credit), findsOneWidget);
    }
  });
}

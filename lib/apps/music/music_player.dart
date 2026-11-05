import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

import 'tracks.dart';

/// What [MusicPlayer] needs from an audio player, so tests can stand in for
/// just_audio, whose plugin doesn't run in widget tests.
abstract class MusicOutput {
  Stream<Duration> get positions;

  /// Fires when the loaded track plays to its end.
  Stream<void> get completions;

  Future<void> load(String asset);
  Future<void> play();
  Future<void> pause();
}

class JustAudioOutput implements MusicOutput {
  final AudioPlayer _player = AudioPlayer();

  @override
  Stream<Duration> get positions => _player.positionStream;

  @override
  Stream<void> get completions => _player.processingStateStream.where(
    (state) => state == ProcessingState.completed,
  );

  @override
  Future<void> load(String asset) => _player.setAsset(asset);

  @override
  Future<void> play() async {
    // play() only completes when playback stops, so don't wait on it.
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();
}

/// Plays [tracks] for the whole game, so the music goes on after the Music
/// app is closed and while other apps are open. It pauses while the game is
/// in the background and picks up again when the player comes back.
class MusicPlayer extends ChangeNotifier with WidgetsBindingObserver {
  MusicPlayer({MusicOutput Function()? output})
    : _createOutput = output ?? JustAudioOutput.new;

  static final MusicPlayer instance = MusicPlayer();

  final MusicOutput Function() _createOutput;
  MusicOutput? _output;
  String? _loaded;

  int _index = 0;
  bool _playing = false;
  bool _resumeOnReturn = false;
  Duration _position = Duration.zero;

  int get index => _index;
  Track get track => tracks[_index];
  bool get playing => _playing;
  Duration get position => _position;

  /// The output is made on the first play, so opening the Music app alone
  /// doesn't touch the audio plugin.
  MusicOutput get _out {
    final existing = _output;
    if (existing != null) return existing;
    WidgetsBinding.instance.addObserver(this);
    final output = _output = _createOutput();
    output.positions.listen((position) {
      _position = position;
      notifyListeners();
    });
    output.completions.listen((_) => select(_index + 1, autoplay: true));
    return output;
  }

  Future<void> _start() async {
    final output = _out;
    final asset = track.asset;
    try {
      if (_loaded != asset) {
        _loaded = asset;
        await output.load(asset);
      }
      // Another track may have been picked while this one loaded.
      if (_playing && track.asset == asset) await output.play();
    } on Exception catch (error) {
      debugPrint('Could not play $asset: $error');
    }
  }

  void toggle() {
    _playing = !_playing;
    notifyListeners();
    if (_playing) {
      unawaited(_start());
    } else {
      unawaited(_out.pause());
    }
  }

  /// Picks a track, wrapping around either end of the list.
  void select(int index, {bool autoplay = false}) {
    _index = index % tracks.length;
    _position = Duration.zero;
    _playing = autoplay || _playing;
    notifyListeners();
    if (_playing) unawaited(_start());
  }

  void next() => select(_index + 1);
  void previous() => select(_index - 1);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        if (_playing) {
          _resumeOnReturn = true;
          toggle();
        }
      case AppLifecycleState.resumed:
        if (_resumeOnReturn) {
          _resumeOnReturn = false;
          if (!_playing) toggle();
        }
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }
}

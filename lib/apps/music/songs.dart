import '../pian/note_player.dart';

/// One note of a melody: [note] for [beats] beats, or a rest when null.
typedef Step = ({Note? note, double beats});

class Song {
  const Song({
    required this.title,
    required this.artist,
    required this.bpm,
    required this.melody,
  });

  final String title;
  final String artist;
  final int bpm;

  /// Notes written as `"c d e- r"`: a letter per note, `-` makes it twice as
  /// long, `.` half as long and `r` is a rest.
  final String melody;

  List<Step> get steps => parseMelody(melody);

  Duration durationOf(Step step) =>
      Duration(milliseconds: (step.beats * 60000 / bpm).round());

  Duration get duration =>
      steps.map(durationOf).fold(Duration.zero, (a, b) => a + b);
}

List<Step> parseMelody(String melody) {
  return [
    for (final token in melody.split(RegExp(r'\s+')).where((t) => t.isNotEmpty))
      (
        note: token[0] == 'r'
            ? null
            : Note.values.firstWhere(
                (n) => n.name == token[0],
                orElse: () =>
                    throw FormatException('Unknown note in "$token"', melody),
              ),
        beats: token
            .substring(1)
            .split('')
            .fold<double>(
              1,
              (beats, mark) => mark == '-' ? beats * 2 : beats / 2,
            ),
      ),
  ];
}

const List<Song> songs = [
  Song(
    title: "Ledective Tema",
    artist: "Büro Orkestrası",
    bpm: 96,
    melody:
        "a- e a b- a g f e- r d e f e d c d e- r "
        "a- e a b- a g f e- f e d c b. a. a-",
  ),
  Song(
    title: "Küçük Yıldız",
    artist: "Geleneksel",
    bpm: 120,
    melody:
        "c c g g a a g- f f e e d d c- "
        "g g f f e e d- g g f f e e d- "
        "c c g g a a g- f f e e d d c-",
  ),
  Song(
    title: "Neşeye Övgü",
    artist: "L. van Beethoven",
    bpm: 132,
    melody:
        "e e f g g f e d c c d e e d. d- "
        "e e f g g f e d c c d e d c. c-",
  ),
  Song(
    title: "Tembel Çocuk",
    artist: "Geleneksel",
    bpm: 132,
    melody:
        "c d e c c d e c e f g- e f g- "
        "g. a. g. f. e c g. a. g. f. e c c d c- c d c-",
  ),
];

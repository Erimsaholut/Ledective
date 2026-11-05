/// A piece of music bundled with the game.
class Track {
  const Track({
    required this.title,
    required this.asset,
    required this.duration,
    required this.style,
  });

  final String title;
  final String asset;
  final Duration duration;

  /// A word or two on what it sounds like, shown under the artist.
  final String style;

  String get artist => 'Kevin MacLeod';

  /// The credit CC BY 4.0 asks for, worded as incompetech.com gives it.
  String get credit =>
      '"$title" Kevin MacLeod (incompetech.com)\n'
      'Licensed under Creative Commons: By Attribution 4.0\n'
      'https://creativecommons.org/licenses/by/4.0/';
}

/// Every track is by Kevin MacLeod under CC BY 4.0; see story/MUZIKLER.md.
const List<Track> tracks = [
  Track(
    title: "Hard Boiled",
    asset: 'assets/apps/music/hard_boiled.m4a',
    duration: Duration(minutes: 3, seconds: 1),
    style: "Noir caz",
  ),
  Track(
    title: "Dances and Dames",
    asset: 'assets/apps/music/dances_and_dames.m4a',
    duration: Duration(minutes: 2, seconds: 27),
    style: "Film noir",
  ),
  Track(
    title: "Spy Glass",
    asset: 'assets/apps/music/spy_glass.m4a',
    duration: Duration(minutes: 3, seconds: 47),
    style: "Cool caz",
  ),
  Track(
    title: "Bass Walker",
    asset: 'assets/apps/music/bass_walker.m4a',
    duration: Duration(minutes: 2, seconds: 41),
    style: "Kontrbas",
  ),
  Track(
    title: "Disquiet",
    asset: 'assets/apps/music/disquiet.m4a',
    duration: Duration(minutes: 3, seconds: 5),
    style: "Solo piyano",
  ),
];

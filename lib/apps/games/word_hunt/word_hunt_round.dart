import 'dart:math';

import 'turkish_words.dart';

/// Every word the game accepts.
final Set<String> turkishWords = turkishWordList.split(' ').toSet();

/// [word] in capitals, with the Turkish dotted and dotless i.
String turkishUpper(String word) =>
    word.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// [word] in small letters, with the Turkish dotted and dotless i.
String turkishLower(String word) =>
    word.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

enum WordCheck { accepted, tooShort, notAWord, alreadyFound }

/// One round of Kelime Avı: the shuffled letters of a [root] word, from
/// which the player makes as many words as they can before time runs out.
class WordHuntRound {
  WordHuntRound(this.root, {Random? random})
    : letters = root.split('')..shuffle(random),
      answers = answersFor(root);

  /// A round on a random root that hides at least [minAnswers] words.
  factory WordHuntRound.random({Random? random}) {
    final options = roots;
    return WordHuntRound(
      options[(random ?? Random()).nextInt(options.length)],
      random: random,
    );
  }

  static const minLength = 3;
  static const minAnswers = 10;
  static const duration = Duration(minutes: 2);

  /// Long words with enough words in their letters to make a round.
  static final List<String> roots = [
    for (final word in turkishWords)
      if (word.length >= 6 &&
          word.length <= 7 &&
          answersFor(word).length >= minAnswers)
        word,
  ]..sort();

  /// The words that can be spelled from the letters of [root].
  static Set<String> answersFor(String root) {
    final available = _letterCounts(root);
    return {
      for (final word in turkishWords)
        if (word.length <= root.length && _fits(word, available)) word,
    };
  }

  static Map<String, int> _letterCounts(String word) {
    final counts = <String, int>{};
    for (final letter in word.split('')) {
      counts[letter] = (counts[letter] ?? 0) + 1;
    }
    return counts;
  }

  static bool _fits(String word, Map<String, int> available) {
    final needed = _letterCounts(word);
    return needed.entries.every((e) => (available[e.key] ?? 0) >= e.value);
  }

  /// Points for a word: longer words are worth much more.
  static int pointsFor(String word) =>
      10 * word.length * (word.length - 1) ~/ 2;

  final String root;
  final List<String> letters;
  final Set<String> answers;

  /// Words found so far, newest first.
  final List<String> found = [];
  int score = 0;

  String? get longest => found.isEmpty
      ? null
      : found.reduce((a, b) => b.length > a.length ? b : a);

  /// Answers the player didn't find, longest first.
  List<String> get missed =>
      answers.where((w) => !found.contains(w)).toList()
        ..sort((a, b) => b.length.compareTo(a.length));

  WordCheck submit(String word) {
    if (word.length < minLength) return WordCheck.tooShort;
    if (found.contains(word)) return WordCheck.alreadyFound;
    if (!answers.contains(word)) return WordCheck.notAWord;
    found.insert(0, word);
    score += pointsFor(word);
    return WordCheck.accepted;
  }

  void shuffle([Random? random]) => letters.shuffle(random);
}

import 'dart:math';

/// State of a memory (pairs) game. Every value appears on exactly two cards.
class MemoryBoard {
  MemoryBoard(List<int> cards) : cards = List.unmodifiable(cards) {
    final counts = <int, int>{};
    for (final card in cards) {
      counts[card] = (counts[card] ?? 0) + 1;
    }
    if (counts.values.any((n) => n != 2)) {
      throw ArgumentError.value(cards, 'cards', 'every value needs a pair');
    }
  }

  /// [pairs] pairs in random order.
  factory MemoryBoard.shuffled(int pairs, {Random? random}) => MemoryBoard(
    [
      for (var i = 0; i < pairs; i++) ...[i, i],
    ]..shuffle(random),
  );

  final List<int> cards;
  final Set<int> _matched = {};
  final List<int> _open = [];
  int _moves = 0;

  /// Turns taken: one per pair of cards turned over.
  int get moves => _moves;

  bool isMatched(int index) => _matched.contains(index);

  bool isFaceUp(int index) => isMatched(index) || _open.contains(index);

  bool get isComplete => _matched.length == cards.length;

  /// True while two unmatched cards are face up and wait for [hideOpen].
  bool get isShowingMismatch => _open.length == 2;

  /// Turns card [index] face up. Returns false if that isn't allowed.
  bool flip(int index) {
    if (isShowingMismatch || isFaceUp(index)) return false;
    _open.add(index);
    if (_open.length == 2) {
      _moves++;
      if (cards[_open[0]] == cards[_open[1]]) {
        _matched.addAll(_open);
        _open.clear();
      }
    }
    return true;
  }

  /// Turns a mismatched pair face down again.
  void hideOpen() => _open.clear();
}

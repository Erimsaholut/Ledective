/// The small language story files use in `requires` and `unlocks`.
///
/// A requirement is one of:
///
///  * `flag`: the flag is set
///  * `!flag`: the flag is not set
///  * `stat >= 60`: compares a number with `>=`, `<=`, `>`, `<`, `==`, `!=`
///
/// An effect (an item of `unlocks`) is one of:
///
///  * `flag`: sets the flag
///  * `!flag`: clears the flag
///  * `stat += 10`, `stat -= 10`, `stat = 50`: changes a number
///
/// Numbers are declared in `state.json`. Personality traits can be read as
/// `trait:merhamet`, money sent to a payee as `paid:<payee id>` (in lira).
///
/// This file only uses `dart:` libraries so the story validator can use it.
library;

/// One term of a condition.
sealed class Requirement {
  const Requirement();

  static final _comparison = RegExp(r'^(.+?)\s*(>=|<=|==|!=|>|<)\s*(-?\d+)$');

  static final _parsed = <String, Requirement>{};

  static Requirement parse(String term) =>
      _parsed[term] ??= _parse(term.trim());

  static Requirement _parse(String text) {
    final match = _comparison.firstMatch(text);
    if (match != null) {
      return StatRequirement(
        match.group(1)!.trim(),
        Comparison.of(match.group(2)!),
        int.parse(match.group(3)!),
      );
    }
    if (text.startsWith('!')) {
      return FlagRequirement(text.substring(1).trim(), negated: true);
    }
    return FlagRequirement(text);
  }

  bool isMetBy(StoryState state);
}

class FlagRequirement extends Requirement {
  const FlagRequirement(this.flag, {this.negated = false});

  final String flag;
  final bool negated;

  @override
  bool isMetBy(StoryState state) => state.has(flag) != negated;
}

enum Comparison {
  atLeast('>='),
  atMost('<='),
  equal('=='),
  notEqual('!='),
  above('>'),
  below('<');

  const Comparison(this.symbol);
  final String symbol;

  static Comparison of(String symbol) =>
      values.firstWhere((c) => c.symbol == symbol);

  bool test(int a, int b) => switch (this) {
    atLeast => a >= b,
    atMost => a <= b,
    equal => a == b,
    notEqual => a != b,
    above => a > b,
    below => a < b,
  };
}

class StatRequirement extends Requirement {
  const StatRequirement(this.stat, this.comparison, this.value);

  final String stat;
  final Comparison comparison;
  final int value;

  @override
  bool isMetBy(StoryState state) => comparison.test(state.value(stat), value);
}

/// One item of an `unlocks` list.
sealed class Effect {
  const Effect();

  static final _change = RegExp(r'^(.+?)\s*(\+=|-=|=)\s*(-?\d+)$');

  static Effect parse(String term) {
    final text = term.trim();
    final match = _change.firstMatch(text);
    if (match != null) {
      final stat = match.group(1)!.trim();
      final amount = int.parse(match.group(3)!);
      return switch (match.group(2)) {
        '+=' => ChangeStat(stat, amount),
        '-=' => ChangeStat(stat, -amount),
        _ => SetStat(stat, amount),
      };
    }
    if (text.startsWith('!')) return ClearFlag(text.substring(1).trim());
    return SetFlag(text);
  }
}

class SetFlag extends Effect {
  const SetFlag(this.flag);
  final String flag;
}

class ClearFlag extends Effect {
  const ClearFlag(this.flag);
  final String flag;
}

class ChangeStat extends Effect {
  const ChangeStat(this.stat, this.delta);
  final String stat;
  final int delta;
}

class SetStat extends Effect {
  const SetStat(this.stat, this.value);
  final String stat;
  final int value;
}

/// What requirements are checked against.
abstract interface class StoryState {
  /// A fixed state, mostly for tests.
  factory StoryState.of(Set<String> flags, [Map<String, int> values]) =
      _FixedState;

  bool has(String flag);
  int value(String stat);
}

class _FixedState implements StoryState {
  _FixedState(this._flags, [this._values = const {}]);

  final Set<String> _flags;
  final Map<String, int> _values;

  @override
  bool has(String flag) => _flags.contains(flag);

  @override
  int value(String stat) => _values[stat] ?? 0;
}

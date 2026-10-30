import 'dart:math' as math;

/// Works out a calculator expression as typed on the keys: digits with a
/// comma or dot, + − × ÷, ^ for powers, √, %, !, π, e, brackets and the
/// functions sin, cos, tan, ln and log. A number before a bracket, π or a
/// function multiplies it, so "2π" is two π. Angles are in degrees unless
/// [radians].
///
/// Throws a [FormatException] for an expression that can't be worked out.
double evaluate(String expression, {bool radians = false}) {
  final parser = _Parser(_tokens(expression), radians: radians);
  final value = parser.expression();
  if (!parser.atEnd) throw const FormatException("Beklenmeyen simge");
  return value;
}

const _functions = ['sin', 'cos', 'tan', 'ln', 'log'];

List<String> _tokens(String text) {
  final tokens = <String>[];
  var i = 0;
  while (i < text.length) {
    final c = text[i];
    if (c == ' ') {
      i++;
    } else if (_isDigit(c) || c == ',' || c == '.') {
      final start = i;
      while (i < text.length &&
          (_isDigit(text[i]) || text[i] == ',' || text[i] == '.')) {
        i++;
      }
      tokens.add(text.substring(start, i).replaceAll(',', '.'));
    } else if (_functions.any((f) => text.startsWith(f, i))) {
      final name = _functions.firstWhere((f) => text.startsWith(f, i));
      tokens.add(name);
      i += name.length;
    } else {
      tokens.add(switch (c) {
        '-' => '−',
        '*' => '×',
        '/' => '÷',
        _ => c,
      });
      i++;
    }
  }
  return tokens;
}

bool _isDigit(String c) => c.codeUnitAt(0) ^ 0x30 <= 9;

class _Parser {
  _Parser(this._tokens, {required this.radians});

  final List<String> _tokens;
  final bool radians;
  var _at = 0;

  bool get atEnd => _at >= _tokens.length;
  String? get _next => atEnd ? null : _tokens[_at];

  bool _take(String token) {
    if (_next != token) return false;
    _at++;
    return true;
  }

  /// Sums: terms joined by + and −.
  double expression() {
    var value = _term();
    while (true) {
      if (_take('+')) {
        value += _term();
      } else if (_take('−')) {
        value -= _term();
      } else {
        return value;
      }
    }
  }

  /// Products: factors joined by × and ÷, or simply written side by side.
  double _term() {
    var value = _unary();
    while (true) {
      if (_take('×')) {
        value *= _unary();
      } else if (_take('÷')) {
        value /= _unary();
      } else if (_startsValue(_next)) {
        value *= _unary();
      } else {
        return value;
      }
    }
  }

  bool _startsValue(String? token) =>
      token != null &&
      (_isDigit(token[0]) ||
          token == '.' ||
          token == '(' ||
          token == 'π' ||
          token == 'e' ||
          token == '√' ||
          _functions.contains(token));

  /// A sign or root in front goes after any power, so −3^2 is −9.
  double _unary() {
    if (_take('−')) return -_unary();
    if (_take('+')) return _unary();
    if (_take('√')) return math.sqrt(_unary());
    return _power();
  }

  /// Powers group from the right: 2^3^2 is 2^9.
  double _power() {
    final base = _postfix();
    if (_take('^')) return math.pow(base, _unary()).toDouble();
    return base;
  }

  /// A value with any % (a hundredth) or ! (factorial) after it.
  double _postfix() {
    var value = _primary();
    while (true) {
      if (_take('%')) {
        value /= 100;
      } else if (_take('!')) {
        value = _factorial(value);
      } else {
        return value;
      }
    }
  }

  double _primary() {
    final token = _next;
    if (token == null) throw const FormatException("Eksik işlem");
    if (_take('(')) {
      final value = expression();
      // A bracket left open is closed at the end, as on a phone.
      _take(')');
      return value;
    }
    if (_take('π')) return math.pi;
    if (_take('e')) return math.e;
    if (_functions.contains(token)) {
      _at++;
      final x = _postfix();
      final angle = radians ? x : x * math.pi / 180;
      return switch (token) {
        'sin' => _clean(math.sin(angle)),
        'cos' => _clean(math.cos(angle)),
        'tan' => _clean(math.tan(angle)),
        'ln' => math.log(x),
        _ => math.log(x) / math.ln10,
      };
    }
    final number = double.tryParse(token);
    if (number == null) throw FormatException("Anlaşılmayan simge: $token");
    _at++;
    return number;
  }

  /// sin 180° comes out as 1e-16; call that the zero it is.
  static double _clean(double x) => x.abs() < 1e-12 ? 0 : x;

  static double _factorial(double n) {
    if (n < 0 || n != n.roundToDouble() || n > 170) {
      throw const FormatException("Faktöriyel yalnızca doğal sayılar için");
    }
    var result = 1.0;
    for (var i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}

/// [value] as the display shows it: up to ten significant digits, a comma
/// for the decimal point, and no trailing zeros.
String formatResult(double value) {
  if (value.isNaN || value.isInfinite) return "Hata";
  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.toInt().toString();
  }
  final magnitude = value.abs();
  final text = magnitude >= 1e15 || magnitude < 1e-6
      ? value.toStringAsExponential(6)
      : value.toStringAsPrecision(10);
  final trimmed = text.contains('e')
      ? text.replaceFirst(RegExp(r'\.?0+e'), 'e')
      : text.replaceFirst(RegExp(r'\.?0+$'), '');
  return trimmed.replaceAll('.', ',');
}

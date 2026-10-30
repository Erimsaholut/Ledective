/// The four operations on the calculator's right-hand column.
enum Operation {
  add('+'),
  subtract('−'),
  multiply('×'),
  divide('÷');

  const Operation(this.symbol);

  final String symbol;

  /// × and ÷ go before + and −.
  bool get first => this == multiply || this == divide;

  double apply(double a, double b) => switch (this) {
    add => a + b,
    subtract => a - b,
    multiply => a * b,
    divide => a / b,
  };
}

/// A pocket calculator that works like the one on a phone: numbers are
/// typed digit by digit, × and ÷ go before + and −, `=` again repeats the
/// last step, and `%` in a sum takes the percentage of what came before
/// (50 + 10% = 55).
class Calculator {
  static const maxDigits = 9;

  /// The number on the display, with a dot for the decimal point;
  /// [display] formats it.
  String _entry = '0';

  /// What has been worked out so far, and the operation waiting for the
  /// next number.
  double? _total;
  Operation? _pending;

  /// A + or − put aside while a × or ÷ after it goes first.
  (double, Operation)? _low;

  /// The step `=` repeats.
  (Operation, double)? _last;

  /// Whether the next digit starts a new number.
  bool _fresh = true;
  bool _error = false;

  /// The operation waiting for its second number, to highlight its key.
  Operation? get pending => _fresh ? _pending : null;

  /// Whether the clear key clears just the number being typed ("C")
  /// rather than everything ("AC").
  bool get clearsEntry => !_fresh;

  /// The display, Turkish style: `1.234,5`.
  String get display => _error ? 'Hata' : format(_entry);

  double get _value => double.parse(_entry);

  void digit(int d) {
    if (_error) clearAll();
    if (_fresh) {
      _entry = '$d';
      _fresh = false;
      return;
    }
    if (_entry.replaceAll(RegExp(r'[-.]'), '').length >= maxDigits) return;
    _entry = switch (_entry) {
      '0' => '$d',
      '-0' => '-$d',
      _ => '$_entry$d',
    };
  }

  void decimalPoint() {
    if (_error) clearAll();
    if (_fresh) {
      _entry = '0.';
      _fresh = false;
      return;
    }
    if (!_entry.contains('.')) _entry = '$_entry.';
  }

  void toggleSign() {
    if (_error) return;
    if (_fresh && _pending != null) {
      // Right after an operation: the next number starts negative.
      _entry = '-0';
      _fresh = false;
      return;
    }
    _entry = _entry.startsWith('-') ? _entry.substring(1) : '-$_entry';
  }

  void percent() {
    if (_error) return;
    final total = _total;
    final op = _pending;
    final ofSum =
        (op == Operation.add || op == Operation.subtract) && total != null;
    _show(ofSum ? total * _value / 100 : _value / 100);
    _fresh = false;
  }

  void operation(Operation op) {
    if (_error) return;
    final pending = _pending;
    if (_fresh && pending != null) {
      // Pressed one operation after another: the last one counts.
      _pending = op;
      if (!op.first) _addLow();
      return;
    }
    final value = _value;
    if (pending == null) {
      _total = value;
    } else if (!pending.first && op.first) {
      _low = (_total!, pending);
      _total = value;
    } else {
      _compute(pending, value);
    }
    if (!op.first) _addLow();
    if (_error) return;
    _pending = op;
    _fresh = true;
  }

  void equals() {
    if (_error) return;
    final op = _pending;
    if (op != null && _total != null) {
      // "5 + =" adds the number on the display to itself, as phones do.
      final operand = _value;
      _compute(op, operand);
      _addLow();
      _last = (op, operand);
      _pending = null;
    } else if (_last case (final op, final operand)) {
      _total = _value;
      _compute(op, operand);
    }
    _fresh = true;
  }

  /// "C": forgets the number being typed but keeps the sum going.
  void clearEntry() {
    _entry = '0';
    _fresh = true;
  }

  /// "AC": starts over.
  void clearAll() {
    _entry = '0';
    _total = null;
    _pending = null;
    _low = null;
    _last = null;
    _fresh = true;
    _error = false;
  }

  /// Removes the last digit typed, like swiping the display.
  void backspace() {
    if (_fresh || _error) return;
    _entry = _entry.substring(0, _entry.length - 1);
    if (_entry.isEmpty || _entry == '-') _entry = '0';
  }

  /// Brings back the + or − put aside for a × or ÷.
  void _addLow() {
    final low = _low;
    if (low == null || _error) return;
    _low = null;
    final (value, op) = low;
    final total = _total;
    _total = value;
    if (total != null) _compute(op, total);
  }

  void _compute(Operation op, double operand) {
    final result = op.apply(_total!, operand);
    if (result.isNaN || result.isInfinite) {
      clearAll();
      _error = true;
      return;
    }
    _total = result;
    _show(result);
  }

  void _show(double value) => _entry = _plain(value);

  /// [value] as a plain number with no more than [maxDigits] significant
  /// digits, so 0.1 + 0.2 shows 0,3.
  static String _plain(double value) {
    if (value == 0) return '0';
    final magnitude = value.abs();
    if (magnitude >= 1e9 || magnitude < 1e-8) {
      return value.toStringAsExponential(5);
    }
    final decimals = maxDigits - magnitude.floor().toString().length;
    var text = value.toStringAsFixed(decimals.clamp(0, maxDigits));
    if (text.contains('.')) text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    return text == '-0' ? '0' : text;
  }

  /// [entry] with Turkish separators: a dot between thousands and a comma
  /// before the decimals.
  static String format(String entry) {
    if (entry.contains('e')) {
      final [mantissa, exponent] = entry.split('e');
      return '${mantissa.replaceAll('.', ',')}e${exponent.replaceAll('+', '')}';
    }
    final negative = entry.startsWith('-');
    final unsigned = negative ? entry.substring(1) : entry;
    final [whole, ...decimals] = unsigned.split('.');
    final grouped = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) grouped.write('.');
      grouped.write(whole[i]);
    }
    final fraction = decimals.isEmpty ? '' : ',${decimals.first}';
    return '${negative ? '-' : ''}$grouped$fraction';
  }
}

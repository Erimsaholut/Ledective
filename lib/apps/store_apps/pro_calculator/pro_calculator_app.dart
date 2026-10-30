import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expression.dart';

const _background = Color(0xFF000000);
const _digit = Color(0xFF333333);
const _function = Color(0xFF1F1F1F);
const _operator = Color(0xFFFF9F0A);
const _clear = Color(0xFFA5A5A5);

/// Hesap Makinesi Pro from AppShop: a scientific calculator. The whole
/// expression is typed out and its result shows as it is typed; the last
/// calculations are kept.
class ProCalculatorApp extends StatefulWidget {
  const ProCalculatorApp({super.key});

  /// Where past calculations are saved.
  static const historyKey = 'proCalculator.history';

  @override
  State<ProCalculatorApp> createState() => _ProCalculatorAppState();
}

class _ProCalculatorAppState extends State<ProCalculatorApp> {
  static const _historyLength = 30;

  String _expression = '';

  /// The last answer, for Ans; shown big after =.
  String? _answer;
  bool _radians = false;

  /// Whether the last = failed, shown until the next key.
  bool _error = false;

  /// Past calculations, newest first, as "expression = result".
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(ProCalculatorApp.historyKey);
    if (stored == null || !mounted) return;
    try {
      setState(() => _history = (json.decode(stored) as List).cast<String>());
    } on Object {
      // History from an older version; start a new one.
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ProCalculatorApp.historyKey, json.encode(_history));
  }

  /// The result of what has been typed so far, or null while it can't be
  /// worked out yet.
  String? get _preview {
    if (_expression.isEmpty) return null;
    try {
      return formatResult(evaluate(_expression, radians: _radians));
    } on Object {
      return null;
    }
  }

  void _press(String key) {
    setState(() {
      switch (key) {
        case 'C':
          _expression = '';
          _answer = null;
        case '⌫':
          if (_expression.isEmpty) break;
          final function = RegExp(r'(sin|cos|tan|ln|log)\($');
          _expression = function.hasMatch(_expression)
              ? _expression.replaceFirst(function, '')
              : _expression.substring(0, _expression.length - 1);
        case '=':
          _equals();
        case 'Rad' || 'Deg':
          _radians = !_radians;
        case 'sin' || 'cos' || 'tan' || 'ln' || 'log':
          _type('$key(');
        case 'x²':
          _type('^2');
        case 'Ans':
          if (_answer case final answer?) _type(answer);
        default:
          _type(key);
      }
    });
  }

  /// Adds [text] to the expression; after an answer, a number starts a new
  /// one and an operator carries on from it.
  void _type(String text) {
    if (_answer != null && _expression == _answer) {
      final carriesOn = RegExp(r'^[+−×÷^%!]').hasMatch(text);
      if (!carriesOn) _expression = '';
    }
    _expression += text;
  }

  void _equals() {
    if (_expression.isEmpty) return;
    String result;
    try {
      result = formatResult(evaluate(_expression, radians: _radians));
    } on Object {
      result = "Hata";
    }
    if (result == "Hata") {
      _answer = null;
      _expression = '';
      _error = true;
      return;
    }
    _history = [
      "$_expression = $result",
      ..._history,
    ].take(_historyLength).toList();
    _saveHistory();
    _expression = result;
    _answer = result;
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: _history.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "Henüz hesap yok",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final line in _history)
                    ListTile(
                      title: Text(
                        line,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _expression = line.split(' = ').last;
                          _answer = _expression;
                        });
                      },
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _history = []);
                      _saveHistory();
                    },
                    child: const Text("Geçmişi temizle"),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
      ),
    );
  }

  static const _rows = [
    ['Deg', 'sin', 'cos', 'tan', 'π'],
    ['ln', 'log', '√', 'x²', '^'],
    ['(', ')', '!', '%', 'e'],
    ['C', '7', '8', '9', '÷'],
    ['⌫', '4', '5', '6', '×'],
    ['Ans', '1', '2', '3', '−'],
    ['0', ',', '=', '+'],
  ];

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final showPreview = preview != null && preview != _expression;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: Text(
          _radians ? "Radyan" : "Derece",
          style: const TextStyle(fontSize: 15, color: Colors.white54),
        ),
        actions: [
          IconButton(
            key: const ValueKey('history'),
            tooltip: "Geçmiş",
            onPressed: _showHistory,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _error && _expression.isEmpty
                            ? "Hata"
                            : _expression.isEmpty
                            ? '0'
                            : _expression,
                        key: const ValueKey('expression'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _expression.length > 12 ? 40 : 56,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: showPreview
                          ? Text(
                              "= $preview",
                              key: const ValueKey('preview'),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 22,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Column(
                children: [
                  for (final row in _rows)
                    Row(
                      children: [
                        for (final key in row)
                          Expanded(
                            flex: key == '0' ? 2 : 1,
                            child: _Key(
                              label: key == 'Deg' && _radians ? 'Rad' : key,
                              color: _colorOf(key),
                              onTap: () {
                                _error = false;
                                _press(key == 'Deg' && _radians ? 'Rad' : key);
                              },
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorOf(String key) {
    if (const ['÷', '×', '−', '+', '='].contains(key)) return _operator;
    if (key == 'C' || key == '⌫') return _clear;
    if (RegExp(r'^[0-9,]$').hasMatch(key)) return _digit;
    return _function;
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = color == _clear;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          key: ValueKey('key-$label'),
          borderRadius: BorderRadius.circular(40),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: dark ? Colors.black : Colors.white,
                  fontSize: label.length > 2 ? 17 : 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
